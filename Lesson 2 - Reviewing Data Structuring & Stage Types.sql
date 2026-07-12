create or replace table util_db.public.my_data_types
(
  my_number number
, my_text varchar(10)
, my_bool boolean
, my_float float
, my_date date
, my_timestamp timestamp_tz
, my_variant variant
, my_array array
, my_object object
, my_geography geography
, my_geometry geometry
, my_vector vector(int,16)
);

use role SYSADMIN;
create or replace database ZENAS_ATHLEISURE_DB;
drop schema if exists ZENAS_ATHLEISURE_DB.public;
create or replace schema ZENAS_ATHLEISURE_DB.PRODUCTS;
use schema ZENAS_ATHLEISURE_DB.PRODUCTS;
create or replace stage sweatsuits
    directory = (enable = true)
    encryption = (type = 'SNOWFLAKE_SSE')
;
create stage PRODUCT_METADATA
    directory = (enable = true)
;

use role accountadmin;
use schema util_db.public;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
 'DLKW01' as step
  ,( select count(*)  
      from ZENAS_ATHLEISURE_DB.INFORMATION_SCHEMA.STAGES 
      where stage_schema = 'PRODUCTS'
      and 
      (stage_type = 'Internal Named' 
      and stage_name = ('PRODUCT_METADATA'))
      or stage_name = ('SWEATSUITS')
   ) as actual
, 2 as expected
, 'Zena stages look good' as description
); 