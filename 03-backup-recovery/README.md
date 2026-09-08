\# Oracle Backup \& Recovery with RMAN



\## Overview



This project demonstrates practical Oracle Database backup and recovery administration using Recovery Manager (RMAN).



The objective is to demonstrate how an Oracle DBA can configure RMAN, perform database backups, protect archived redo logs, validate backups, monitor backup activity, and perform restore and recovery operations.



The scripts are designed for an Oracle Database laboratory or authorized test environment.



\---



\## DBA Skills Demonstrated



\- Oracle RMAN administration

\- Database backup strategy

\- Full database backups

\- Incremental backups

\- Archived redo log backups

\- Control file backups

\- SPFILE backups

\- RMAN retention policies

\- Backup validation

\- Database restore operations

\- Complete database recovery

\- Point-in-time recovery concepts

\- Backup monitoring

\- Recovery troubleshooting

\- Oracle data dictionary queries



\---



\## Project Structure



```text

03-backup-recovery/

│

├── README.md

├── 01-rman-configuration.sql

├── 02-database-backup.rman

├── 03-archivelog-backup.rman

├── 04-restore-database.rman

├── 05-recovery-scenarios.rman

└── 06-backup-monitoring.sql



=====================

1\. RMAN Configuration

=====================



Script



01-rman-configuration.sql



This section documents important RMAN configuration settings used by an Oracle DBA.



Typical configuration areas include:



Retention policy

Backup optimization

Control file autobackup

Backup device type

Parallelism

Backup compression



Example RMAN commands:



CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;



CONFIGURE BACKUP OPTIMIZATION ON;



CONFIGURE CONTROLFILE AUTOBACKUP ON;



CONFIGURE DEVICE TYPE DISK PARALLELISM 2;



SHOW ALL;



These settings should be reviewed according to the organization's backup and recovery requirements.



==================

2\. Database Backup

==================



Script



02-database-backup.rman



This script demonstrates database backup operations using RMAN.



Example:



BACKUP DATABASE

FORMAT '/backup/oracle/full\_%U.bkp';



An incremental backup can also be performed:



BACKUP INCREMENTAL LEVEL 1 DATABASE

FORMAT '/backup/oracle/inc1\_%U.bkp';



The %U RMAN substitution variable generates unique backup piece names.



===========================

3\. Archived Redo Log Backup

===========================



Script



03-archivelog-backup.rman



Archived redo logs are critical for database recovery.



Example:



BACKUP ARCHIVELOG ALL

FORMAT '/backup/oracle/arch\_%U.bkp'

DELETE INPUT;



This operation backs up archived redo logs and removes the input archived logs after successful backup according to the command's behavior and environment.



Archived redo log backups support recovery to a more recent point in time than a full database backup alone.



=====================

4\. Restore Operations

=====================



Script



04-restore-database.rman



Restore operations recreate database files from RMAN backups.



Example:



STARTUP MOUNT;



RESTORE DATABASE;



RECOVER DATABASE;



A restore retrieves required files from backup.



Recovery applies available redo and archived redo information to bring the database to a consistent state.



=====================

5\. Recovery Scenarios

=====================



Script



05-recovery-scenarios.rman



This script documents common Oracle recovery scenarios.



Examples include:



Complete database recovery

Datafile recovery

Control file recovery

Incomplete recovery

Point-in-time recovery



Example:



STARTUP MOUNT;



RESTORE DATABASE;



RECOVER DATABASE;



ALTER DATABASE OPEN;



Point-in-time recovery requires careful planning because the database is recovered to a selected time, SCN, or sequence rather than the latest available state.



====================

6\. Backup Monitoring

====================



Script



06-backup-monitoring.sql



Oracle provides data dictionary and dynamic performance views that can be used to monitor RMAN backup activity.



Important views include:



V$RMAN\_BACKUP\_JOB\_DETAILS

V$BACKUP\_SET

V$BACKUP\_PIECE

V$BACKUP\_DATAFILE

V$DATABASE

V$ARCHIVED\_LOG



Example:



SELECT

&#x20;   session\_key,

&#x20;   input\_type,

&#x20;   status,

&#x20;   start\_time,

&#x20;   end\_time,

&#x20;   input\_bytes,

&#x20;   output\_bytes,

&#x20;   time\_taken\_display

FROM v$rman\_backup\_job\_details

ORDER BY start\_time DESC;



\------------------------

RMAN Backup Workflow

\------------------------



A practical Oracle backup workflow can be represented as:



Database

&#x20;   |

&#x20;   v

RMAN Configuration

&#x20;   |

&#x20;   v

Full / Incremental Backup

&#x20;   |

&#x20;   v

Archived Redo Log Backup

&#x20;   |

&#x20;   v

Backup Validation

&#x20;   |

&#x20;   v

Backup Monitoring

&#x20;   |

&#x20;   v

Restore Testing

&#x20;   |

&#x20;   v

Recovery





A backup strategy should not be considered complete until backups can be successfully restored and recovered.



\---------------------------------

Backup and Recovery Concepts

\---------------------------------



Backup:



A backup is a copy of database files or recovery-related information that can be used to restore the database.



Restore:



Restore means copying database files from backup media back to their required locations.



Recovery:



Recovery applies redo information to restored files to make them consistent with the desired recovery point.



Complete Recovery:



Complete recovery attempts to recover the database to the latest possible consistent point using available backups and redo.



Incomplete Recovery:



Incomplete recovery recovers the database to a specific point in time, SCN, or log sequence.



\--------------------------------

Recovery Point Objective

\--------------------------------



Recovery Point Objective (RPO) defines how much data loss an organization can tolerate after a failure.



For example:



RPO = 15 minutes



means the backup and replication strategy should aim to limit potential data loss to approximately 15 minutes.



\-------------------------------

Recovery Time Objective

\-------------------------------



Recovery Time Objective (RTO) defines how quickly a database service should be restored after an outage.



For example:



RTO = 1 hour



means the recovery process should aim to restore service within approximately one hour.



RTO and RPO are important factors when designing Oracle backup strategies.



\-----------------------------

Backup Validation

\-----------------------------



Backups should be validated rather than simply assumed to be usable.



RMAN provides commands such as:



RESTORE DATABASE VALIDATE;



and:



BACKUP VALIDATE DATABASE;



These operations can help identify problems with backup availability or database files.



\------------------------------------

Common DBA Recovery Workflow

\------------------------------------



When a database failure occurs, a DBA may follow a workflow such as:



Identify Failure

&#x20;     |

&#x20;     v

Assess Database State

&#x20;     |

&#x20;     v

Identify Required Backups

&#x20;     |

&#x20;     v

Restore Required Files

&#x20;     |

&#x20;     v

Apply Redo / Recover Database

&#x20;     |

&#x20;     v

Validate Database

&#x20;     |

&#x20;     v

Open Database

&#x20;     |

&#x20;     v

Verify Application Availability



The exact procedure depends on the failure type and recovery objective.



\---------------------------------

Monitoring Checklist

\---------------------------------



A DBA should regularly review:



1. Last successful database backup

2\. Backup duration

3\. Backup size

4\. Backup status

5\. Archived redo log backup status

6\. Backup failures

7\. Backup piece availability

8\. Backup retention

9\. Available backup storage

10.Recovery test results



\--------------------------------

Production DBA Considerations

\--------------------------------



In a production environment, backup strategy should consider:



1. Database size

2\. Transaction volume

3\. RPO

4\. RTO

5\. Backup storage capacity

6\. Backup retention requirements

7\. Disaster recovery requirements

8\. Network bandwidth

9\. Encryption requirements

10.Backup testing

11.Offsite or secondary backup copies



RMAN configuration should always be aligned with the organization's recovery requirements.



\--------------------------------

Safety Notice

\--------------------------------



The scripts in this repository are intended for an Oracle Database laboratory, development environment, or other authorized environment.



Do not execute destructive restore or recovery commands against a production database without an approved recovery procedure and appropriate authorization.



Never store database passwords, wallet files, private keys, production connection strings, or confidential database information in this GitHub repository.



Example paths such as:



/backup/oracle/



are placeholders and should be replaced with an approved backup destination in a laboratory or authorized environment.



\-------------------------------

Learning Objectives

\-------------------------------



After completing this, we should be able to:



1. Explain Oracle RMAN architecture

2\. Configure basic RMAN settings

3\. Perform full database backups

4\. Perform incremental backups

5\. Back up archived redo logs

6\. Understand control file and SPFILE protection

7\. Validate RMAN backups

8\. Monitor backup jobs

9\. Explain restore vs recovery

10.Perform basic restore and recovery procedures in a lab

11.Understand complete and incomplete recovery

13.Explain RPO and RTO

14.Troubleshoot common backup failures



\----------------------------

Real-World DBA Use Cases

\----------------------------



This repo demonstrates techniques that can support:



1. Daily Oracle database backups

2\. Weekly full backup strategies

3\. Incremental backup strategies

4\. Archived redo log protection

5\. Backup health monitoring

6\. Disaster recovery preparation

7\. Database restore testing

8\. Point-in-time recovery

9\. Backup failure investigation

10.Recovery procedure documentation



\------------------------

Disclaimer

\------------------------



This project is created for educational, demonstration, and portfolio purposes.



Database backup and recovery commands should only be executed against databases for which you have appropriate authorization.



Production recovery operations require an approved recovery plan and should be performed by authorized personnel.



\---------------

Author

\---------------



Shivar



Oracle DBA Portfolio



GitHub:



https://github.com/Shivar230692/Oracle-DBA-Portfolio

