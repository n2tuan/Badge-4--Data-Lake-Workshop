use role SYSADMIN;
use schema MELS_SMOOTHIE_CHALLENGE_DB.TRAILS;
create or replace view CHERRY_CREEK_TRAIL as (
    select $1:sequence_1 as point_id, 
    $1:trail_name::VARCHAR as trail_name,
    $1:latitude::NUMBER(8,5) AS lng, 
    $1:longitude::NUMBER(8,5) as lat,
    lng || ' ' || lat as coord_pair
    from @TRAILS_PARQUET
    (FILE_FORMAT => FF_PARQUET)
    order by point_id    
)
;
select top 100
lng || ' ' || lat as coord_pair,
'POINT(' || coord_pair || ')' as trail_point
from CHERRY_CREEK_TRAIL;
select 
'LINESTRING(' || listagg(coord_pair,',') within group (order by point_id) || ')'
from CHERRY_CREEK_TRAIL
where point_id < 2450
group by trail_name;
create or replace view DENVER_AREA_TRAILS as 
select
$1:features[0]:properties:Name::string as feature_name
,$1:features[0]:geometry:coordinates::string as feature_coordinates
,$1:features[0]:geometry::string as geometry
,$1:features[0]:properties::string as feature_properties
,$1:crs:properties:name::string as specs
,$1 as whole_object
from @trails_geojson (file_format => ff_json);

use role accountadmin;
use schema util_db.public;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
'DLKW06' as step
 ,( select count(*) as tally
      from mels_smoothie_challenge_db.information_schema.views 
      where table_name in ('CHERRY_CREEK_TRAIL','DENVER_AREA_TRAILS')) as actual
 ,2 as expected
 ,'Mel\'s views on the geospatial data from Camila' as description
 ); 