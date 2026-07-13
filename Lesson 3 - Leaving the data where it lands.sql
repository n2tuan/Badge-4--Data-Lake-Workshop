use schema zenas_athleisure_db.products;
list @zenas_athleisure_db.products.product_metadata;
select $1 from @product_metadata/product_coordination_suggestions.txt;
create or replace file format zmd_file_format_1
  record_delimiter = ';'
  trim_space = True
;
select $1 from @product_metadata/product_coordination_suggestions.txt
(file_format => 'zmd_file_format_1');
create or replace file format zmd_file_format_2
  field_delimiter = '|'
  record_delimiter = ';'
  trim_space = True
;
select $1,$2 from @product_metadata/product_coordination_suggestions.txt
(file_format => 'zmd_file_format_2');
create or replace file format zmd_file_format_3
  field_delimiter = '='
  record_delimiter = '^'
  trim_space = True
;
create or replace view zenas_athleisure_db.products.SWEATBAND_COORDINATION as
select $1 as product_code,
$2 as has_matching_sweatsuit
from @product_metadata/product_coordination_suggestions.txt
(file_format => 'zmd_file_format_3');
create or replace view zenas_athleisure_db.products.sweatsuit_sizes as
select replace($1,'\r\n') as sizes_available 
from @product_metadata/sweatsuit_sizes.txt
(file_format => 'zmd_file_format_1')
where sizes_available != ''
;
create or replace view zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE as 
select replace($1,'\r\n') as product_code,
$2 as headband_description,
$3 as wristband_description 
from @product_metadata/swt_product_line.txt
(file_format => 'zmd_file_format_2')
;
select * from zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE;
select * from zenas_athleisure_db.products.SWEATBAND_COORDINATION;
select * from zenas_athleisure_db.products.sweatsuit_sizes;
use role accountadmin;
use schema util_db.public;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
   'DLKW02' as step
   ,( select sum(tally) from
        ( select count(*) as tally
        from ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATBAND_PRODUCT_LINE
        where length(product_code) > 7 
        union
        select count(*) as tally
        from ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUIT_SIZES
        where LEFT(sizes_available,2) = char(13)||char(10))     
     ) as actual
   ,0 as expected
   ,'Leave data where it lands.' as description
); 