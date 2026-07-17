-- Make sure everything you create is owned by the SYSADMIN role.
USE ROLE SYSADMIN;
-- Create a database called MELS_SMOOTHIE_CHALLENGE_DB.
create or replace database MELS_SMOOTHIE_CHALLENGE_DB;
-- Drop the PUBLIC schema
DROP SCHEMA MELS_SMOOTHIE_CHALLENGE_DB.PUBLIC;
-- Add a schema named TRAILS
CREATE OR REPLACE SCHEMA MELS_SMOOTHIE_CHALLENGE_DB.TRAILS;
USE SCHEMA MELS_SMOOTHIE_CHALLENGE_DB.TRAILS;
-- Add an internal named stage called TRAILS_GEOJSON
CREATE OR REPLACE STAGE TRAILS_GEOJSON
    DIRECTORY = (ENABLE = TRUE);
-- Add an internal named stage called TRAILS_PARQUET
CREATE OR REPLACE STAGE TRAILS_PARQUET
    DIRECTORY = (ENABLE = TRUE);
SHOW STAGES IN SCHEMA MELS_SMOOTHIE_CHALLENGE_DB.TRAILS;

-- Create file format for JSON files
CREATE OR REPLACE FILE FORMAT FF_JSON
    TYPE = JSON
;
CREATE OR REPLACE FILE FORMAT FF_PARQUET
    TYPE = PARQUET
;
LIST @TRAILS_PARQUET;
SELECT count(*)
FROM @TRAILS_PARQUET
(FILE_FORMAT => FF_PARQUET)
;
USE ROLE ACCOUNTADMIN;
USE SCHEMA UTIL_DB.PUBLIC;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
'DLKW05' as step
 ,( select sum(tally)
   from
     (select count(*) as tally
      from mels_smoothie_challenge_db.information_schema.stages 
      union all
      select count(*) as tally
      from mels_smoothie_challenge_db.information_schema.file_formats)) as actual
 ,4 as expected
 ,'Camila\'s Trail Data is Ready to Query' as description
 ); 