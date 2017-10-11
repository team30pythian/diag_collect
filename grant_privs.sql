----------------------------------------------------------
-- 
-- SQL to grant privileges to DIAG_COLLECT 
-- 
----------------------------------------------------------

set feed 5
set pages 500
set lines 200
set head on
set verify off

GRANT CREATE SESSION   TO diag_collect;
GRANT CREATE TABLE     TO diag_collect;
GRANT CREATE VIEW      TO diag_collect;
GRANT CREATE PROCEDURE TO diag_collect;
GRANT CREATE SEQUENCE  TO diag_collect;
GRANT CREATE JOB       TO diag_collect;

GRANT SELECT ON sys.v_$event_name     TO diag_collect;
GRANT SELECT ON sys.v_$statname       TO diag_collect;
GRANT SELECT ON sys.gv_$session       TO diag_collect;
GRANT SELECT ON sys.gv_$session_wait  TO diag_collect;
GRANT SELECT ON sys.gv_$sql           TO diag_collect;
GRANT SELECT ON sys.gv_$sql_plan      TO diag_collect;
GRANT SELECT ON sys.gv_$sesstat       TO diag_collect;
GRANT SELECT ON sys.gv_$session_event TO diag_collect;

