----------------------------------------------------------
-- SQL to install DIAG_COLLECT schema
-- 
-- Need to create 
--   a new tablespace
--   a user
--   grant some privileges
--   create objects
--
----------------------------------------------------------

-- Ensure we are the SYS schema

set pages 0
set head off
set lines 200
set feed off
set term off

spool exit.sql
SELECT 'prompt ***** ERROR ****** - User '||sys_context('USERENV','SESSION_USER')||' is not SYS.  Must be logged into SYS to install'
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

set pages 500
set head on
set verify off

accept OraPassWd prompt 'Enter password for DIAG_COLLECT user               : '

select '+'||name asm_disk_group
from  v$asm_diskgroup
order by name
/

accept DFName prompt    'Enter datafile name for tablespace DIAG_COLLECT_TS : '

set feed 5

spool install

CREATE TABLESPACE diag_collect_ts DATAFILE '&DFName' SIZE 100M autoextend on next 100M maxsize 2G;

CREATE USER diag_collect identified by "&OraPassWd"
  DEFAULT TABLESPACE diag_collect_ts
  QUOTA UNLIMITED ON diag_collect_ts
/

@grant_privs.sql

connect diag_collect/&OraPassWd

@create_tables

@create_views

@create_procs

@insert_base_data

exec collector.create_jobs

@check_jobs

spool off

prompt Installation Complete

show user
