use role accountadmin;
use schema util_db.public;
select GRADER(step, (actual = expected), actual, expected,
description) as graded_results from
(
    SELECT
    'DLKW10' as step
    ,( select row_count
        from MY_ICEBERG_DB.INFORMATION_SCHEMA.TABLES
        where table_catalog = 'MY_ICEBERG_DB'
        and table_name like 'CCT_%'
        and table_type = 'BASE TABLE')
    as actual
    ,100 as expected
    ,'Iceberg table created and populated!' as description
);