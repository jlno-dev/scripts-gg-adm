ALTER SESSION SET CURRENT_SCHEMA=OGGDMDE;

--grant select on dba_tables  to OGGDMDE;
--grant select on dba_cons_columns  to OGGDMDE;
--grant select on dba_constraints  to OGGDMDE;
--grant select on dba_objects  to OGGDMDE;
--grant select on dba_tab_columns  to OGGDMDE;
--grant select on dba_log_group_columns  to OGGDMDE;

-- ============================================================================
CREATE OR REPLACE PACKAGE PKG_OGG_GENERER_FICHIERS
-- ============================================================================
IS



END;
/

	-- ============================================================================
	-- 
	-- ============================================================================
CREATE OR REPLACE PACKAGE BODY PKG_OGG_GENERER_FICHIERS
IS

	-- on redeclare la constante en local pour éviter des appels incessants
	cste_car_retour_ligne		CONSTANT CHAR(1) := oggdmde.pkg_ogg_commun.cste_caractere_retour_ligne;


-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	procedure GENERER_FICHIERS_SQL_PRM (
		pIdDemandes		IN NUMBER,
		pBaseCible 		IN VARCHAR2,
		pSchemaCible	IN VARCHAR2,
		pTypeCode		IN VARCHAR2
	)
	AS
		nomFicSQL VARCHAR2(1024);
	BEGIN
		FOR v IN ( SELECT  d.base_cible,d.schema_cible, d.nom_table, d.lib_type_code, d.code
			FROM oggdmde.v_dmde_tab_code d  
				INNER JOIN oggdmde.v_dmde_tab_a_faire t ON  t.id_dmde_table =d.id_dmde_table 
				WHERE d.lib_type_code = pTypeCode)
		LOOP
			nomFicSQL := oggdmde.pkg_ogg_config.renvoyer_nom_fichier (v.base_cible, v.schema_cible, v.nom_table, v.lib_type_code);
			oggdmde.pkg_ogg_commun.ecrire_fichier(nomFicSQL, v.code);
		END LOOP;
		
		EXCEPTION
			WHEN OTHERS THEN
				RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION FORMATER_NOM_FICHIER_ETAPE (
		pNomEtape		IN VARCHAR2,
		pSchema			IN VARCHAR2,
		pTypeFichier	IN VARCHAR2
	) RETURN VARCHAR2
	IS
		nomFichier VARCHAR2(2048) := pSchema||'_'||pNomEtape;
	BEGIN
		CASE pTypeFichier
			WHEN 'SQL' THEN nomFichier := nomFichier||'.sql';
			WHEN 'OK' THEN nomFichier := nomFichier ||'.ok';
			ELSE
				nomFichier := null;
		END CASE;
		RETURN lower(nomFichier);
	END;
	
	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION FORMATER_NOM_FICHIER_ETAPE_SQL (
		pNomEtape		IN VARCHAR2,
		pSchema			IN VARCHAR2
	) RETURN VARCHAR2
	IS
	BEGIN
		RETURN formater_nom_fichier_etape(pNomEtape, pSchema, cste_fic_extention_sql);
	END;
	
	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION FORMATER_NOM_FICHIER_ETAPE_OK (
		pNomEtape		IN VARCHAR2,
		pSchema			IN VARCHAR2
	) RETURN VARCHAR2
	IS
	BEGIN
		RETURN formater_nom_fichier_etape(pNomEtape, pSchema, cste_fic_extention_ok);
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
		typeExtension := oggdmde.pkg_ogg_config.donner_lib_ext_pour_type_code(pLibTypeCodeGG);
		nomFichier := renvoyer_nom_fichier_sans_ext(pNomBaseCible, pNomSchemacible, pNomTable, typeCodeGG)||'.'||typeExtension;
		RETURN lower(nomFichier);
	END;
	

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	procedure GENERER_FICHIERS_SQL_DDL (
		pIdDemandes		IN NUMBER,
		pBaseCible 		IN VARCHAR2,
		pSchemaCible	IN VARCHAR2
	)
	AS
	BEGIN
		generer_fichiers_sql_prm(pIdDemandes, pBaseCible, pSchemaCible, 
			oggdmde.pkg_ogg_config.cste_type_obj_gg_ddl);
	END;
	
	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	procedure GENERER_FICHIERS_SQL_INIT (
		pIdDemandes		IN NUMBER,
		pBaseCible 		IN VARCHAR2,
		pSchemaCible	IN VARCHAR2
	)
	AS
	BEGIN
		generer_fichiers_sql_prm(pIdDemandes, pBaseCible, pSchemaCible, 
			oggdmde.pkg_ogg_config.cste_type_obj_gg_init);
	END;
	


	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE GENERER_FICHIER_PRM_EXTRACT(
		pIdDemandes		IN NUMBER,
		pBaseCible 		IN VARCHAR2,
		pSchemaCible	IN VARCHAR2
	)
	IS 
		codePRM VARCHAR2(32000);
	BEGIN
		FOR curs IN (
			SELECT t.schema_cible,t.schema_source,t.nom_table, f.id_dmde_table, 
				LISTAGG(f.nom_colonne ||' '|| f.filtre||' ' ||f.operateur,' ') WITHIN GROUP (ORDER BY f.id_dmde_table, f.operateur) as filtre 
			FROM oggdmde.dmde_tab_filtres_e f
			  INNER JOIN oggdmde.v_dmde_tables t ON t.id_dmde_table = f.id_dmde_table 
				AND t.id_demande = pIdDemandes AND t.base_cible = pBaseCible 
				AND t.schema_cible = pSchemaCible
			 GROUP BY t.schema_cible,t.schema_source,t.nom_table, f.id_dmde_table
		)
		LOOP
			codePRM := renvoyer_code_extract_table (curs.nom_table, curs.schema_source, curs.filtre);
			oggdmde.pkg_ogg_config.ajouter_dmde_tab_code (curs.id_dmde_table,
				oggdmde.pkg_ogg_config.cste_type_obj_gg_extr
				, codePRM);
		END LOOP ;
	
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE GENERER_FICHIER_PRM_REPLICAT(
		pIdDemandes		IN NUMBER,
		pBaseCible 		IN VARCHAR2,
		pSchemaCible	IN VARCHAR2
	)
	IS
	BEGIN 
		dbms_output.put_line('GENERER_FICHIER_PRM_REPLICAT() A FAIRE');
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE GENERER_FICHIER_OBEY_TRANDATA(
		pIdDemandes		IN NUMBER,
		pBaseCible 		IN VARCHAR2,
		pSchemaCible	IN VARCHAR2
	)
	IS
	BEGIN 
		dbms_output.put_line('GENERER_FICHIER_PRM_REPLICAT() A FAIRE');
	END;


	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION CONSTRUIRE_MAKEFILE_FIC_VALIDE (
		pBaseCible		IN VARCHAR2,
		pSchemaCible	IN VARCHAR2,
		pTypeCode		IN VARCHAR2
	) RETURN VARCHAR2
	IS
		nomFicValidationMakeFile VARCHAR2(256);
	BEGIN
		SELECT lower(pBaseCible)||'_'||lower(pSchemaCible)||'_'||lower(et.libelle_complet)||'.ok'
			INTO nomFicValidationMakeFile
			FROM oggdmde.v_code_ext_fic et
			WHERE et.lib_type_code = pTypeCode;
		RETURN nomFicValidationMakeFile;
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION CONTRUIRE_MAKEFILE_NOMFIC (
		pBaseCible		IN VARCHAR2,
		pSchemacible	IN VARCHAR2,
		pTypeCode		IN VARCHAR2
	) RETURN VARCHAR2
	IS
		nomFichierMakelfile VARCHAR2(1024);
	BEGIN
		SELECT lower(pBaseCible)||'_'||lower(pSchemaCible) ||'_'||lower(libelle_complet)||'.makefile'
			INTO nomFichierMakelfile
			FROM oggdmde.type_code_r
			WHERE lib_type_code = pTypeCode;
		RETURN nomFichierMakelfile;

		EXCEPTION
			WHEN OTHERS THEN
				RAISE;
	END;


	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION CONSTRUIRE_MAKEFILE_ENTETE (
		pEtapeObligatoire		IN VARCHAR2,
		pEtapeComplete			IN VARCHAR2,
		pCompteAdmin			IN VARCHAR2,
		pSchemaCible			IN VARCHAR2,
		pNomFichierMakelfile	IN VARCHAR2
	) RETURN VARCHAR2
	AS
		makeFileEntete VARCHAR2(4000);
		oracleSID VARCHAR2(15);
		nomEtapeObligatoire VARCHAR2(1024);
		ficSqlEtapeObligatoire VARCHAR2(1024);
		ficOkEtapeObligatoire VARCHAR2(1024);
		ficOkEtapeComplete VARCHAR2(1024);
	BEGIN
		SELECT instance_name INTO oracleSID FROM v$instance;

		nomEtapeObligatoire := pSchemaCible||'_'||pEtapeObligatoire;
		ficSqlEtapeObligatoire := formater_nom_fichier_etape_sql(pEtapeObligatoire, pSchemaCible);
		ficOkEtapeObligatoire := formater_nom_fichier_etape_ok(pEtapeObligatoire, pSchemaCible);
		ficOkEtapeComplete := formater_nom_fichier_etape_ok(pEtapeComplete, pSchemaCible);

		makeFileEntete := 'SID='||oracleSID||cste_car_retour_ligne;
		makeFileEntete := makeFileEntete|| 'EXEC_SQL=./etape -s $(SID)'||cste_car_retour_ligne;
		makeFileEntete := makeFileEntete||cste_car_tabulation||'EXEC_SQL_OGGADM=$(EXEC_SQL) -u '||pCompteAdmin||cste_car_retour_ligne;
		makeFileEntete := makeFileEntete|| 'ETAPE_OBLIGATOIRE=$(SID).'||FicOkEtapeObligatoire||cste_car_retour_ligne;
		makeFileEntete := makeFileEntete|| '# Syntaxe: '||cste_car_retour_ligne||'# make [SID=<ORACLE_SID>] [-j <nb processus>] -f '||pNomFichierMakelfile||cste_car_retour_ligne;
		makeFileEntete := makeFileEntete|| '# Liste des dépendances' ||cste_car_retour_ligne;
		makeFileEntete := makeFileEntete|| 'all : $(SID).'||ficOkEtapeComplete||cste_car_retour_ligne;
		makeFileEntete := makeFileEntete|| '# Teste si le schema cible existe'||cste_car_retour_ligne;
		makeFileEntete := makeFileEntete||'$(ETAPE_OBLIGATOIRE) : '||ficSqlEtapeObligatoire||cste_car_retour_ligne;
		makeFileEntete := makeFileEntete||cste_car_tabulation||'$(EXEC_SQL_OGGADM) -e '||nomEtapeObligatoire ||' -f '||ficSqlEtapeObligatoire||' -p '''||pSchemaCible||'''';
		RETURN  makeFileEntete;
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION CONSTRUIRE_MAKEFILE_CORPS(
		pIdDemandes			IN NUMBER,
		pBaseCible			IN VARCHAR2,
		pSchemaCible		IN VARCHAR2,
		pFicEtapeComplete	IN VARCHAR2,
		pTypeCode			IN VARCHAR2
	) RETURN VARCHAR2
	AS
		makeFileCorps VARCHAR2(32000):= NULL ;
		ligne VARCHAR2(1024);
		listeCibles VARCHAR2(32000);
		cible VARCHAR2(1024);
		fichierSQL VARCHAR2(1024);
	BEGIN
		FOR v IN ( SELECT renvoyer_nom_fichier_sans_ext (
						tc.base_cible,
						tc.schema_cible,
						tc.nom_table,
						tc.lib_type_code) nom_fichier_sans_ext
				,tc.code
				,'.'|| ve.lib_type_ext_fichier as extension_fichier
			FROM oggdmde.v_dmde_tab_code tc
				INNER JOIN oggdmde.v_code_ext_fic ve ON ve.lib_type_code = tc.lib_type_code
			WHERE tc.id_demande = pIdDemandes
				AND tc.schema_cible=  pSchemaCible
				AND tc.base_cible = pBaseCible
				AND tc.lib_type_code = pTypeCode
		) LOOP
			cible := '$(SID).'||v.nom_fichier_sans_ext||'.ok';
			fichierSQL := v.nom_fichier_sans_ext||v.extension_fichier;

			ligne := cible||' : '||fichierSQL||' $(ETAPE_OBLIGATOIRE) '||chr(10)||Chr(9)||'$(EXEC_SQL_OGGADM) -f '||fichierSQL||chr(10);

			IF (listeCibles IS NULL) THEN
				listeCibles := cible;
			ELSE
				listeCibles := listeCibles||' '||cible;
			END IF;

			IF ( makeFileCorps IS NULL) THEN
				makeFileCorps := ligne;
			ELSE
				makeFileCorps := makeFileCorps || ligne||chr(10);
			END IF;
		END LOOP;

		makeFileCorps := makeFileCorps||Chr(10)|| 'LISTE_TABLE='||listeCibles;
		makeFileCorps := makeFileCorps||chr(10)|| '$(SID).'||pFicEtapeComplete||' : $(LISTE_TABLE)';
		RETURN makeFileCorps;
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION CONSTRUIRE_MAKEFILE_FIN
	RETURN VARCHAR2
	IS
		makeFileFin  VARCHAR2(1024);
	BEGIN
		makeFileFin := 'clean :'||chr(10)||chr(9)|| 'rm -f $(SID).*.ok $(SID).*.err $(SID).*.log';
		RETURN makeFileFin;
	END;


	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	PROCEDURE GENERER_MAKEFILE (
		pIdDemandes				IN NUMBER,
		pCompteAdmin			IN VARCHAR2,
		pBaseCible				IN VARCHAR2,
		pSchemaCible			IN VARCHAR2,
		pFicEtapeObligatoire	IN VARCHAR2,
		pFicEtapeValidation		IN VARCHAR2,
		pTypeCode				IN VARCHAR2
	)
	AS
		nomFicMakeFile  VARCHAR2(1024);
		nomFicValidationMakeFile VARCHAR2(256);
		contenuMakeFile VARCHAR2(32000);
		makeFileEntete VARCHAR2(32000);
		makeFileCoprs VARCHAR2(32000);
		makeFileFin VARCHAR2(32000);
	BEGIN
		nomFicValidationMakeFile := construire_makefile_fic_valide(pBaseCible, pSchemaCible, pTypeCode);
		nomFicMakeFile := contruire_makefile_nomfic(pBaseCible, pSchemaCible, pTypeCode);
		makeFileEntete := construire_makefile_entete (pFicEtapeObligatoire, nomFicValidationMakeFile, pCompteAdmin, pSchemaCible, nomFicMakeFile);

		makeFileCoprs := construire_makefile_corps(
			pIdDemandes,
			pBaseCible,
			pSchemaCible,
			nomFicValidationMakeFile,
			pTypeCode);
		makeFileFin := construire_makefile_fin();

		contenuMakeFile := makeFileEntete||chr(10)||makeFileCoprs||chr(10)||makeFileFin;
		oggdmde.pkg_ogg_commun.ecrire_fichier(nomFicMakeFile, makeFileEntete||chr(10)||makeFileCoprs||chr(10)||makeFileFin);
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	PROCEDURE GENERER_MAKEFILE_DDL (
		pIdDemandes				IN NUMBER,
		pCompteAdmin			IN VARCHAR2,
		pBaseCible				IN VARCHAR2,
		pSchemaCible			IN VARCHAR2, 
		pFicEtapeValidation		IN VARCHAR2,
		pFicEtapeObligatoire	IN VARCHAR2
	)
	IS
	BEGIN
		generer_makefile(
			pIdDemandes,
			pCompteAdmin,
			pBaseCible,
			pSchemaCible,
			pFicEtapeObligatoire,
			pFicEtapeValidation,
			oggdmde.pkg_ogg_config.cste_type_obj_gg_ddl
		);
		
		EXCEPTION
			WHEN OTHERS THEN
				RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	PROCEDURE GENERER_MAKEFILE_INIT (
		pIdDemandes				IN NUMBER,
		pCompteAdmin			IN VARCHAR2,
		pBaseCible				IN VARCHAR2,
		pSchemaCible			IN VARCHAR2,
		pFicEtapeValidation		IN VARCHAR2,
		pFicEtapeObligatoire	IN VARCHAR2
	)
	IS
	BEGIN
		generer_makefile(
			pIdDemandes,
			pCompteAdmin,
			pBaseCible,
			pSchemaCible,
			pFicEtapeObligatoire,
			pFicEtapeValidation,
			oggdmde.pkg_ogg_config.cste_type_obj_gg_init
		);
		
		EXCEPTION
			WHEN OTHERS THEN
				RAISE;
	END;
	

END;
/