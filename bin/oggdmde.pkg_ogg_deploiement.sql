ALTER SESSION SET CURRENT_SCHEMA=OGGDMDE;

--grant select on dba_tables  to OGGDMDE;
--grant select on dba_cons_columns  to OGGDMDE;
--grant select on dba_constraints  to OGGDMDE;
--grant select on dba_objects  to OGGDMDE;
--grant select on dba_tab_columns  to OGGDMDE;
--grant select on dba_log_group_columns  to OGGDMDE;

-- ============================================================================
CREATE OR REPLACE PACKAGE PKG_OGG_DEPLOIEMENT
-- ============================================================================
IS

	

	-- ----------------------------------------------------------------------------
	PROCEDURE DEPLOYER_VIA_SQL;

	-- ----------------------------------------------------------------------------
	PROCEDURE DEPLOYER_VIA_MAKEFILE;

END;
/

	-- ============================================================================
	-- 
	-- ============================================================================
CREATE OR REPLACE PACKAGE BODY PKG_OGG_DEPLOIEMENT
IS

	TYPE TINFO_CLEPRIMAIRE IS RECORD (
		nom_schema		VARCHAR2(30),
		nom_table		VARCHAR2(30),
		nom_cleprimaire	VARCHAR2(30),
		liste_colonnes	VARCHAR2(4000)
	);

	-- on redeclare la constante en local pour éviter des appels incessants
	cste_car_retour_ligne		CONSTANT CHAR(1) := oggdmde.pkg_ogg_commun.cste_caractere_retour_ligne;
	cste_car_tabulation			CONSTANT CHAR(1) := oggdmde.pkg_ogg_commun.cste_caractere_tabulation;

	cste_car_espace				CONSTANT CHAR(1) := oggdmde.pkg_ogg_commun.cste_caractere_espace;
	cste_sep_fin_cmde			CONSTANT VARCHAR2(4) := oggdmde.pkg_ogg_commun.cste_caractere_fin_cmde ||cste_car_retour_ligne;
	cste_separateur_bloc		CONSTANT VARCHAR2(60) := cste_car_retour_ligne || rpad('-- ',50,'+') || cste_car_retour_ligne;
	cste_separateur_commentaire	CONSTANT VARCHAR2(60) := cste_car_retour_ligne || rpad('-- ',50,'-') || cste_car_retour_ligne;
	cste_sep_colonne_ret_ligne	CONSTANT CHAR(2) := oggdmde.pkg_ogg_commun.cste_caractere_sep_virgule||cste_car_retour_ligne;

	cst_choix_interface_OS	 CONSTANT VARCHAR2(15) := 'INTERFACE_OS';
	cst_choix_interface_SQL	 CONSTANT VARCHAR2(15) := 'INTERFACE_SQL';
	cste_fic_extention_sql  CONSTANT VARCHAR2(5) := 'sql';
	cste_fic_extention_ok   CONSTANT VARCHAR2(5) := 'ok';


	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	FUNCTION FORMATTER_NOM_CLEPRIMAIRE (
		pNomTable IN VARCHAR2
	) RETURN VARCHAR2
	IS 
	BEGIN 
		RETURN substr(pNomTable, 1, 27)||'_PK';
	END;

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	FUNCTION FORMATER_FILTRE_EXTRACTION (
		pNomColonne IN VARCHAR2,
		pTypeDonnee IN VARCHAR2,
		pValeurFiltre  IN VARCHAR2
	) RETURN  VARCHAR2
	IS
		filtre VARCHAR2(8000);
	BEGIN
		CASE pTypeDonnee
			WHEN 'DATE' THEN 
				filtre := '(@DATE(''JUL'', ''YYYY-MM-DD'', '||pNomColonne||') >= @DATE(''JUL'', ''YYYY-MM-DD'', '''||pValeurFiltre||'''))';
			WHEN 'VARCHAR2' THEN
				filtre := '@STREQ ("'||pNomColonne||'", ''||pValeurFiltre||'') > 0';
			ELSE 
				RAISE CASE_NOT_FOUND;
		END CASE;
		RETURN filtre;
	END;


	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION FORMATER_SQL_DDL_COLONNE(
		pNomColonne IN dba_tab_columns.column_name%TYPE,
		pTypeDonnee IN dba_tab_columns.data_type%TYPE,
		pPrecision  IN dba_tab_columns.data_precision%TYPE,
		pLongueur   IN dba_tab_columns.data_length%TYPE,
		pEchelle    IN dba_tab_columns.data_scale%TYPE
	) RETURN VARCHAR2
	IS
		ddlColonne VARCHAR2(512);
	BEGIN
		IF (pTypeDonnee = 'NUMBER') THEN
			IF (pPrecision IS NULL) then
				ddlColonne := TO_CHAR(pLongueur);
			ELSE
				ddlColonne := TO_CHAR(pPrecision)||','||TO_CHAR(pEchelle);
			END IF;
			ddlColonne := pNomColonne ||' NUMBER(' || ddlColonne || ')';
		ELSIF (pTypeDonnee = 'VARCHAR2' ) THEN
			ddlColonne := pNomColonne ||' VARCHAR2('||TO_CHAR(pLongueur)||')';
		ELSIF (pTypeDonnee = 'CHAR' ) THEN
			ddlColonne := pNomColonne ||' CHAR('||TO_CHAR(pLongueur)||')';
		ELSE
			ddlColonne := pNomColonne || ' '||pTypeDonnee;
		END IF;
		RETURN ddlColonne;
	END;



	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION CONSTRUIRE_DDL_CLEPRIMAIRE (
		pSchema					IN VARCHAR2,
		pTable					IN VARCHAR2,
		pNomClePrimaire			IN VARCHAR2,
		pListeColClePrimaire	IN VARCHAR2,
		pTbsIndex				IN VARCHAR2
	) RETURN VARCHAR2
	IS
		codeDDL VARCHAR2(32000);
		clePrimaire VARCHAR2(80);
		schemaTable VARCHAR2(80);
	BEGIN
		clePrimaire := pSchema||'.'||pNomClePrimaire;
		schemaTable :=  pSchema||'.'||pTable;
		codeDDL := 'CREATE UNIQUE INDEX '|| clePrimaire || cste_car_retour_ligne;
		codeDDL := codeDDL || ' ON ' ||schemaTable||' ('||cste_car_retour_ligne;
		codeDDL := codeDDL || pListeColClePrimaire || cste_car_retour_ligne|| ' )' || cste_car_retour_ligne
		codeDDL := codeDDL || ' TABLESPACE '||pTbsIndex|| cste_car_retour_ligne ||'NOPARALLEL; ';

		codeDDL := codeDDL || cste_separateur_bloc || cste_car_retour_ligne;
		codeDDL := codeDDL || 'ALTER TABLE ' ||schemaTable|| ' ADD ('|| cste_car_retour_ligne;
		codeDDL := codeDDL || '   ( CONSTRAINT ' || pNomClePrimaire || cste_car_retour_ligne || ' PRIMARY KEY ('|| cste_car_retour_ligne;
		codeDDL := codeDDL || pListeColClePrimaire||' )'|| cste_car_retour_ligne;
		codeDDL := codeDDL || '    USING INDEX '||clePrimaire|| ' ENABLE VALIDATE'
		codeDDL := codeDDL ||  cste_car_retour_ligne||');';
		RETURN codeDDL;
	END;

	-- -----------------------------------------------------------------------------
	-- PUBLIQUE
	-- -----------------------------------------------------------------------------
	FUNCTION CONSTRUIRE_DDL_CREATION_TABLE(
		pSchema					IN VARCHAR2,
		pTable					IN VARCHAR2,
		pDdlColonnes			IN VARCHAR2,
		pNomclePrimaire			IN VARCHAR2,
		pColonnesClePrimaire	IN VARCHAR2,
		pTbsDonnee				IN VARCHAR2,
		pTbsIndex				IN VARCHAR2
	) RETURN VARCHAR2
	IS 
		codeDDL VARCHAR2(32000);
		codeSQLClePrimaire VARCHAR2(32000);
	BEGIN
		codeDDL := 'CREATE TABLE '|| pSchema ||'.'||pTable|| ' ('||cste_car_retour_ligne;
		codeDDL := codeDDL || pDdlColonnes ||')'|| cste_car_retour_ligne;
		codeDDL := codeDDL || ' TABLESPACE '||pTbsDonnee ||cste_sep_fin_cmde;
		CodeDDL := codeDDL || cste_separateur_bloc;
		codeSQLClePrimaire := construire_ddl_cleprimaire (pSchema, pTable, pNomclePrimaire, pColonnesClePrimaire, pTbsIndex);
		codeDDL := codeDDL || codeSQLClePrimaire;
		RETURN CodeDDL;
	END;

	-- -----------------------------------------------------------------------------
	-- PUBLIQUE
	-- -----------------------------------------------------------------------------
	FUNCTION CONSTRUIRE_DDL_CREATION_COL (
		pSchema					IN VARCHAR2,
		pTable					IN VARCHAR2,
		pDdlColonnes			IN VARCHAR2
	) RETURN VARCHAR2
	IS 
		codeDDL VARCHAR2(32000);
	BEGIN
		codeDDL := 'ALTER TABLE '|| pSchema ||'.'||pTable|| ' ADD ('||cste_car_retour_ligne;
		codeDDL := codeDDL || pDdlColonnes ||')'|| cste_sep_fin_cmde;
		RETURN CodeDDL;	  
	END;

	-- -----------------------------------------------------------------------------
	-- PUBLIQUE
	-- -----------------------------------------------------------------------------
	FUNCTION CONSTRUIRE_DDL_SUPPRESSION_COL (
		pSchema			IN VARCHAR2,
		pTable			IN VARCHAR2,
		pListeColonnes	IN VARCHAR2
	) RETURN VARCHAR2
	IS 
		codeDDL VARCHAR2(32000);
	BEGIN
		codeDDL := 'ALTER TABLE '|| pSchema ||'.'||pTable|| ' DROP  ('||cste_car_retour_ligne;
		codeDDL := codeDDL || pListeColonnes ||')'|| cste_sep_fin_cmde;
		RETURN CodeDDL;	  
	END;

	-- -------------------------------------------------------------------------
	-- PRIVEE
	-- -------------------------------------------------------------------------
	FUNCTION CONSTRUIRE_DDL_CHARGE_TABLE (
		pNomTable		IN VARCHAR2,
		pBaseSource		IN VARCHAR2,
		pSchemaSource	IN VARCHAR2,
		pListeColSource	IN VARCHAR2,
		pSchemaCible	IN VARCHAR2,
		pListeColCible	IN VARCHAR2,
		pSiViderTable	BOOLEAN
	) RETURN VARCHAR2
	IS 
	BEGIN
		IF (pSiViderTable)  THEN
			codeSQL := cste_separateur_bloc|| 'TRUNCATE TABLE '||pSchemaCible||'.'||pNomTable||Chr(10);
		ELSE
			codeSQL := cste_separateur_bloc||'-- pas de suppression de donnees avant operation !?'||Chr(10);
		END IF;
		
		codeSQL := 'INSERT INTO '||pSchemaCible||'.'||pNomTable;
		codeSQL := codeSQL|| '('||cste_car_retour_ligne||pListeColCible||')'||cste_car_retour_ligne;
		codeSQL := codeSQL|| 'SELECT '||cste_car_retour_ligne||pListeColSource|| cste_car_retour_ligne;
		codeSQL := codeSQL|| ' FROM '||pSchemaSource||'.'||pNomTable||'@'||pBaseSource||cste_sep_fin_cmde;
		codeSQL := codeSQL|| 'COMMIT'||cste_sep_fin_cmde;	  
		RETURN codeSQL;	  
	END;

	-- -------------------------------------------------------------------------
	-- PRIVEE
	-- -------------------------------------------------------------------------
	FUNCTION CONSTRUIRE_PRM_REPLI_SOURCE (
		pTable			IN VARCHAR2,
		pSchemaSource	IN VARCHAR2,
		pSchemaCible	IN VARCHAR2,
		pListeColFormatees IN VARCHAR2
	) RETURN VARCHAR2
	IS 
		codePrm VARCHAR2(32000);
	BEGIN
		codePrm := 'MAP '||pSchemaSource||'.'||pTable||', TARGET '
			||pSchemaCible||'.'||pTable||cste_car_retour_ligne
			||',COLMAP ('||cste_car_retour_ligne
			|| pListeColFormatees ||cste_car_retour_ligne
			|| ')'||cste_car_retour_ligne
			||',COMPARECOLS (ON UPDATE KEY, ON DELETE KEY)'||cste_car_retour_ligne
			||',RESOLVECONFLICT (INSERTROWEXISTS, (DEFAULT, DISCARD))'||cste_car_retour_ligne
			||',RESOLVECONFLICT (UPDATEROWMISSING, (DEFAULT, OVERWRITE))'||cste_car_retour_ligne
			||',RESOLVECONFLICT (UPDATEROWEXISTS, (DEFAULT, OVERWRITE))'||cste_car_retour_ligne
			||',RESOLVECONFLICT (DELETEROWMISSING, (DEFAULT, DISCARD))'||cste_car_retour_ligne
			||';'||cste_car_retour_ligne;;
	  	RETURN codePrm;
	END;

	-- -------------------------------------------------------------------------
	-- PRIVEE
	-- -------------------------------------------------------------------------
	FUNCTION CONSTRUIRE_PRM_EXTRACT_SOURCE (
		pTable			IN VARCHAR2,
		pSchemaSource	IN VARCHAR2,
		pFiltre			IN VARCHAR2
	) RETURN VARCHAR2
	IS 
		codePrm VARCHAR2(32000);
	BEGIN
		codePrm:= cste_separateur_commentaire;
		codePrm:= codePrm ||pTable||cste_car_espace;
		codePrm:= codePrm ||cste_separateur_commentaire;
		codePrm:= codePrm ||'TABLE '||pSchemaSource||'.'||pTable||' GETBEFORECOLS(ON UPDATE ALL, ON DELETE ALL)'||cste_car_retour_ligne;
		IF (pFiltre IS NOT NULL) THEN
			codePrm:= codePrm || cste_car_tabulation|| ','||pFiltre ;
		END IF;
		codePrm:= codePrm || cste_sep_fin_cmde;
		RETURN codePrm;
	END;


	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION RENVOYER_COL_CLEPRIMAIRE_DMDE (
		pBaseSource	IN VARCHAR2,
		pIdDmdeTable	IN NUMBER
	) RETURN VARCHAR2
	IS 
		codeSQL				VARCHAR2(32000);
		listeColonnes		VARCHAR2(32000);
	BEGIN
		CodeSQL := 'SELECT listagg(
				decode(t.nom_col_cible, NULL, v.column_name, t.nom_col_cible)
				,',') WITHIN GROUP (ORDER BY v.position) liste_colonnes
				FROM  oggdmde.v_dmde_tab_colonnes  t
					INNER JOIN ( SELECT co.owner, co.table_name, cc.column_name,cc.position
					FROM dba_constraints@'||pBaseSource||' co  
						INNER JOIN dba_cons_columns@'||pBaseSource||' cc ON cc.owner = co.owner
						AND cc.table_name = co.table_name
							AND cc.constraint_name = co.constraint_name
					WHERE  co.constraint_type = ''P'' ) v ON v.owner = t.schema_source
					AND v.table_name = t.nom_table
					AND v.column_name = t.nom_col_source
				WHERE t.id_dmde_table = :1';
	EXECUTE IMMEDIATE codeSQL INTO listeColonnes USING pIdDmdeTable;
	RETURN listeColonnes;

	EXCEPTION
		WHEN OTHERS THEN
		RAISE; 
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION RENVOYER_DDL_COL_TABLE_DMDE (
		pBaseSource		IN VARCHAR2,
		pIdDmdeTable	IN NUMBER
	) RETURN VARCHAR2
	IS 
		codeSQL				VARCHAR2(32000);
		listeColonnes		VARCHAR2(32000);
	BEGIN
		CodeSQL := CodeSQL := 'SELECT listagg(
				oggdmde.formater_sql_ddl_colonne( 
						Decode(d.nom_col_cible, NULL, c.column_name ,d.nom_col_cible), 
						c.data_type,c.data_precision, c.data_length, c.data_scale)
				, '',''||chr(10) )
				WITHIN GROUP (ORDER BY c.column_id) liste_colonnes
			FROM oggdmde.v_dmde_tab_colonnes d 
				INNER JOIN dba_tab_columns@'|| pBaseSource||' c ON c.owner = d.schema_source 
					AND c.table_name= d.nom_table 
					AND c.column_name = d.nom_col_source
			WHERE d.id_dmde_table = :1';
	EXECUTE IMMEDIATE codeSQL INTO listeColonnes USING pIdDmdeTable;
	RETURN listeColonnes;

	EXCEPTION
		WHEN OTHERS THEN
		RAISE; 
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION RENVOYER_COL_A_SUPPRIMER_DMDE (
		pBaseCible		IN VARCHAR2,
		pIdDmdeTable	IN NUMBER
	) RETURN VARCHAR2
	IS 
		codeSQL				VARCHAR2(32000);
		listeColonnes		VARCHAR2(32000);
	BEGIN
		CodeSQL := CodeSQL := 'SELECT 
				listagg(d.nom_col_cible, '',''||chr(10)) WITHIN GROUP (ORDER BY c.co lumn_id) liste_colonnes
			FROM oggdmde.v_dmde_tab_colonnes d
  				INNER JOIN dba_tab_columns@'||pBaseCible||' c ON c.owner = d.schema_cible 
				  	AND c.table_name = d.nom_table 
					AND c.column_name = d.nom_col_cible 
			WHERE d.id_dmde_table = :1';
	EXECUTE IMMEDIATE codeSQL INTO listeColonnes USING pIdDmdeTable;
	RETURN listeColonnes;

	EXCEPTION
		WHEN OTHERS THEN
		RAISE; 
	END;



	-- -----------------------------------------------------------------------------
	-- PUBLIQUE
	-- -----------------------------------------------------------------------------
	FUNCTION RENVOYER_SQL_DDL_TABLE(
		pBaseSource		IN VARCHAR2,
		pAction			IN VARCHAR2,
		pIdDmdeTable	NUMBER,
		pBaseCible		IN VARCHAR2,
		pSchemaCible	IN VARCHAR2,
		pTbsDonnee		IN VARCHAR2,
		pTbsIndex		IN VARCHAR2
	) RETURN VARCHAR2
	AS
		codeDDL				VARCHAR2(32000);
		listeColonnes		VARCHAR2(32000);
		schemaCible			VARCHAR2(128);
		nomTable			VARCHAR2(128);
		libAction			VARCHAR2(128);
		BEGIN
			schemaCible  := upper(pSchemaCible);
			nomTable     := upper(pTable);
			
			IF oggdmde.pkg_ogg_commun.si_action_supprimer(pAction) THEN
				listeColonnes := renvoyer_col_a_supprimer_dmde(pBaseCible, pIdDmdeTable);
				codeDDL := construire_ddl_suppression_col(schemaCible, nomTable, listeColonnes)
			ELSIF IF oggdmde.pkg_ogg_commun.si_action_modifier(pAction) THEN
				listeColonnes := renvoyer_ddl_col_table_dmde(pBaseSource, pIdDmdeTable);
				codeDDL := construire_ddl_creation_col(schemaCible, nomTable, listeColonnes);
			IF oggdmde.pkg_ogg_commun.si_action_ajouter(pAction) THEN
				listeColonnes := renvoyer_ddl_col_table_dmde(pBaseSource, pIdDmdeTable);
				colonnesClePrimaire := renvoyer_col_cleprimaire_dmde (pBaseSource, pIdDmdeTable);
				-- pour eviter les caractères # dans le nom de cle primaire source
				-- on force le nom de cle cible
				nomCleprimaire := formatter_nom_cleprimaire(nomTable); 
				codeDDL := construire_ddl_creation_table(schemaCible, nomTable, listeColonnes, 
					nomCleprimaire, colonnesClePrimaire, pTbsDonnee, pTbsIndex);

			RETURN codeDDL;

			EXCEPTION
				WHEN OTHERS THEN
				RAISE;
		END;

	-- ---------------------------------------------------------------------------
	-- PUBLIQUE
	-- ---------------------------------------------------------------------------
	 FUNCTION RENVOYER_SQL_CHARGEMENT_TABLE (
		pBaseSource		IN VARCHAR2,
		pSchemaSource	IN VARCHAR2,
		pBaseCible		IN VARCHAR2,
		pSchemaCible	IN VARCHAR2,
		pNomTable		IN VARCHAR2,
		pChargementInit	IN VARCHAR2
	) RETURN VARCHAR2
	IS
		codeSQL VARCHAR2(32000);
		listeColonneCible VARCHAR2(8000);
		listeColonneSource VARCHAR2(8000);
	BEGIN
		codeSQL:= 'SELECT 
				listagg(c.column_name, cste_sep_colonne_ret_ligne)
					WITHIN GROUP (ORDER BY c.table_name, c.column_id) liste_col_cible
				, listagg(nvl(d.nom_col_source, c.column_name),cste_sep_colonne_ret_ligne)
					WITHIN GROUP (ORDER BY c.table_name, c.column_id) liste_col_source
			FROM dba_tab_columns@'||pBaseCible||'  c
			LEFT OUTER JOIN oggdmde.v_dmde_tab_derniere_colonne v ON v.schema_cible = c.owner 
				AND v.nom_table = c.table_name AND v.nom_col_cible = c.column_name
			WHERE c.owner= UPPER(:1) and c.table_name = UPPER(:2)';
		EXECUTE IMMEDIATE CodeSQL INTO listeColonneCible, listeColonneSource USING pSchemaCible, pNomTable;

		RETURN CONSTRUIRE_DDL_CHARGE_TABLE (
			pNomTable, pBaseSource,
			pSchemaSource, listeColonneSource,
			pSchemaCible, listeColonneCible,
			oggdmde.pkg_ogg_config.si_chargement_avec_suppression(pChargementInit) );
	
		 EXCEPTION
		   WHEN OTHERS THEN
			 RAISE;

	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION RENVOYER_CODE_REPLICAT_TABLE(
		pNomBaseCible	IN VARCHAR2,
		pTable			IN VARCHAR2,
		pSchemaSource	IN VARCHAR2,
		pSchemaCible	IN VARCHAR2
	) RETURN VARCHAR2
	AS
		codeSQL VARCHAR2(32000);
		listeColFormatees  VARCHAR2(32000);
	BEGIN

		codeSQL := 'SELECT 
			listagg(c.column_name||''=''||v.nom_col_source,'||cste_sep_colonne_ret_ligne||')
				WITHIN GROUP (ORDER BY c.table_name, c.column_id) liste_col_cible
			FROM dba_tab_columns@' ||pNomBaseCible ||' c
			LEFT OUTER JOIN v_dmde_tab_derniere_colonne v ON v.schema_cible = c.owner 
				AND v.nom_table = c.table_name
				AND v.nom_col_cible = c.column_name
			WHERE c.owner= UPPER(:1) and c.table_name = UPPER(:2)';

		EXECUTE IMMEDIATE CodeSQL INTO listeColFormatees  USING pSchemaCible, pTable;
		RETURN construire_prm_repli_source(pTable, pSchemaSource, pSchemaCible, listeColFormatees);
	END;


	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION RENVOYER_CODE_EXTRACT_TABLE(
		pTable			IN VARCHAR2,
		pSchemaSource	IN VARCHAR2,
		pFiltre			IN VARCHAR2
	) RETURN VARCHAR2
	AS
	BEGIN
		RETURN CONSTRUIRE_PRM_EXTRACT_SOURCE(pTable, pSchemaSource, pFiltre);
	END;


	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	PROCEDURE ENREGISTRER_DMDE_TAB_CODE(
		pIdDemandes	IN NUMBER
	)
	IS
		tbsDonnees	VARCHAR2(30);
		tbsIndex	VARCHAR2(30);
		codeSQL		VARCHAR2(32000);
	BEGIN
		FOR curs IN (
			SELECT v.base_cible,v.schema_cible,v.nom_table, v.lib_type_action, v.schema_source,v.base_source,
				v.id_dmde_table , l.nom_lien_base
			FROM oggdmde.v_dmde_tab_a_faire v
				INNER JOIN oggdmde.v_lien_base_e l ON l.nom_base = v.base_cible AND l.nom_schema = v.schema_cible
			WHERE v.id_demande = pIdDemandes 
		)
		LOOP
			tbsDonnees := oggdmde.pkg_ogg_config.donner_tbs_donnee(curs.base_cible, curs.schema_cible);
			tbsIndex  := oggdmde.pkg_ogg_config.donner_tbs_indx(curs.base_cible, curs.schema_cible);

			--dbms_output.put_line(curs.nom_lien_base||'-'||curs.base_cible||'-'|| curs.schema_cible);
			codeSQL := renvoyer_sql_ddl_table(
				curs.nom_lien_base,
				curs.lib_type_action,
				curs.id_dmde_table,
				curs.schema_cible,
				curs.base_cible,
				tbsDonnees, tbsIndex );

			oggdmde.pkg_ogg_config.ajouter_dmde_tab_code_ddl (curs.id_dmde_table, codeSQL);
		END LOOP ;
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	PROCEDURE ENREGISTRER_DMDE_TAB_CODE_DDL (
		pIdDemandes	IN NUMBER
	)
	IS
		tbsDonnees	VARCHAR2(30);
		tbsIndex	VARCHAR2(30);
		codeSQL		VARCHAR2(32000);
	BEGIN
		FOR curs IN (
			SELECT v.base_cible,v.schema_cible,v.nom_table, v.lib_type_action, v.schema_source,v.base_source,
				v.id_dmde_table , l.nom_lien_base
			FROM oggdmde.v_dmde_tables v
				INNER JOIN oggdmde.v_lien_base_e l ON l.nom_base = v.base_cible AND l.nom_schema = v.schema_cible
			WHERE v.id_demande = pIdDemandes
		)
		LOOP
			tbsDonnees := oggdmde.pkg_ogg_config.donner_tbs_donnee(curs.base_cible, curs.schema_cible);
			tbsIndex  := oggdmde.pkg_ogg_config.donner_tbs_indx(curs.base_cible, curs.schema_cible);

			--dbms_output.put_line(curs.nom_lien_base||'-'||curs.base_cible||'-'|| curs.schema_cible);
			codeSQL := renvoyer_sql_ddl_table(
				curs.nom_lien_base,
				curs.lib_type_action,
				curs.id_dmde_table,
				curs.schema_cible,
				curs.base_cible,
				tbsDonnees, tbsIndex );

			oggdmde.pkg_ogg_config.ajouter_dmde_tab_code_ddl (curs.id_dmde_table, codeSQL);
		END LOOP ;
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	PROCEDURE ENREGISTRER_DMDE_TAB_CODE_INIT (
		pIdDemandes	IN NUMBER
	)
	IS
		codeSQL VARCHAR2(32000);
	BEGIN
		FOR curs IN (
			SELECT v.base_cible,v.schema_cible,v.nom_table, v.lib_type_action, v.schema_source,v.base_source,
				l.nom_lien_base, v.lib_type_chargement, v.id_dmde_table 
			FROM oggdmde.v_dmde_tables v
				INNER  JOIN oggdmde.v_lien_base_e l ON l.nom_base = v.base_cible AND l.nom_schema = v.schema_cible
			WHERE v.id_demande = pIdDemandes
			ORDER BY v.schema_cible,v.nom_table, v.lib_type_action
		)
		LOOP
			codeSQL := renvoyer_sql_chargement_table ( curs.base_source,
						curs.schema_source,
						curs.base_cible,
						curs.schema_cible,
						curs.nom_table,
						curs.lib_type_chargement);
						
			oggdmde.pkg_ogg_config.ajouter_dmde_tab_code_init (curs.id_dmde_table, codeSQL);
		END LOOP ;
	END;

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	FUNCTION SI_INTERFACE_OS (
		pChoixInterface IN VARCHAR2
	) RETURN BOOLEAN
	IS
	BEGIN
		RETURN (pChoixInterface = cst_choix_interface_OS);
	END;

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	FUNCTION SI_INTERFACE_SQL (
		pChoixInterface IN VARCHAR2
	) RETURN BOOLEAN
	IS
	BEGIN
		RETURN (pChoixInterface = cst_choix_interface_SQL);
	END;

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	PROCEDURE FAIRE_MAJ_STRUCTURE
	IS
	BEGIN 
		dbms_output.put_line('FAIRE_MAJ_STRUCTURE()');
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	PROCEDURE DEPLOYER_VIA_SQL
	IS
	BEGIN
		dbms_output.put_line('DEPLOYER_VIA_SQL() A FAIRE');
		--oggdmde.pkg_ogg_generer_code.generer_fichiers_sql_ddl();
		faire_maj_structure();
		--oggdmde.pkg_ogg_generer_code.generer_fichiers_sql_init();

		
		EXCEPTION
			WHEN OTHERS THEN
				RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	PROCEDURE DEPLOYER_VIA_MAKEFILE
	IS
	BEGIN
		dbms_output.put_line('DEPLOYER_VIA_MAKEFILE() A FAIRE');
		EXCEPTION
			WHEN OTHERS THEN
				RAISE;	  
	END;
	
END;
/