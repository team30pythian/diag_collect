----------------------------------------------------------
-- 
-- SQL to install DIAG_COLLECT schema - packages etc
-- 
-- Version 1.0         Create 11 Oct 2017 - Luke
--
-- Version 1.1         Added on 13 Nov 2017 - Luke
--                     Added procedures
--                       collect_latchholders
--                       collect_mutex_sleep_history
--
----------------------------------------------------------

CREATE OR REPLACE PACKAGE diag_collect.collector
AS
        CheckJobName VARCHAR2(30) := 'DIAG_COLLECT_CHECK';
        PurgeJobName VARCHAR2(30) := 'DIAG_COLLECT_PURGE';
        
        FUNCTION check_sessions
        RETURN NUMBER;
        
        PROCEDURE check_sessions;
        
        PROCEDURE collect_data;
        
        PROCEDURE purge_data (
                  KeepDays NUMBER DEFAULT 60
        );
        
        PROCEDURE create_jobs (
                  CheckIntervalSecs NUMBER  DEFAULT 60
                , PurgeIntervalDays NUMBER  DEFAULT 60
                , CheckJob          BOOLEAN DEFAULT TRUE
                , PurgeJob          BOOLEAN DEFAULT TRUE
        );
        
        PROCEDURE enable_jobs (
                  CheckJob BOOLEAN DEFAULT TRUE
                , PurgeJob BOOLEAN DEFAULT TRUE
        );
        
        PROCEDURE disable_jobs (
                  CheckJob BOOLEAN DEFAULT TRUE
                , PurgeJob BOOLEAN DEFAULT TRUE
        );
        
        PROCEDURE drop_jobs (
                  CheckJob BOOLEAN DEFAULT TRUE
                , PurgeJob BOOLEAN DEFAULT TRUE
        );
END;
/


CREATE OR REPLACE PACKAGE BODY diag_collect.collector
AS
        ObjCount NUMBER;
        
        FUNCTION check_sessions
        RETURN NUMBER
        IS
                SessionCount NUMBER;
        BEGIN
                SELECT session_count
                  INTO SessionCount
                  FROM check_sessions;

                
                RETURN SessionCount;
        END check_sessions;

        PROCEDURE check_sessions
        IS
        BEGIN
                IF check_sessions > 0 
                THEN
                        collect_data;
                END IF;
        END check_sessions;

        FUNCTION collect_snap
        RETURN NUMBER
        IS
                CollectID collect_snaps.collect_id%TYPE;
        BEGIN
                INSERT INTO collect_snaps (
                          collect_id
                        , collect_time
                        , purgable
                ) VALUES (
                          collect_seq.nextval
                        , systimestamp
                        , 'Y'
                ) RETURNING collect_id INTO CollectID;
                
                RETURN CollectID;
        END collect_snap;
        
        PROCEDURE collect_sessions (
                  CollectID collect_snaps.collect_id%TYPE
        ) IS
        BEGIN
                -- 11.2.0.4
                
                INSERT INTO collect_sessions (
                          COLLECT_ID
                        , INST_ID
                        , SADDR
                        , SID
                        , SERIAL#
                        , AUDSID
                        , PADDR
                        , USER#
                        , USERNAME
                        , COMMAND
                        , OWNERID
                        , TADDR
                        , LOCKWAIT
                        , STATUS
                        , SERVER
                        , SCHEMA#
                        , SCHEMANAME
                        , OSUSER
                        , PROCESS
                        , MACHINE
                        , PORT
                        , TERMINAL
                        , PROGRAM
                        , TYPE
                        , SQL_ADDRESS
                        , SQL_HASH_VALUE
                        , SQL_ID
                        , SQL_CHILD_NUMBER
                        , SQL_EXEC_START
                        , SQL_EXEC_ID
                        , PREV_SQL_ADDR
                        , PREV_HASH_VALUE
                        , PREV_SQL_ID
                        , PREV_CHILD_NUMBER
                        , PREV_EXEC_START
                        , PREV_EXEC_ID
                        , PLSQL_ENTRY_OBJECT_ID
                        , PLSQL_ENTRY_SUBPROGRAM_ID
                        , PLSQL_OBJECT_ID
                        , PLSQL_SUBPROGRAM_ID
                        , MODULE
                        , MODULE_HASH
                        , ACTION
                        , ACTION_HASH
                        , CLIENT_INFO
                        , FIXED_TABLE_SEQUENCE
                        , ROW_WAIT_OBJ#
                        , ROW_WAIT_FILE#
                        , ROW_WAIT_BLOCK#
                        , ROW_WAIT_ROW#
                        , TOP_LEVEL_CALL#
                        , LOGON_TIME
                        , LAST_CALL_ET
                        , PDML_ENABLED
                        , FAILOVER_TYPE
                        , FAILOVER_METHOD
                        , FAILED_OVER
                        , RESOURCE_CONSUMER_GROUP
                        , PDML_STATUS
                        , PDDL_STATUS
                        , PQ_STATUS
                        , CURRENT_QUEUE_DURATION
                        , CLIENT_IDENTIFIER
                        , BLOCKING_SESSION_STATUS
                        , BLOCKING_INSTANCE
                        , BLOCKING_SESSION
                        , FINAL_BLOCKING_SESSION_STATUS
                        , FINAL_BLOCKING_INSTANCE
                        , FINAL_BLOCKING_SESSION
                        , SEQ#
                        , EVENT#
                        , EVENT
                        , P1TEXT
                        , P1
                        , P1RAW
                        , P2TEXT
                        , P2
                        , P2RAW
                        , P3TEXT
                        , P3
                        , P3RAW
                        , WAIT_CLASS_ID
                        , WAIT_CLASS#
                        , WAIT_CLASS
                        , WAIT_TIME
                        , SECONDS_IN_WAIT
                        , STATE
                        , WAIT_TIME_MICRO
                        , TIME_REMAINING_MICRO
                        , TIME_SINCE_LAST_WAIT_MICRO
                        , SERVICE_NAME
                        , SQL_TRACE
                        , SQL_TRACE_WAITS
                        , SQL_TRACE_BINDS
                        , SQL_TRACE_PLAN_STATS
                        , SESSION_EDITION_ID
                        , CREATOR_ADDR
                        , CREATOR_SERIAL#
                        , ECID
                )
                SELECT    CollectID
                        , INST_ID
                        , SADDR
                        , SID
                        , SERIAL#
                        , AUDSID
                        , PADDR
                        , USER#
                        , USERNAME
                        , COMMAND
                        , OWNERID
                        , TADDR
                        , LOCKWAIT
                        , STATUS
                        , SERVER
                        , SCHEMA#
                        , SCHEMANAME
                        , OSUSER
                        , PROCESS
                        , MACHINE
                        , PORT
                        , TERMINAL
                        , PROGRAM
                        , TYPE
                        , SQL_ADDRESS
                        , SQL_HASH_VALUE
                        , SQL_ID
                        , SQL_CHILD_NUMBER
                        , SQL_EXEC_START
                        , SQL_EXEC_ID
                        , PREV_SQL_ADDR
                        , PREV_HASH_VALUE
                        , PREV_SQL_ID
                        , PREV_CHILD_NUMBER
                        , PREV_EXEC_START
                        , PREV_EXEC_ID
                        , PLSQL_ENTRY_OBJECT_ID
                        , PLSQL_ENTRY_SUBPROGRAM_ID
                        , PLSQL_OBJECT_ID
                        , PLSQL_SUBPROGRAM_ID
                        , MODULE
                        , MODULE_HASH
                        , ACTION
                        , ACTION_HASH
                        , CLIENT_INFO
                        , FIXED_TABLE_SEQUENCE
                        , ROW_WAIT_OBJ#
                        , ROW_WAIT_FILE#
                        , ROW_WAIT_BLOCK#
                        , ROW_WAIT_ROW#
                        , TOP_LEVEL_CALL#
                        , LOGON_TIME
                        , LAST_CALL_ET
                        , PDML_ENABLED
                        , FAILOVER_TYPE
                        , FAILOVER_METHOD
                        , FAILED_OVER
                        , RESOURCE_CONSUMER_GROUP
                        , PDML_STATUS
                        , PDDL_STATUS
                        , PQ_STATUS
                        , CURRENT_QUEUE_DURATION
                        , CLIENT_IDENTIFIER
                        , BLOCKING_SESSION_STATUS
                        , BLOCKING_INSTANCE
                        , BLOCKING_SESSION
                        , FINAL_BLOCKING_SESSION_STATUS
                        , FINAL_BLOCKING_INSTANCE
                        , FINAL_BLOCKING_SESSION
                        , SEQ#
                        , EVENT#
                        , EVENT
                        , P1TEXT
                        , P1
                        , P1RAW
                        , P2TEXT
                        , P2
                        , P2RAW
                        , P3TEXT
                        , P3
                        , P3RAW
                        , WAIT_CLASS_ID
                        , WAIT_CLASS#
                        , WAIT_CLASS
                        , WAIT_TIME
                        , SECONDS_IN_WAIT
                        , STATE
                        , WAIT_TIME_MICRO
                        , TIME_REMAINING_MICRO
                        , TIME_SINCE_LAST_WAIT_MICRO
                        , SERVICE_NAME
                        , SQL_TRACE
                        , SQL_TRACE_WAITS
                        , SQL_TRACE_BINDS
                        , SQL_TRACE_PLAN_STATS
                        , SESSION_EDITION_ID
                        , CREATOR_ADDR
                        , CREATOR_SERIAL#
                        , ECID
                  FROM  gv$session;
        END collect_sessions;

        PROCEDURE collect_sql (
                  CollectID collect_snaps.collect_id%TYPE
        ) IS
        BEGIN
                -- 11.2.0.4
                
                FOR SQLRec in ( 
                                  SELECT  INST_ID
                                        , SQL_TEXT 
                                        , SQL_FULLTEXT 
                                        , SQL_ID 
                                        , SHARABLE_MEM 
                                        , PERSISTENT_MEM 
                                        , RUNTIME_MEM
                                        , SORTS
                                        , LOADED_VERSIONS
                                        , OPEN_VERSIONS
                                        , USERS_OPENING
                                        , FETCHES
                                        , EXECUTIONS 
                                        , PX_SERVERS_EXECUTIONS
                                        , END_OF_FETCH_COUNT 
                                        , USERS_EXECUTING
                                        , LOADS
                                        , FIRST_LOAD_TIME
                                        , INVALIDATIONS
                                        , PARSE_CALLS
                                        , DISK_READS 
                                        , DIRECT_WRITES
                                        , BUFFER_GETS
                                        , APPLICATION_WAIT_TIME
                                        , CONCURRENCY_WAIT_TIME
                                        , CLUSTER_WAIT_TIME
                                        , USER_IO_WAIT_TIME
                                        , PLSQL_EXEC_TIME
                                        , JAVA_EXEC_TIME 
                                        , ROWS_PROCESSED 
                                        , COMMAND_TYPE 
                                        , OPTIMIZER_MODE 
                                        , OPTIMIZER_COST 
                                        , OPTIMIZER_ENV
                                        , OPTIMIZER_ENV_HASH_VALUE 
                                        , PARSING_USER_ID
                                        , PARSING_SCHEMA_ID
                                        , PARSING_SCHEMA_NAME
                                        , KEPT_VERSIONS
                                        , ADDRESS
                                        , TYPE_CHK_HEAP
                                        , HASH_VALUE 
                                        , OLD_HASH_VALUE 
                                        , PLAN_HASH_VALUE
                                        , CHILD_NUMBER 
                                        , SERVICE
                                        , SERVICE_HASH 
                                        , MODULE 
                                        , MODULE_HASH
                                        , ACTION 
                                        , ACTION_HASH
                                        , SERIALIZABLE_ABORTS
                                        , OUTLINE_CATEGORY 
                                        , CPU_TIME 
                                        , ELAPSED_TIME 
                                        , OUTLINE_SID
                                        , CHILD_ADDRESS
                                        , SQLTYPE
                                        , REMOTE 
                                        , OBJECT_STATUS
                                        , LITERAL_HASH_VALUE 
                                        , LAST_LOAD_TIME 
                                        , IS_OBSOLETE
                                        , IS_BIND_SENSITIVE
                                        , IS_BIND_AWARE
                                        , IS_SHAREABLE 
                                        , CHILD_LATCH
                                        , SQL_PROFILE
                                        , SQL_PATCH
                                        , SQL_PLAN_BASELINE
                                        , PROGRAM_ID 
                                        , PROGRAM_LINE#
                                        , EXACT_MATCHING_SIGNATURE 
                                        , FORCE_MATCHING_SIGNATURE 
                                        , LAST_ACTIVE_TIME 
                                        , BIND_DATA
                                        , TYPECHECK_MEM
                                        , IO_CELL_OFFLOAD_ELIGIBLE_BYTES
                                        , IO_INTERCONNECT_BYTES 
                                        , PHYSICAL_READ_REQUESTS
                                        , PHYSICAL_READ_BYTES 
                                        , PHYSICAL_WRITE_REQUESTS 
                                        , PHYSICAL_WRITE_BYTES
                                        , OPTIMIZED_PHY_READ_REQUESTS 
                                        , LOCKED_TOTAL
                                        , PINNED_TOTAL
                                        , IO_CELL_UNCOMPRESSED_BYTES
                                        , IO_CELL_OFFLOAD_RETURNED_BYTES 
                                    FROM ( SELECT INST_ID
                                                , SQL_TEXT 
                                                , SQL_FULLTEXT 
                                                , SQL_ID 
                                                , SHARABLE_MEM 
                                                , PERSISTENT_MEM 
                                                , RUNTIME_MEM
                                                , SORTS
                                                , LOADED_VERSIONS
                                                , OPEN_VERSIONS
                                                , USERS_OPENING
                                                , FETCHES
                                                , EXECUTIONS 
                                                , PX_SERVERS_EXECUTIONS
                                                , END_OF_FETCH_COUNT 
                                                , USERS_EXECUTING
                                                , LOADS
                                                , FIRST_LOAD_TIME
                                                , INVALIDATIONS
                                                , PARSE_CALLS
                                                , DISK_READS 
                                                , DIRECT_WRITES
                                                , BUFFER_GETS
                                                , APPLICATION_WAIT_TIME
                                                , CONCURRENCY_WAIT_TIME
                                                , CLUSTER_WAIT_TIME
                                                , USER_IO_WAIT_TIME
                                                , PLSQL_EXEC_TIME
                                                , JAVA_EXEC_TIME 
                                                , ROWS_PROCESSED 
                                                , COMMAND_TYPE 
                                                , OPTIMIZER_MODE 
                                                , OPTIMIZER_COST 
                                                , OPTIMIZER_ENV
                                                , OPTIMIZER_ENV_HASH_VALUE 
                                                , PARSING_USER_ID
                                                , PARSING_SCHEMA_ID
                                                , PARSING_SCHEMA_NAME
                                                , KEPT_VERSIONS
                                                , ADDRESS
                                                , TYPE_CHK_HEAP
                                                , HASH_VALUE 
                                                , OLD_HASH_VALUE 
                                                , PLAN_HASH_VALUE
                                                , CHILD_NUMBER 
                                                , SERVICE
                                                , SERVICE_HASH 
                                                , MODULE 
                                                , MODULE_HASH
                                                , ACTION 
                                                , ACTION_HASH
                                                , SERIALIZABLE_ABORTS
                                                , OUTLINE_CATEGORY 
                                                , CPU_TIME 
                                                , ELAPSED_TIME 
                                                , OUTLINE_SID
                                                , CHILD_ADDRESS
                                                , SQLTYPE
                                                , REMOTE 
                                                , OBJECT_STATUS
                                                , LITERAL_HASH_VALUE 
                                                , LAST_LOAD_TIME 
                                                , IS_OBSOLETE
                                                , IS_BIND_SENSITIVE
                                                , IS_BIND_AWARE
                                                , IS_SHAREABLE 
                                                , CHILD_LATCH
                                                , SQL_PROFILE
                                                , SQL_PATCH
                                                , SQL_PLAN_BASELINE
                                                , PROGRAM_ID 
                                                , PROGRAM_LINE#
                                                , EXACT_MATCHING_SIGNATURE 
                                                , FORCE_MATCHING_SIGNATURE 
                                                , LAST_ACTIVE_TIME 
                                                , BIND_DATA
                                                , TYPECHECK_MEM
                                                , IO_CELL_OFFLOAD_ELIGIBLE_BYTES
                                                , IO_INTERCONNECT_BYTES 
                                                , PHYSICAL_READ_REQUESTS
                                                , PHYSICAL_READ_BYTES 
                                                , PHYSICAL_WRITE_REQUESTS 
                                                , PHYSICAL_WRITE_BYTES
                                                , OPTIMIZED_PHY_READ_REQUESTS 
                                                , LOCKED_TOTAL
                                                , PINNED_TOTAL
                                                , IO_CELL_UNCOMPRESSED_BYTES
                                                , IO_CELL_OFFLOAD_RETURNED_BYTES
                                                , ROW_NUMBER () OVER ( PARTITION BY sql_id , plan_hash_value ORDER BY inst_id, sql_id, plan_hash_value ) first_row
                                             FROM gv$sql s
                                            WHERE sql_id IN ( 
                                                              SELECT sql_id
                                                                FROM collect_sessions 
                                                               WHERE collect_id = CollectID
                                                               UNION
                                                              SELECT prev_sql_id
                                                                FROM collect_sessions
                                                               WHERE collect_id = CollectID
                                                            )
                                              AND NOT EXISTS ( 
                                                               SELECT 1
                                                                 FROM collect_sql
                                                                WHERE sql_id          = s.sql_id
                                                                  AND plan_hash_value = s.plan_hash_value
                                                             )
                                         )
                                   WHERE first_row = 1
                                )
                LOOP
                        -- 11.2.0.4
                
                        INSERT INTO collect_sql (
                                  INST_ID
                                , SQL_TEXT 
                                , SQL_FULLTEXT 
                                , SQL_ID 
                                , SHARABLE_MEM 
                                , PERSISTENT_MEM 
                                , RUNTIME_MEM
                                , SORTS
                                , LOADED_VERSIONS
                                , OPEN_VERSIONS
                                , USERS_OPENING
                                , FETCHES
                                , EXECUTIONS 
                                , PX_SERVERS_EXECUTIONS
                                , END_OF_FETCH_COUNT 
                                , USERS_EXECUTING
                                , LOADS
                                , FIRST_LOAD_TIME
                                , INVALIDATIONS
                                , PARSE_CALLS
                                , DISK_READS 
                                , DIRECT_WRITES
                                , BUFFER_GETS
                                , APPLICATION_WAIT_TIME
                                , CONCURRENCY_WAIT_TIME
                                , CLUSTER_WAIT_TIME
                                , USER_IO_WAIT_TIME
                                , PLSQL_EXEC_TIME
                                , JAVA_EXEC_TIME 
                                , ROWS_PROCESSED 
                                , COMMAND_TYPE 
                                , OPTIMIZER_MODE 
                                , OPTIMIZER_COST 
                                , OPTIMIZER_ENV
                                , OPTIMIZER_ENV_HASH_VALUE 
                                , PARSING_USER_ID
                                , PARSING_SCHEMA_ID
                                , PARSING_SCHEMA_NAME
                                , KEPT_VERSIONS
                                , ADDRESS
                                , TYPE_CHK_HEAP
                                , HASH_VALUE 
                                , OLD_HASH_VALUE 
                                , PLAN_HASH_VALUE
                                , CHILD_NUMBER 
                                , SERVICE
                                , SERVICE_HASH 
                                , MODULE 
                                , MODULE_HASH
                                , ACTION 
                                , ACTION_HASH
                                , SERIALIZABLE_ABORTS
                                , OUTLINE_CATEGORY 
                                , CPU_TIME 
                                , ELAPSED_TIME 
                                , OUTLINE_SID
                                , CHILD_ADDRESS
                                , SQLTYPE
                                , REMOTE 
                                , OBJECT_STATUS
                                , LITERAL_HASH_VALUE 
                                , LAST_LOAD_TIME 
                                , IS_OBSOLETE
                                , IS_BIND_SENSITIVE
                                , IS_BIND_AWARE
                                , IS_SHAREABLE 
                                , CHILD_LATCH
                                , SQL_PROFILE
                                , SQL_PATCH
                                , SQL_PLAN_BASELINE
                                , PROGRAM_ID 
                                , PROGRAM_LINE#
                                , EXACT_MATCHING_SIGNATURE 
                                , FORCE_MATCHING_SIGNATURE 
                                , LAST_ACTIVE_TIME 
                                , BIND_DATA
                                , TYPECHECK_MEM
                                , IO_CELL_OFFLOAD_ELIGIBLE_BYTES
                                , IO_INTERCONNECT_BYTES 
                                , PHYSICAL_READ_REQUESTS
                                , PHYSICAL_READ_BYTES 
                                , PHYSICAL_WRITE_REQUESTS 
                                , PHYSICAL_WRITE_BYTES
                                , OPTIMIZED_PHY_READ_REQUESTS 
                                , LOCKED_TOTAL
                                , PINNED_TOTAL
                                , IO_CELL_UNCOMPRESSED_BYTES
                                , IO_CELL_OFFLOAD_RETURNED_BYTES
                          ) VALUES ( 
                                  SQLRec.INST_ID
                                , SQLRec.SQL_TEXT 
                                , SQLRec.SQL_FULLTEXT 
                                , SQLRec.SQL_ID 
                                , SQLRec.SHARABLE_MEM 
                                , SQLRec.PERSISTENT_MEM 
                                , SQLRec.RUNTIME_MEM
                                , SQLRec.SORTS
                                , SQLRec.LOADED_VERSIONS
                                , SQLRec.OPEN_VERSIONS
                                , SQLRec.USERS_OPENING
                                , SQLRec.FETCHES
                                , SQLRec.EXECUTIONS 
                                , SQLRec.PX_SERVERS_EXECUTIONS
                                , SQLRec.END_OF_FETCH_COUNT 
                                , SQLRec.USERS_EXECUTING
                                , SQLRec.LOADS
                                , SQLRec.FIRST_LOAD_TIME
                                , SQLRec.INVALIDATIONS
                                , SQLRec.PARSE_CALLS
                                , SQLRec.DISK_READS 
                                , SQLRec.DIRECT_WRITES
                                , SQLRec.BUFFER_GETS
                                , SQLRec.APPLICATION_WAIT_TIME
                                , SQLRec.CONCURRENCY_WAIT_TIME
                                , SQLRec.CLUSTER_WAIT_TIME
                                , SQLRec.USER_IO_WAIT_TIME
                                , SQLRec.PLSQL_EXEC_TIME
                                , SQLRec.JAVA_EXEC_TIME 
                                , SQLRec.ROWS_PROCESSED 
                                , SQLRec.COMMAND_TYPE 
                                , SQLRec.OPTIMIZER_MODE 
                                , SQLRec.OPTIMIZER_COST 
                                , SQLRec.OPTIMIZER_ENV
                                , SQLRec.OPTIMIZER_ENV_HASH_VALUE 
                                , SQLRec.PARSING_USER_ID
                                , SQLRec.PARSING_SCHEMA_ID
                                , SQLRec.PARSING_SCHEMA_NAME
                                , SQLRec.KEPT_VERSIONS
                                , SQLRec.ADDRESS
                                , SQLRec.TYPE_CHK_HEAP
                                , SQLRec.HASH_VALUE 
                                , SQLRec.OLD_HASH_VALUE 
                                , SQLRec.PLAN_HASH_VALUE
                                , SQLRec.CHILD_NUMBER 
                                , SQLRec.SERVICE
                                , SQLRec.SERVICE_HASH 
                                , SQLRec.MODULE 
                                , SQLRec.MODULE_HASH
                                , SQLRec.ACTION 
                                , SQLRec.ACTION_HASH
                                , SQLRec.SERIALIZABLE_ABORTS
                                , SQLRec.OUTLINE_CATEGORY 
                                , SQLRec.CPU_TIME 
                                , SQLRec.ELAPSED_TIME 
                                , SQLRec.OUTLINE_SID
                                , SQLRec.CHILD_ADDRESS
                                , SQLRec.SQLTYPE
                                , SQLRec.REMOTE 
                                , SQLRec.OBJECT_STATUS
                                , SQLRec.LITERAL_HASH_VALUE 
                                , SQLRec.LAST_LOAD_TIME 
                                , SQLRec.IS_OBSOLETE
                                , SQLRec.IS_BIND_SENSITIVE
                                , SQLRec.IS_BIND_AWARE
                                , SQLRec.IS_SHAREABLE 
                                , SQLRec.CHILD_LATCH
                                , SQLRec.SQL_PROFILE
                                , SQLRec.SQL_PATCH
                                , SQLRec.SQL_PLAN_BASELINE
                                , SQLRec.PROGRAM_ID 
                                , SQLRec.PROGRAM_LINE#
                                , SQLRec.EXACT_MATCHING_SIGNATURE 
                                , SQLRec.FORCE_MATCHING_SIGNATURE 
                                , SQLRec.LAST_ACTIVE_TIME 
                                , SQLRec.BIND_DATA
                                , SQLRec.TYPECHECK_MEM
                                , SQLRec.IO_CELL_OFFLOAD_ELIGIBLE_BYTES
                                , SQLRec.IO_INTERCONNECT_BYTES 
                                , SQLRec.PHYSICAL_READ_REQUESTS
                                , SQLRec.PHYSICAL_READ_BYTES 
                                , SQLRec.PHYSICAL_WRITE_REQUESTS 
                                , SQLRec.PHYSICAL_WRITE_BYTES
                                , SQLRec.OPTIMIZED_PHY_READ_REQUESTS 
                                , SQLRec.LOCKED_TOTAL
                                , SQLRec.PINNED_TOTAL
                                , SQLRec.IO_CELL_UNCOMPRESSED_BYTES
                                , SQLRec.IO_CELL_OFFLOAD_RETURNED_BYTES 
                        );

                        INSERT INTO collect_sql_plans (
                                  INST_ID
                                , ADDRESS
                                , HASH_VALUE
                                , SQL_ID
                                , PLAN_HASH_VALUE
                                , CHILD_ADDRESS
                                , CHILD_NUMBER
                                , TIMESTAMP
                                , OPERATION
                                , OPTIONS
                                , OBJECT_NODE
                                , OBJECT#
                                , OBJECT_OWNER
                                , OBJECT_NAME
                                , OBJECT_ALIAS
                                , OBJECT_TYPE
                                , OPTIMIZER
                                , ID
                                , PARENT_ID
                                , DEPTH
                                , POSITION
                                , SEARCH_COLUMNS
                                , COST
                                , CARDINALITY
                                , BYTES
                                , OTHER_TAG
                                , PARTITION_START
                                , PARTITION_STOP
                                , PARTITION_ID
                                , OTHER
                                , DISTRIBUTION
                                , CPU_COST
                                , IO_COST
                                , TEMP_SPACE
                                , ACCESS_PREDICATES
                                , FILTER_PREDICATES
                                , PROJECTION
                                , TIME
                                , QBLOCK_NAME
                                , REMARKS
                                , OTHER_XML
                        ) SELECT  INST_ID
                                , ADDRESS
                                , HASH_VALUE
                                , SQL_ID
                                , PLAN_HASH_VALUE
                                , CHILD_ADDRESS
                                , CHILD_NUMBER
                                , TIMESTAMP
                                , OPERATION
                                , OPTIONS
                                , OBJECT_NODE
                                , OBJECT#
                                , OBJECT_OWNER
                                , OBJECT_NAME
                                , OBJECT_ALIAS
                                , OBJECT_TYPE
                                , OPTIMIZER
                                , ID
                                , PARENT_ID
                                , DEPTH
                                , POSITION
                                , SEARCH_COLUMNS
                                , COST
                                , CARDINALITY
                                , BYTES
                                , OTHER_TAG
                                , PARTITION_START
                                , PARTITION_STOP
                                , PARTITION_ID
                                , OTHER
                                , DISTRIBUTION
                                , CPU_COST
                                , IO_COST
                                , TEMP_SPACE
                                , ACCESS_PREDICATES
                                , FILTER_PREDICATES
                                , PROJECTION
                                , TIME
                                , QBLOCK_NAME
                                , REMARKS
                                , OTHER_XML
                          FROM  gv$sql_plan
                         WHERE  inst_id         = SQLRec.inst_id
                           AND  sql_id          = SQLRec.sql_id
                           AND  plan_hash_value = SQLRec.plan_hash_value
                           AND  child_number    = SQLRec.child_number
                         ORDER BY position;
                END LOOP;
        END collect_sql;
        
        PROCEDURE collect_events (
                  CollectID collect_snaps.collect_id%TYPE
        ) IS
        BEGIN
                INSERT INTO collect_session_events (
                           collect_id        
                         , inst_id           
                         , sid               
                         , event             
                         , total_waits       
                         , total_timeouts    
                         , time_waited       
                         , average_wait      
                         , max_wait          
                         , time_waited_micro 
                         , event_id          
                         , wait_class_id     
                         , wait_class#       
                         , wait_class
                )       
                SELECT     CollectID
                         , inst_id           
                         , sid               
                         , event             
                         , total_waits       
                         , total_timeouts    
                         , time_waited       
                         , average_wait      
                         , max_wait          
                         , time_waited_micro 
                         , event_id          
                         , wait_class_id     
                         , wait_class#       
                         , wait_class
                  FROM   gv$session_event
                 WHERE   (inst_id,sid) IN (
                                            SELECT inst_id
                                                 , sid 
                                              FROM collect_sessions
                                             WHERE collect_id = CollectID
                                               AND status     = 'ACTIVE'
                                          );
        END collect_events;

        PROCEDURE collect_stats (
                  CollectID collect_snaps.collect_id%TYPE
        ) IS
        BEGIN
                INSERT INTO collect_session_stats (
                           collect_id        
                         , inst_id           
                         , sid               
                         , statistic#
                         , value
                )       
                SELECT     CollectID
                         , inst_id           
                         , sid               
                         , statistic#
                         , value
                  FROM   gv$sesstat
                 WHERE   (inst_id,sid) IN (
                                            SELECT inst_id
                                                 , sid 
                                              FROM collect_sessions
                                             WHERE collect_id = CollectID
                                               AND status     = 'ACTIVE'
                                          )
                   AND   VALUE > 0;                
        END collect_stats;        

        PROCEDURE collect_latchholders (
                  CollectID collect_snaps.collect_id%TYPE
        ) IS
        BEGIN
                INSERT INTO collect_latchholders (
                           collect_id
                         , inst_id
                         , pid    
                         , sid    
                         , laddr  
                         , name   
                         , gets 
                ) 
                SELECT     CollectID
                         , inst_id
                         , pid    
                         , sid    
                         , laddr  
                         , name   
                         , gets 
                  FROM   gv$latchholder;
        END collect_latchholders;
                        
        PROCEDURE collect_mutex_sleep_history (
                  CollectID collect_snaps.collect_id%TYPE
        ) IS
        BEGIN
                INSERT INTO collect_mutex_sleep_history (
                           collect_id
                         , inst_id           
                         , mutex_identifier  
                         , sleep_timestamp   
                         , mutex_type        
                         , gets              
                         , sleeps            
                         , requesting_session
                         , blocking_session  
                         , location          
                         , mutex_value       
                         , p1                
                         , p1raw             
                         , p2                
                         , p3                
                         , p4                
                         , p5 
                )
                SELECT     CollectID
                         , inst_id           
                         , mutex_identifier  
                         , sleep_timestamp   
                         , mutex_type        
                         , gets              
                         , sleeps            
                         , requesting_session
                         , blocking_session  
                         , location          
                         , mutex_value       
                         , p1                
                         , p1raw             
                         , p2                
                         , p3                
                         , p4                
                         , p5 
                  FROM   gv$mutex_sleep_history;
        END collect_mutex_sleep_history;
        
        PROCEDURE collect_data
        IS
                  CollectID collect_snaps.collect_id%TYPE;
        BEGIN 
                -- Get the collect ID 
                
                CollectID := collect_snap;
                
                collect_sessions(CollectID);
                
                collect_sql(CollectID);

                collect_events(CollectID);

                collect_stats(CollectID);

                collect_latchholders(CollectID);

                collect_mutex_sleep_history(CollectID);

                COMMIT;
        END collect_data;
        
        PROCEDURE delete_snaps (
                  KeepDays NUMBER
        ) IS 
        BEGIN
                DELETE FROM collect_snaps
                WHERE  collect_time < SYSTIMESTAMP - KeepDays;
        END delete_snaps;
        
        PROCEDURE delete_sql
        IS
        BEGIN
                DELETE FROM collect_sql
                WHERE  sql_id NOT IN ( 
                                       SELECT DISTINCT sql_id
                                         FROM collect_sessions
                                     );
        END delete_sql;
        
        PROCEDURE purge_data (
                  KeepDays NUMBER DEFAULT 60
        ) IS
        BEGIN
                delete_snaps(KeepDays);
                
                delete_sql;

                COMMIT;
        END purge_data;

        PROCEDURE create_jobs (
                  CheckIntervalSecs NUMBER  DEFAULT 60
                , PurgeIntervalDays NUMBER  DEFAULT 60
                , CheckJob          BOOLEAN DEFAULT TRUE
                , PurgeJob          BOOLEAN DEFAULT TRUE
        ) IS
        BEGIN
                IF CheckJob 
                THEN
                        SELECT COUNT(*)
                          INTO ObjCount
                          FROM user_scheduler_jobs
                         WHERE job_name = CheckJobName;
                         
                        IF ObjCount = 0
                        THEN
                                DBMS_SCHEDULER.CREATE_JOB (
                                          job_name        => CheckJobName
                                        , job_type        => 'PLSQL_BLOCK'
                                        , job_action      => 'BEGIN collector.check_sessions; END;'
                                        , start_date      => SYSDATE
                                        , repeat_interval => 'FREQ=SECONDLY;INTERVAL='||TO_CHAR(CheckIntervalSecs)
                                        , enabled         =>  TRUE
                                        , comments        => 'Check sessions for wait events'
                                );
                        END IF;
                END IF;
                
                IF PurgeJob 
                THEN
                        SELECT COUNT(*)
                          INTO ObjCount
                          FROM user_scheduler_jobs
                         WHERE job_name = PurgeJobName;
                         
                        IF ObjCount = 0
                        THEN
                                DBMS_SCHEDULER.CREATE_JOB (
                                          job_name        => PurgeJobName
                                        , job_type        => 'PLSQL_BLOCK'
                                        , job_action      => 'BEGIN collector.purge_data('||TO_CHAR(PurgeIntervalDays)||'); END;'
                                        , start_date      => TRUNC(SYSDATE)+1
                                        , repeat_interval => 'FREQ=DAILY'
                                        , enabled         =>  TRUE
                                        , comments        => 'Purge DIAG_COLLECT data'
                                );
                        END IF;
                END IF;
                
                COMMIT;
        END create_jobs;
        
        PROCEDURE enable_jobs (
                  CheckJob BOOLEAN DEFAULT TRUE
                , PurgeJob BOOLEAN DEFAULT TRUE
        ) IS
        BEGIN
                IF CheckJob
                THEN
                        DBMS_SCHEDULER.ENABLE(Name => CheckJobName);
                END IF;

                IF PurgeJob
                THEN
                        DBMS_SCHEDULER.ENABLE(Name => PurgeJobName);
                END IF;
                
                COMMIT;
        END enable_jobs;
        
        PROCEDURE disable_jobs (
                  CheckJob BOOLEAN DEFAULT TRUE
                , PurgeJob BOOLEAN DEFAULT TRUE
        ) IS
        BEGIN
                IF CheckJob
                THEN
                        DBMS_SCHEDULER.DISABLE(name => CheckJobName);
                END IF;

                IF PurgeJob
                THEN
                        DBMS_SCHEDULER.DISABLE(name => PurgeJobName);
                END IF;
                
                COMMIT;
        END disable_jobs;
        
        PROCEDURE drop_jobs(
                  CheckJob BOOLEAN DEFAULT TRUE
                , PurgeJob BOOLEAN DEFAULT TRUE
        ) IS
        BEGIN
                IF CheckJob
                THEN
                        DBMS_SCHEDULER.DROP_JOB(job_name => CheckJobName);
                END IF;

                IF PurgeJob
                THEN
                        DBMS_SCHEDULER.DROP_JOB(job_name => PurgeJobName);
                END IF;
                
                COMMIT;
        END drop_jobs;

END;
/

