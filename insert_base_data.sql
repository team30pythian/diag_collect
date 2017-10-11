----------------------------------------------------------
--
-- SQL to populate DIAG_COLLECT schema
-- 
----------------------------------------------------------

DELETE FROM event_threshold;

INSERT INTO event_threshold (
        EVENT_NAME
      , EVENT_TYPE
) SELECT NAME
       , UPPER(WAIT_CLASS)
    FROM v$event_name
   WHERE wait_class = 'Idle';

prompt Setting default number of sessions to 5

INSERT INTO event_threshold (
        EVENT_NAME
      , EVENT_TYPE
      , EVENT_THRESHOLD_TYPE
      , EVENT_THRESHOLD_VALUE
) VALUES (
        'DEFAULT'
      , 'DEFAULT'
      , 'SESSION_THRESHOLD'
      , '5'
);

prompt Setting default number of seconds in wait to 45

INSERT INTO event_threshold (
        EVENT_NAME
      , EVENT_TYPE
      , EVENT_THRESHOLD_TYPE
      , EVENT_THRESHOLD_VALUE
) VALUES (
        'DEFAULT'
      , 'DEFAULT'
      , 'TIME_THRESHOLD'
      , '45'
);
   
COMMIT;
