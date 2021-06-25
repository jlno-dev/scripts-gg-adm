ALTER SESSION SET CURRENT_SCHEMA=OGGDMDE;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW V_DMDE_STATUT_A_FAIRE
AS
SELECT ID_TYPE_STATUT_DMDE, LIB_TYPE_STATUT_DMDE 
FROM oggdmde.TYPE_STATUT_DMDE_R
WHERE LIB_TYPE_STATUT_DMDE in ('A_FAIRE');

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create or replace view V_DMDE_STATUT_EN_COURS
AS
SELECT ID_TYPE_STATUT_DMDE, LIB_TYPE_STATUT_DMDE 
FROM oggdmde.TYPE_STATUT_DMDE_R
WHERE LIB_TYPE_STATUT_DMDE in ('EN_COURS');

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE FORCE VIEW V_SQLLDR_DMDE_TABLE
AS
SELECT DISTINCT p.base_source,
    d.schema_source,
    p.base_cible,
    d.schema_cible,
    nom_table,
    c.lib_type_chargement,
    p.id_base_source,
    p.id_schema_source,
    p.id_base_cible,
    p.id_schema_cible,
    p.id_base_schema_source,
    p.id_base_schema_cible,
    c.id_type_chargement,
    r.id_type_demande
FROM oggdmde.sqlldr_dmde_t  d
  INNER JOIN oggdmde.v_projets_details p ON p.schema_source = d.schema_source
        AND p.schema_cible = d.schema_cible
        AND p.base_cible = d.base_cible
  INNER JOIN oggdmde.type_demande_r r ON r.lib_type_demande = d.lib_type_demande
  INNER JOIN oggdmde.type_chargement_r c ON c.lib_type_chargement = d.type_chargement
;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW v_dmde_invalides_source
AS 
  SELECT
    s.type_base,
    d.lib_type_demande,
    d.lib_type_objet,
    d.nom_col_source col_source_inexistante,
    s.nom_base,
    s.nom_schema,
    d.nom_table,
    i.id_dmde_sqlldr,
    i.id_base_schema
  FROM oggdmde.sqlldr_dmde_invalides_e  i
    INNER JOIN oggdmde.sqlldr_dmde_t d ON d.id_dmde_sqlldr = i.id_dmde_sqlldr
    INNER JOIN oggdmde.V_BASES_SCHEMAS s ON s.id_base_schema = i.id_base_schema AND s.type_base='SOURCE'
;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW v_dmde_invalides_cible
AS 
  SELECT
    s.type_base,
    d.lib_type_demande,
    d.lib_type_objet,
    d.nom_col_source col_cible_inexistante,
    s.nom_base,
    s.nom_schema,
    d.nom_table,
    i.id_dmde_sqlldr,
    i.id_base_schema
  FROM oggdmde.sqlldr_dmde_invalides_e  i
    INNER JOIN oggdmde.sqlldr_dmde_t d ON d.id_dmde_sqlldr = i.id_dmde_sqlldr
    INNER JOIN oggdmde.V_BASES_SCHEMAS s ON s.id_base_schema = i.id_base_schema AND s.type_base='CIBLE'
;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW V_DMDE_INVALIDES
AS 
	SELECT s.type_base, d.lib_type_demande, d.lib_type_objet
		, CASE 
			WHEN s.type_base = 'STAGING' THEN d.nom_col_cible
			ELSE d.nom_col_source 
		END col_cible_existe_deja
		, CASE 
			WHEN s.type_base != 'STAGING' THEN d.nom_col_source
			ELSE NULL
		END col_source_inexistante
		,s.nom_base, s.nom_schema
		,d.nom_table
		,i.id_dmde_sqlldr, i.id_base_schema
	FROM oggdmde.sqlldr_dmde_invalides_e i
    INNER JOIN oggdmde.sqlldr_dmde_t d ON d.id_dmde_sqlldr = i.id_dmde_sqlldr
    INNER JOIN oggdmde.V_BASES_SCHEMAS s ON s.id_base_schema = i.id_base_schema
;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW v_base
AS
SELECT 
	b.nom_base,
	t.lib_type_base AS type_base,
	b.id_base,
	b.id_type_base
	FROM oggdmde.base_e  b
	INNER JOIN oggdmde.type_base_r t ON t.id_type_base = b.id_type_base
;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW V_BASES_SCHEMAS 
AS
	SELECT b.nom_base, s.nom_schema, b.type_base
	,bs.id_base_schema, bs.id_schema, bs.id_base
	FROM oggdmde.base_schema_a bs
		INNER JOIN oggdmde.schema_r s ON s.id_schema = bs.id_schema
		INNER JOIN oggdmde.v_base b ON bs.id_base = b.id_base
;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW V_LIEN_BASE_E 
AS 
SELECT
  s.nom_schema,
  b.nom_base,
  e.nom_lien_base,
  e.id_schema_cible,
  e.id_base_cible
FROM lien_base_e e
INNER JOIN oggdmde.base_e b ON b.id_base = e.id_base_cible 
INNER JOIN oggdmde.schema_r  s ON s.id_schema = e.id_schema_cible ;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW V_TBS
AS 
	SELECT t.nom_tbs , r.lib_type_tbs
		,t.id_type_tbs, t.id_tbs
	FROM oggdmde.tbs_e t
		INNER JOIN oggdmde.type_tbs_r r ON r.id_type_tbs = t.id_type_tbs
;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW V_SCHEMAS_DETAILS
AS
	SELECT v.nom_base, v.nom_schema, t.nom_tbs, t.lib_type_tbs
		, v.id_base_schema, t.id_tbs, inf.id_base_schema_tbs
	FROM oggdmde.base_schema_tbs_a inf
		INNER JOIN oggdmde.v_tbs t ON t.id_tbs = inf.id_tbs
		INNER JOIN oggdmde.V_BASES_SCHEMAS v ON v.id_base_schema = inf.id_base_schema
;



-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE FORCE VIEW V_DMDE_TABLES
AS
SELECT d.date_dmde,
  a.lib_type_action,
  vc.nom_base base_cible,
  vc.nom_schema schema_cible,
  t.nom_table,
  vs.nom_base base_source,
  vs.nom_schema schema_source,
  d.commentaire,
  c.lib_type_chargement,
  t.id_dmde_table,
  t.id_demande,
  t.id_base_schema_source,
  t.id_base_schema_cible,
  t.id_type_action,
  t.id_type_chargement
FROM oggdmde.dmde_tables_e  t
  INNER JOIN oggdmde.V_BASES_SCHEMAS vc
      ON vc.id_base_schema = t.id_base_schema_cible
  INNER JOIN oggdmde.V_BASES_SCHEMAS vs
      ON vs.id_base_schema = t.id_base_schema_source
  INNER JOIN oggdmde.type_action_r a
      ON a.id_type_action = t.id_type_action
  INNER JOIN oggdmde.demandes_e d ON d.id_demande = t.id_demande
  INNER JOIN oggdmde.type_chargement_r c ON c.id_type_chargement = t.id_type_chargement
;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW V_DMDE_TAB_COLONNES
AS 
	SELECT t.date_dmde, t.lib_type_action,
		t.base_cible, t.schema_cible, t.nom_table, r.lib_type_demande, c.nom_col_cible 
		,t.base_source, t.schema_source, c.nom_col_source
		, c.id_dmde_tab_col, c.id_dmde_table, t.id_base_schema_source, t.id_base_schema_cible, t.id_demande
		,t.id_type_action, c.id_type_demande
	FROM oggdmde.dmde_tab_colonnes_e c
		INNER JOIN oggdmde.v_dmde_tables t ON t.id_dmde_table = c.id_dmde_table
		INNER JOIN oggdmde.type_demande_r r ON r.id_type_demande = c.id_type_demande
;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW V_PARAMETRES 
AS 
	SELECT t.lib_type_parametre, p.nom_parametre, p.id_type_parametre, p.id_parametre
	FROM oggdmde.parametre_e p
		INNER JOIN oggdmde.type_parametre_r t ON t.id_type_parametre = p.id_type_parametre
;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW V_COMPOSANTS
AS 
	SELECT c.nom_composant,  t.lib_type_composant, c.id_composant, c.id_type_composant  
	FROM oggdmde.composant_e c
		INNER JOIN oggdmde.type_composant_r t ON t.id_type_composant = c.id_type_composant
;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE FORCE VIEW V_COMPOSANTS_ENVIRONNEMENT
AS
SELECT j.nom_projet,
        e.lib_type_environnement,
        c.nom_composant,
        p.nom_parametre,
        d.valeur
  FROM oggdmde.composant_parametre_a  d
        INNER JOIN oggdmde.v_parametres p
            ON p.id_parametre = d.id_parametre AND  p.lib_type_parametre ='ENVIRONNEMENT'
        INNER JOIN oggdmde.projet_r j ON j.id_projet = d.id_projet
        INNER JOIN oggdmde.type_environnement_r e
            ON e.id_type_environnement = d.id_type_environnement
        INNER JOIN oggdmde.composant_e c
            ON c.id_composant = d.id_composant
;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE FORCE VIEW V_COMPOSANTS_CONFIGURATION
AS
SELECT j.nom_projet,
        e.lib_type_environnement,
        c.nom_composant,
        p.nom_parametre,
        d.valeur
  FROM oggdmde.composant_parametre_a  d
        INNER JOIN oggdmde.v_parametres p
            ON p.id_parametre = d.id_parametre AND p.lib_type_parametre ='CONFIGURATION'
        INNER JOIN oggdmde.projet_r j ON j.id_projet = d.id_projet
        INNER JOIN oggdmde.type_environnement_r e
            ON e.id_type_environnement = d.id_type_environnement
        INNER JOIN oggdmde.composant_e c
            ON c.id_composant = d.id_composant
;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW V_DMDE_TAB_CODE
AS 
SELECT t.date_dmde,
        t.lib_type_action,
        t.nom_table,
        r.lib_type_code,
        t.base_source,
        t.schema_source,
        t.base_cible,
        t.schema_cible,
        c.code,
        c.id_dmde_table,
        t.id_base_schema_source,
        t.id_base_schema_cible,
        t.id_demande,
        c.id_type_code
  FROM oggdmde.dmde_tab_code_e  c
        INNER JOIN oggdmde.v_dmde_tables t
            ON t.id_dmde_table = c.id_dmde_table
        INNER JOIN oggdmde.type_code_r r
            ON r.id_type_code = c.id_type_code
-- ORDER BY base_source, nom_table  
;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW v_code_ext_fic
AS 
SELECT c.lib_type_code, e.lib_type_ext_fichier, 
c.libelle_complet,t.id_type_code, t.id_type_ext_fichier  
FROM code_ext_fic_e t
	INNER JOIN  oggdmde.type_code_r c ON c.id_type_code = t.id_type_code
	INNER JOIN  oggdmde.type_ext_fichier_r e ON e.id_type_ext_fichier = t.id_type_ext_fichier
;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW V_DMDE_TAB_DERNIERE_COLONNE
AS
SELECT  d.base_cible,
	d.schema_cible ,d.nom_table, d.nom_col_cible,
	d.base_source,d.schema_source,
	LAST_VALUE(d.nom_col_source) 
		OVER (PARTITION BY d.nom_table,d.nom_col_cible ORDER BY d.id_dmde_tab_col) 
	as nom_col_source
FROM oggdmde.v_dmde_tab_colonnes d
--ORDER BY d.schema_cible, d.nom_table, d.nom_col_cible
;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CREATE OR REPLACE VIEW  v_dmde_tab_a_faire
AS 
SELECT
  t.nom_table,
  t.base_source, t.schema_source,
  t.base_cible, t.schema_cible,
  t.lib_type_action,    
  r.lib_type_statut_dmde ,
  t.date_dmde,
  dt.fait_le,
  dt.id_dmde_tab_a_traiter,
  dt.id_dmde_table,
  dt.id_type_statut_dmde
FROM oggdmde.dmde_tab_a_traiter_e dt
  INNER JOIN oggdmde.v_dmde_tables t ON t.id_dmde_table = dt.id_dmde_table 
  INNER JOIN oggdmde.v_dmde_statut_a_faire r ON r.id_type_statut_dmde = dt.id_type_statut_dmde
;

CREATE OR REPLACE FORCE VIEW V_DMDE_TAB_ENCOURS
AS
SELECT t.nom_table,
       t.base_source,
       t.schema_source,
       t.base_cible,
       t.schema_cible,
       t.lib_type_action,
       s.lib_type_statut_dmde,
       t.date_dmde,
       dt.fait_le,
       dt.id_dmde_tab_a_traiter,
       dt.id_dmde_table,
       dt.id_type_statut_dmde
  FROM oggdmde.dmde_tab_a_traiter_e  dt
       INNER JOIN oggdmde.v_dmde_tables t
           ON t.id_dmde_table = dt.id_dmde_table
       INNER JOIN oggdmde.v_dmde_statut_en_cours s
           ON s.id_type_statut_dmde = dt.id_type_statut_dmde;
           




