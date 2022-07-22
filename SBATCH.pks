CREATE OR REPLACE PACKAGE sbatch
is
    v_q_grp_db_cleaning number;
    v_q_grp_execution number;
    
    v_nl varchar2 (10 byte) := chr (10);
    v_cr varchar2 (10 byte) := chr (13);
    v_eol varchar2 (10 byte) := v_nl || v_cr;
    v_eol2 varchar2 (10 byte) := v_nl || v_nl || v_cr;

    type bat_con_tbl is table of sb_conditions%rowtype;
    
    type execute_query_param is record
    (
        p_batch_id number,
        p_group_id number,
        p_sequence_id number,
        p_tmp_table_ts char(8),
        p_execution_id number,
        p_drop char(1),
        p_replace varchar2(4000),
        p_from_sequence_id number,
        p_just_query char(1),
        p_query clob
    );

    procedure execute_batch
    (
        i_batch_id in number default null,
        i_drop in char default '1',
        i_from_sequence_id number default null,
        i_created_by number,
        io_execution_id in out number
    );
    
    procedure backup_batch_definitions
    (
        i_just_check in char default '0',
        i_description in varchar2 default null,
        i_created_by in number default null,
        o_bak_id out number,
        o_differents out varchar2
    );
    
    procedure save_execution_info
    (
        io_execution_id in out number,
        i_batch_id in number default null,
        i_tmp_table_drop in char default null,
        i_created_by in number default null,
        i_exec_start_date in date default null,
        i_exec_end_date in date default null
    );
    
    function get_tag_val
    (
        i_tag_name in varchar2
    ) return varchar2;
    
    function check_table
    (
        i_table_name in varchar2
    ) return number;
    
    function query_group_id
    (
        i_query_id in number
    ) return number;
    
    procedure execute_queries
    (
        i_params in out execute_query_param
    );
    
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
    );  
    
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
    );  
    
    function close_s
    (
        i_string in varchar2,
        i_suffix in varchar2 default null
    ) return varchar2 deterministic;
    
    function bound_s
    (
        i_prefix in varchar2,
        i_string in varchar2,
        i_suffix in varchar2
    ) return varchar2 deterministic;
    
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
    );  
    
    procedure process_log
    (
        i_log_text in varchar2,
        i_execution_id number,
        i_code_row_number in number,
        i_sql_row_count in number,
        i_query in clob default null
    );
end;
/
