ALTER SESSION SET CURRENT_SCHEMA=OGGDMDE;

exec oggdmde.SupprObjetSiExiste('OGGDMDE', 'T_CONFIG');

CREATE TABLE oggdmde.t_config AS
	SELECT pr nom_projet,
	tbs type_base_source, bs base_source, ss schema_source,
	tbc type_base_cible, bc base_cible, sc schema_cible,
	sc||'_DATA' tbs_donnees,'DONNEE' type_tbs_donnee ,
	sc||'_INDX' tbs_index, 'INDEX' type_tbs_indx,
	dbl lien_base
	FROM
	( SELECT 'ALLBIRDS' pr, 'SOURCE' tbs, 'REC001' bs ,'VB' ss ,'CIBLE' tbc, 'ALLBIRDS' bc , 'OSM001' sc , 'OSM001' dbl FROM dual
		UNION
		SELECT 'ALLBIRDS' , 'SOURCE' ,'RECAM' , 'VB' ,'CIBLE' , 'ALLBIRDS' , 'OSMAPM', 'OSMAPM' FROM dual
		UNION
		SELECT 'ALLBIRDS' , 'SOURCE' ,'RECEXP' , 'VB' ,'CIBLE' , 'ALLBIRDS' , 'OSMEXP', 'OSMEXP' FROM dual
		UNION
		SELECT 'ALLBIRDS' , 'SOURCE' ,'RECBUD' , 'ERM' ,'CIBLE' , 'ALLBIRDS' , 'OSMBUD', 'OSMBUD' FROM dual
		UNION
		SELECT 'ALLBIRDS' , 'SOURCE' ,'REC054' , 'VB' ,'CIBLE' , 'ALLBIRDS' , 'OSMJBM', 'OSMJBM' FROM dual
		UNION
		SELECT 'YOUPLAN' , 'SOURCE' ,'REC001' , 'VB' ,'CIBLE' , 'STAGING' , 'OSM001', 'OSM001' FROM dual
		UNION
		SELECT 'YOUPLAN' , 'SOURCE' ,'RECEXP' , 'VB' ,'CIBLE' , 'STAGING' , 'OSMEXP', 'OSMEXP' FROM dual
		UNION
		SELECT 'YOUPLAN' , 'SOURCE' ,'RECAM' , 'VB' ,'CIBLE' , 'STAGING' , 'OSMAPM', 'OSMAPM' FROM dual
		UNION
		SELECT 'YOUPLAN' , 'SOURCE' ,'REC054' , 'VB' ,'CIBLE' , 'STAGING' , 'OSMJBM', 'OSMJBM' FROM dual
		UNION
		SELECT 'ALLBIRDS' , 'SOURCE' ,'REC001' , 'VB' ,'CIBLE' , 'ALLBIRDS' , 'OSMTEST', 'OSM001' FROM dual
	);


INSERT INTO TYPE_CONNECTEUR_R (LIB_TYPE_CONNECTEUR) VALUES('JMS');
INSERT INTO TYPE_CONNECTEUR_R (LIB_TYPE_CONNECTEUR) VALUES('BIGDATA');
INSERT INTO TYPE_CONNECTEUR_R (LIB_TYPE_CONNECTEUR) VALUES('DB');

INSERT INTO TYPE_PARAMETRE_R (LIB_TYPE_PARAMETRE) VALUES ('ENVIRONNEMENT');
INSERT INTO TYPE_PARAMETRE_R (LIB_TYPE_PARAMETRE) VALUES ('PARAMETRE_GOLDENGATE');

INSERT INTO TYPE_ENVIRONNEMENT_R (LIB_TYPE_ENVIRONNEMENT) VALUES('DEV');
INSERT INTO TYPE_ENVIRONNEMENT_R (LIB_TYPE_ENVIRONNEMENT) VALUES('RCT');
INSERT INTO TYPE_ENVIRONNEMENT_R (LIB_TYPE_ENVIRONNEMENT) VALUES('PRD');


INSERT INTO TYPE_COMPOSANT_R (LIB_TYPE_COMPOSANT) VALUES('MANAGER');
INSERT INTO TYPE_COMPOSANT_R (LIB_TYPE_COMPOSANT) VALUES('EXTRACT');
INSERT INTO TYPE_COMPOSANT_R (LIB_TYPE_COMPOSANT) VALUES('REPLICAT');
INSERT INTO TYPE_COMPOSANT_R (LIB_TYPE_COMPOSANT) VALUES('DUMP');
INSERT INTO TYPE_COMPOSANT_R (LIB_TYPE_COMPOSANT) VALUES('INITIAL LOAD');
INSERT INTO TYPE_COMPOSANT_R (LIB_TYPE_COMPOSANT) VALUES('BINARIES');


INSERT INTO TYPE_CODE_R (LIB_TYPE_CODE, LIBELLE_COMPLET) VALUES('DDL','MODIFICATION_STRUCTURE');
INSERT INTO TYPE_CODE_R (LIB_TYPE_CODE, LIBELLE_COMPLET) VALUES('EXTR','EXTRACTION');
INSERT INTO TYPE_CODE_R (LIB_TYPE_CODE, LIBELLE_COMPLET) VALUES('REPL','REPLICATION');
INSERT INTO TYPE_CODE_R (LIB_TYPE_CODE, LIBELLE_COMPLET) VALUES('INIT','CHARGEMENT_INITIAL');
INSERT INTO TYPE_CODE_R (LIB_TYPE_CODE, LIBELLE_COMPLET) VALUES('TRAN','TRANDATA');

INSERT INTO TYPE_EXT_FICHIER_R (LIB_TYPE_EXT_FICHIER) VALUES ('sql');
INSERT INTO TYPE_EXT_FICHIER_R (LIB_TYPE_EXT_FICHIER) VALUES ('prm');
INSERT INTO TYPE_EXT_FICHIER_R (LIB_TYPE_EXT_FICHIER) VALUES ('obey');

INSERT INTO TYPE_OBJET_R (LIB_TYPE_OBJET) VALUES('TABLE');
INSERT INTO TYPE_OBJET_R (LIB_TYPE_OBJET) VALUES('COLONNE');

INSERT INTO TYPE_DEMANDE_R (LIB_TYPE_DEMANDE) VALUES ('AJOUTER');
INSERT INTO TYPE_DEMANDE_R (LIB_TYPE_DEMANDE) VALUES ('MODIFIER');
INSERT INTO TYPE_DEMANDE_R (LIB_TYPE_DEMANDE) VALUES ('SUPPRIMER');

INSERT INTO TYPE_ACTION_R (LIB_TYPE_ACTION) VALUES ('CREATE');
INSERT INTO TYPE_ACTION_R (LIB_TYPE_ACTION) VALUES ('ALTER');
INSERT INTO TYPE_ACTION_R (LIB_TYPE_ACTION) VALUES ('DROP');



INSERT INTO TYPE_CHARGEMENT_R (LIB_TYPE_CHARGEMENT) VALUES ('CHARGEMENT_INITIAL');
INSERT INTO TYPE_CHARGEMENT_R (LIB_TYPE_CHARGEMENT) VALUES ('RECHARGEMENT');
INSERT INTO TYPE_CHARGEMENT_R (LIB_TYPE_CHARGEMENT) VALUES ('CHARGEMENT_VIA_EXTRACT');

INSERT INTO OGGDMDE.TYPE_STATUT_DMDE_R (LIB_TYPE_STATUT_DMDE) VALUES ('A_FAIRE');
INSERT INTO OGGDMDE.TYPE_STATUT_DMDE_R (LIB_TYPE_STATUT_DMDE) VALUES ('EN_COURS');
INSERT INTO OGGDMDE.TYPE_STATUT_DMDE_R (LIB_TYPE_STATUT_DMDE) VALUES ('TRAITEE_AVEC_SUCCES');
INSERT INTO OGGDMDE.TYPE_STATUT_DMDE_R  (LIB_TYPE_STATUT_DMDE) VALUES ('TRAITEE_EN_ECHEC');


INSERT INTO TYPE_TBS_R (LIB_TYPE_TBS)
	SELECT DISTINCT type_tbs_donnee 
		FROM oggdmde.t_config
	UNION
	SELECT DISTINCT type_tbs_indx 
		FROM oggdmde.t_config;


INSERT INTO TYPE_BASE_R (LIB_TYPE_BASE) 
	SELECT DISTINCT type_base_source 
		FROM oggdmde.t_config
	UNION
	SELECT DISTINCT type_base_cible 
		FROM oggdmde.t_config
;

INSERT INTO PROJET_R (NOM_PROJET)
	SELECT DISTINCT nom_projet 
	FROM oggdmde.t_config
;

INSERT INTO SCHEMA_R (NOM_SCHEMA)
	SELECT DISTINCT schema_source 
	FROM oggdmde.t_config
	UNION
	SELECT DISTINCT schema_cible 
	FROM oggdmde.t_config
;


INSERT INTO TBS_E (ID_TYPE_TBS,NOM_TBS) 
	SELECT b.id_type_tbs ,tbs_donnees
		FROM oggdmde.t_config a 
		INNER JOIN oggdmde.TYPE_TBS_R b ON b.lib_type_tbs = a.type_tbs_donnee
	UNION
	SELECT b.id_type_tbs ,tbs_index
		FROM oggdmde.t_config a 
		INNER JOIN oggdmde.TYPE_TBS_R b ON b.lib_type_tbs = a.type_tbs_indx
;

INSERT INTO BASE_E (id_type_base,nom_base) 
	SELECT distinct b.id_type_base, base_source
		FROM oggdmde.t_config a 
		INNER JOIN oggdmde.TYPE_base_R b ON b.lib_type_base = a.type_base_source
	UNION
	SELECT DISTINCT b.id_type_base, base_cible
		FROM oggdmde.t_config a 
		INNER JOIN oggdmde.TYPE_base_R b ON b.lib_type_base = a.type_base_cible
;

INSERT INTO LIEN_BASE_E (
	id_base_cible,
	id_schema_cible,
	nom_lien_base
) SELECT b.id_base, s.id_schema, a.lien_base
	FROM  oggdmde.t_config a
	INNER JOIN base_e b ON b.nom_base = a.base_cible
	INNER JOIN schema_r s ON s.nom_schema = a.schema_cible ;


INSERT INTO CODE_EXT_FIC_E (id_type_code, id_type_ext_fichier)
	SELECT c.id_type_code, e.id_type_ext_fichier
	FROM 
	(
	SELECT 'DDL' code, 'sql' ext FROM dual
	UNION 
	SELECT 'EXTR' code, 'prm' ext FROM dual
	UNION 
	SELECT 'REPL' code, 'prm' ext FROM dual
	UNION 
	SELECT 'INIT' code, 'sql' ext FROM dual
	UNION 
	SELECT 'TRAN' code, 'obey' ext FROM dual
	) v 
	INNER JOIN  oggdmde.type_code_r c ON c.lib_type_code = v.code
	INNER JOIN  oggdmde.type_ext_fichier_r e ON e.lib_type_ext_fichier = v.ext
;

INSERT INTO oggdmde.base_schema_a (id_base, id_schema)
	SELECT distinct b.id_base, s.id_schema
		FROM oggdmde.t_config a
		INNER JOIN oggdmde.schema_r s ON s.nom_schema = a.schema_source
		INNER JOIN oggdmde.base_e b ON b.nom_base = a.base_source
	UNION
	SELECT distinct b.id_base, s.id_schema
		FROM oggdmde.t_config a
		INNER JOIN oggdmde.schema_r s ON s.nom_schema = a.schema_cible
		INNER JOIN oggdmde.base_e b ON b.nom_base = a.base_cible
;

INSERT INTO oggdmde.base_schema_tbs_a (id_base_schema, id_tbs) 
	SELECT DISTINCT b.id_base_schema, r.id_tbs
		FROM oggdmde.t_config a
		INNER JOIN V_BASES_SCHEMAS b ON b.nom_base = a.base_cible AND b.nom_schema = a.schema_cible
		INNER JOIN oggdmde.tbs_e r ON r.nom_tbs = a.tbs_donnees
	UNION
	SELECT b.id_base_schema, r.id_tbs
		FROM oggdmde.t_config a
		INNER JOIN oggdmde.V_BASES_SCHEMAS b ON b.nom_base = a.base_cible AND b.nom_schema = a.schema_cible
		INNER JOIN oggdmde.tbs_e r ON r.nom_tbs = a.tbs_index
;

INSERT INTO oggdmde.projet_detail_a (id_base_schema_source, id_base_schema_cible, id_projet)
	SELECT 
	vs.id_base_schema id_base_schema_source
	,vc.id_base_schema id_base_schema_cible, 
	p.id_projet
	FROM 
	oggdmde.t_config c
	INNER JOIN oggdmde.V_BASES_SCHEMAS vs ON vs.nom_base = c.base_source AND vs.nom_schema = c.schema_source 
	INNER JOIN oggdmde.V_BASES_SCHEMAS vc ON vc.nom_base = c.base_cible AND vc.nom_schema = c.schema_cible
	INNER JOIN oggdmde.projet_r p ON p.nom_projet = c.nom_projet
;


COMMIT;