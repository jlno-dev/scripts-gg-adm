ALTER SESSION SET CURRENT_SCHEMA=OGGDMDE;


UPDATE oggdmde.sqlldr_param_t
SET schema_cible=base_cible
WHERE schema_cible='VB';

UPDATE oggdmde.sqlldr_param_t
SET base_cible=Decode(projet,'BUS','STAGING','YOUPLAN','STAGING','ALLBIRDS')
--WHERE schema_cible='VB';
;



delete oggdmde.composant_e ;

INSERT INTO oggdmde.composant_e (id_type_composant, nom_composant)
	SELECT DISTINCT c.id_type_composant, t.nomcomposant
	FROM oggdmde.sqlldr_param_t t
	INNER JOIN oggdmde.type_composant_r c ON c.lib_type_composant = t.objet
;


-- oggdmde.parametre_e
-- -----------------------------------------------------------------
DELETE oggdmde.parametre_e;

ALTER TABLE oggdmde.parametre_e
MODIFY id_parametre GENERATED ALWAYS AS IDENTITY RESTART START WITH 1;

	INSERT INTO oggdmde.parametre_e (id_type_parametre, nom_parametre)
    SELECT  t.id_type_parametre, nom_parametre
	  FROM (
		  SELECT 1 ID_PARAMETRE ,'ENV' Nom_parametre from dual
		  UNION
		  SELECT 3,'NOMCOMPOSANT' FROM DUAL
		  UNION
		  SELECT 2,'CONNECTEUR' FROM DUAL
		  UNION
		  SELECT 4,'OBJET' FROM DUAL
		  UNION
		  SELECT 5,'PROJET' FROM DUAL
		  UNION
		  SELECT 6,'GGHOME' FROM DUAL
		  UNION
		  SELECT 7,'OHOME' FROM DUAL
		  UNION
		  SELECT 8,'SERVEUR' FROM DUAL
		  UNION
		  SELECT 9,'BASE_CIBLE' FROM DUAL
		  UNION
		  SELECT 10,'SCHEMA_CIBLE' FROM DUAL
		  UNION
		  SELECT 11,'SCHEMA_ADM' FROM DUAL
		  UNION
		  SELECT 12,'ORDRE' FROM DUAL
		  UNION
		  SELECT 13,'MONITORER' FROM DUAL
	  ) v
  INNER JOIN oggdmde.type_parametre_r t ON t.lib_type_parametre = 'ENVIRONNEMENT'
  ORDER BY id_parametre;


INSERT INTO oggdmde.parametre_e (id_type_parametre, nom_parametre)
	SELECT  id_type_parametre, nom_parametre
	FROM (
		SELECT 'EXTRACT'AS nom_parametre  FROM DUAL
		UNION
		SELECT 'USERIDALIAS' FROM DUAL
		UNION
		SELECT 'TRANLOGOPTIONS' FROM DUAL
		UNION  
    SELECT 'EXTTRAIL' FROM DUAL
		UNION
		SELECT 'LOGALLSUPCOLS' FROM DUAL
		UNION
		SELECT 'UPDATERECORDFORMAT' FROM DUAL
		UNION
		SELECT 'DISCARDFILE' FROM DUAL
		UNION
		SELECT 'DISCARDROLLOVER' FROM DUAL
		UNION
		SELECT 'DBOPTIONS' FROM DUAL
		UNION
		SELECT 'SETENV' FROM DUAL
		UNION
		SELECT 'REPLICAT' FROM DUAL
	) v
  INNER JOIN oggdmde.type_parametre_r t ON t.lib_type_parametre = 'CONFIGURATION'
;


DELETE oggdmde.COMPOSANT_PARAMETRE_A;

INSERT INTO  oggdmde.COMPOSANT_PARAMETRE_A (id_projet, id_type_environnement, id_parametre, id_composant, valeur)
WITH t_init_p AS (
	SELECT
		num_ligne,
		CASE
			WHEN num_ligne < 14 THEN num_ligne
			ELSE num_ligne - 13 * id_param
		END id_parametre,
		id_groupe,
		valeur
	FROM
	(
		SELECT ROWNUM num_ligne, id_param - 1 AS id_param, id_param AS id_groupe, Valeur
		FROM
		(SELECT
			id_param,
			environnement,
			connecteur,
			nomcomposant,
			objet,
			projet,
			gghome,
			ohome,
			serveur,
			base_cible,
			schema_cible,
			schema_adm,
			ordre,
			monitorer
			FROM oggdmde.sqlldr_param_t
			ORDER BY ID_param
		)
		UNPIVOT
			(valeur FOR value_type IN (
			environnement,
			connecteur,
			nomcomposant,
			objet,
			projet,
			gghome,
			ohome,
			serveur,
			base_cible,
			schema_cible,
			schema_adm,
			ordre,
			monitorer)
		)
	)
)
SELECT v1.id_projet,v2.id_type_environnement, i.id_parametre, v3.id_composant, i.valeur
FROM t_init_p i
	INNER JOIN ( SELECT p.id_projet, i.id_groupe
			FROM oggdmde.t_init_p i
			INNER JOIN oggdmde.projet_r p ON p.nom_projet = i.valeur
				AND i.id_parametre IN (SELECT id_parametre FROM oggdmde.parametre_e WHERE nom_parametre='PROJET')
	) v1 ON v1.id_groupe = i.id_groupe
	INNER JOIN (
		SELECT e.id_type_environnement, i.id_groupe
		FROM oggdmde.t_init_p i
		INNER JOIN  oggdmde.type_environnement_r e ON e.lib_type_environnement = i.valeur
				AND i.id_parametre IN (SELECT id_parametre FROM oggdmde.parametre_e WHERE nom_parametre='ENV')
	) v2 ON v2.id_groupe = i.id_groupe
	INNER JOIN (
		SELECT c.id_composant, i.id_groupe, c.nom_composant
		FROM oggdmde.t_init_p i
		INNER JOIN  oggdmde.composant_e c ON c.nom_composant = i.valeur
			AND i.id_parametre IN (SELECT id_parametre FROM oggdmde.parametre_e WHERE nom_parametre='NOMCOMPOSANT')
	) v3 ON v3.id_groupe = i.id_groupe
;



COMMIT;