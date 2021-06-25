
ALTER SESSION SET CURRENT_SCHEMA=OGGDMDE;

-- ============================================================================
-- Auteur : JLNOIRET
-- cree le : 01-01-2021
-- ----------------------------------------------------------------------------
-- PRE REQUIS:
--	grant select on dba_tables  to OGGDMDE;
--	grant select on dba_cons_columns  to OGGDMDE;
--	grant select on dba_constraints  to OGGDMDE;
--	grant select on dba_objects  to OGGDMDE;
--	grant select on dba_tab_columns  to OGGDMDE;
--	grant select on dba_log_group_columns  to OGGDMDE;
-- ----------------------------------------------------------------------------
-- DEPENDANCES 
-- tables et vues de oggdmde
-- package : pkg_ogg_commun, pkg_ogg_config
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE PKG_OGG_DEMANDES
-- ============================================================================
IS
	-- ----------------------------------------------------------------------------
	PROCEDURE GENERER_LISTE_DMDE_A_TRAITER (
		  pListeBaseCibles IN VARCHAR2,
		  pListeSchemas IN VARCHAR2,
		  pListeTables IN VARCHAR2
	);
	
-- ----------------------------------------------------------------------------
	PROCEDURE GENERER_LISTE_DMDE_A_TRAITER (
		pIdDemande	IN NUMBER
	);

	-- ----------------------------------------------------------------------------
	PROCEDURE CREER_DEMANDES (
		pNomProjet		IN VARCHAR2,
		pBaseCible		IN VARCHAR2,
		pcommentaire	IN VARCHAR2
	);

END;
/

	-- ============================================================================
	-- 
	-- ============================================================================
CREATE OR REPLACE PACKAGE BODY OGGDMDE.PKG_OGG_DEMANDES
IS
	TYPE TCURSREF IS REF CURSOR;


	
	DateParDefaut date := null;

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	FUNCTION FORMATER_CHOIX_EN_LISTAGG_DMDE (
		pListeChoix IN VARCHAR2,
		pNomColonne IN VARCHAR2
	) RETURN VARCHAR2
	IS 
			listeAgg VARCHAR2(2048);
			codeSQL  VARCHAR2(32000);
		BEGIN
		IF (pListeChoix = '*') THEN
			codeSQL := 'SELECT listagg(nom_colonne,'','') as liste_agg
				FROM
					(SELECT DISTINCT t.'||pNomColonne||' as nom_colonne 
						FROM oggdmde.v_dmde_tables t)';
			EXECUTE IMMEDIATE codeSQL INTO 	listeAgg;
		ELSE
			listeAgg := REPLACE(pListeChoix,' ','');
		END IF;
		RETURN listeAgg;
	END;
	


-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	PROCEDURE CREER_DMDE_TABLES (
		pIdDemandes NUMBER,
		pBaseCible	IN VARCHAR2
	) IS
		curs		TCURSREF;
		codeSQL			VARCHAR2(8000);
		nomTable		VARCHAR2(30);
		idBaseSchemaSource	NUMBER;
		idBaseSchemaCible	NUMBER;
		idTypeChargement	NUMBER;
		idTypeAction		NUMBER;
	BEGIN
		codeSQL := 'SELECT v.id_base_schema_source, v.id_base_schema_cible, a.id_type_action, v.id_type_chargement, v.nom_table 
			FROM ( SELECT v.id_base_schema_source, v.id_base_schema_cible,
					v.id_type_chargement, oggdmde.pkg_ogg_commun.decoder_type_action(t.table_name) AS lib_type_action,
					v.nom_table  
				FROM oggdmde.v_sqlldr_dmde_table v
				LEFT OUTER JOIN dba_tables@'||pBaseCible||' t ON t.owner = v.schema_cible AND t.table_name = v.nom_table
				WHERE v.base_cible = '''||pBaseCible||'''
			) v
			INNER JOIN oggdmde.type_action_r a ON a.lib_type_action = v.lib_type_action';

		OPEN curs FOR codeSQL;
		LOOP
			FETCH curs INTO idBaseSchemaSource, idBaseSchemaCible, idTypeAction, idTypeChargement, nomTable;
			EXIT WHEN curs%NOTFOUND; 

			oggdmde.pkg_ogg_config.ajouter_dmde_tables_e (pIdDemandes, idBaseSchemaSource, idBaseSchemaCible, 
				idTypeAction, idTypeChargement, nomTable);
		END LOOP; 
		CLOSE curs;
	END;

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	PROCEDURE CREER_DMDE_TAB_COLONNES (
		pIdDemandes	IN NUMBER
	)
	IS
	BEGIN
		FOR curs IN (
			SELECT v.id_dmde_table, d.id_type_demande, d.nom_col_source, d.nom_col_cible
			FROM oggdmde.v_dmde_tables v
				INNER JOIN  ( SELECT d.nom_table, d.nom_col_source, d.nom_col_cible, d.schema_cible , d.schema_source, r.id_type_demande
				FROM oggdmde.sqlldr_dmde_t d
				INNER JOIN oggdmde.type_demande_r r ON r.lib_type_demande = d.lib_type_demande
				) d ON v.schema_cible = d.schema_cible AND  d.schema_source = v.schema_source AND d.nom_table = v.nom_table
			WHERE v.id_demande = pIdDemandes
		)
		LOOP
			oggdmde.pkg_ogg_config.ajouter_dmde_tab_colonnes_e (curs.id_dmde_table, curs.id_type_demande,
				curs.nom_col_source, curs.nom_col_cible);
		END LOOP ;
	END;

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	PROCEDURE CREER_DMDE_TAB_FILTRES (
		pIdDemandes	IN NUMBER
	)
	IS
	BEGIN
		FOR curs IN (
			SELECT v.id_dmde_table, d.nom_col_source, d.filtre_source
			FROM oggdmde.v_dmde_tables v
				INNER JOIN oggdmde.sqlldr_dmde_t d  ON v.schema_cible = d.schema_cible
					AND d.schema_source = v.schema_source AND d.nom_table = v.nom_table
					AND v.id_demande = pIdDemandes
				WHERE  d.filtre_source IS NOT NULL
				ORDER BY v.id_dmde_table
		)
		LOOP
			oggdmde.pkg_ogg_config.ajouter_dmde_tab_filtre_e (curs.id_dmde_table, curs.nom_col_source, curs.filtre_source );
		END LOOP ;
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	PROCEDURE CREER_DEMANDES (
		pNomProjet		IN VARCHAR2,
		pBaseCible		IN VARCHAR2,
		pcommentaire	IN VARCHAR2
	) IS
		idDmdeCourante NUMBER;
	BEGIN
		oggdmde.pkg_ogg_config.ajouter_demande (pNomProjet,pcommentaire);
		idDmdeCourante := oggdmde.pkg_ogg_config.donner_id_dmde_courante();
		creer_dmde_tables(idDmdeCourante, pBaseCible);
		creer_dmde_tab_colonnes(idDmdeCourante);
		creer_dmde_tab_filtres (idDmdeCourante);

		exception
		  when no_data_found then
			raise;
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------

	FUNCTION FORMATER_LISTE_DMDE_BASES (
		pListeBases IN VARCHAR2
	) RETURN VARCHAR2 
	IS
	BEGIN
		RETURN FORMATER_CHOIX_EN_LISTAGG_DMDE(pListeBases, 'base_cible');
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION FORMATER_LISTE_DMDE_SCHEMAS (
		pListeSchemas IN VARCHAR2
	) RETURN VARCHAR2 
	IS
	BEGIN
		RETURN FORMATER_CHOIX_EN_LISTAGG_DMDE(pListeSchemas, 'schema_cible');
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION FORMATER_LISTE_DMDE_TABLES (
		pListeTables IN VARCHAR2
	) RETURN VARCHAR2 
	IS
	BEGIN
		RETURN FORMATER_CHOIX_EN_LISTAGG_DMDE(pListeTables, 'nom_table');
	END;
		
	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	PROCEDURE GENERER_LISTE_DMDE_A_TRAITER (
		pIdDemande	IN NUMBER
	) IS
	BEGIN 
		FOR curs IN (
			SELECT d.id_dmde_table, d.base_cible, d.schema_cible, d.nom_table
			FROM oggdmde.v_dmde_tables d
			WHERE id_demande = pIdDemande					
		)
		LOOP
			oggdmde.pkg_ogg_config.ajouter_dmde_a_traiter_afaire(curs.id_dmde_table, DateParDefaut);
		END LOOP;
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	PROCEDURE GENERER_LISTE_DMDE_A_TRAITER (
		pListeBaseCibles IN VARCHAR2,
		pListeSchemas IN VARCHAR2,
		pListeTables IN VARCHAR2
	) IS
		listeBaseCibles VARCHAR2(4000);
		listeSchemas VARCHAR2(4000);
		listeTables VARCHAR2(32000);
	BEGIN
		listeBaseCibles := formater_liste_dmde_bases(pListeBaseCibles);
		listeSchemas := formater_liste_dmde_schemas(pListeSchemas);
		listeTables := formater_liste_dmde_tables(pListeTables);

		FOR curs IN (
			SELECT
					d.base_cible,
					d.schema_cible,
					d.nom_table,
					d.id_dmde_table
				FROM 
					oggdmde.v_dmde_tables d
					INNER JOIN (
						SELECT regexp_substr(listeBaseCibles,'[^,]+', 1, LEVEL) base_cible 
						FROM dual
						CONNECT BY regexp_substr(listeBaseCibles, '[^,]+', 1, LEVEL) IS NOT NULL
					) v_bases ON v_bases.base_cible = d.base_cible
					INNER JOIN (
						SELECT regexp_substr(listeSchemas,'[^,]+', 1, LEVEL) schema_cible 
						FROM dual
						CONNECT BY regexp_substr(listeSchemas, '[^,]+', 1, LEVEL) IS NOT NULL
					) v_schemas ON v_schemas.schema_cible = d.schema_cible
					INNER JOIN (
						SELECT regexp_substr(listeTables,'[^,]+', 1, LEVEL) nom_table 
						FROM dual
						CONNECT BY regexp_substr(listeTables, '[^,]+', 1, LEVEL) IS NOT NULL
					) v_tables ON v_tables.nom_table = d.nom_table
		)
		LOOP
			oggdmde.pkg_ogg_config.ajouter_dmde_a_traiter_afaire(curs.id_dmde_table, DateParDefaut);
			dbms_output.put_line(
				curs.base_cible||'.'||curs.schema_cible||'.'||curs.nom_table
				||'['||to_char(curs.id_dmde_table||']'));
		END LOOP;
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	FUNCTION SI_DMDE_A_FAIRE
		RETURN BOOLEAN
	IS
		nbLigne NUMBER;
	BEGIN
		SELECT count(1) INTO nbLigne
			FROM oggdmde.dmde_tab_a_traiter_e;
		RETURN (nbLigne > 0);
	END;





-- ============================================================================
END;
/

