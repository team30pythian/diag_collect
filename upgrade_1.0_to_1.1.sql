----------------------------------------------------------
-- 
-- SQL to upgrade from Version 1.0 to 1.1
-- 
-- History
-- 
---------------------------------------------------------

set feed 5
set pages 500
set lines 200
set head on
set verify off

GRANT SELECT ON sys.gv_$latchholder         TO diag_collect;
GRANT SELECT ON sys.gv_$mutex_sleep_history TO diag_collect;


-- Adding delete cascade for SQL Plan table

ALTER TABLE diag_collect.collect_sql_plans DROP CONSTRAINT collect_sql_plan_fk;
ALTER TABLE diag_collect.collect_sql_plans ADD CONSTRAINT collect_sql_plan_fk FOREIGN KEY ( sql_id, plan_hash_value ) REFERENCES diag_collect.collect_sql ( sql_id , plan_hash_value ) ON DELETE CASCADE;

-- Collector Latch Holder table

CREATE TABLE diag_collect.collect_latchholders
AS
SELECT 1 collect_id
     , s.*
  FROM gv$latchholder s
 WHERE 1=0
/

ALTER TABLE diag_collect.collect_latchholders ADD CONSTRAINT collect_latchholders_pk PRIMARY KEY ( collect_id , inst_id , pid , sid );

ALTER TABLE diag_collect.collect_latchholders ADD CONSTRAINT collect_latchholders_fk FOREIGN KEY ( collect_id ) REFERENCES diag_collect.collect_snaps ( collect_id ) ON DELETE CASCADE;

-- Collector Mutex Sleep History

CREATE TABLE diag_collect.collect_mutex_sleep_history
AS
SELECT 1 collect_id
     , s.*
  FROM gv$mutex_sleep_history s
 WHERE 1=0
/

CREATE INDEX diag_collect.collect_mutex_sleep_history_ix ON diag_collect.collect_mutex_sleep_history ( collect_id , inst_id , mutex_identifier , sleep_timestamp );

ALTER TABLE diag_collect.collect_mutex_sleep_history ADD CONSTRAINT collect_mutex_sleep_history_fk FOREIGN KEY ( collect_id ) REFERENCES diag_collect.collect_snaps ( collect_id ) ON DELETE CASCADE;

@@create_procs

