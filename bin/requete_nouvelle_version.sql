alter session set current_schema=OGGDMDE;

declare
        seq number;
begin
	oggdmde.pkg_ogg_config.ajouter_demande ('ALLBIRDS','Initialiation du projet ALLBIRDS');
	select max(id_demandes) into seq  from oggdmde.demandes_e;
	-- ----------------------------------------------------------------------------
	oggdmde.pkg_ogg_config.ajouter_dmde_tables (seq,'RECAM', 'VB','ALLBIRDS','OSMAPM','ALTER','COMCON_E');
	select max(id_dmde_tables) into seq  from oggdmde.dmde_tables_e;
	oggdmde.pkg_ogg_config.ajouter_dmde_tab_colonnes (seq, 'AJOUTER', 'U$$NUMCOMMANDE','U__NUMCOMMANDE' );
	commit;
end;
/




SELECT * FROM OGGDMDE.parametre_detail_a
ORDER BY id_type_parametre, id_parametre;
 
SELECT rownum, id, Value
FROM (
  (SELECT ID_param,
    ENVIRONNEMENT,
    CONNECTEUR,
    NOMCOMPOSANT,
    OBJET,
    PROJET,
    GGHOME,
    OHOME,
    SERVEUR,
    BASE_CIBLE,
    SCHEMA_CIBLE,
    SCHEMA_ADM,
    ORDRE,
    MONITORER
    FROM OGGDMDE.SQLLDR_PARAM_T
    ORDER BY ID
  )
  unpivot
  (  Value FOR value_type IN ( ENVIRONNEMENT,
    CONNECTEUR,
    NOMCOMPOSANT,
    OBJET,
    PROJET,
    GGHOME,
    OHOME,
    SERVEUR,
    BASE_CIBLE,
    SCHEMA_CIBLE,
    SCHEMA_ADM,
    ORDRE,
    MONITORER
  )
)
) ORDER BY 2, 1;



/*
DELETE oggdmde.sqlldr_dmde_t;

INSERT INTO oggdmde.sqlldr_dmde_t (
	TYPE_DEMANDE,
	TYPE_OBJET,
	NOM_TABLE,
	SCHEMA_CIBLE,
	NOM_COL_CIBLE,
	SCHEMA_SOURCE,
	NOM_COL_SOURCE,
	FILTRE_SOURCE
)
SELECT 'AJOUTER','COLONNE',table_name, owner, column_name, 'VB',column_name,NULL filtre FROM dba_tab_columns  WHERE owner ='OSM001';

UPDATE oggdmde.sqlldr_dmde_t
SET FILTRE_SOURCE = '>=''01/01/2019'''
WHERE NOM_COL_SOURCE ='S_DATEMODIF';

COMMIT;
*/

--SELECT * FROM oggdmde.demandes_e;
--SELECT * FROM oggdmde.sqlldr_dmde_t;

--SELECT SCHEMA_CIBLE, nom_table FROM oggdmde.sqlldr_dmde_t
--GROUP BY SCHEMA_CIBLE, nom_table;

--  TABLE DMDE_TABLES_E
--	ID_DMDE_TABLES NUMBER GENERATED ALWAYS AS IDENTITY,

--	ID_DEMANDES NUMBER,
--	ID_BASE_SCHEMA_SOURCE NUMBER,
--	ID_BASE_SCHEMA_CIBLE NUMBER,
--	ID_TYPE_ACTION NUMBER,
--	NOM_TABLE VARCHAR2(30)
INSERT INTO oggdmde.dmde_tables_e (
ID_DEMANDES,
ID_BASE_SCHEMA_SOURCE,
ID_BASE_SCHEMA_CIBLE,
ID_TYPE_ACTION,
NOM_TABLE
)
SELECT
  bs.id_base_schema id_base_schema_source
  , bc.id_base_schema id_base_schema_cible
  , ta.id_type_action
  , d.nom_table
FROM
(SELECT d.schema_source, d.schema_cible, d.nom_table, Decode(t.table_name,NULL,'CREATE','ALTER') as lib_type_action
  FROM  oggdmde.sqlldr_dmde_t d
  left OUTER JOIN dba_tables t ON t.owner = d.schema_cible AND t.table_name = d.nom_table
  GROUP BY d.schema_source, d.schema_cible, d.nom_table, t.table_name, Decode(t.table_name,NULL,'CREATE','ALTER')
) d
  INNER JOIN oggdmde.v_base_schema bc ON bc.nom_schema = d.schema_cible AND bc.alias_base = 'ALLBIRDS'
  INNER JOIN oggdmde.v_base_schema bs ON bs.nom_schema = d.schema_source AND bs.alias_base = 'REC001'
  INNER JOIN oggdmde.type_action_r ta ON ta.lib_type_action = d.lib_type_action
;


SELECT c.owner, c.table_name, c.column_name, v.nom_col_source
FROM dba_tab_columns c
INNER JOIN (SELECT schema_cible,nom_table,nom_col_cible,
  LAST_VALUE(nom_col_source) IGNORE NULLS OVER (PARTITION BY
 schema_cible,nom_table,nom_col_cible
  ORDER BY schema_cible,nom_table) AS nom_col_source
FROM oggdmde.v_dmde_tab_colonnes) v ON v.schema_cible = c.owner AND v.nom_table = c.table_name AND v.nom_col_cible = c.column_name
;

