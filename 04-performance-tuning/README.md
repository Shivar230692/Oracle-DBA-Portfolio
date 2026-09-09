\# Oracle Performance Tuning



\## Overview



This project demonstrates practical Oracle Database performance

monitoring and troubleshooting techniques using SQL and Oracle

dynamic performance views.



The objective is to identify potential performance bottlenecks,

investigate expensive SQL statements, analyze execution plans,

review indexes and optimizer statistics, investigate wait events,

and monitor tablespace utilization.



This project represents a read-only performance investigation

workflow that can be used as a starting point for Oracle DBA

health checks and troubleshooting.



\---



\## DBA Skills Demonstrated



\- Oracle Database Performance Monitoring

\- Session Monitoring

\- SQL Performance Analysis

\- CPU and Elapsed-Time Analysis

\- Logical and Physical I/O Analysis

\- SQL\_ID Investigation

\- Execution Plan Analysis

\- Index Analysis

\- Optimizer Statistics Review

\- Wait Event Analysis

\- Blocking Session Investigation

\- Tablespace Monitoring

\- Capacity Monitoring

\- DBA Troubleshooting Methodology

\- Performance Reporting



\---



\## Project Structure



```text

04-performance-tuning/

│

├── README.md

├── 01-session-monitoring.sql

├── 02-top-sql.sql

├── 03-execution-plans.sql

├── 04-index-analysis.sql

├── 05-wait-events.sql

├── 06-tablespace-performance.sql

└── 07-performance-report.sql



1\. Session Monitoring



File: 01-session-monitoring.sql



Purpose



Monitor active database sessions and identify sessions that may require further performance investigation.



Key Oracle Views

* V$SESSION
* V$SESSTAT
* V$STATNAME



Investigation Areas

* Active sessions
* Waiting sessions
* CPU-consuming sessions
* Long-running SQL
* Blocking sessions
* Logical reads
* SQL\_ID identification



Example DBA Workflow:



Active Session

&#x20;     |

&#x20;     v

Identify SQL\_ID

&#x20;     |

&#x20;     v

Investigate SQL

&#x20;     |

&#x20;     v

Review Execution Plan

&#x20;     |

&#x20;     v

Analyze Wait Events



2\. Top SQL Analysis



File: 02-top-sql.sql



Purpose



Identify SQL statements consuming significant database resources.



Key Oracle View



V$SQL



Metrics Reviewed

* CPU time
* Elapsed time
* Executions
* Average elapsed time
* Buffer gets
* Disk reads
* Rows processed



Why This Matters



A SQL statement with high total resource consumption may be a candidate for tuning.



However, total consumption should be considered together with execution count.



For example, a SQL statement executed millions of times may have a relatively small cost per execution but still create significant overall workload.



3\. Execution Plan Analysis



File: 03-execution-plans.sql



Purpose



Demonstrate how Oracle execution plans can be reviewed during performance investigations.



Key Oracle Tools and Views

* EXPLAIN PLAN
* DBMS\_XPLAN
* V$SQL
* Execution Plan Areas



The project demonstrates investigation of:



* Table access paths
* Index scans
* Full table scans
* Nested loops
* Hash joins
* Merge joins
* Optimizer cost
* Plan hash values
* Child cursors
* Important DBA Principle



An index is not automatically better than a full table scan.



Oracle's optimizer considers factors such as:



* Data volume
* Predicate selectivity
* Statistics
* Data distribution
* Clustering
* Cost of the access path



The execution plan should therefore be analyzed before making performance changes.



4\. Index Analysis



File: 04-index-analysis.sql



Purpose



Review Oracle indexes and identify potential index-related performance issues.



Key Oracle Views

* USER\_INDEXES
* USER\_IND\_COLUMNS
* USER\_TABLES



Investigation Areas

* Index status
* Index visibility
* Indexed columns
* Index uniqueness
* Clustering factor
* Optimizer statistics
* Recently analyzed tables
* Potentially stale statistics
* DBA Consideration



Indexes can improve selective queries, but indexes also introduce:



* Storage requirements
* DML maintenance overhead
* Additional write activity



Therefore, index decisions should be based on actual workload and execution-plan evidence.



5\. Wait Event Analysis



File: 05-wait-events.sql



Purpose



Investigate Oracle wait events and identify potential database

bottlenecks.



Key Oracle Views

V$SYSTEM\_EVENT

V$SESSION

V$SQL

Wait Classes Investigated



Examples include:



User I/O

Concurrency

Application

Other non-idle waits

Blocking Session Investigation



The project also identifies:



* Blocking sessions
* Final blocking sessions
* Sessions waiting for locks
* SQL\_ID values associated with waiting sessions
* Important DBA Principle



A wait event is not automatically a performance problem.



Oracle databases legitimately wait for resources during normal operation.



A DBA should consider:



* Frequency
* Duration
* Workload
* Resource consumption
* Business impact



before determining whether a wait represents a real performance problem.



6\. Tablespace Performance and Capacity



File: 06-tablespace-performance.sql



Purpose



Monitor tablespace usage, datafiles, free space, temporary tablespaces, and large segments.



Key Oracle Views

* DBA\_TABLESPACES
* DBA\_DATA\_FILES
* DBA\_FREE\_SPACE
* DBA\_TEMP\_FILES
* DBA\_SEGMENTS



Investigation Areas

* Tablespace utilization
* Free space
* Datafile size
* Autoextend configuration
* Maximum datafile size
* Temporary tablespace
* Large database segments
* Capacity Monitoring



A tablespace approaching capacity should be investigated before it becomes an operational issue.



However, high tablespace utilization does not automatically mean poor database performance.



Storage capacity, I/O latency, workload, and underlying storage must also be considered.



7\. Consolidated Performance Report



File: 07-performance-report.sql



Purpose



Provide a consolidated starting point for an Oracle database performance health check.



The report combines information about:



Database status

Instance status

Active sessions

Waiting sessions

Blocking sessions

Top CPU-consuming SQL

Top elapsed-time SQL

Logical reads

Wait events

Index health

Optimizer statistics

Tablespace utilization

Performance Troubleshooting Methodology



A structured Oracle DBA performance investigation can follow this

workflow:



1\. Detect

&#x20;  |

&#x20;  v

2\. Measure

&#x20;  |

&#x20;  v

3\. Identify affected session or SQL\_ID

&#x20;  |

&#x20;  v

4\. Review execution plan

&#x20;  |

&#x20;  v

5\. Analyze wait events

&#x20;  |

&#x20;  v

6\. Investigate indexes and statistics

&#x20;  |

&#x20;  v

7\. Check storage and tablespace conditions

&#x20;  |

&#x20;  v

8\. Determine root cause

&#x20;  |

&#x20;  v

9\. Apply an appropriate change

&#x20;  |

&#x20;  v

10\. Measure performance again



Example Performance Investigation Scenario:



An application reports that a business transaction has become slow.



Step 1 — Identify active sessions



Use:



01-session-monitoring.sql



Look for:



Active sessions

SQL\_ID

Wait events

Blocking sessions



Step 2 — Investigate SQL



Use:



02-top-sql.sql



Review:



CPU

Elapsed time

Executions

Buffer gets

Disk reads



Step 3 — Review execution plan



Use:



03-execution-plans.sql



Investigate:



Access path

Join method

Optimizer cost

Plan hash value



Step 4 — Review indexes



Use:



04-index-analysis.sql



Check:



Index status

Indexed columns

Statistics

Clustering factor



Step 5 — Investigate waits



Use:



05-wait-events.sql



Determine whether the session is experiencing:



I/O waits

Lock waits

Concurrency waits

Application waits



Step 6 — Check storage



Use:



06-tablespace-performance.sql



Review:



Tablespace utilization

Datafile growth

Free space

Large segments



Step 7 — Generate summary



Use:



07-performance-report.sql



Use the collected information to document the suspected root cause and recommended action.



Oracle Performance Metrics



Important metrics used in this project include:



Metric			Purpose

\------			-------

CPU Time		Measures CPU consumed by SQL

Elapsed Time		Measures total execution duration

Executions		Shows how frequently SQL runs

Buffer Gets		Measures logical reads

Disk Reads		Measures physical reads

Wait Time		Measures time spent waiting for resources

SQL\_ID			Identifies SQL statements

Plan Hash Value		Helps identify execution-plan changes

Tablespace Used %	Helps monitor storage capacity

Production DBA Considerations



In a production environment, performance tuning should be evidence-based.



A DBA should avoid making changes solely because a metric looks high.



Before changing production systems, investigate:



* Application workload
* Business impact
* SQL execution plans
* Wait events
* Optimizer statistics
* Index design
* Storage performance
* Recent application or database changes
* Historical performance trends



Changes should be tested and authorized according to the organization's change-management process.



Oracle Views Used

Oracle View	: Purpose

V$SESSION	: Session activity and waits

V$SESSTAT	: Session statistics

V$STATNAME	: Statistic names

V$SQL	        : SQL resource consumption

V$SYSTEM\_EVENT	: System wait events

V$DATABASE	: Database status

V$INSTANCE	: Instance status

USER\_INDEXES	: Current-user index information

USER\_IND\_COLUMNS: Indexed columns

USER\_TABLES	: Table statistics

DBA\_TABLESPACES	: Tablespace configuration

DBA\_DATA\_FILES	: Datafile information

DBA\_FREE\_SPACE	: Free space

DBA\_TEMP\_FILES	: Temporary datafiles

DBA\_SEGMENTS	: Segment storage information



\------------------------

Learning Objectives

\------------------------



After completing this project, the DBA should be able to:



* Monitor Oracle database sessions.
* Identify resource-intensive SQL.
* Investigate SQL using SQL\_ID.
* Review Oracle execution plans.
* Analyze indexes and optimizer statistics.
* Investigate wait events.
* Identify blocking sessions.
* Monitor tablespace capacity.
* Build a structured performance investigation.
* Document findings and recommended actions.
* Safety and Disclaimer



The scripts in this project are primarily intended for read-only monitoring and analysis.



They should be tested in a development or test environment before being used in production.



Do not automatically:



* Kill sessions
* Rebuild indexes
* Resize datafiles
* Change optimizer parameters
* Modify production configuration



based solely on the output of these scripts.



Production changes should follow appropriate authorization, testing, and change-management procedures.



\----------------------

Portfolio Value:

\----------------------



This project demonstrates practical Oracle DBA troubleshooting skills beyond basic SQL.



It shows an understanding of the relationship between:



Sessions

&#x20;  ↓

SQL

&#x20;  ↓

Execution Plans

&#x20;  ↓

Indexes / Statistics

&#x20;  ↓

Wait Events

&#x20;  ↓

Storage

&#x20;  ↓

Root Cause

&#x20;  ↓

Performance Improvement



The objective is not simply to find a "slow query", but to systematically investigate the underlying cause of a performance problem.



\------------------

Author

\------------------



Shivar



Oracle DBA Portfolio



GitHub:

https://github.com/Shivar230692/Oracle-DBA-Portfolio

