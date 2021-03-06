CREATE TABLESPACE OGGDMDE_DATA DATAFILE
SIZE 500M autoextend ON NEXT 10M;
 
CREATE TABLESPACE OGGDMDE_INDX DATAFILE
SIZE 500M autoextend ON NEXT 10M;

CREATE USER OGGDMDE
  IDENTIFIED BY "SAww0ZtfJXn5kpmMcIap"
  HTTP DIGEST DISABLE
  DEFAULT TABLESPACE OGGDMDE_DATA
  TEMPORARY TABLESPACE TEMP
  PROFILE APPLICATIF
  ACCOUNT LOCK;

-- 2 Tablespace Quotas for OGGDMDE 
ALTER USER OGGDMDE QUOTA UNLIMITED ON OGGDMDE_DATA;
ALTER USER OGGDMDE QUOTA UNLIMITED ON OGGDMDE_INDX;

-- 4 Roles for OGGADM 
--GRANT CONNECT TO OGGDMDE;
--GRANT DBA TO OGGADM;
GRANT SELECT ON DBA_USERS  TO OGGDMDE;
GRANT SELECT ON DBA_CONS_COLUMNS  TO OGGDMDE;
GRANT SELECT ON DBA_CONSTRAINTS  TO OGGDMDE;
GRANT SELECT ON DBA_OBJECTS  TO OGGDMDE;
GRANT SELECT ON DBA_TAB_COLUMNS  TO OGGDMDE;
GRANT SELECT ON DBA_TABLES  TO OGGDMDE;
GRANT SELECT ON DBA_LOG_GROUP_COLUMNS  TO OGGDMDE;
GRANT SELECT ON SYS.V_$DATABASE TO OGGDMDE;
GRANT RESOURCE TO OGGDMDE;

