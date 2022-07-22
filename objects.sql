create table sb_backup_log
(
    bak_id number,
    bak_date date,
    description varchar2(500 char),
    changed_tables varchar2(4000 char),
    created_by number
);
/

create unique index sb_backup_log_01 on sb_backup_log (bak_id);
/

--drop sequence sq_sb_backup_log_id;

create sequence sq_sb_backup_log_id nocache order;
/

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

create table sb_query_arrays
(
    a_id number,
    a_order_id number,
    q_seq_from_id number,
    q_seq_to_id number
);
/

create unique index sb_query_arrays_01 on sb_query_arrays (a_id, a_order_id);
/

create table sb_queries
(
    q_group_id number,
    q_sequence_id number,
    q_text clob,
    q_description varchar2(1000 char)
);
/

create unique index sb_queries_01 on sb_queries (q_group_id, q_sequence_id);
/

create table sb_query_groups
(
    q_id number,
    qg_id number,
    qg_description varchar2(1000 char)
);
/

create unique index sb_query_groups_01 on sb_query_groups (q_id);
/

create unique index sb_query_groups_02 on sb_query_groups (qg_id);
/

-------------------------------------------------------------------------------

create table sb_query_arrays_bak
(
    bak_id number,
    a_id number,
    a_order_id number,
    q_seq_from_id number,
    q_seq_to_id number
);
/

create index sb_query_arrays_bak_01 on sb_query_arrays_bak (bak_id);
/

create table sb_queries_bak
(
    bak_id number,
    q_group_id number,
    q_sequence_id number,
    q_text clob,
    q_description varchar2(1000 char)
);
/

create index sb_queries_bak_01 on sb_queries_bak (bak_id);
/

create table sb_query_groups_bak
(
    bak_id number,
    q_id number,
    qg_id number,
    qg_description varchar2(1000 char)
);
/

create unique index sb_query_groups_bak_01 on sb_query_groups_bak (bak_id);
/

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

create table sb_condition_arrays
(
    a_id number,
    a_order_id number,
    c_from_id number,
    c_to_id number
);
/

create unique index sb_condition_arrays_01 on sb_condition_arrays (a_id, a_order_id);
/

create table sb_conditions
(
  c_id number,
  c_parent_id number,
  c_bounds char(1),
  condition varchar2(4000 char),
  description varchar2(4000 char)
);
/

create unique index sb_conditions_01 on sb_conditions (c_id);
/

-------------------------------------------------------------------------------

create table sb_condition_arrays_bak
(
    bak_id number,
    a_id number,
    a_order_id number,
    c_from_id number,
    c_to_id number
);
/

create index sb_condition_arrays_bak_01 on sb_condition_arrays_bak (bak_id);
/

create table sb_conditions_bak
(
  bak_id number,
  c_id number,
  c_parent_id number,
  c_bounds char(1),
  condition varchar2(4000 char),
  description varchar2(4000 char)
);
/

create index sb_conditions_bak_01 on sb_conditions_bak (bak_id);
/

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

create table sb_query_tags
(
  t_id number,
  tag varchar2(4000 char),
  tag_value varchar2(4000 char),
  tag_name varchar2(100 char),
  tag_description varchar2(500 char),
  tag_quoted char(1 char)
);
/

create unique index sb_query_tags_01 on sb_query_tags (t_id);
/

create unique index sb_query_tags_02 on sb_query_tags (tag);
/

create table sb_query_list_tags
(
  l_id number,
  t_from_id number,
  t_to_id number
);
/

create unique index sb_query_list_tags_01 on sb_query_list_tags (l_id, t_from_id);
/

create table sb_query_list_tag_info
(
  l_id number,
  list_tag varchar2(4000 char),
  tag_name varchar2(100 char),
  tag_description varchar2(500 char)
);
/

create unique index sb_query_list_tag_info_01 on sb_query_list_tag_info (l_id);
/

create unique index sb_query_list_tag_info_02 on sb_query_list_tag_info (list_tag);
/

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

create table sb_query_tags_bak
(
  bak_id number,
  t_id number,
  tag varchar2(4000 char),
  tag_value varchar2(4000 char),
  tag_name varchar2(100 char),
  tag_description varchar2(500 char),
  tag_quoted char(1 char)
);
/

create index sb_query_tags_bak_01 on sb_query_tags_bak (bak_id);
/

create table sb_query_list_tags_bak
(
  bak_id number,
  l_id number,
  t_from_id number,
  t_to_id number
);
/

create index sb_query_list_tags_bak_01 on sb_query_list_tags_bak (bak_id);
/

create table sb_query_list_tag_info_bak
(
  bak_id number,
  l_id number,
  list_tag varchar2(4000 char),
  tag_name varchar2(100 char),
  tag_description varchar2(500 char)
);
/

create index sb_query_list_tag_info_bak_01 on sb_query_list_tag_info_bak (bak_id);
/

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--drop sequence sq_sb_execution_id;

create sequence sq_sb_execution_id nocache order;
/


create table sb_execution_info
(
    execution_id number(18),
    batch_id number,
    tmp_table_drop char(1) default '1',
    exec_start_date date,
    exec_end_date date,
    created_date date,
    created_by number
);
/
                
create index sb_execution_info_01 on sb_execution_info (execution_id);
/
                
create index sb_execution_info_02 on sb_execution_info (exec_start_date);
/

create table sb_log
(
    log_id number(18),
    log_date date,
    execution_id number(18),
    code_row_number number(18),
    sql_row_count number(18),
    log_text varchar2(4000 char),
    q_text clob
);
/

create index sb_log_01 on sb_log (execution_id);
/

create unique index sb_log_02 on sb_log (log_date, log_id);
/

--drop sequence sq_sb_log_id;

create sequence sq_sb_log_id nocache order;
/