use role sysadmin;
show stages in schema zenas_athleisure_db.products;
use schema zenas_athleisure_db.products;
list @SWEATSUITS;
select metadata$filename, count(metadata$file_row_number)
from @sweatsuits
group by metadata$filename;
select *
from directory(@sweatsuits)
;
select INITCAP(REPLACE(REPLACE(relative_path, '_', ' '), '.png')) as product_name
from directory(@sweatsuits);
create or replace table sweatsuits (
    color_or_style VARCHAR(25),
    file_name VARCHAR(50),
    price number(5,2)
);
--fill the new table with some data
insert into  zenas_athleisure_db.products.sweatsuits 
          (color_or_style, file_name, price)
values
 ('Burgundy', 'burgundy_sweatsuit.png',65)
,('Charcoal Grey', 'charcoal_grey_sweatsuit.png',65)
,('Forest Green', 'forest_green_sweatsuit.png',64)
,('Navy Blue', 'navy_blue_sweatsuit.png',65)
,('Orange', 'orange_sweatsuit.png',65)
,('Pink', 'pink_sweatsuit.png',63)
,('Purple', 'purple_sweatsuit.png',64)
,('Red', 'red_sweatsuit.png',68)
,('Royal Blue',	'royal_blue_sweatsuit.png',65)
,('Yellow', 'yellow_sweatsuit.png',67);
create or replace view PRODUCT_LIST as
select INITCAP(REPLACE(REPLACE(ps.file_name, '_', ' '), '.png')) as product_name,
ps.file_name,
ps.color_or_style,
ps.price,
ds.file_url
from zenas_athleisure_db.products.sweatsuits ps
join directory(@sweatsuits) ds
on ps.file_name = ds.relative_path
;
create or replace view CATALOG as
select * 
from PRODUCT_LIST
join sweatsuit_sizes
;
select count(*) from CATALOG;
use role accountadmin;
use schema util_db.public;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
 'DLKW03' as step
 ,( select count(*) from ZENAS_ATHLEISURE_DB.PRODUCTS.CATALOG) as actual
 ,180 as expected
 ,'Cross-joined view exists' as description
); 