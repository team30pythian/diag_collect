col job_action for a40
col repeat_interval for a30
col start_date for a35

set lines 200
set head on
set feed 5
set pages 500

SELECT job_name
     , job_action
     , enabled
     , start_date
     , repeat_interval
  FROM user_scheduler_jobs
 WHERE job_name LIKE 'DIAG_COLLECT%';
