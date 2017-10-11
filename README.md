# diag_collect

To install run @install 

It will create a user called DIAG_COLLECT 
and a tablespace on an ASM volumne called DIAG_COLLECT

Then it will set up the tables, views, sequences, packages and jobs

Defaults are 5 sessions on any event with waits longs than 45 seconds before diagnostics are gathered.

Check job runs every 60 seconds.

Purge job run daily and purge data older than 60 days.

If a data collection is initiated then the following is collected

All gv$session data
All gv$sql data for SQL in any sessions current SQL_ID or PREV_SQL_ID
All gv$sql_plan data for any SQL captured
All gv$session_event data for any ACTIVE sessions
All gv$sesstat data for aby ACTIVE sessions that have values > 0

The schema that owns all the data is called DIAG_COLLECT and all tables are stored in a tablespace DIAG_COLLECT.

Table names are

EVENT_THRESHOLD
COLLECT_SNAPS
COLLECT_SESSIONS
COLLECT_SQL
COLLECT_SQL_PLANS
COLLECT_SESSION_STATS
COLLECT_SESSION_EVENTS

View names

CHECK_SESSIONS

Package

COLLECTOR

FUNCTION CHECK_SESSIONS RETURNS NUMBER

PROCEDURE CHECK_SESSIONS

PROCEDURE COLLECT_DATA

PROCEDURE CREATE_JOBS
Argument Name Type In/Out Default?
------------------------------ ----------------------- ------ --------
CHECKINTERVALSECS NUMBER IN DEFAULT
PURGEINTERVALDAYS NUMBER IN DEFAULT
CHECKJOB BOOLEAN IN DEFAULT
PURGEJOB BOOLEAN IN DEFAULT

PROCEDURE DISABLE_JOBS
Argument Name Type In/Out Default?
------------------------------ ----------------------- ------ --------
CHECKJOB BOOLEAN IN DEFAULT
PURGEJOB BOOLEAN IN DEFAULT

PROCEDURE DROP_JOBS
Argument Name Type In/Out Default?
------------------------------ ----------------------- ------ --------
CHECKJOB BOOLEAN IN DEFAULT
PURGEJOB BOOLEAN IN DEFAULT

PROCEDURE ENABLE_JOBS
Argument Name Type In/Out Default?
------------------------------ ----------------------- ------ --------
CHECKJOB BOOLEAN IN DEFAULT
PURGEJOB BOOLEAN IN DEFAULT

PROCEDURE PURGE_DATA
Argument Name Type In/Out Default?
------------------------------ ----------------------- ------ --------
KEEPDAYS NUMBER IN DEFAULT
