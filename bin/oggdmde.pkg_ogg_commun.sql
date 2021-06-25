ALTER SESSION SET current_schema=oggdmde;

-- GRANT EXECUTE ON SYS.UTL_FILE TO OGGDMDE;

CREATE OR REPLACE PACKAGE pkg_ogg_commun
is
	cste_caractere_retour_ligne	CONSTANT 	CHAR(1)		:= chr(10);
	cste_caractere_espace		CONSTANT 	CHAR(1)		:= ' ';
	cste_caractere_fin_cmde		CONSTANT 	CHAR(1)		:= ';';
	cste_caractere_sep_virgule	CONSTANT 	CHAR(1)		:= ',';
	cste_caractere_tabulation	CONSTANT 	CHAR(1)		:= chr(9);
	cste_separateur_colonne		CONSTANT VARCHAR2(10)	:= cste_caractere_sep_virgule||cste_caractere_retour_ligne;
	
	cste_action_creer_objet		CONSTANT VARCHAR2(15) := 'CREATE';
	cste_action_modifier_objet	CONSTANT VARCHAR2(15) := 'ALTER';
	cste_action_supprimer_objet	CONSTANT VARCHAR2(15) := 'DROP';
	cste_dmde_supprimer			CONSTANT VARCHAR2(15) := 'SUPPRIMER';
	cste_dmde_ajouter			CONSTANT VARCHAR2(15) := 'AJOUTER';
	cste_dmde_modifier			CONSTANT VARCHAR2(15) := 'MODIFIER';	
	cste_type_objet_table		CONSTANT dba_objects.object_type%TYPE := 'TABLE';
	cste_type_objet_colonne		CONSTANT dba_objects.object_type%TYPE := 'COLONNE';

	cste_message_ok				CONSTANT VARCHAR2(5) :='OK';
	cste_message_ko				CONSTANT VARCHAR2(5) :='KO';
	-- ----------------------------------------------------------------------------
	PROCEDURE AFFICHER_MESSAGE_OK(pMessage IN VARCHAR2);
	
	PROCEDURE AFFICHER_MESSAGE_KO(pMessage IN VARCHAR2);
	
	-- ----------------------------------------------------------------------------
	PROCEDURE ECRIRE_FICHIER(
		pNomFichier	IN VARCHAR2,
		pDonnee		IN CLOB
	);
	
	-- ----------------------------------------------------------------------------
	FUNCTION SI_EXISTE_SCHEMA(
		pNomSchema IN VARCHAR2,
		pBaseDistante IN VARCHAR2
	) RETURN BOOLEAN;

	-- ----------------------------------------------------------------------------
	FUNCTION SI_EXISTE_OBJET(
		pSchema			IN VARCHAR2,
		pNomObjet		IN VARCHAR2,
		pTypeObjet		IN VARCHAR2,
		pBaseDistante	IN VARCHAR2
	) RETURN BOOLEAN;

	-- ----------------------------------------------------------------------------
	FUNCTION SI_EXISTE_TABLE(
		pSchema			IN VARCHAR2,
		pTable			IN VARCHAR2,
		pBaseDistante	IN VARCHAR2
	) RETURN BOOLEAN;
	
	-- ----------------------------------------------------------------------------
	FUNCTION DECODER_TYPE_ACTION(
		pNomTable IN VARCHAR2
	) RETURN VARCHAR2;

	-- ----------------------------------------------------------------------------
	FUNCTION SI_ACTION_AJOUTER( 
		pTypeAction	IN VARCHAR2
	) RETURN BOOLEAN;

	-- ----------------------------------------------------------------------------
	FUNCTION SI_ACTION_MODIFIER( 
			IN VARCHAR2
	) RETURN BOOLEAN;

	-- ----------------------------------------------------------------------------
	FUNCTION SI_ACTION_SUPPRIMER( 
			IN VARCHAR2
	) RETURN BOOLEAN;
	
END ;
/

CREATE OR REPLACE PACKAGE BODY PKG_OGG_COMMUN
is
	-- ----------------------------------------------------------------------------
	PROCEDURE AFFICHER_MESSAGE(
		pMessage IN VARCHAR2,
		pTypeMessage IN VARCHAR2
	) IS
		prefixeMsg VARCHAR2(4000);
		suffixeMsg VARCHAR2(4000);
	BEGIN
		IF (pTypeMessage = cste_message_ko) THEN
			prefixeMsg := 'ERREUR: ';
			suffixeMsg := ' -'||cste_message_ko ||'- : ';
		ELSIF  pTypeMessage = cste_message_ok THEN
			prefixeMsg := ' ';
			suffixeMsg := ' -'||cste_message_ok||'- : ';
		 ELSE
			prefixeMsg := ' ';
			suffixeMsg := ' ';
		END IF;
	
		Dbms_Output.put_line(prefixeMsg||pMessage||suffixeMsg);
	END;
	
	-- ---------------------------------------------------------
	PROCEDURE AFFICHER_MESSAGE_OK(pMessage IN VARCHAR2)
	IS
	BEGIN
		afficher_message(pMessage, cste_message_ok);
	END;

	-- ---------------------------------------------------------
	PROCEDURE AFFICHER_MESSAGE_KO(pMessage IN VARCHAR2)
	IS
	BEGIN
		afficher_message(pMessage, cste_message_ko);
	END;

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	PROCEDURE ECRIRE_FICHIER(
		pNomFichier	IN VARCHAR2,
		pDonnee		IN CLOB
	)
	IS
		hFichier UTL_FILE.FILE_TYPE;
	BEGIN
		hFichier := UTL_FILE.FOPEN(
			location		=> 'OGG_DIR_LIVRAISON_SQL_PRM',
			filename		=> pNomFichier,
			open_mode		=> 'w',
			max_linesize	=> 32767
		);
		UTL_FILE.PUT_LINE(hFichier, pDonnee);
		UTL_FILE.FCLOSE(hFichier);

		EXCEPTION
			WHEN OTHERS THEN
				RAISE;
	END;
	

	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	FUNCTION SI_EXISTE_SCHEMA(
		pNomSchema		IN VARCHAR2,
		pBaseDistante	IN VARCHAR2
	) RETURN BOOLEAN
	AS
		lcompteur NUMBER :=0;
		nomBase VARCHAR2(30) := cste_caractere_espace;
	BEGIN
		IF ( pBaseDistante IS NOT NULL) THEN
		EXECUTE IMMEDIATE 'SELECT count(1) FROM dba_users@'
				||pBaseDistante||' WHERE username = :1'
			INTO lcompteur using pNomSchema;
		ELSE
			SELECT count(1) INTO lcompteur 
				FROM dba_users
				WHERE username = pNomSchema;
		END IF;
		RETURN (lcompteur >0);
	END;
	
	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	FUNCTION SI_EXISTE_OBJET(
		pSchema			IN VARCHAR2,
		pNomObjet		IN VARCHAR2,
		pTypeObjet		IN VARCHAR2,
		pBaseDistante	IN VARCHAR2
	) RETURN BOOLEAN
	AS
		lcompteur	NUMBER :=0;
		schemaObjet	VARCHAR2(30) := upper(pSchema);
		nomObjet	VARCHAR2(30) := upper(pNomObjet);
		typeObjet	VARCHAR2(30) := upper(pTypeObjet);

	BEGIN
		IF (pBaseDistante IS NULL) THEN
			SELECT count(1) INTO lcompteur
			FROM dba_objects
			WHERE owner = schemaObjet
				AND object_name = nomObjet
				AND object_type = typeObjet;
		ELSE
			EXECUTE IMMEDIATE 'SELECT count(1)
				FROM dba_objects@'||pBaseDistante||' WHERE owner = :1 AND object_name = :2 AND object_type = :3'
				INTO lcompteur using schemaObjet, nomObjet, typeObjet;
		END IF;
		RETURN (lcompteur > 0);
	END;


	-- ----------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------
	FUNCTION SI_EXISTE_TABLE(
		pSchema			IN VARCHAR2,
		pTable			IN VARCHAR2,
		pBaseDistante	IN VARCHAR2
	) RETURN BOOLEAN
	AS
	BEGIN
		RETURN si_existe_objet(pSchema, pTable, cste_type_objet_table, pBaseDistante);
	END;

	-- ---------------------------------------------------------------------------
	-- PUBLIQUE
	-- ---------------------------------------------------------------------------
	FUNCTION DECODER_TYPE_ACTION( pNomTable IN VARCHAR2)
		RETURN VARCHAR2
	IS
		typeAction VARCHAR2(30);
	BEGIN
		IF (pNomTable IS NULL) then
			typeAction := cste_action_creer_objet;
		ELSE
			typeAction := cste_action_modifier_objet;
		END IF;
		RETURN typeAction;
	END;

	-- ---------------------------------------------------------------------------
	-- PUBLIQUE
	-- ---------------------------------------------------------------------------
	FUNCTION SI_ACTION_AJOUTER( 
		pTypeAction	IN VARCHAR2
	) RETURN BOOLEAN
	IS 
	BEGIN 
		RETURN (pTypeAction = cste_dmde_ajouter); 
	END;

	-- ---------------------------------------------------------------------------
	-- PUBLIQUE
	-- ---------------------------------------------------------------------------
	FUNCTION SI_ACTION_MODIFIER( 
		pTypeAction	IN VARCHAR2
	) RETURN BOOLEAN
	IS 
	BEGIN 
		RETURN (pTypeAction = cste_dmde_modifier);
	END;
	-- ---------------------------------------------------------------------------
	-- PUBLIQUE
	-- ---------------------------------------------------------------------------
	FUNCTION SI_ACTION_SUPPRIMER( 
		pTypeAction	IN VARCHAR2
	) RETURN BOOLEAN
	IS 
	BEGIN 
		RETURN (pTypeAction = cste_dmde_supprimer); 
	END;

END;
/
