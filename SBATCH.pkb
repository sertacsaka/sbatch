CREATE OR REPLACE PACKAGE BODY sbatch
is
    procedure execute_batch
    (
        i_batch_id in number default null,
        i_drop in char default '1',
        i_from_sequence_id number default null,
        i_created_by number,
        io_execution_id in out number
    )
    is
        v_start_date date;
        v_sqlerrm varchar2(4000 char);
        v_backtrace varchar2(4000 char);
        v_conditions clob;
        v_bak_id number;
        v_differents varchar2(4000 char);
        v_params execute_query_param;
        v_message varchar2(500 char);
    begin
        v_start_date := sysdate;
        
        sbatch.v_q_grp_db_cleaning := sbatch.query_group_id(1);
        sbatch.v_q_grp_execution := sbatch.query_group_id(2);
        
        if i_from_sequence_id is null then
        
            sbatch.save_execution_info
            (
                io_execution_id => io_execution_id,
                i_batch_id => i_batch_id,
                i_tmp_table_drop => i_drop,
                i_created_by => i_created_by
            );
        
            v_params.p_batch_id := i_batch_id;
            v_params.p_group_id := null;
            v_params.p_sequence_id := null;
            v_params.p_tmp_table_ts := to_char(v_start_date, 'DDHH24MISS');
            v_params.p_execution_id := io_execution_id;
            v_params.p_drop := i_drop;
            v_params.p_replace := null;
            v_params.p_from_sequence_id := null;
            v_params.p_just_query := '0';
            v_params.p_query := null;
        
            sbatch.process_log('Batch kitlesi hazirlama islemi basladi. created_by: ' || i_created_by || ', USER: ' || USER || ', tmp_table_ts: ' || v_params.p_tmp_table_ts, io_execution_id, $$plsql_line, sql%rowcount);
            
            sbatch.backup_batch_definitions(i_just_check => '1', o_bak_id => v_bak_id, o_differents => v_differents);
            
            if v_differents is not null then
            
                sbatch.process_log('Tanim tablolarinda yedeklenmeyen degisiklik mevcut: ' || v_differents, io_execution_id, $$plsql_line, sql%rowcount);
                
            end if;
            
            sbatch.save_execution_info
            (
                io_execution_id => io_execution_id,
                i_exec_start_date => v_start_date
            );

            --Temizlik sorgulari
            v_params.p_group_id := sbatch.v_q_grp_db_cleaning;
            v_params.p_drop := '1'; /* ilk temizlikte dropu istege bagli birakmiyoruz */
            
            sbatch.execute_queries(v_params);
            
            v_params.p_drop := i_drop; /* temizlik istege bagli devam */
            
        else
        
            if io_execution_id is null then
        
                v_message := 'i_from_sequence_id parametresi verildiginde io_execution_id parametresi de verilmelidir.';
                
                raise_application_error (-20010, v_message); 
            
            end if;
        
            select
                batch_id,
                null p_group_id,
                null p_sequence_id,
                to_char(created_date, 'DDHH24MISS') p_tmp_table_ts,
                execution_id,
                tmp_table_drop,
                null p_replace,
                i_from_sequence_id,
                0 p_just_query,
                null p_query
            into
                v_params.p_batch_id,
                v_params.p_group_id,
                v_params.p_sequence_id,
                v_params.p_tmp_table_ts,
                v_params.p_execution_id,
                v_params.p_drop,
                v_params.p_replace,
                v_params.p_from_sequence_id,
                v_params.p_just_query,
                v_params.p_query
            from sb_execution_info
            where execution_id = io_execution_id;
            
            --isteniyorsa logdan bularak kaldigin yerden devam et 
            if i_from_sequence_id = -1 then
            
                select to_number(substr(qt, length('i_sequence_id: ') + 1, instr(qt, sbatch.v_nl, 1, 1) - length('i_sequence_id: ') - length(sbatch.v_nl)))
                into v_params.p_from_sequence_id
                from
                (
                    select substr(q_text, instr(q_text, 'i_sequence_id: ', 1, 1)) qt
                    from sb_log
                    where log_id =
                    (
                        select max(log_id)
                        from sb_log
                        where q_text is not null
                        and execution_id = io_execution_id
                    )
                );
            
            end if;
        
            sbatch.process_log('Batch kitlesi hazirlama islemi devam ediyor.', io_execution_id, $$plsql_line, sql%rowcount);
            
        end if;
        
        --Kitle sekillendirme sorgulari
        v_params.p_group_id := sbatch.v_q_grp_execution;
        
        sbatch.execute_queries(v_params);
        
        --Son gecici tablonun dusurulmesi
        v_params.p_group_id := sbatch.v_q_grp_db_cleaning;
        
        sbatch.execute_queries(v_params);
        
        sbatch.save_execution_info
        (
            io_execution_id => io_execution_id,
            i_exec_end_date => sysdate
        );
        
    exception 
        when others then
            v_sqlerrm := sqlerrm;
            v_backtrace := dbms_utility.format_error_backtrace;
            
            sbatch.process_log('EXCEPTION' || v_eol2 || 'sqlerrm:' || v_eol || v_sqlerrm || v_eol2 || 'backtrace:' || v_eol || v_backtrace, io_execution_id, $$plsql_line, sql%rowcount);
    end;
    
    procedure backup_batch_definitions
    (
        i_just_check in char default '0',
        i_description in varchar2 default null,
        i_created_by in number default null,
        o_bak_id out number,
        o_differents out varchar2
    )
    as
        v_table_owner varchar2(50);
        v_backup_date date;
        v_compare_columns varchar2(4000);
        v_is_different char(1 char);
        v_last_bak_id number;
        v_owner_name varchar2(100);
        v_caller_name varchar2(100);
        v_line_number number;
        v_caller_type varchar2(100);
    begin
        v_backup_date := sysdate;
        
        owa_util.who_called_me(v_owner_name, v_caller_name, v_line_number, v_caller_type);
        
        v_table_owner := v_owner_name;
        
        for i in
        (
            select owner, substr(table_name, 1, length(table_name)-4) table_name
            from all_tables
            where owner = v_table_owner
            and table_name like 'BAT_%_BAK'
        )
        loop
            v_compare_columns := null;
            
            select 
                listagg
                (
                    case when data_type = 'CLOB' then 'to_char(' || column_name || ')'
                    else column_name end, ', '
                ) within group (order by column_id)
            into v_compare_columns
            from all_tab_columns
            where owner = upper(i.owner)
            and table_name = upper(i.table_name);
            
            v_last_bak_id := null;
            
            execute immediate 'select nvl(max(bak_id), 0) from ' || i.owner || '.' || i.table_name || '_BAK' into v_last_bak_id;
            
            v_is_different := '0';
        
            execute immediate
            '
                select decode(count(*), 0, 0, 1)
                from
                (
                    (
                        select ' || v_compare_columns || '
                        from ' || i.owner || '.' || i.table_name || ' 
                        minus 
                        select ' || v_compare_columns || '
                        from ' || i.owner || '.' || i.table_name || '_BAK' || '
                        where bak_id = ' || v_last_bak_id || '
                    )
                    union all
                    (
                        select ' || v_compare_columns || '
                        from ' || i.owner || '.' || i.table_name || '_BAK' || '
                        where bak_id = ' || v_last_bak_id || '
                        minus 
                        select ' || v_compare_columns || '
                        from ' || i.owner || '.' || i.table_name || ' 
                    )
                )
            '
            into v_is_different;
                
            if v_is_different = 1 then
            
                if i_just_check = '0' then
                        
                    execute immediate
                    '
                        insert into ' || v_table_owner || '.' || i.table_name || '_BAK 
                        select ' ||
                            v_last_bak_id || ', ' ||  
                            v_compare_columns || '
                        from '  || v_table_owner || '.' || i.table_name || ' 
                    ';
                        
                end if;
                    
                o_differents := o_differents || ' ' || i.table_name;
                    
            end if;
            
        end loop;
            
        o_differents := trim(o_differents);
        
        if o_differents is not null and i_just_check = '0' then
        
            o_bak_id := sq_sb_backup_log_id.nextval;
            
            insert into sb_backup_log
            (
                bak_id,
                bak_date,
                description,
                changed_tables,
                created_by
            )
            values
            (
                o_bak_id,
                sysdate,
                i_description,
                o_differents,
                i_created_by
            );
            
            commit;
            
        end if;
        
    end;
    
    procedure save_execution_info
    (
        io_execution_id in out number,
        i_batch_id in number default null,
        i_tmp_table_drop in char default null,
        i_created_by in number default null,
        i_exec_start_date in date default null,
        i_exec_end_date in date default null
    )
    as
    begin

        if io_execution_id is null then
        
            if 
                i_batch_id is null or 
                i_tmp_table_drop is null or 
                i_created_by is null
            then
                raise_application_error(-20000, 'Zorunlu parametreler: batch_id, tmp_table_drop, created_by)');
            end if;
        
            if 
                i_exec_start_date is not null or 
                i_exec_end_date is not null
            then
                raise_application_error(-20000, 'Yeni kayit icin kullanilmayan parametreler: exec_start_date, exec_end_date');
            end if;
                
            select sq_sb_execution_id.nextval into io_execution_id from dual;
                  
            insert into sb_execution_info
            (
                execution_id,
                batch_id,
                tmp_table_drop,
                created_date,
                created_by
            )
            values 
            (
                io_execution_id,
                i_batch_id,
                i_tmp_table_drop,
                sysdate,
                i_created_by
            );
            
        else
        
            if 
                i_batch_id is not null or 
                i_tmp_table_drop is not null or 
                i_created_by is not null
            then
                raise_application_error(-20000, 'Guncelleme icin kullanilamayan parametreler: batch_id, tmp_table_drop, created_by)');
            end if;
        
            update sb_execution_info
            set
                exec_start_date = decode(i_exec_start_date, null, exec_start_date, i_exec_start_date),
                exec_end_date = decode(i_exec_end_date, null, exec_end_date, i_exec_end_date)
            where execution_id = io_execution_id;
        
        end if;
    end;
    
    function get_tag_val
    (
        i_tag_name in varchar2
    ) return varchar2
    as
        v_tag_value varchar2(4000);
    begin
        select a.tag_value
        into v_tag_value
        from sb_query_tags a
        where a.tag_name = upper(i_tag_name);
        
        return v_tag_value;
    end;
    
    function check_table
    (
        i_table_name in varchar2
    ) return number
    as
    begin
        execute immediate 'select count(*) from ' || i_table_name || ' where rownum < 1';
        
        return 1;
    exception
        when others then
            if SQLCODE = -942 then
                return 0;
            end if;
    end;
    
    function query_group_id
    (
        i_query_id in number
    ) return number
    as
        v_query_group_id number;
    begin
        select qg_id
        into v_query_group_id
        from sb_query_groups a
        where a.q_id = i_query_id;
        
        return v_query_group_id;
    end;
    
    procedure execute_queries
    (
        i_params in out execute_query_param
    )
    is
    begin
    
        if i_params.p_group_id = sbatch.v_q_grp_execution then

            for i in
            (
                select q.q_group_id gi, q.q_sequence_id si
                from 
                    sb_query_arrays a,
                    sb_queries q
                where q.q_sequence_id between a.q_seq_from_id and nvl(a.q_seq_to_id, a.q_seq_from_id)
                and q.q_group_id = i_params.p_group_id
                and a.a_id = i_params.p_batch_id
                order by a.a_order_id asc, q.q_sequence_id asc
            )
            loop
            
                if i_params.p_from_sequence_id is null or (i_params.p_from_sequence_id is not null and i.si >= i_params.p_from_sequence_id) then
            
                    i_params.p_sequence_id := i.si;
                            
                    sbatch.execute_query(i_params => i_params);
                    
                end if;
                
            end loop;
            
        else

            for i in
            (
                select q_group_id gi, q_sequence_id si
                from 
                    sb_queries
                where q_group_id = i_params.p_group_id
                order by q_sequence_id asc
            )
            loop
            
                i_params.p_sequence_id := i.si;
                        
                sbatch.execute_query(i_params => i_params);
                        
            end loop;
            
        end if;
    end;
    
    procedure execute_query
    (
        i_params in out execute_query_param,
        i_batch_id in number default -1,
        i_group_id in number default -1,
        i_sequence_id in number default -1,
        i_tmp_table_ts in char default '-1',
        i_execution_id in number default -1,
        i_drop in char default '-1',
        i_replace in varchar2 default '-1',
        i_just_query in char default '-1'
    )
    is
    begin
        if i_batch_id is not null and i_batch_id != -1 then i_params.p_batch_id := i_batch_id; end if;
        if i_group_id is not null and i_group_id != -1 then i_params.p_group_id := i_group_id; end if;
        if i_sequence_id is not null and i_sequence_id != -1 then i_params.p_sequence_id := i_sequence_id; end if;
        if i_tmp_table_ts is not null and i_tmp_table_ts != '-1' then i_params.p_tmp_table_ts := i_tmp_table_ts; end if;
        if i_execution_id is not null and i_execution_id != -1 then i_params.p_execution_id := i_execution_id; end if;
        if i_drop is not null and i_drop != '-1' then i_params.p_drop := i_drop; end if;
        if i_replace is not null and i_replace != '-1' then i_params.p_replace := i_replace; end if;
        if i_just_query is not null and i_just_query != '-1' then i_params.p_just_query := i_just_query; end if;
        
        sbatch.execute_query
        (
            i_batch_id => i_params.p_batch_id,
            i_group_id => i_params.p_group_id, 
            i_sequence_id => i_params.p_sequence_id, 
            i_tmp_table_ts => i_params.p_tmp_table_ts, 
            i_execution_id => i_params.p_execution_id, 
            i_drop => i_params.p_drop, 
            i_replace => i_params.p_replace, 
            i_just_query => i_params.p_just_query, 
            o_query => i_params.p_query
        );
    end;  
    
    procedure execute_query
    (
        i_batch_id in number,
        i_group_id in number,
        i_sequence_id in number,
        i_tmp_table_ts in char,
        i_execution_id in number,
        i_drop in char,
        i_replace in varchar2 default null,
        i_just_query in char default '0',
        o_query out clob
    )
    is
        v_query_stamp varchar2(250 char);
        v_query clob;
        v_idx pls_integer;
        v_id2 pls_integer;
        v_list varchar2 (4000) := i_replace;
        v_del char(1) := '^';
        v_dl2 char(1) := '¨';
        v_replace_pair varchar2 (4000);
        v_find_txt varchar2 (4000);
        v_replace_txt varchar2 (4000);
        v_ne_txt varchar2 (50);
        v_conditions clob;
        v_q char(1 char) := '''';
    begin
        v_query_stamp := 'batch_id: ' || i_batch_id || ', i_group_id: ' || i_group_id || ', i_sequence_id: ' || i_sequence_id;
    
        --tek sefer donen loop
        for i in 
        (
            select q_text, q_description
            from sb_queries
            where q_sequence_id = i_sequence_id
            and q_group_id = i_group_id
        )
        loop
            v_query := i.q_text;
                
            if not (v_query like '%drop%table%' and i_drop = 0) then 
                    
                --batch conditions replace
                --bu basta yapilir cunku <batch_conditions> tagi da replace edilecek tag icerir
                if v_query like '%<batch_conditions>%' then
                
                    sbatch.create_case_s
                    (
                        i_batch_id => i_batch_id, 
                        i_tab_level => 1, 
                        i_show_markers => '0',
                        o_conditions => v_conditions
                    );
                    
                    v_query := replace(v_query, '<batch_conditions>', v_conditions);
                    
                end if;
            
                --default replace
                v_query := replace(v_query, '<timestamp>', i_tmp_table_ts);
                v_query := replace(v_query, '<execution_id>', i_execution_id);
                    
                --parametrik replace
                if i_replace is not null then
                    
                    loop
                        v_idx := instr (v_list, v_del);

                        if v_idx > 0
                        then
                            v_replace_pair := substr (v_list, 1, v_idx - 1);
                            v_list := substr (v_list, v_idx + length (v_del));
                        else
                            v_replace_pair := v_list;
                        end if;
                    
                        v_id2 := instr(v_replace_pair, v_dl2);
                        v_find_txt := substr(v_replace_pair, 1, v_id2 - 1);
                        v_replace_txt := substr(v_replace_pair, v_id2 + 1);
                            
                        v_query := replace(v_query, v_find_txt, v_replace_txt);

                        if v_idx <= 0 then exit; end if;
                    end loop;
                end if;
                
                if v_query like '%<%>%' then
                
                    --tablodan replace
                    
                    --once liste tagleri yerlestirilmeli
                    if v_query like '%<<%>>%' then
                        for r in
                        (
                            select i.list_tag, listagg(decode(t.tag_quoted, '1', v_q||t.tag_value||v_q, t.tag_value), ', ') within group (order by 1) tag_value
                            from 
                                sb_query_list_tag_info i,
                                sb_query_list_tags l,
                                sb_query_tags t
                            where l.l_id = i.l_id
                            and t.t_id between l.t_from_id and l.t_to_id
                            group by i.list_tag
                        )
                        loop
                            if v_query like '%' || r.list_tag || '%' then
                                v_query := replace(v_query, r.list_tag, r.tag_value);
                            end if;
                        end loop;
                    
                    end if;
                 
                    --kalanlar tekil tag
                    for r in
                    (
                        select tag, tag_value, tag_quoted
                        from sb_query_tags
                    )
                    loop
                        if v_query like '%' || r.tag || '%' then

                            v_query := replace
                            (
                                v_query, 
                                r.tag, 
                                (case when r.tag_quoted = '1' then v_q||r.tag_value||v_q else r.tag_value end)
                            );
                        end if;
                    end loop;
                    
                end if;
                
                o_query := v_query;
                
                if i_just_query = '0' then
                    
                    begin
                        
                        execute immediate v_query;

                    exception
                        when others then
                            sbatch.process_log('EXCEPTION', i_execution_id, $$plsql_line, sql%rowcount, v_query_stamp || v_eol || v_query);
                                    
                            raise;
                    end;
                    
                end if;
                
                v_ne_txt := null;
                
            else
                
                v_ne_txt := '--not executed' || v_eol;
            
            end if;
            
            if i_just_query = '0' then
            
                sbatch.process_log
                (
                    i.q_description, 
                    i_execution_id, 
                    $$plsql_line, 
                    sql%rowcount, 
                    v_ne_txt || v_query_stamp || v_eol || v_query
                );
                
            end if; 
            
            commit;
        end loop;
    end; 
    
    function close_s
    (
        i_string in varchar2,
        i_suffix in varchar2 default null
    ) return varchar2 deterministic
    as 
    begin
        return case when i_string is null then null else rtrim(i_string, ' | ')||i_suffix end;
    end;
    
    function bound_s
    (
        i_prefix in varchar2,
        i_string in varchar2,
        i_suffix in varchar2
    ) return varchar2 deterministic
    as 
    begin
        return case when i_string is null then null else i_prefix||rtrim(i_string, ' | ')||i_suffix end;
    end;
    
    procedure create_case_s
    (
        i_batch_id in number,
        i_node in sb_conditions%rowtype default null,
        i_is_last_sibling in number default 0,
        i_parent in sb_conditions%rowtype default null,
        i_tab_level in number default 0,
        i_row_space in char default '0',
        i_show_markers in char default '0',
        o_conditions in out clob
    ) as
        v_node sbatch.bat_con_tbl;
        v_child sbatch.bat_con_tbl;
        v_nl varchar2 (5 byte);
        eol varchar2 (5 byte);
        eolf varchar2 (5 byte);
        tab varchar2 (1 byte);
        tabs varchar2 (100 byte);
        tabst varchar2 (100 byte);
        cws varchar2 (10 byte);
        ths varchar2 (10 byte);
        sths varchar2 (10 byte);
        sp varchar2 (10 byte);
        pp varchar2 (15 byte);
        spp varchar2 (25 byte);
        en varchar2 (10 byte);
        sen varchar2 (10 byte);
        enp varchar2 (25 byte);
        senp varchar2 (25 byte);
        qt varchar2 (10 byte);
        cm varchar2 (10 byte);
        v_childs_count number;
        v_p_loop_count number;
        v_p_loop_id number;
        v_c_loop_count number;
        v_c_loop_id number;
        v_sibling_counter number;
    begin
        
        qt := chr(39);
        cm := '--';
        
        v_nl := chr (10);
        eol := v_nl;
        eolf := v_nl;
        
        tab := chr (9);
        tabs := null;
        tabst := tabs;
        
        sp := chr(32);
        cws := 'case when' || sp;
        ths := 'then' || sp;
        sths := sp || ths;
        
        
        pp := '|| '' | '' ||';
        spp := sp || pp;
        en := 'end';
        sen := sp || en;
        enp := en || spp;
        senp := sp || enp;
        
        if i_row_space = '1' then eol := eol || cm || eol; end if;
        
        for i in 1 .. i_tab_level
        loop
            tabs := tabs || tab;
        end loop;
        
        tabst := tabs || tab;
        
        if i_node.c_id is null then
        
            o_conditions := o_conditions || tabs || 'sbatch.close_s' || eol || tabs || '(' || eol;
        
            select c.*
            bulk collect into v_node
            from 
                sb_condition_arrays a,
                sb_conditions c
            where c.c_parent_id is null
            and c.c_id between a.c_from_id and a.c_to_id
            and a.a_id = i_batch_id
            order by a.a_order_id asc, c.c_id asc;
            
            v_sibling_counter := 1;
        
            for i in
            (
                select *
                from table(v_node)
            )
            loop
            
                sbatch.create_case_s
                (
                    i_batch_id => i_batch_id,
                    i_node => i, 
                    i_is_last_sibling => case when v_sibling_counter = v_node.count then 1 else 0 end,
                    i_parent => null, 
                    i_tab_level => i_tab_level + 1, 
                    i_row_space => i_row_space,
                    i_show_markers => i_show_markers,
                    o_conditions => o_conditions
                );
                
                v_sibling_counter := v_sibling_counter + 1;
            end loop;
        
            o_conditions := o_conditions || tabs || ')';
            
        else
        
            select c.*
            bulk collect into v_child
            from 
                sb_condition_arrays a,
                sb_conditions c
            where c.c_parent_id = i_node.c_id
            and c.c_id between a.c_from_id and a.c_to_id
            and a.a_id = i_batch_id
            order by a.a_order_id asc, c.c_id asc;

            if i_show_markers = '1' then
                o_conditions := o_conditions || tabs || '+' || i_node.c_id || '+[' || eol;
            end if;
            
            if i_parent.c_id is null then
                    
                o_conditions := o_conditions || tabs || 'sbatch.close_s(' || cws;
                
            else
            
                if i_parent.c_bounds = '1' then
                
                    o_conditions := o_conditions || tabs || 'sbatch.close_s(' || cws;
                    
                else
                
                    if i_parent.condition is null or i_parent.condition = 'not' then
                
                        o_conditions := o_conditions || tabs;
                        
                    end if;
                
                end if;
            
            end if;
            
            if i_node.c_bounds = '1' then
                    
                o_conditions := o_conditions || i_node.condition || sths || 'sbatch.bound_s(';
                o_conditions := o_conditions || qt || i_node.description || ' (' || qt || ', ' || eol;
                    
            else
                
                if v_child is not null and v_child.count > 0 then
                    
                    if i_node.condition is null or i_node.condition = 'not' then
                
                        o_conditions := o_conditions || case when i_node.condition is not null then i_node.condition || sths end || eol;
                            
                    end if; 
                        
                else
                
                    o_conditions := o_conditions || i_node.condition;
                    
                end if;
                    
            end if;

            if v_child is not null and v_child.count > 0 then
            
                o_conditions := o_conditions || tabs ||  '(' || eol;
                
                v_sibling_counter := 1;
                
                for i in
                (
                    select *
                    from table (v_child)
                )
                loop
                    sbatch.create_case_s
                    (
                        i_batch_id => i_batch_id,
                        i_node => i, 
                        i_is_last_sibling => case when v_sibling_counter = v_child.count then 1 else 0 end,
                        i_parent => i_node, 
                        i_tab_level => i_tab_level + 1, 
                        i_row_space => i_row_space,
                        i_show_markers => i_show_markers,
                        o_conditions => o_conditions
                    );
                    
                    v_sibling_counter := v_sibling_counter + 1;
                end loop;
            
                o_conditions := o_conditions || tabs ||  ')';
                
            end if;
            
            if i_node.c_bounds = '1' then
                    
                o_conditions := o_conditions || ', '')'')' || sen || case when i_is_last_sibling = 0 then ', '' | '') ||' else ', null)' end || eol;
                
            else
                
                if v_child is not null and v_child.count > 0 then
                    
                    if i_node.condition is null or i_node.condition = 'not' then
                    
                        if i_parent.c_id is null or i_parent.c_bounds = '1' then
                    
                            o_conditions := o_conditions || sths || qt || i_node.description || qt || sen || case when i_is_last_sibling = 0 then ', '' | '') ||' else ', null)' end || eol;
                            
                        else
                        
                            if i_is_last_sibling = 1 then
                    
                                o_conditions := o_conditions || eol;
                                
                            else
                    
                                o_conditions := o_conditions || ' and' || eol;
                                
                            end if;
                        
                        end if;
                            
                    end if; 
                        
                else
                    
                    if i_parent.c_id is null or i_parent.c_bounds = '1' then
                
                        o_conditions := o_conditions || sths || qt || i_node.description || qt || sen || case when i_is_last_sibling = 0 then ', '' | '') ||' else ', null)' end || eol;
                        
                    else
                        
                        if i_is_last_sibling = 1 then
                    
                            o_conditions := o_conditions || eol;
                        
                        else
                    
                            o_conditions := o_conditions || ' and' || eol;
                            
                        end if;
                    
                    end if;
                    
                end if;
                    
            end if;
                
            if i_show_markers = '1' then
                o_conditions := o_conditions || tabs || '+' || i_parent.c_id || '+]' || eol;
            end if;
        end if;
        
        return;
        
    end;
    
    procedure process_log
    (
        i_log_text in varchar2,
        i_execution_id number,
        i_code_row_number in number,
        i_sql_row_count in number,
        i_query in clob default null
    )
    is
        pragma autonomous_transaction;
    begin
        insert into sb_log
        values 
        (
            sq_sb_log_id.nextval, 
            sysdate, 
            i_execution_id,
            i_code_row_number, 
            i_sql_row_count, 
            i_log_text,
            i_query
        );
                
        commit;
    end;
end;
/