
ALTER SESSION SET CURRENT_SCHEMA=OGGDMDE;

-- ============================================================================
-- Auteur : JLNOIRET
-- cree le : 01-01-2021
-- ----------------------------------------------------------------------------
-- Fournit des fonctions pour gérer la saisie des demandes 
-- via interface web/fichiers csv
-- ----------------------------------------------------------------------------
-- PRE REQUIS:
--	grant select on dba_tab_columns  to OGGDMDE;
--	grant select on dba_users to OGGDMDE;
-- ----------------------------------------------------------------------------
-- DEPENDANCES 
-- tables et vues de oggdmde
-- package : pkg_ogg_commun, pkg_ogg_config
-- ----------------------------------------------------------------------------

CREATE OR REPLACE  PACKAGE PKG_OGG_SQLLDR
IS
	-- ----------------------------------------------------------------------------
	PROCEDURE VALIDER_SQLLDR_DMDE (
		pNomProjet IN VARCHAR2,
		pBaseSource IN VARCHAR2,
		pBaseCible IN VARCHAR2
	);
	
END;
/

-- ============================================================================
-- 
-- ============================================================================
CREATE OR REPLACE  PACKAGE BODY PKG_OGG_SQLLDR
IS

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	PROCEDURE PURGER_SQLLDR_DMDE_INVALIDES_E
	IS
	BEGIN
		DELETE oggdmde.sqlldr_dmde_invalides_e;
	END;

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	FUNCTION SI_DMDE_SCHEMA_EXISTE(
		pNomBase	IN VARCHAR2,
		pNomColonne	IN VARCHAR2
	) RETURN BOOLEAN
	IS
		codeSQL VARCHAR2(32000);
		nbLignes NUMBER;
		nomColonne VARCHAR2(30);
	BEGIN
		codeSQL := 'SELECT count(1) AS nb_schema_inexistant 
			FROM 
			( SELECT DISTINCT '||pNomColonne||' schema_source  as nom_schema 
				FROM oggdmde.sqlldr_dmde_t ) d
				LEFT OUTER JOIN dba_users@'||pNomBase||' u ON u.username = d.nom_schema
				WHERE u.username IS NULL';

		EXECUTE IMMEDIATE codeSQL INTO nbLignes ;
		RETURN (nbLignes > 0);

		EXCEPTION
		  WHEN OTHERS THEN
			RAISE;

	END ;

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	FUNCTION SI_SCHEMA_SOURCE_EXISTE(
		pNomBase	IN VARCHAR2
	) RETURN BOOLEAN
	IS
	BEGIN
		RETURN si_dmde_schema_existe(pNomBase, pkg_ogg_config.renvoyer_colonne_schema_source));

		EXCEPTION
		WHEN OTHERS THEN
			RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	FUNCTION SI_SCHEMA_CIBLE_EXISTE(
		pNomBase IN VARCHAR2
	) RETURN BOOLEAN
	IS
	BEGIN
		RETURN si_dmde_schema_existe(pNomBase, pkg_ogg_config.renvoyer_colonne_schema_cible());

		EXCEPTION
		WHEN OTHERS THEN
			RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	PROCEDURE VERIFIER_BASE_SOURCE (
		pNomProjet IN VARCHAR2,
		pBaseSource IN VARCHAR2
	)
	IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		codeSQL VARCHAR2(32000);
	BEGIN
		codeSQL := 'INSERT INTO oggdmde.sqlldr_dmde_invalides_e(id_dmde_sqlldr, id_base_schema)
			 SELECT d.id_dmde_sqlldr, p.id_base_schema_source
				FROM oggdmde.sqlldr_dmde_t d
					INNER JOIN oggdmde.v_projets_details p ON p.nom_projet= :1  
						AND p.base_source = :2
						AND p.schema_source = d.schema_source 
						AND p.schema_cible = d.schema_cible
				WHERE NOT EXISTS ( SELECT 1
					FROM dba_tab_columns@'||pBaseSource||' c
					WHERE c.owner = d.schema_source AND c.table_name = d.nom_table
						AND c.column_name = d.nom_col_source
					)';
	EXECUTE IMMEDIATE codeSQL USING pNomProjet, pBaseSource ;
	COMMIT;

	EXCEPTION
	  WHEN OTHERS THEN
	  ROLLBACK;
		RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	PROCEDURE VERIFIER_SQLLDR_BASE_CIBLE (
		pNomProjet IN VARCHAR2,
		pBaseCible IN VARCHAR2
	)
	IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		codeSQL VARCHAR2(32000);
	BEGIN
		codeSQL := 'INSERT INTO oggdmde.sqlldr_dmde_invalides_e(id_dmde_sqlldr, id_base_schema)
		SELECT d.id_dmde_sqlldr, p.id_base_schema_cible
			FROM oggdmde.sqlldr_dmde_t d
			INNER JOIN oggdmde.v_projets_details p ON p.nom_projet= :1
				AND p.base_cible = :2
				AND p.schema_source = d.schema_source
				AND p.schema_cible = d.schema_cible
			WHERE EXISTS ( SELECT 1
				FROM dba_tab_columns@'||pBaseCible||' c
				WHERE c.owner = d.schema_cible
					AND c.table_name = d.nom_table
					AND c.column_name = d.nom_col_cible)';
		
		EXECUTE IMMEDIATE codeSQL USING pNomProjet, pBaseCible ;
		
		COMMIT;
		EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK;
				RAISE;
	END;

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	FUNCTION SI_SQLLDR_VIDE
		RETURN BOOLEAN
	IS
		nbLigne NUMBER;
	BEGIN
		SELECT count(1) INTO nbLigne
			FROM oggdmde.sqlldr_dmde_t;
		RETURN (nbLigne = 0);
	END; 

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	FUNCTION SI_SQLLDR_DMDE_INVALIDE_SOURCE(pNomBase IN VARCHAR2)
	RETURN BOOLEAN
	IS
		nbLignes NUMBER;
	BEGIN
		SELECT Count(1) INTO nbLignes
			FROM oggdmde.v_dmde_invalides_source
			WHERE nom_base = pNomBase;
		RETURN (nbLignes > 0);
	END;

	-- ----------------------------------------------------------------------------
	-- PRIVEE
	-- ----------------------------------------------------------------------------
	FUNCTION SI_SQLLDR_DMDE_INVALIDE_CIBLE(pNomBase IN VARCHAR2)
	RETURN BOOLEAN
	IS
		nbLignes NUMBER;
	BEGIN
		SELECT Count(1) INTO nbLignes
			FROM oggdmde.v_dmde_invalides_cible
			WHERE nom_base = pNomBase;
		RETURN (nbLignes > 0);
	END;

	-- ----------------------------------------------------------------------------
	-- PUBLIQUE
	-- ----------------------------------------------------------------------------
	PROCEDURE VALIDER_SQLLDR_DMDE (
		pNomProjet IN VARCHAR2,
		pBaseSource IN VARCHAR2,
		pBaseCible IN VARCHAR2
	)
	IS
	BEGIN
		IF (si_sqlldr_vide()) THEN
			IF ( NOT si_schema_source_existe(pBaseSource)) THEN
				admin.pkg_trt.lever_exception('code_err_ogg_dmde_schema_invalide',' base source '||pBaseSource);
			END IF;
			pkg_ogg_commun.afficher_message_ok('SI_SCHEMA_SOURCE_EXISTEIER_SQLLDR_DMDE');

			IF ( NOT si_schema_cible_existe(pBaseCible)) THEN
				admin.pkg_trt.lever_exception('code_err_ogg_dmde_schema_invalide',' base cible '||pBaseCible);
			END IF;

			pkg_ogg_commun.afficher_message_ok('SI_SCHEMA_CIBLE_EXISTE');

			purger_sqlldr_dmde_invalides_e();

			verifier_base_source (pNomProjet, pBaseSource);
			IF (si_sqlldr_dmde_invalide_source(pBaseSource)) THEN
				admin.pkg_trt.lever_exception ('code_err_ogg_dmde_base_source_invalide'
				,pBaseSource||' consultez la vue oggdmde.V_DMDE_INVALIDES'
				);
			END IF;

			verifier_sqlldr_base_cible(pNomProjet, pBaseCible);
			IF (si_sqlldr_dmde_invalide_cible(pBaseCible)) THEN
				admin.pkg_trt.lever_exception ('code_err_ogg_dmde_base_cible_invalide'
				, pBaseCible||' consultez la vue oggdmde.V_DMDE_INVALIDES'
				);
			END IF;
		ELSE
			pkg_ogg_commun.afficher_message_ok('Aucune demande a faire!');
		END IF;

		EXCEPTION
			WHEN OTHERS THEN
			RAISE;

	END;
	
END;
/
