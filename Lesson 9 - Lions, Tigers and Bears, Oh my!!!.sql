use role sysadmin;
use schema MELS_SMOOTHIE_CHALLENGE_DB.TRAILS;

create or replace stage EXTERNAL_AWS_DLKW
url = 's3://uni-dlkw'
directory = (enable = true);
list @EXTERNAL_AWS_DLKW;

create or replace external table T_CHERRY_CREEK_TRAIL(
    my_file_name VARCHAR(100)  as (metadata$filename::varchar(100))
)
location=@EXTERNAL_AWS_DLKW
auto_refresh=true
file_format=(type=parquet)
;
--drop table T_CHERRY_CREEK_TRAIL;
create secure materialized view MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.SMV_CHERRY_CREEK_TRAIL(
	POINT_ID,
	TRAIL_NAME,
	LNG,
	LAT,
	COORD_PAIR,
    DISTANCE_TO_MELANIES
) as
select 
 value:sequence_1 as point_id,
 value:trail_name::varchar as trail_name,
 value:latitude::number(11,8) as lng,
 value:longitude::number(11,8) as lat,
 lng||' '||lat as coord_pair,
 locations.distance_to_mc(st_makepoint(lng, lat)) as distance_to_melanies
from t_cherry_creek_trail;

use role accountadmin;
use schema util_db.public;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
  SELECT
  'DLKW09' as step
  ,( select row_count
       from mels_smoothie_challenge_db.information_schema.tables
       where table_schema = 'TRAILS'
       and table_name = 'SMV_CHERRY_CREEK_TRAIL'
    ) as actual
  ,3526 as expected
  ,'Secure Materialized View Created' as description
 );

 --Iceberg
 use schema mels_smoothie_challenge_db.trails;
 CREATE OR REPLACE EXTERNAL VOLUME iceberg_external_volume
   STORAGE_LOCATIONS =
      (
         (
            NAME = 'iceberg-s3-us-west-2'
            STORAGE_PROVIDER = 'S3'
            STORAGE_BASE_URL = 's3://uni-dlkw-iceberg'
            STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::321463406630:role/dlkw_iceberg_role'
            STORAGE_AWS_EXTERNAL_ID = 'dlkw_iceberg_id'
         )
      );
DESC EXTERNAL VOLUME iceberg_external_volume;

--{"NAME":"iceberg-s3-us-west-2","STORAGE_PROVIDER":"S3","STORAGE_BASE_URL":"s3://uni-dlkw-iceberg","STORAGE_ALLOWED_LOCATIONS":["s3://uni-dlkw-iceberg/*"],"STORAGE_AWS_ROLE_ARN":"arn:aws:iam::321463406630:role/dlkw_iceberg_role","STORAGE_AWS_IAM_USER_ARN":"arn:aws:iam::802693430741:user/1a4x1000-s","STORAGE_AWS_EXTERNAL_ID":"dlkw_iceberg_id","ENCRYPTION_TYPE":"NONE","ENCRYPTION_KMS_KEY_ID":""}
create database my_iceberg_db
  catalog = 'SNOWFLAKE'
  external_volume = 'iceberg_external_volume'
  ;

set table_name = 'CCT_'||current_account();

create iceberg table identifier($table_name) (
    point_id number(10,0),
    trail_name string,
    coord_pair string,
    distance_to_melanies decimal(20,10),
    user_name string
)
  base_location = $table_name
  as
  select top 100
      point_id,
      trail_name,
      coord_pair,
      distance_to_melanies,
      current_user()
  from MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.SMV_CHERRY_CREEK_TRAIL;

  select top 10 *
  from CCT_XUB97866;