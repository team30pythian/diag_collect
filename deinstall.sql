----------------------------------------------------------
-- SQL to deinstall DIAG_COLLECT schema
-- 
-- Need to create 
--   drop user
--   drop tablespace
--
----------------------------------------------------------

-- Ensure we are the SYS schema

set pages 0
set head off
set lines 200
set feed off
set term off

spool exit.sql
SELECT 'prompt ***** ERROR ****** - User '||sys_context('USERENV','SESSION_USER')||' is not SYS.  Must be logged into SYS to deinstall'
  FROM dual
 WHERE sys_context('USERENV','SESSION_USER') != 'SYS'
UNION ALL
SELECT 'exit'
  FROM dual
 WHERE sys_context('USERENV','SESSION_USER') != 'SYS'
/
spool off

set term on

@exit

set feed 5
set pages 500
set head on

DROP USER diag_collect CASCADE;

DROP TABLESPACE diag_collect_ts INCLUDING CONTENTS AND DATAFILES;

exit
