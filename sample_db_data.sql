/*
drop table smp_invoices purge;
/
drop table smp_products purge;
/
drop table smp_accounts purge;
/
*/

create table smp_accounts
(
    account_id number(7, 0) not null,
    status char(1 char), --1: active, 0: inactive
    account_segment char(1 char), --2: gold, 1: silver, 0: standard
    account_type char(1 char), --1: corporate, 0: individual
    region char(1 char), --0: local, 1: foreign
    exec_proc char(1 char), --0: no, 1: yes in executive proceeding
    constraint pk_account_id primary key (account_id)
);
/

insert into smp_accounts
select 
    account_id, 
    case when trunc(dbms_random.value(1,5)) in (1, 2, 3) then '1' else '0' end status,
    case when trunc(dbms_random.value(1,5)) in (1, 2) then '0' else case when trunc(dbms_random.value(1,3)) in (1) then '1' else '2' end end account_segment,
    case when trunc(dbms_random.value(1,9)) in (1) then '1' else '0' end account_type,
    case when trunc(dbms_random.value(1,9)) in (1) then '0' else '1' end region,
    case when trunc(dbms_random.value(1,21)) in (1) then '1' else '0' end exec_proc
from
(
    select distinct trunc(dbms_random.value(1,100000)) + 1e6 account_id
    from dual
    connect by level <= 10000
);
/

/*
select *
from smp_accounts
*/

/*
select account_segment, count(*)
from smp_accounts
group by account_segment
order by 1
*/


create table smp_products
(
    product_id numeric(10, 0) not null,
    product_code numeric(4, 0) not null,
    account_id number(7, 0) not null,
    status char(1 char), --1: active, 0: inactive
    constraint pk_product_id primary key (product_id),
    constraint fk_account_id foreign key (account_id) references smp_accounts(account_id)
);
/

declare 
    v_product_count number;
    v_product_id number;
begin
    v_product_id := 10000;
    
    delete from smp_products;
    
    for i in
    (
        select *
        from smp_accounts
    )
    loop
        v_product_count := trunc(dbms_random.value(1,10));
        
        for j in 1 .. v_product_count
        loop
            insert into smp_products values
            (
                v_product_id,
                trunc(dbms_random.value(1,100)) + 1e3,
                i.account_id,
                case when trunc(dbms_random.value(1,5)) in (1) then 0 else 1 end
            );
            
            v_product_id := v_product_id + 1;
        end loop;
        
    end loop;
    
    commit;
end;
/

/*
select *
from smp_products
*/


create table smp_invoices
(
    invoice_id number(10, 0) not null,
    invoice_date date not null,
    account_id number(7, 0) not null,
    debt_amount number(11, 2) not null,
    constraint pk_invoice_id primary key (invoice_id),
    constraint fk_inv_account_id foreign key (account_id) references smp_accounts(account_id)
);
/

declare 
    v_invoice_count number;
    v_invoice_id number;
    v_current_month date;
begin
    v_invoice_id := 1e9;
    
    delete from smp_invoices;
    
    for i in
    (
        select *
        from smp_accounts
    )
    loop
        v_invoice_count := 5;
        v_current_month := add_months(trunc(sysdate, 'MM'), -4);
        
        for j in 1 .. v_invoice_count
        loop
            if trunc(dbms_random.value(1, 11)) != 1 then
                insert into smp_invoices values
                (
                    v_invoice_id,
                    v_current_month,
                    i.account_id,
                    case 
                        when j = v_invoice_count then 
                            case when trunc(dbms_random.value(1, 5)) in (1, 2) then dbms_random.value(0, v_invoice_count) * 5 else 0 end
                        when j = v_invoice_count - 1 then 
                            case when trunc(dbms_random.value(1, 5)) in (1) then dbms_random.value(0, v_invoice_count) * 5 else 0 end
                        else
                            case when trunc(dbms_random.value(1, 50)) in (1) then dbms_random.value(0, v_invoice_count) * 1 else 0 end
                    end 
                );
            end if;
            
            v_invoice_id := v_invoice_id + 1;
            v_current_month := add_months(v_current_month, 1);
        end loop;
        
    end loop;
    
    commit;
end;
/

/*
select account_id, invoice_id, invoice_date, debt_amount
from smp_invoices
order by account_id, invoice_id desc
*/

