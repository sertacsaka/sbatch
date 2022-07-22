SET DEFINE OFF;
Insert into SB_QUERY_GROUPS
   (Q_ID, QG_ID, QG_DESCRIPTION)
 Values
   (1, 1, 'DB Cleaning');
Insert into SB_QUERY_GROUPS
   (Q_ID, QG_ID, QG_DESCRIPTION)
 Values
   (2, 2, 'Execution');
COMMIT;

SET DEFINE OFF;
Insert into SB_QUERY_ARRAYS
   (A_ID, A_ORDER_ID, Q_SEQ_FROM_ID, Q_SEQ_TO_ID)
 Values
   (1, 1, 1, 18);
COMMIT;


SET DEFINE OFF;
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (1, 1, 'begin
    for i in 
    (
        select *
        from user_objects
        where object_name like ''TMP_BAT_____________''
        and object_type = ''TABLE''
        and created < trunc(sysdate) - 1
    )
    loop
        begin
            execute immediate ''drop table '' || i.object_name || '' purge'';
        exception
            when others then
                if sqlerrm like ''ORA-00942%'' then 
                    --table or view does not exist
                    null; 
                else 
                    raise; 
                end if;
        end;
    end loop;
end;', 'Dusurulmeden kalmis eski gecici tablolarin dusurulmesi');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (1, 2, 'begin
    for i in 
    (
        select *
        from user_objects
        where object_name like ''TMP_BAT_<timestamp>____''
        and object_type = ''TABLE''
    )
    loop
        begin
            execute immediate ''drop table '' || i.object_name || '' purge'';
        exception
            when others then
                if sqlerrm like ''ORA-00942%'' then 
                    --table or view does not exist
                    null; 
                else 
                    raise; 
                end if;
        end;
    end loop;
end;', 'Varsa ayni isimli gecici tablolarin dusurulmesi');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 1, 'create table tmp_bat_<timestamp>_001
(
  account_id number(7, 0)
) nologging parallel', 'Aktif urunlu accountlar tablosu');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 2, 'insert /*+ no_gather_optimizer_statistics */ into tmp_bat_<timestamp>_001
select distinct a.account_id
from
    smp_accounts a, 
    smp_products b
where b.status = ''1''
and a.status = ''1''
and b.account_id = a.account_id', 'Aktif urunlu aktif accountlar');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 3, 'create table tmp_bat_<timestamp>_002
(
  account_id number(7, 0)
) nologging parallel', 'Fatura borcu olan aktif urunlu aktif accountlar tablosu');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 4, 'create index tmp_bat_<timestamp>_002_01 on tmp_bat_<timestamp>_002 (account_id) nologging parallel', 'Fatura borcu olan aktif urunlu aktif accountlar tablosu index');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 5, 'insert /*+ no_gather_optimizer_statistics */ into tmp_bat_<timestamp>_002
select distinct a.account_id
from
    tmp_bat_<timestamp>_001 a
where exists
(
    select 1
    from smp_invoices b
    where b.account_id = a.account_id
    and b.debt_amount > 0
)', 'Fatura borcu olan aktif urunlu aktif accountlar');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 6, 'drop table tmp_bat_<timestamp>_001 purge', 'Aktif urunlu aktif accountlar tablosunu dusurme');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 7, 'create table tmp_bat_<timestamp>_003
(
  account_id number(7, 0),
  period_to_backward number(18),
  debt_amount number(24, 2)
) nologging parallel', 'Fatura borcu olan aktif urunlu aktif accountlarin borclu oldugu faturalari tablosu');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 8, 'create index tmp_bat_<timestamp>_003_01 on tmp_bat_<timestamp>_003 (account_id) nologging parallel', 'Fatura borcu olan aktif urunlu aktif accountlarin borclu oldugu faturalari tablosu index');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 9, 'insert /*+ no_gather_optimizer_statistics */ into tmp_bat_<timestamp>_003
select 
    b.account_id, 
    months_between(trunc(sysdate,''MM''), trunc(b.invoice_date, ''MM'')), 
    b.debt_amount
from
    tmp_bat_<timestamp>_002 a,
    smp_invoices b
where b.account_id = a.account_id
and b.debt_amount > 0', 'Fatura borcu olan aktif urunlu aktif accountlarin borclu oldugu faturalar');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 10, 'declare
    v_sql varchar2(4000 char);
begin
    if sbatch.check_table(''<PREPARATION_TABLE>'') = 0 then
        v_sql := ''create table <PREPARATION_TABLE> '';
        v_sql := v_sql || ''( '';
        v_sql := v_sql || ''    account_id number(7, 0) not null, '';
        v_sql := v_sql || ''    account_segment char(1 char), ''; --1: gold, 0: standard
        v_sql := v_sql || ''    account_type char(1 char), ''; --1: corporate, 0: individual
        v_sql := v_sql || ''    region char(1 char), ''; --local: corporate, 0: foreign
        v_sql := v_sql || ''    exec_proc char(1 char), ''; --0: no, 1: yes in executive proceeding
        v_sql := v_sql || ''    total_debt_amount number(24, 2), ''; 
        v_sql := v_sql || ''    open_inv_count number(18), '';
        v_sql := v_sql || ''    invoice_pattern varchar2(500), ''; --yeniden eskiye acik faturalar
        v_sql := v_sql || ''    oit_except_last2_underl char(1), ''; --son 2 donem haric borc limit altinda
        v_sql := v_sql || ''    limit_asimi char(1), '';
        v_sql := v_sql || ''    haric_kalma_sebebi varchar2(4000) '';
        v_sql := v_sql || '') nologging parallel '';
        
        execute immediate v_sql;
        
        v_sql := ''create index <PREPARATION_TABLE>_01 on <PREPARATION_TABLE> (account_id) nologging parallel'';
        
        execute immediate v_sql;
        
        v_sql := ''create index <PREPARATION_TABLE>_02 on <PREPARATION_TABLE> (haric_kalma_sebebi, ''''null'''') nologging parallel'';
        
        execute immediate v_sql;
        
    else
        execute immediate ''truncate table <PREPARATION_TABLE>'';
    end if;
end;', 'Batch kitlesinin aktarilacagi tablo');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 11, 'insert /*+ no_gather_optimizer_statistics */ into <PREPARATION_TABLE>
select 
    a.account_id, 
    a.account_segment, 
    a.account_type,
    a.region,
    a.exec_proc,
    null, null, null, null, null, null
from
    smp_accounts a,
    tmp_bat_<timestamp>_002 b
where a.account_id = b.account_id', 'Batch kitlesi');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 12, 'drop table tmp_bat_<timestamp>_002 purge', 'Fatura borcu olan aktif urunlu aktif accountlar tablosunu dusurme');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 13, 'update /*+ no_parallel no_gather_optimizer_statistics */ <PREPARATION_TABLE> a
set
    (a.invoice_pattern, a.total_debt_amount, a.open_inv_count) =
    (
        select /*+ index(b tmp_bat_<timestamp>_003_01) */ 
            substr(''-''||listagg(b.period_to_backward, ''-'') within group (order by b.period_to_backward asc)||''-'', 1, 500),
            sum(b.debt_amount), 
            count(*)
        from tmp_bat_<timestamp>_003 b
        where b.account_id = a.account_id
    )', 'Borclu olunan faturalar ile toplam fatura borcu ve adedi tespiti');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 14, 'update /*+ no_parallel no_gather_optimizer_statistics */ <PREPARATION_TABLE> a
set a.oit_except_last2_underl = 
(
    select 
        case when nvl(sum
        (
            case when b.period_to_backward > 2 then b.debt_amount else 0 end
        ), 0) < <LIMIT_IHMAL_EDILECEK> then 1 else 0 end
    from tmp_bat_<timestamp>_003 b
    where b.account_id = a.account_id
)', 'Son 2 donem haric borc toplami limit altinda durumu tespiti');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 15, 'drop table tmp_bat_<timestamp>_003 purge', 'Fatura borcu olan aktif urunlu aktif accountlar tablosunu dusurme');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 16, 'update /*+ no_parallel no_gather_optimizer_statistics */ <PREPARATION_TABLE> a
set a.limit_asimi =
(
    case when
    (
        a.total_debt_amount
        -
        decode
        (
            a.region,
            <ACC_REGION_LOCAL>, decode
            (
                a.account_type,
                <ACC_TYPE_CORPORATE>, <LMT_LOCAL_CORPORATE>,
                <ACC_TYPE_INDIVIDUAL>, decode
                (
                    a.account_segment,
                    <ACC_SEGMENT_GOLD>, <LMT_LOCAL_GOLD>,
                    <ACC_SEGMENT_SILVER>, <LMT_LOCAL_SILVER>,
                    <LMT_LOCAL_STANDARD>
                ),
                0
            ), decode
            (
                a.account_type,
                <ACC_TYPE_CORPORATE>, <LMT_FOREIGN_CORPORATE>,
                <ACC_TYPE_INDIVIDUAL>, decode
                (
                    a.account_segment,
                    <ACC_SEGMENT_GOLD>, <LMT_FOREIGN_GOLD>,
                    <ACC_SEGMENT_SILVER>, <LMT_LOCAL_SILVER>,
                    <LMT_FOREIGN_STANDARD>
                ),
                0
            )
        )
    ) >= 0 then ''1'' else ''0'' end
)', 'Limit asimi tespiti');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 17, 'update /*+ no_parallel no_gather_optimizer_statistics */ <PREPARATION_TABLE> a
set a.haric_kalma_sebebi = 
(
<batch_conditions>
)', 'Batch kitlesine girmeme sebeplerinin tespiti');
Insert into SB_QUERIES
   (Q_GROUP_ID, Q_SEQUENCE_ID, Q_TEXT, Q_DESCRIPTION)
 Values
   (2, 18, 'update /*+ no_parallel no_gather_optimizer_statistics */ smp_accounts a
set
    a.exec_proc = ''2''
where exists
(
    select /*+ index(b <PREPARATION_TABLE>_01) */ 
        1
    from <PREPARATION_TABLE> b
    where b.account_id = a.account_id
    and b.exec_proc = ''0''
    and b.haric_kalma_sebebi is null
)', 'Borcu sebebiyle yasal takibe gonderileceklerin tespiti');
COMMIT;