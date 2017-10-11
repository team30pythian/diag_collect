----------------------------------------------------------
-- 
-- SQL to install DIAG_COLLECT schema - views
-- 
----------------------------------------------------------

CREATE OR REPLACE VIEW check_sessions 
AS
SELECT NVL(sum(event_count),0) session_count
  FROM event_threshold de
     , (
          SELECT sw.event
               , count(*) event_count
            FROM                 event_threshold default_event 
               ,                 gv$session_wait sw                              
                 LEFT OUTER JOIN event_threshold event
                   ON event.event_name           = sw.event
                  AND event.event_threshold_type = 'TIME_THRESHOLD'
           WHERE sw.event NOT IN ( SELECT event_name
                                     FROM event_threshold
                                    WHERE event_type = 'IDLE'
                                 )
             AND default_event.event_name           = 'DEFAULT'
             AND default_event.event_threshold_type = 'TIME_THRESHOLD'
             AND sw.state                           = 'WAITING'
             AND sw.wait_time_micro                >= TO_NUMBER(NVL(event.event_threshold_value,default_event.event_threshold_value))*1000000
          GROUP BY sw.event
        ) s
        LEFT OUTER JOIN event_threshold e
          ON e.event_name           = s.event
         AND e.event_threshold_type = 'SESSION_THRESHOLD'
 WHERE de.event_name           = 'DEFAULT'
   AND de.event_threshold_type = 'SESSION_THRESHOLD'
   AND s.event_count          >= TO_NUMBER(NVL(e.event_threshold_value,de.event_threshold_value));
