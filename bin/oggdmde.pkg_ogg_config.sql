ALTER SESSION SET CURRENT_SCHEMA=OGGDMDE;



CREATE OR REPLACE PACKAGE PKG_OGG_CONFIG
IS

	cste_type_tbs_indx			CONSTANT TYPE_TBS_R.LIB_TYPE_TBS%TYPE := 'INDEX';
	cste_type_tbs_donnee		CONSTANT TYPE_TBS_R.LIB_TYPE_TBS%TYPE := 'DONNEE';

	cste_type_base_staging		CONSTANT TYPE_BASE_R.LIB_TYPE_BASE%TYPE := 'STAGING';
	cste_type_base_source		CONSTANT TYPE_BASE_R.LIB_TYPE_BASE%TYPE := 'SOURCE';
	cste_type_base_cible		CONSTANT TYPE_BASE_R.LIB_TYPE_BASE%TYPE := 'CIBLE';
	
	cste_type_obj_gg_ddl		CONSTANT TYPE_CODE_R.LIB_TYPE_CODE%TYPE := 'DDL';
	cste_type_obj_gg_extr		CONSTANT TYPE_CODE_R.LIB_TYPE_CODE%TYPE := 'EXTR';
	cste_type_obj_gg_repl		CONSTANT TYPE_CODE_R.LIB_TYPE_CODE%TYPE := 'REPL';
	cste_type_obj_gg_init		CONSTANT TYPE_CODE_R.LIB_TYPE_CODE%TYPE := 'INIT';
	cste_type_obj_gg_tran		CONSTANT TYPE_CODE_R.LIB_TYPE_CODE%TYPE := 'TRAN';

	cste_extension_fic_obj_sql		CONSTANT TYPE_EXT_FICHIER_R.LIB_TYPE_EXT_FICHIER%TYPE := 'sql';
	cste_extension_fic_obj_prm		CONSTANT TYPE_EXT_FICHIER_R.LIB_TYPE_EXT_FICHIER%TYPE := 'prm';
	cste_type_rechargement			CONSTANT VARCHAR2(30) := 'RECHARGEMENT';
	cste_type_chargement_initial	CONSTANT VARCHAR2(30) := 'CHARGEMENT_INITIAL';
	
	cste_tstatut_dmde_a_faire	CONSTANT TYPE_STATUT_DMDE_R.LIB_TYPE_STATUT_DMDE%TYPE := 'A_FAIRE';
	cste_tstatut_dmde_encours	CONSTANT TYPE_STATUT_DMDE_R.LIB_TYPE_STATUT_DMDE%TYPE := 'EN_COURS';
	cste_tstatut_dmde_succes	CONSTANT TYPE_STATUT_DMDE_R.LIB_TYPE_STATUT_DMDE%TYPE := 'TRAITEE_AVEC_SUCCES';
	cste_tstatut_dmde_echec		CONSTANT TYPE_STATUT_DMDE_R.LIB_TYPE_STATUT_DMDE%TYPE := 'TRAITEE_EN_ECHEC';
	

	IdDemandeCourante NUMBER := -1;
	idDmdeTableCourante NUMBER := -1;
	
	-- ----------------------------------------------------------------------------
	FUNCTION SI_EXISTE_PROJET_BASE_SCHEMA (
		pNomProjet	IN VARCHAR2,
		pNomBase	IN VARCHAR2,
		pNomSchema	IN VARCHAR2
	) RETURN BOOLEAN;

	FUNCTION SI_CHARGEMENT_AVEC_SUPPRESSION(
		pLibTypeChargement IN VARCHAR2
	) RETURN BOOLEAN;

	FUNCTION RENVOYER_NOM_FICHIER_SANS_EXT (
		pNomBaseCible	IN VARCHAR2,
		pNomSchemacible	IN VARCHAR2,
		pNomTable		IN VARCHAR2,
		pLibTypeCodeGG	IN VARCHAR2
	) RETURN VARCHAR2;
		
	FUNCTION RENVOYER_NOM_FICHIER (
		pNomBaseCible	IN VARCHAR2,
		pNomSchemacible	IN VARCHAR2,
		pNomTable		IN VARCHAR2,
		pLibTypeCodeGG	IN VARCHAR2
	) RETURN VARCHAR2;
	
	PROCEDURE ajouter_type_environnement_r (pLibType IN VARCHAR2);
	PROCEDURE ajouter_type_parametre_r (pLibType IN VARCHAR2);
	PROCEDURE ajouter_type_composant_r (pLibType IN VARCHAR2);
	PROCEDURE ajouter_type_code_r (pLibType IN VARCHAR2);
	PROCEDURE ajouter_type_tbs_r (pLibType IN VARCHAR2);
	PROCEDURE ajouter_type_objet_r (pLibType IN VARCHAR2);
	PROCEDURE ajouter_type_demande_r (pLibType IN VARCHAR2);
	PROCEDURE ajouter_type_action_r (pLibType IN VARCHAR2);
	PROCEDURE ajouter_type_base_r (pLibType IN VARCHAR2);
	PROCEDURE ajouter_schema_r (pNomSchema IN VARCHAR2);
	PROCEDURE ajouter_projet_r (pNomProjet IN VARCHAR2);

	PROCEDURE ajouter_tbs_e (pNomTbs IN VARCHAR2, pIdTypeTbs IN NUMBER );
	PROCEDURE ajouter_tbs (pNomTbs IN VARCHAR2, pLibTypeTbs IN VARCHAR2 );

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_base_e (pNomBase IN VARCHAR2, pIdTypeBase IN NUMBER );
	PROCEDURE ajouter_base (pNomBase IN VARCHAR2, pLibTypeBase IN VARCHAR2 );

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_base_schema_a (pIdBase IN NUMBER, pIdSchema IN NUMBER );
	PROCEDURE ajouter_base_schema (pNomBase IN VARCHAR2, pNomSchema IN VARCHAR2);

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_base_schema_tbs_a (
		pIdBaseSchema	IN NUMBER ,
		pIdTbs			IN NUMBER
	);
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_base_schema_tbs (
		pNomBase	IN VARCHAR2,
		pNomSchema	IN VARCHAR2,
		pNomTbs		IN VARCHAR2
	);

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_projet_detail_a (
		pIdProjet			IN NUMBER,
		pIdBaseSchemaSource	IN NUMBER,
		pIdBaseSchemaCible	IN NUMBER
	);

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_projet_detail (
		pNomprojet		IN VARCHAR2,
		pBaseSource		IN VARCHAR2,
		pSchemaSource	IN VARCHAR2,
		pBaseCible		IN VARCHAR2,
		pSchemaCible	IN VARCHAR2
	);

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_demande_e (
		pIdProjet		IN NUMBER,
		pDateDmde		IN DATE,
		pDateTrt		IN DATE,
		pCommentaire	IN VARCHAR2
	);

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_demande (
		pNomProjet		IN VARCHAR2,
		pCommentaire	IN VARCHAR2
	);

	FUNCTION donner_id_dmde_courante
		RETURN NUMBER;
		
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tables_e (
		pIdDemandes			IN NUMBER,
		pIdBaseSchemaSource	IN NUMBER,
		pIdBaseSchemaCible	IN NUMBER,
		pIdTypeAction		IN NUMBER,
		pIdTypeChargement	IN NUMBER,
		pNomTable			IN VARCHAR2
	);

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tables (
		pIdDemandes			IN NUMBER,
		pBaseSource			IN VARCHAR2,
		pSchemaSource		IN VARCHAR2,
		pBaseCible			IN VARCHAR2,
		pSchemacible		IN VARCHAR2,
		pLibTypeAction		IN VARCHAR2,
		pLibTypeChargement	IN VARCHAR2,
		pNomTable			IN VARCHAR2
	);

		
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_colonnes_e (
		pIdDmdeTable	NUMBER,
		pIdTypeDemande	NUMBER,
		pNomColSource	VARCHAR2,
		pNomColCible	VARCHAR2
	);

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_colonnes (
		pIdDmdeTable	NUMBER,
		pLibTypeDemande	VARCHAR2,
		pNomColSource	VARCHAR2,
		pNomColCible	VARCHAR2
	);

-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_code_e (
		pIdDmdeTables	IN NUMBER,
		pIdTypeCode		IN NUMBER,
		pCode			IN CLOB
	);

-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_code (
		pIdDmdeTables	IN NUMBER,
		pLibTypeCode	IN VARCHAR2,
		pCode			IN CLOB
	);
	
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_code_init (
		pIdDmdeTables	IN NUMBER,
		pCode			IN CLOB
	);

	-- ----------------------------------------------------------------------------
	PROCEDURE AJOUTER_DMDE_TAB_CODE_DDL (
		pIdDmdeTables	IN NUMBER,
		pCode			IN CLOB
	);

-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_filtre_e (
		pIdDmdeTables	IN NUMBER,
		pNomcolonne		IN VARCHAR2,
		pFiltre			IN CLOB
	);

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_a_traiter_e (
		pIdDmdeTables		IN NUMBER,
		pIdTypeStatutDmde	IN NUMBER,
		pFaitLe				IN DATE
	);
	
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_a_traiter_afaire (
		pIdDmdeTables		IN NUMBER,
		pFaitLe				IN DATE
	);

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_parametre_e (
		pIdTypeParametre	oggdmde.parametre_e.id_type_parametre%type ,
		pNomParametre		oggdmde.parametre_e.nom_parametre%type 
	);

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_parametre (
		pLibTypeParametre	oggdmde.type_parametre_r.lib_type_parametre%type ,
		pNomParametre		oggdmde.parametre_e.nom_parametre%type 
	);

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_composant_e (
		pIdTypeComposant	oggdmde.composant_e.id_type_composant%type ,
		pNomComposant		oggdmde.composant_e.nom_composant%type 
	);

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_composant (
		pLibTypeComposant	oggdmde.type_composant_r.lib_type_composant%type ,
		pNomComposant		oggdmde.composant_e.nom_composant%type 
	);
	
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_composant_parametre_a (
		pIdProjet 				oggdmde.composant_parametre_a.id_projet%TYPE,
		pIdTypeEnvironnement	oggdmde.composant_parametre_a.id_type_environnement%TYPE,
		pIdComposant			oggdmde.composant_parametre_a.id_composant%TYPE,
		pIdParametre			oggdmde.composant_parametre_a.id_parametre%TYPE,
		pValeur					oggdmde.composant_parametre_a.valeur%TYPE
	);

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_composant_parametre (
		pNomProjet 				oggdmde.projet_r.nom_projet%TYPE,
		pLibTypeEnvironnement	oggdmde.type_environnement_r.lib_type_environnement%TYPE,
		pNomComposant			oggdmde.composant_e.nom_composant%TYPE,
		pNomParametre			oggdmde.parametre_e.nom_parametre%TYPE,
		pValeur					oggdmde.composant_parametre_a.valeur%TYPE 
	);


-- ----------------------------------------------------------------------------

	FUNCTION donner_id_dmde_table_courante
		RETURN NUMBER;	
-- ----------------------------------------------------------------------------
	FUNCTION donner_lien_base (
		pNomBase IN VARCHAR2,
		pNomSchema IN VARCHAR2
	) RETURN VARCHAR2;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_projet(
		pNomProjet IN oggdmde.projet_r.nom_projet%type
	) RETURN NUMBER;
	
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_environnement (
		pLibTypeEnvironnement IN VARCHAR2
	) RETURN NUMBER;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_chargement (
		pLibTypeChargement IN VARCHAR2
	) RETURN NUMBER;
	
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_Parametre (
		pNomParametre IN VARCHAR2
	) RETURN NUMBER;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_identifiant_ligne (
		pSchema 		IN dba_tab_columns.owner%TYPE,
		pNomTable 		IN dba_tab_columns.table_name%TYPE,
		pNomColonneID	IN dba_tab_columns.column_name%TYPE,
		pNomColValeur	IN dba_tab_columns.column_name%TYPE,
		pValeur 		IN VARCHAR2
	) RETURN NUMBER;
	
	-- ----------------------------------------------------------------------------
	PROCEDURE donner_info_tbs_schema (
		pNomBase	IN VARCHAR2,
		pNomSchema	IN VARCHAR2,
		pTbsDonnees	OUT VARCHAR2,
		pTbsIndex	OUT VARCHAR2
	);

	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_action (
		pLibTypeAction IN VARCHAR2
	) RETURN NUMBER;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_tbs_donnee (
		pNomBase	IN VARCHAR2,
		pNomSchema	IN VARCHAR2
	) RETURN VARCHAR2;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	FUNCTION donner_tbs_indx (
		pNomBase	IN VARCHAR2,
		pNomSchema	IN VARCHAR2
	) RETURN VARCHAR2;

	FUNCTION donner_id_tbs(
		pNomTbs IN oggdmde.type_tbs_r.lib_type_tbs%type
	) RETURN NUMBER;
	
	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_baseschema (
		pNomBase	IN VARCHAR2,
		pNomSchema	IN VARCHAR2
	) RETURN NUMBER;


	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_dmde (
		pLibTypeDmde IN VARCHAR2
	) RETURN NUMBER;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_code(
		pLibTypeCode IN VARCHAR2
	) RETURN NUMBER;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_ext_fichier(
		pLibTypeExtFic IN  VARCHAR2
	) RETURN NUMBER;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_lib_complet_type_code (
		pLibTypeCode	IN VARCHAR2
	) RETURN VARCHAR2;
	
	-- ----------------------------------------------------------------------------
	FUNCTION donner_lib_ext_pour_type_code (
		pLibTypeCode IN VARCHAR2
	) RETURN VARCHAR2;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_composant(
		pNomComposant IN oggdmde.composant_e.nom_composant%type
	) RETURN NUMBER;
	
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_parametre(
		pLibtypeParametre IN  oggdmde.type_parametre_r.lib_type_parametre%type
	) RETURN NUMBER;
	
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_composant(
		pLibTypeComposant IN oggdmde.type_composant_r.lib_type_composant%type
	) RETURN NUMBER;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_schema (
		pNomSchema IN VARCHAR2
	) RETURN NUMBER;
	
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_base (
		pNomBase IN VARCHAR2
	) RETURN NUMBER;
	
	-- ----------------------------------------------------------------------------
	FUNCTION DONNER_ID_TYPE_STATUT_DMDE (
		pLibTypeStatutDmde IN type_statut_dmde_r.lib_type_statut_dmde%type
	) RETURN NUMBER;
	
	-- ----------------------------------------------------------------------------
	FUNCTION DONNER_ID_TSTATUT_DMDE_AFAIRE
		RETURN NUMBER;

	-- ----------------------------------------------------------------------------
	FUNCTION DONNER_ID_TSTATUT_DMDE_ENCOURS
		RETURN NUMBER;
		
	-- ----------------------------------------------------------------------------
	FUNCTION DONNER_ID_TSTATUT_DMDE_SUCCES
		RETURN NUMBER;
		
	-- ----------------------------------------------------------------------------
	FUNCTION DONNER_ID_TSTATUT_DMDE_ECHCEC
		RETURN NUMBER;

	-- ----------------------------------------------------------------------------
	FUNCTION RENVOYER_COLONNE_SCHEMA_SOURCE 
		RETURN VARCHAR2;

	-- ----------------------------------------------------------------------------
	FUNCTION RENVOYER_COLONNE_SCHEMA_CIBLE
		RETURN VARCHAR2;
	


	-- ----------------------------------------------------------------------------
END; -- PACKAGE PKG_OGG_CONFIG
/

CREATE OR REPLACE PACKAGE BODY OGGDMDE.PKG_OGG_CONFIG
IS
	
	-- --------------------------------------------------------------------------
	FUNCTION donner_identifiant_ligne (
		pSchema 		IN dba_tab_columns.owner%TYPE,
		pNomTable 		IN dba_tab_columns.table_name%TYPE,
		pNomColonneID	IN dba_tab_columns.column_name%TYPE,
		pNomColValeur	IN dba_tab_columns.column_name%TYPE,
		pValeur 		IN VARCHAR2
	) RETURN NUMBER
	IS
		codeSQL VARCHAR2(32000);
		nbLignes NUMBER;
		idLigne NUMBER;
	BEGIN
		SELECT Count(1) INTO nbLignes 
			FROM dba_tab_columns
			WHERE owner = upper(pSchema) AND table_name = upper(pNomTable)
				AND  ( column_name = upper(pNomColonneID) or column_name = upper(pNomColValeur) );
		IF (nbLignes <> 2) THEN
			oggdmde.pkg_ogg_commun.afficher_message_ko('donner_identifiant_ligne() <nbligne !=2>');
		END IF;
		codeSQL := 'select  '||pNomColonneID||' from ' ||pSchema||'.'||pNomTable||' where '||pNomColValeur ||' = :1';
		EXECUTE IMMEDIATE codeSQL INTO idLigne USING pValeur;
		RETURN idLigne;
		
		EXCEPTION 
            WHEN OTHERS THEN
                RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE donner_info_tbs_schema (
		pNomBase	IN VARCHAR2,
		pNomSchema	IN VARCHAR2,
		pTbsDonnees	OUT VARCHAR2,
		pTbsIndex	OUT VARCHAR2
	) AS
	BEGIN
		pTbsDonnees := NULL;
		pTbsIndex := NULL;
		FOR curs IN (SELECT nom_tbs, lib_type_tbs
			FROM oggdmde.v_schemas_details
			WHERE nom_base = pNomBase AND nom_schema = pNomSchema
		)
		LOOP
			IF ( curs.lib_type_tbs = cste_type_tbs_indx) THEN
				pTbsIndex := curs.nom_tbs;
			END IF;
			IF ( curs.lib_type_tbs = cste_type_tbs_donnee) THEN
				pTbsDonnees := curs.nom_tbs;
			END IF;
		END LOOP;

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
		
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	FUNCTION donner_tbs_donnee (
		pNomBase IN VARCHAR2,
		pNomSchema IN VARCHAR2
	) RETURN VARCHAR2
	IS
		tbsDonnee	VARCHAR2(30);
		tbsIndex	VARCHAR2(30);
	BEGIN
		donner_info_tbs_schema(pNomBase, pNomSchema, tbsDonnee, tbsIndex);
		RETURN tbsDonnee;
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	FUNCTION donner_tbs_indx (
		pNomBase IN VARCHAR2,
		pNomSchema IN VARCHAR2
	) RETURN VARCHAR2
	IS
		tbsDonnee	VARCHAR2(30);
		tbsIndex	VARCHAR2(30);
	BEGIN
		donner_info_tbs_schema(pNomBase, pNomSchema, tbsDonnee, tbsIndex);
		RETURN tbsIndex;
	END;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_schema (
		pNomSchema IN VARCHAR2
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','schema_r','id_schema','nom_schema', pNomSchema);
	END;
	
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_base (
		pNomBase IN VARCHAR2
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','base_e','id_base','nom_base', pNomBase);
	END;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_action (
		pLibTypeAction IN VARCHAR2
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','type_action_r','id_type_action','lib_type_action', pLibTypeAction);
	END;
	
	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_baseschema (
		pNomBase	IN VARCHAR2,
		pNomSchema	IN VARCHAR2
	) RETURN NUMBER
	IS
		idBaseSchema base_schema_a.id_base_schema%TYPE;
	BEGIN
		SELECT id_base_schema INTO idBaseSchema
			FROM oggdmde.v_bases_schemas v
			WHERE v.nom_schema = pNomSchema AND v.nom_base = pNomBase;
		RETURN idBaseSchema;
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_dmde (
		pLibTypeDmde	IN VARCHAR2
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','type_demande_r','id_type_demande','lib_type_demande', pLibTypeDmde);
	END;

	
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_code(
		pLibTypeCode IN  VARCHAR2
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','type_code_r','id_type_code','lib_type_code', pLibTypeCode);
	END;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_ext_fichier(
		pLibTypeExtFic IN  VARCHAR2
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','type_ext_fichier_r'
			,'id_type_ext_fichier','lib_type_ext_fichier', pLibTypeExtFic);
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	FUNCTION donner_lib_ext_pour_type_code (
		pLibTypeCode	IN VARCHAR2
	) RETURN VARCHAR2
	IS
		libTypeExt VARCHAR2(128);
	BEGIN
		SELECT lib_type_ext_fichier INTO libTypeExt
			FROM oggdmde.v_code_ext_fic v
			WHERE v.lib_type_code = pLibTypeCode;
		RETURN libTypeExt;
		
		EXCEPTION
			WHEN OTHERS THEN
				RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	FUNCTION donner_lib_complet_type_code (
		pLibTypeCode	IN VARCHAR2
	) RETURN VARCHAR2
	IS
		libelle_complet_type_code VARCHAR2(128);
	BEGIN
		SELECT libelle_complet INTO libelle_complet_type_code
			FROM oggdmde.v_code_ext_fic v
			WHERE v.lib_type_code = pLibTypeCode;
		RETURN libelle_complet_type_code;
		
		EXCEPTION
			WHEN OTHERS THEN
				RAISE;
	END;


	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_parametre(
		pLibtypeParametre IN  oggdmde.type_parametre_r.lib_type_parametre%type
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','type_parametre_r','id_type_parametre','lib_type_parametre', pLibtypeParametre);
	END;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_composant(
		pLibTypeComposant IN oggdmde.type_composant_r.lib_type_composant%type
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','type_composant_r','id_type_composant','lib_type_composant', pLibTypeComposant);
	END;
	
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_composant(
		pNomComposant IN oggdmde.composant_e.nom_composant%type
	) RETURN NUMBER
	IS

	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','composant_e','id_composant','nom_composant', pNomComposant);
	END;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_tbs(
		pNomTbs IN oggdmde.type_tbs_r.lib_type_tbs%type
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','type_tbs_r','id_type_tbs','lib_type_tbs', pNomTbs);
	END;
	
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_base(
		pLibTypebase IN oggdmde.type_base_r.lib_type_base%type
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','type_base_r','id_type_base','lib_type_base', pLibTypebase);
	END;
	
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_projet(
		pNomProjet IN oggdmde.projet_r.nom_projet%type
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','projet_r','id_projet','nom_projet', pNomProjet);
	END;
	
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_environnement (
		pLibTypeEnvironnement IN VARCHAR2
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde',
			'type_environnement_r','id_type_environnement',
			'lib_type_environnement', pLibTypeEnvironnement);
	END;
	
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_Parametre (
		pNomParametre IN VARCHAR2
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','parametre_e',
		'id_parametre','nom_parametre', pNomParametre);
	END;

	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_type_chargement (
		pLibTypeChargement IN VARCHAR2
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','type_chargement_r',
		'id_type_chargement','lib_type_chargement', pLibTypeChargement);
	END;
	
	-- ----------------------------------------------------------------------------
	FUNCTION DONNER_ID_TYPE_STATUT_DMDE (
		pLibTypeStatutDmde IN type_statut_dmde_r.lib_type_statut_dmde%type
	) RETURN NUMBER
	IS
	BEGIN
		RETURN donner_identifiant_ligne('oggdmde','type_statut_dmde_r',
			'id_type_statut_dmde','lib_type_statut_dmde', pLibTypeStatutDmde);
	END;
	
	-- ----------------------------------------------------------------------------
	FUNCTION DONNER_ID_TSTATUT_DMDE_AFAIRE
		RETURN NUMBER
	IS
	BEGIN
		RETURN donner_id_type_statut_dmde(cste_tstatut_dmde_a_faire);
	END;

	-- ----------------------------------------------------------------------------
	FUNCTION DONNER_ID_TSTATUT_DMDE_ENCOURS
		RETURN NUMBER
	IS
	BEGIN
		RETURN donner_id_type_statut_dmde(cste_tstatut_dmde_encours);
	END;

	-- ----------------------------------------------------------------------------
	FUNCTION DONNER_ID_TSTATUT_DMDE_SUCCES
		RETURN NUMBER
	IS
	BEGIN
		RETURN donner_id_type_statut_dmde(cste_tstatut_dmde_succes);
	END;

	-- ----------------------------------------------------------------------------
	FUNCTION DONNER_ID_TSTATUT_DMDE_ECHCEC
		RETURN NUMBER
	IS
	BEGIN
		RETURN DONNER_ID_TYPE_STATUT_DMDE(cste_tstatut_dmde_echec);
	END;


	-- ----------------------------------------------------------------------------
	FUNCTION donner_lien_base (
		pNomBase IN VARCHAR2,
		pNomSchema IN VARCHAR2
	) RETURN VARCHAR2
	IS
		nomLienBase VARCHAR2(30);
	BEGIN
		SELECT nom_lien_base INTO nomLienBase
		FROM  oggdmde.v_lien_base_e
		WHERE nom_base = pNomBase AND nom_schema = pNomSchema;
		RETURN nomLienBase;
		
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;
	
	-- ----------------------------------------------------------------------------
	FUNCTION si_existe_projet_base_schema (
		pNomProjet	IN VARCHAR2,
		pNomBase	IN VARCHAR2,
		pNomSchema	IN VARCHAR2
	) RETURN BOOLEAN
	IS
		nbLignes NUMBER;
	BEGIN
		SELECT COUNT(1) INTO nbLignes
		FROM oggdmde.v_projets_details
		WHERE nom_projet = pNomProjet AND 
		(
			( base_source = pNomBase AND schema_source = pNomSchema) 
			OR 
			( base_cible = pNomBase AND schema_cible = pNomSchema)
		);
		RETURN (nbLignes > 0);
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION SI_CHARGEMENT_AVEC_SUPPRESSION(
		pLibTypeChargement IN VARCHAR2
	) RETURN BOOLEAN
	IS
	BEGIN
		RETURN (
			pLibTypeChargement = oggdmde.pkg_ogg_config.cste_type_rechargement
			OR pLibTypeChargement = oggdmde.pkg_ogg_config.cste_type_chargement_initial
		);
	END;
	
	
		-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION RENVOYER_NOM_FICHIER_SANS_EXT (
		pNomBaseCible	IN VARCHAR2,
		pNomSchemacible	IN VARCHAR2,
		pNomTable		IN VARCHAR2,
		pLibTypeCodeGG	IN VARCHAR2
	) RETURN VARCHAR2
	is
		nomFichier	VARCHAR2(128);
		typeCodeGG 	VARCHAR2(128):= pLibTypeCodeGG;
	begin
		nomFichier := pNomBaseCible||'.'||pNomSchemacible||
			'.'||typeCodeGG ||'.'||pNomTable;
			
		RETURN lower(nomFichier);
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION RENVOYER_NOM_FICHIER (
		pNomBaseCible	IN VARCHAR2,
		pNomSchemacible	IN VARCHAR2,
		pNomTable		IN VARCHAR2,
		pLibTypeCodeGG	IN VARCHAR2
	) RETURN VARCHAR2
	is
		nomFichier		VARCHAR2(128);
		typeExtension	VARCHAR2(128);
		typeCodeGG 	VARCHAR2(128):= pLibTypeCodeGG;
	begin
		typeExtension := donner_lib_ext_pour_type_code(pLibTypeCodeGG);
		nomFichier := renvoyer_nom_fichier_sans_ext(pNomBaseCible, pNomSchemacible,
			pNomTable,typeCodeGG)||'.'||typeExtension;
		RETURN lower(nomFichier);
	END;
	
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_type_environnement_r (pLibType IN VARCHAR2)
	IS
	BEGIN
		INSERT INTO oggdmde.type_environnement_r(lib_type_environnement)
		VALUES(pLibType);
		
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_type_parametre_r (pLibType IN VARCHAR2)
	IS
	BEGIN
		INSERT INTO oggdmde.type_parametre_r(lib_type_parametre)
		VALUES(pLibType);
		
		EXCEPTION
			WHEN OTHERS THEN
				RAISE;
	END;

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_type_composant_r (pLibType IN VARCHAR2)
	IS
	BEGIN
		INSERT INTO oggdmde.type_composant_r(lib_type_composant)
		VALUES(pLibType);
		
		EXCEPTION
			WHEN OTHERS THEN
				RAISE;
	END;


	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_type_code_r (pLibType IN VARCHAR2)
	IS
	BEGIN
		INSERT INTO oggdmde.type_code_r (LIB_TYPE_CODE)
			VALUES (pLibType);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;


	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_type_tbs_r (pLibType IN VARCHAR2)
	IS
	BEGIN
		INSERT INTO oggdmde.type_tbs_r (lib_type_tbs)
			VALUES (pLibType);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_type_objet_r (pLibType IN VARCHAR2)
	IS
	BEGIN
		INSERT INTO oggdmde.type_objet_r (lib_type_objet)
			VALUES (pLibType);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_type_demande_r (pLibType IN VARCHAR2)
	IS
	BEGIN
		INSERT INTO oggdmde.type_demande_r (lib_type_demande)
			VALUES (pLibType);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_type_action_r (pLibType IN VARCHAR2)
	IS
	BEGIN
		INSERT INTO oggdmde.type_action_r (lib_type_action)
			VALUES (pLibType);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_type_base_r (pLibType IN VARCHAR2)
	IS
	BEGIN
		INSERT INTO oggdmde.type_base_r (lib_type_base)
			VALUES (pLibType);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_schema_r (pNomSchema IN VARCHAR2)
	IS
	BEGIN
		INSERT INTO oggdmde.schema_r (nom_schema)
			VALUES (pNomSchema);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_projet_r (pNomProjet IN VARCHAR2)
	IS
	BEGIN
		INSERT INTO oggdmde.projet_r (nom_projet)
			VALUES (pNomProjet);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_tbs_e (pNomTbs IN VARCHAR2, pIdTypeTbs IN NUMBER )
	IS
	BEGIN
		INSERT INTO oggdmde.tbs_e (id_type_tbs, nom_tbs)
			VALUES (pIdTypeTbs, pNomTbs);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_tbs (pNomTbs IN VARCHAR2, pLibTypeTbs IN VARCHAR2)
	IS
		idTypeTbs NUMBER;
	BEGIN
		idTypeTbs := donner_id_tbs(pLibTypeTbs);
		ajouter_tbs_e(pNomTbs, idTypeTbs);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_base_e (pNomBase IN VARCHAR2, pIdTypeBase IN NUMBER )
	IS
	BEGIN
		INSERT INTO oggdmde.base_e (id_type_base, nom_base)
			VALUES (pIdTypeBase, pNombase);
		EXCEPTION
		WHEN OTHERS THEN
		RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_base (pNomBase IN VARCHAR2, pLibTypeBase IN VARCHAR2)
	IS
		idTypebase NUMBER;
	BEGIN
		idTypebase := donner_id_type_base(pLibTypeBase);
		ajouter_base_e(pNomBase, idTypebase);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_base_schema_a (pIdBase IN NUMBER, pIdSchema IN NUMBER )
	IS
	BEGIN
		INSERT INTO oggdmde.base_schema_a (id_base, id_schema)
			VALUES(pIdBase, pIdSchema);

		EXCEPTION
		WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_base_schema (
		pNomBase IN VARCHAR2,
		pNomSchema IN VARCHAR2
		)
	IS
		idTypebase NUMBER;
		idSchema NUMBER;
	BEGIN
		idTypebase := donner_id_base(pNomBase);
		idSchema := donner_id_schema(pNomSchema);
		ajouter_base_schema_a(idTypebase, idSchema);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_base_schema_tbs_a (
		pIdBaseSchema	IN NUMBER ,
		pIdTbs			IN NUMBER
	)
	IS
	BEGIN
		INSERT INTO oggdmde.base_schema_tbs_a (id_base_schema, id_tbs)
			VALUES(pIdBaseSchema, pIdTbs);

		EXCEPTION
		WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_base_schema_tbs (
		pNomBase	IN VARCHAR2,
		pNomSchema	IN VARCHAR2,
		pNomtbs		IN VARCHAR2
	)
	IS
		idBaseSchema	NUMBER;
		idTbs			NUMBER;
	BEGIN
		idBaseSchema := donner_id_baseschema(pNomBase, pNomSchema);
		idTbs := donner_id_tbs(pNomtbs);
		ajouter_base_schema_tbs_a(idBaseSchema, idTbs);

		EXCEPTION
			WHEN OTHERS THEN
				RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_projet_detail_a (
		pIdProjet			IN NUMBER,
		pIdBaseSchemaSource	IN NUMBER,
		pIdBaseSchemaCible	IN NUMBER
	)
	IS
	BEGIN
		INSERT INTO oggdmde.projet_detail_a (id_projet, id_base_schema_source, id_base_schema_cible)
			VALUES (pIdProjet, pIdBaseSchemaSource, pIdBaseSchemaCible);
			
		EXCEPTION
			WHEN OTHERS THEN
				RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_projet_detail (
		pNomprojet		IN VARCHAR2,
		pBaseSource		IN VARCHAR2,
		pSchemaSource	IN VARCHAR2,
		pBaseCible		IN VARCHAR2,
		pSchemaCible	IN VARCHAR2
	)
	IS
		idProjet		NUMBER;
		idBaseSchemaSource	NUMBER;
		idBaseSchemaCible	NUMBER;
	BEGIN
		idProjet := donner_id_projet(pNomprojet);
		idBaseSchemaCible := donner_id_baseschema(pBaseSource, pSchemaSource);
		idBaseSchemaCible := donner_id_baseschema(pBaseCible, pSchemaCible);
		ajouter_projet_detail_a(idProjet, idBaseSchemaSource, idBaseSchemaCible);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------
	PROCEDURE ajouter_demande_e (
		pIdProjet		IN NUMBER,
		pDateDmde		IN DATE,
		pDateTrt		IN DATE,
		pCommentaire	IN VARCHAR2
	)
	IS

	BEGIN
		INSERT INTO oggdmde.demandes_e (id_projet, date_dmde, date_traitement, commentaire)
		VALUES (pIdProjet, pDateDmde, pDateTrt, pCommentaire) 
			RETURNING id_demande INTO IdDemandeCourante;

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- --------------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_demande (
		pNomProjet		IN VARCHAR2,
		pCommentaire	IN VARCHAR2
	)
	IS
		idProjet NUMBER;
	BEGIN
		idProjet := donner_id_projet(pNomprojet);
		ajouter_demande_e (idProjet, SYSDATE, NULL, pCommentaire);
		
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;
	
	-- --------------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_dmde_courante
		RETURN NUMBER
	IS
	BEGIN
		RETURN IdDemandeCourante;
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tables_e (
		pIdDemandes			IN NUMBER,
		pIdBaseSchemaSource	IN NUMBER,
		pIdBaseSchemaCible	IN NUMBER,
		pIdTypeAction		IN NUMBER,
		pIdTypeChargement	IN NUMBER,
		pNomTable			IN VARCHAR2
	)
	IS
	BEGIN
		INSERT INTO oggdmde.dmde_tables_e (id_demande,
			id_base_schema_source, id_base_schema_cible,
			id_type_action, nom_table, id_type_chargement 
		) VALUES (pIdDemandes,
			pIdBaseSchemaSource, pIdBaseSchemaCible,
			pIdTypeAction, pNomTable,
			pIdTypeChargement
		) RETURNING id_dmde_table INTO idDmdeTableCourante;

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tables (
		pIdDemandes			IN NUMBER,
		pBaseSource			IN VARCHAR2,
		pSchemaSource		IN VARCHAR2,
		pBaseCible			IN VARCHAR2,
		pSchemacible		IN VARCHAR2,
		pLibTypeAction		IN VARCHAR2,
		pLibTypeChargement	IN VARCHAR2,
		pNomTable			IN VARCHAR2
	)
	IS
		idBaseSource		NUMBER;
		idBaseCIBLE			NUMBER;
		idTypeAction		NUMBER;
		idTypeChargement	NUMBER;
	BEGIN
		idBaseSource := donner_id_baseschema (pBaseSource, pSchemaSource);
		idBaseCible := donner_id_baseschema (pBaseCible, pSchemacible);
		idTypeAction := donner_id_type_action(pLibTypeAction);
		idTypeChargement := donner_id_type_chargement(pLibTypeChargement);
		ajouter_dmde_tables_e (
			pIdDemandes,
			idBaseSource, idBaseCible,
			idTypeAction,idTypeChargement,
			pNomTable
		);

		EXCEPTION
				WHEN OTHERS THEN
				RAISE;
	END;

	-- --------------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	FUNCTION donner_id_dmde_table_courante
		RETURN NUMBER
	IS
	BEGIN
		RETURN idDmdeTableCourante;
	END;


	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_colonnes_e (
		pIdDmdeTable	NUMBER,
		pIdTypeDemande	NUMBER,
		pNomColSource	VARCHAR2,
		pNomColCible	VARCHAR2
	)
	IS
	BEGIN
		INSERT INTO oggdmde.dmde_tab_colonnes_e (
			id_dmde_table,
			id_type_demande,
			nom_col_source,
			nom_col_cible
		)
		VALUES (
			pIdDmdeTable,
			pIdTypeDemande,
			pNomColSource,
			pNomColCible
		);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_colonnes (
		pIdDmdeTable	NUMBER,
		pLibTypeDemande	VARCHAR2,
		pNomColSource	VARCHAR2,
		pNomColCible	VARCHAR2
	)
	IS
		idTypeDemande NUMBER;
	BEGIN
		-- SELECT id_type_demande INTO idTypeDemande
			-- FROM oggdmde.type_demande_r
			-- WHERE  lib_type_demande = pLibTypeDemande;
		idTypeDemande:= donner_id_type_dmde(pLibTypeDemande);
		ajouter_dmde_tab_colonnes_e (
			pIdDmdeTable, idTypeDemande,
			pNomColSource, pNomColCible
		);

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_code_e (
		pIdDmdeTables	IN NUMBER,
		pIdTypeCode		IN NUMBER,
		pCode			IN CLOB
	)
	IS
	BEGIN
		INSERT INTO oggdmde.dmde_tab_code_e (id_dmde_table, id_type_code, code)
			VALUES (pIdDmdeTables, pIdTypeCode, pCode);
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_code (
		pIdDmdeTables	IN NUMBER,
		pLibTypeCode	IN VARCHAR2,
		pCode			IN CLOB
	)
	IS
		idTypeCode NUMBER; 
	BEGIN
		idTypeCode := donner_id_type_code(pLibTypeCode);
		ajouter_dmde_tab_code_e (pIdDmdeTables, idTypeCode, pCode);
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_code_init (
		pIdDmdeTables	IN NUMBER,
		pCode			IN CLOB
	) is 
	begin
	  ajouter_dmde_tab_code(pIdDmdeTables, cste_type_obj_gg_init, pCode);
	end;

	-- ----------------------------------------------------------------------------
	PROCEDURE AJOUTER_DMDE_TAB_CODE_DDL (
		pIdDmdeTables	IN NUMBER,
		pCode			IN CLOB
	) is 
	begin
	  ajouter_dmde_tab_code(pIdDmdeTables, cste_type_obj_gg_ddl, pCode);
	end;


-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_filtre_e (
		pIdDmdeTables	IN NUMBER,
		pNomcolonne		IN VARCHAR2,
		pFiltre			IN CLOB
	)
	IS
	BEGIN
		INSERT INTO oggdmde.dmde_tab_filtres_e (id_dmde_table,nom_colonne, filtre)
		VALUES (pIdDmdeTables, pNomcolonne, pFiltre);
		
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_a_traiter_e (
		pIdDmdeTables		IN NUMBER,
		pIdTypeStatutDmde	IN NUMBER,
		pFaitLe				IN DATE
	)
	AS
	BEGIN
		INSERT INTO oggdmde.dmde_tab_a_traiter_e (id_dmde_table,id_type_statut_dmde, fait_le)
			VALUES (pIdDmdeTables, pIdTypeStatutDmde, pFaitLe);
		
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_tab_a_traiter (
		pIdDmdeTables		IN NUMBER,
		pLibTypeStatutDmde	IN VARCHAR2,
		pFaitLe				IN DATE
	)
	AS
		idTypeStatutDmde NUMBER;
	BEGIN
		idTypeStatutDmde := donner_id_type_statut_dmde(pLibTypeStatutDmde);
		ajouter_dmde_tab_a_traiter_e (pIdDmdeTables,idTypeStatutDmde, pFaitLe);
		
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_dmde_a_traiter_afaire (
		pIdDmdeTables		IN NUMBER,
		pFaitLe				IN DATE
	)
	AS
	BEGIN
		ajouter_dmde_tab_a_traiter (pIdDmdeTables, cste_tstatut_dmde_a_faire, pFaitLe);
		
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_composant_e (
		pIdTypeComposant	oggdmde.composant_e.id_type_composant%type ,
		pNomComposant		oggdmde.composant_e.nom_composant%type 
	)
	AS
	BEGIN
		INSERT INTO oggdmde.composant_e (id_type_composant, nom_composant)
		VALUES(pIdTypeComposant, pNomComposant);
		
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_composant (
		pLibTypeComposant	oggdmde.type_composant_r.lib_type_composant%type ,
		pNomComposant		oggdmde.composant_e.nom_composant%type 
	)
	AS
		idTypeComposant NUMBER;
	BEGIN
		idTypeComposant := donner_id_composant(pLibTypeComposant);
		ajouter_composant_e(idTypeComposant, pNomComposant);
		
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_parametre_e (
		pIdTypeParametre	oggdmde.parametre_e.id_type_parametre%type ,
		pNomParametre		oggdmde.parametre_e.nom_parametre%type 
	)
	IS
	BEGIN
		INSERT INTO oggdmde.parametre_e  (id_type_parametre, nom_parametre)
			VALUES (pIdTypeParametre, pNomParametre);
	
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;
	
	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_parametre (
		pLibTypeParametre	oggdmde.type_parametre_r.lib_type_parametre%type ,
		pNomParametre		oggdmde.parametre_e.nom_parametre%type 
	)
	IS
		idTypeParametre oggdmde.parametre_e.id_type_parametre%type ;
	BEGIN
		idTypeParametre := donner_id_type_parametre(pLibTypeParametre);
		ajouter_parametre_e(idTypeParametre, pNomParametre);
		
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_composant_parametre_a (
		pIdProjet 				oggdmde.composant_parametre_a.id_projet%TYPE,
		pIdTypeEnvironnement	oggdmde.composant_parametre_a.id_type_environnement%TYPE,
		pIdComposant			oggdmde.composant_parametre_a.id_composant%TYPE,
		pIdParametre			oggdmde.composant_parametre_a.id_parametre%TYPE,
		pValeur					oggdmde.composant_parametre_a.valeur%TYPE
	)
	IS
	BEGIN
		INSERT INTO oggdmde.composant_parametre_a(id_projet, id_type_environnement, id_composant, id_parametre, valeur)
		VALUES (pIdProjet, pIdTypeEnvironnement, pIdComposant, pIdParametre, pValeur);
		
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE ajouter_composant_parametre (
		pNomProjet 				oggdmde.projet_r.nom_projet%TYPE,
		pLibTypeEnvironnement	oggdmde.type_environnement_r.lib_type_environnement%TYPE,
		pNomComposant			oggdmde.composant_e.nom_composant%TYPE,
		pNomParametre			oggdmde.parametre_e.nom_parametre%TYPE,
		pValeur					oggdmde.composant_parametre_a.valeur%TYPE 
	)
	IS
		idProjet 			oggdmde.composant_parametre_a.id_projet%TYPE;
		idTypeEnvironnement	oggdmde.composant_parametre_a.id_type_environnement%TYPE;
		idComposant			oggdmde.composant_parametre_a.id_composant%TYPE;
		idParametre			oggdmde.composant_parametre_a.id_parametre%TYPE;
	BEGIN

		iDProjet := donner_id_projet(pNomProjet);
		idTypeEnvironnement := donner_id_type_environnement(pLibTypeEnvironnement);
		idComposant := donner_id_composant(pNomComposant);
		idParametre := donner_id_Parametre(pNomParametre);
		ajouter_composant_parametre_a (idProjet, idTypeEnvironnement, idComposant, idParametre, pValeur);
		
		EXCEPTION
			WHEN OTHERS THEN
			RAISE;
	END;
	
	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------	
	FUNCTION RENVOYER_NOM_COLONNE_TYPE_BASE (
		pLibTypeBase	IN VARCHAR2
	) RETURN VARCHAR2
	IS 
		nomColonne VARCHAR2(30);
	BEGIN
	 	IF (pLibTypeBase = cste_type_base_cible) THEN
			nomColonne := 'schema_cible';
		ELSIF (pLibTypeBase = cste_type_base_source) THEN
			nomColonne := 'schema_source';
		ELSE
			nomColonne := NULL;
		END IF;
		RETURN nomColonne;	 
	END;

	-- ----------------------------------------------------------------------------
	FUNCTION RENVOYER_COLONNE_SCHEMA_SOURCE 
		RETURN VARCHAR2
	IS 
	BEGIN 
		return RENVOYER_NOM_COLONNE_TYPE_BASE(cste_type_base_source);
	END;

	-- ----------------------------------------------------------------------------
	FUNCTION RENVOYER_COLONNE_SCHEMA_CIBLE
		RETURN VARCHAR2
	IS 
	BEGIN 
		return RENVOYER_NOM_COLONNE_TYPE_BASE(cste_type_base_cible);
	END;


END ;
/