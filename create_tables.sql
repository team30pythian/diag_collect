----------------------------------------------------------
-- 
-- SQL to install DIAG_COLLECT schema - tables
--
----------------------------------------------------------


-- Meta data table for configuration

CREATE TABLE event_threshold ( 
        event_name            VARCHAR2(64)
      , event_type            VARCHAR2(64)
      , event_threshold_type  VARCHAR2(30)
      , event_threshold_value VARCHAR2(100)
) TABLESPACE diag_collect_ts;

CREATE INDEX event_threshhold_idx ON diag_collect.event_threshold( EVENT_NAME ) TABLESPACE diag_collect_ts;



-- Collector sequence 

CREATE SEQUENCE collect_seq;


-- Collector snap reference table

CREATE TABLE collect_snaps (
        collect_id   NUMBER
      , collect_time TIMESTAMP
      , purgable     CHAR(1)
)
/

ALTER TABLE collect_snaps ADD CONSTRAINT collect_snaps_pk PRIMARY KEY ( collect_id );


-- Collector session table

CREATE TABLE collect_sessions
AS
SELECT 1 collect_id
     , s.*
  FROM gv$session s
 WHERE 1=0
/

ALTER TABLE collect_sessions ADD CONSTRAINT collect_sessions_pk PRIMARY KEY (collect_id,inst_id,sid);

ALTER TABLE collect_sessions ADD CONSTRAINT collect_session_fk FOREIGN KEY ( collect_id ) REFERENCES collect_snaps ( collect_id ) ON DELETE CASCADE;


-- Collector SQL table

CREATE TABLE collect_sql
AS
SELECT *
  FROM gv$sql
 WHERE 1=0
/

ALTER TABLE collect_sql ADD CONSTRAINT collect_sql_pk PRIMARY KEY ( sql_id, plan_hash_value );


-- Collector SQL plan table

CREATE TABLE collect_sql_plans 
AS
SELECT *
  FROM gv$sql_plan
 WHERE 1=0
/

CREATE INDEX collect_sql_plans_idx ON collect_sql_plans ( sql_id, plan_hash_value );

ALTER TABLE collect_sql_plans ADD CONSTRAINT collect_sql_plan_fk FOREIGN KEY ( sql_id, plan_hash_value ) REFERENCES collect_sql ( sql_id , plan_hash_value );


-- Collector Session Stats table

CREATE TABLE collect_session_stats
AS
SELECT 1 collect_id
     , s.*
  FROM gv$sesstat s
 WHERE 1=0
/

ALTER TABLE collect_session_stats ADD CONSTRAINT collect_session_stats_pk PRIMARY KEY ( collect_id, inst_id , sid , statistic# );

ALTER TABLE collect_session_stats ADD CONSTRAINT collect_session_stats_fk FOREIGN KEY ( collect_id, inst_id , sid ) REFERENCES collect_sessions ( collect_id,inst_id,sid ) ON DELETE CASCADE;


-- Collector Session Events table

CREATE TABLE collect_session_events
AS
SELECT 1 collect_id
     , s.*
  FROM gv$session_event s
 WHERE 1=0
/

ALTER TABLE collect_session_events ADD CONSTRAINT collect_session_events_pk PRIMARY KEY ( collect_id , inst_id , sid , event );

ALTER TABLE collect_session_events ADD CONSTRAINT collect_session_events_fk FOREIGN KEY ( collect_id, inst_id , sid ) REFERENCES collect_sessions ( collect_id,inst_id,sid ) ON DELETE CASCADE;

