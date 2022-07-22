select a.*
from SB_QUERIES a
order by 1, 2

select a.*, a.rowid
from SB_CONDITIONS a
order by 1

select a.*
from SB_QUERY_TAGS a

declare
    v_conditions clob;
begin
    sbatch.create_case_s
    (
        i_batch_id => 1,
        o_conditions => v_conditions
    );
    dbms_output.put_line(v_conditions);
end;

declare
    v_query clob;
begin
    sbatch.execute_query
    (
        i_batch_id => 1,
        i_group_id => 2,
        i_sequence_id => 17,
        i_tmp_table_ts => 'test',
        i_execution_id => 0,
        i_drop => '0',
        i_just_query => '1',
        o_query => v_query
    );
    dbms_output.put_line(v_query);
end;

declare
    v_execution_id number;
begin
    sbatch.execute_batch
    (
        i_batch_id => 1,
        i_drop => '0',
        i_created_by => 10001,
        io_execution_id => v_execution_id
    );
    dbms_output.put_line('v_execution_id: ' || v_execution_id);
end;

select *
from sb_log
order by 1 desc

select *
from BATCH_COLLECTION
where HARIC_KALMA_SEBEBI is null

select exec_proc, count(*)
from smp_accounts
group by exec_proc
order by 1

select exec_proc, count(*)
from smp_accounts
where account_id in
(
    select account_id
    from BATCH_COLLECTION
    where HARIC_KALMA_SEBEBI is null
)
group by exec_proc