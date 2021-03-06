ALTER SESSION SET CURRENT_SCHEMA=OGGDMDE;

CREATE OR REPLACE PROCEDURE  SupprObjetSiExiste(pSchema in VARCHAR2, pNomObjet in VARCHAR2, pTypeObjet in VARCHAR2 DEFAULT 'TABLE')
is
	nb NUMBER;
	codeSQL VARCHAR2(1024);
BEGIN
	SELECT COUNT(1) INTO nb 
		FROM dba_objects 
		WHERE owner = upper(pSchema) AND object_name = upper(pNomObjet) AND object_type = upper(pTypeObjet);
	IF (nb>0) THEN
		codeSQL := 'drop '||pTypeObjet||' '||pSchema||'.'||pNomObjet;
		IF (pTypeObjet='TABLE') THEN 
		codeSQL := codeSQL || ' purge';
		END IF;
		EXECUTE IMMEDIATE codeSQL;
	ELSE
		Dbms_Output.put_line('Objet '||pTypeObjet||' inexistant '||pSchema||'.'||pNomObjet);
	END IF;
END;
/


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'T#DONNEES');

CREATE GLOBAL TEMPORARY TABLE OGGDMDE."T#DONNEES"
(
  VALEUR  VARCHAR2(30 BYTE) NOT NULL
)
ON COMMIT PRESERVE ROWS
RESULT_CACHE (MODE DEFAULT)
NOCACHE;


CREATE UNIQUE INDEX OGGDMDE."T#DONNEES_U" ON OGGDMDE."T#DONNEES"
(VALEUR);


ALTER TABLE OGGDMDE."T#DONNEES" ADD (
  CONSTRAINT T#DONNEES_U
  UNIQUE (VALEUR)
  USING INDEX T#DONNEES_U
  ENABLE VALIDATE);



-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'SQLLDR_PARAM_T');

CREATE TABLE SQLLDR_PARAM_T (
	ID_PARAM NUMBER,
	ENVIRONNEMENT	VARCHAR2(80),
	CONNECTEUR	VARCHAR2(80),
	NOMCOMPOSANT	VARCHAR2(80),
	OBJET	VARCHAR2(80),
	PROJET	VARCHAR2(80),
	GGHOME	VARCHAR2(1024),
	OHOME	VARCHAR2(1024),
	SERVEUR	VARCHAR2(80),
	BASE_CIBLE	VARCHAR2(80),
	SCHEMA_CIBLE	VARCHAR2(80),
	SCHEMA_ADM	VARCHAR2(80),
	ORDRE	VARCHAR2(80),
	MONITORER	VARCHAR2(80)
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'SQLLDR_DMDE_T');

-- La colonne [ID_DMDE_SQLLDR] est alimentee par une sequence via sqlldr
CREATE TABLE SQLLDR_DMDE_T (
	ID_DMDE_SQLLDR	NUMBER,
	BASE_CIBLE	VARCHAR2(30),
	LIB_TYPE_DEMANDE	VARCHAR2(30),
	LIB_TYPE_OBJET		VARCHAR2(30),
	NOM_TABLE		VARCHAR2(30),
	SCHEMA_CIBLE	VARCHAR2(30),
	NOM_COL_CIBLE	VARCHAR2(30),
	SCHEMA_SOURCE 	VARCHAR2(30),
	NOM_COL_SOURCE	VARCHAR2(30),
	FILTRE_SOURCE	VARCHAR2(2048),
	TYPE_CHARGEMENT VARCHAR2(50)
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'SQLLDR_DMDE_INVALIDES_E');

CREATE TABLE SQLLDR_DMDE_INVALIDES_E (
	ID_SQLLDRDMDE_INVALIDE NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_DMDE_SQLLDR NUMBER,
	ID_BASE_SCHEMA NUMBER
);


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'TYPE_CHARGEMENT_R');

CREATE TABLE TYPE_CHARGEMENT_R (
	ID_TYPE_CHARGEMENT NUMBER GENERATED ALWAYS AS IDENTITY,
	LIB_TYPE_CHARGEMENT VARCHAR2(30)
);

CREATE UNIQUE INDEX TYPE_CHARGEMENT_PK ON TYPE_CHARGEMENT_R (ID_TYPE_CHARGEMENT) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TYPE_CHARGEMENT_U_NOM ON TYPE_CHARGEMENT_R (LIB_TYPE_CHARGEMENT) TABLESPACE OGGDMDE_INDX;

ALTER TABLE TYPE_CHARGEMENT_R ADD (
	CONSTRAINT TYPE_CHARGEMENT_PK PRIMARY KEY (ID_TYPE_CHARGEMENT)
 USING INDEX TYPE_CHARGEMENT_PK ENABLE VALIDATE
);



-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'TYPE_CONNECTEUR_R');

CREATE TABLE TYPE_CONNECTEUR_R (
	ID_TYPE_CONNECTEUR NUMBER GENERATED ALWAYS AS IDENTITY,
	LIB_TYPE_CONNECTEUR VARCHAR2(30)
);

CREATE UNIQUE INDEX TYPE_CONNECTEUR_PK ON TYPE_CONNECTEUR_R (ID_TYPE_CONNECTEUR) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TYPE_CONNECTEUR_U_NOM ON TYPE_CONNECTEUR_R (LIB_TYPE_CONNECTEUR) TABLESPACE OGGDMDE_INDX;

ALTER TABLE TYPE_CONNECTEUR_R ADD (
	CONSTRAINT TYPE_CONNECTEUR_PK PRIMARY KEY (ID_TYPE_CONNECTEUR)
 USING INDEX TYPE_CONNECTEUR_PK ENABLE VALIDATE
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'TYPE_ENVIRONNEMENT_R');

CREATE TABLE TYPE_ENVIRONNEMENT_R (
	ID_TYPE_ENVIRONNEMENT NUMBER GENERATED ALWAYS AS IDENTITY,
	LIB_TYPE_ENVIRONNEMENT VARCHAR2(30)
);

CREATE UNIQUE INDEX TYPE_ENVIRONNEMENT_PK ON TYPE_ENVIRONNEMENT_R (ID_TYPE_ENVIRONNEMENT) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TYPE_ENVIRONNEMENT_U_NOM ON TYPE_ENVIRONNEMENT_R (LIB_TYPE_ENVIRONNEMENT) TABLESPACE OGGDMDE_INDX;

ALTER TABLE TYPE_ENVIRONNEMENT_R ADD (
	CONSTRAINT TYPE_ENVIRONNEMENT_PK PRIMARY KEY (ID_TYPE_ENVIRONNEMENT)
 USING INDEX TYPE_ENVIRONNEMENT_PK ENABLE VALIDATE
);


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'TYPE_PARAMETRE_R');

CREATE TABLE TYPE_PARAMETRE_R (
	ID_TYPE_PARAMETRE NUMBER GENERATED ALWAYS AS IDENTITY,
	LIB_TYPE_PARAMETRE VARCHAR2(30)
);

CREATE UNIQUE INDEX TYPE_PARAMETRE_PK ON TYPE_PARAMETRE_R (ID_TYPE_PARAMETRE) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TYPE_PARAMETRE_U_NOM ON TYPE_PARAMETRE_R (LIB_TYPE_PARAMETRE) TABLESPACE OGGDMDE_INDX;

ALTER TABLE TYPE_PARAMETRE_R ADD (
	CONSTRAINT TYPE_PARAMETRE_PK PRIMARY KEY (ID_TYPE_PARAMETRE)
 USING INDEX TYPE_PARAMETRE_PK ENABLE VALIDATE
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'TYPE_CODE_R');

CREATE TABLE TYPE_CODE_R (
	ID_TYPE_CODE NUMBER GENERATED ALWAYS AS IDENTITY,
	LIB_TYPE_CODE VARCHAR2(30),
	LIBELLE_COMPLET VARCHAR2(128)
);

CREATE UNIQUE INDEX TYPE_CODE_PK ON TYPE_CODE_R (ID_TYPE_CODE) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TYPE_CODE_U_NOM ON TYPE_CODE_R (LIB_TYPE_CODE) TABLESPACE OGGDMDE_INDX;

ALTER TABLE TYPE_CODE_R ADD (
	CONSTRAINT TYPE_CODE_PK PRIMARY KEY (ID_TYPE_CODE)
 USING INDEX TYPE_CODE_PK ENABLE VALIDATE
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'TYPE_EXT_FICHIER_R');

CREATE TABLE TYPE_EXT_FICHIER_R (
	ID_TYPE_EXT_FICHIER NUMBER GENERATED ALWAYS AS IDENTITY,
	LIB_TYPE_EXT_FICHIER VARCHAR2(30)
);

CREATE UNIQUE INDEX TYPE_EXT_FICHIER_PK ON TYPE_EXT_FICHIER_R (ID_TYPE_EXT_FICHIER) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TYPE_EXT_FICHIER_U_NOM ON TYPE_EXT_FICHIER_R (LIB_TYPE_EXT_FICHIER) TABLESPACE OGGDMDE_INDX;

ALTER TABLE TYPE_EXT_FICHIER_R ADD (
	CONSTRAINT TYPE_EXT_FICHIER_PK PRIMARY KEY (ID_TYPE_EXT_FICHIER)
 USING INDEX TYPE_EXT_FICHIER_PK ENABLE VALIDATE
);


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'TYPE_COMPOSANT_R');

CREATE TABLE TYPE_COMPOSANT_R (
	ID_TYPE_COMPOSANT NUMBER GENERATED ALWAYS AS IDENTITY,
	LIB_TYPE_COMPOSANT VARCHAR2(30)
);

CREATE UNIQUE INDEX TYPE_COMPOSANT_PK ON TYPE_COMPOSANT_R (ID_TYPE_COMPOSANT) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TYPE_COMPOSANT_U_NOM ON TYPE_COMPOSANT_R (LIB_TYPE_COMPOSANT) TABLESPACE OGGDMDE_INDX;

ALTER TABLE TYPE_COMPOSANT_R ADD (
	CONSTRAINT TYPE_COMPOSANT_PK PRIMARY KEY (ID_TYPE_COMPOSANT)
 USING INDEX TYPE_COMPOSANT_PK ENABLE VALIDATE
);


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'TYPE_TBS_R');


CREATE TABLE TYPE_TBS_R (
	ID_TYPE_TBS NUMBER GENERATED ALWAYS AS IDENTITY,
	LIB_TYPE_TBS VARCHAR2(30)
);

CREATE UNIQUE INDEX TYPE_TBS_PK ON TYPE_TBS_R (ID_TYPE_TBS) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TYPE_TBS_U_NOM ON TYPE_TBS_R (LIB_TYPE_TBS) TABLESPACE OGGDMDE_INDX;

ALTER TABLE TYPE_TBS_R ADD (
	CONSTRAINT TYPE_TBS_PK PRIMARY KEY (ID_TYPE_TBS)
 USING INDEX TYPE_TBS_PK ENABLE VALIDATE
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'TYPE_OBJET_R');

CREATE TABLE TYPE_OBJET_R (
	ID_TYPE_OBJET NUMBER GENERATED ALWAYS AS IDENTITY,
	LIB_TYPE_OBJET VARCHAR2(30)
);

CREATE UNIQUE INDEX TYPE_OBJET_PK ON TYPE_OBJET_R (ID_TYPE_OBJET) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TYPE_OBJET_U_NOM ON TYPE_OBJET_R (LIB_TYPE_OBJET) TABLESPACE OGGDMDE_INDX;

ALTER TABLE TYPE_OBJET_R ADD (
	CONSTRAINT TYPE_OBJET_PK PRIMARY KEY (ID_TYPE_OBJET)
 USING INDEX TYPE_OBJET_PK ENABLE VALIDATE
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

exec  SupprObjetSiExiste('OGGDMDE', 'TYPE_DEMANDE_R');

CREATE TABLE TYPE_DEMANDE_R (
	ID_TYPE_DEMANDE NUMBER GENERATED ALWAYS AS IDENTITY,
	LIB_TYPE_DEMANDE VARCHAR2(30)
);

CREATE UNIQUE INDEX TYPE_DEMANDE_PK ON TYPE_DEMANDE_R (ID_TYPE_DEMANDE) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TYPE_DEMANDE_U_NOM ON TYPE_DEMANDE_R (LIB_TYPE_DEMANDE) TABLESPACE OGGDMDE_INDX;

ALTER TABLE TYPE_DEMANDE_R ADD (
	CONSTRAINT TYPE_DEMANDE_PK PRIMARY KEY (ID_TYPE_DEMANDE)
 USING INDEX TYPE_DEMANDE_PK ENABLE VALIDATE
);


-- ----------------------------------------------------------------------------
-- ---------------------------------------------------------------------------- 
exec  SupprObjetSiExiste('OGGDMDE', 'TYPE_STATUT_DMDE_R');

CREATE TABLE TYPE_STATUT_DMDE_R (
	ID_TYPE_STATUT_DMDE NUMBER GENERATED ALWAYS AS IDENTITY,
	LIB_TYPE_STATUT_DMDE VARCHAR2(128)
);

CREATE UNIQUE INDEX TYPE_STATUT_DMDE_PK
ON TYPE_STATUT_DMDE_R (ID_TYPE_STATUT_DMDE)
 TABLESPACE OGGDMDE_INDX;

ALTER TABLE TYPE_STATUT_DMDE_R ADD (
	CONSTRAINT TYPE_STATUT_DMDE_PK PRIMARY KEY (ID_TYPE_STATUT_DMDE)
 USING INDEX TYPE_STATUT_DMDE_PK ENABLE VALIDATE
);

CREATE UNIQUE INDEX TYPE_STATUT_DMDE_U_LIB
ON TYPE_STATUT_DMDE_R (LIB_TYPE_STATUT_DMDE)
 TABLESPACE OGGDMDE_INDX;



-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

exec  SupprObjetSiExiste('OGGDMDE', 'TYPE_ACTION_R');

CREATE TABLE TYPE_ACTION_R (
	ID_TYPE_ACTION NUMBER GENERATED ALWAYS AS IDENTITY,
	LIB_TYPE_ACTION VARCHAR2(30)
);

CREATE UNIQUE INDEX TYPE_ACTION_PK ON TYPE_ACTION_R (ID_TYPE_ACTION) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TYPE_ACTION_U_NOM ON TYPE_ACTION_R (LIB_TYPE_ACTION) TABLESPACE OGGDMDE_INDX;

ALTER TABLE TYPE_ACTION_R ADD (
	CONSTRAINT TYPE_ACTION_PK PRIMARY KEY (ID_TYPE_ACTION)
 USING INDEX TYPE_ACTION_PK ENABLE VALIDATE
);


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'TYPE_BASE_R');

CREATE TABLE TYPE_BASE_R (
	ID_TYPE_BASE NUMBER GENERATED ALWAYS AS IDENTITY,
	LIB_TYPE_BASE VARCHAR2(30)
);

CREATE UNIQUE INDEX TYPE_BASE_PK ON TYPE_BASE_R (ID_TYPE_BASE) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TYPE_BASE_U_NOM ON TYPE_BASE_R (LIB_TYPE_BASE) TABLESPACE OGGDMDE_INDX;

ALTER TABLE TYPE_BASE_R ADD (
	CONSTRAINT TYPE_BASE_PK PRIMARY KEY (ID_TYPE_BASE)
 USING INDEX TYPE_BASE_PK ENABLE VALIDATE
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'SCHEMA_R');
CREATE TABLE SCHEMA_R (
	ID_SCHEMA NUMBER GENERATED ALWAYS AS IDENTITY,
	NOM_SCHEMA VARCHAR2(30)
);

CREATE UNIQUE INDEX SCHEMA_R_PK ON SCHEMA_R (ID_SCHEMA) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX SCHEMA_R_U_NOM ON SCHEMA_R (NOM_SCHEMA) TABLESPACE OGGDMDE_INDX;

ALTER TABLE SCHEMA_R ADD (
	CONSTRAINT SCHEMA_R_PK PRIMARY KEY (ID_SCHEMA)
 USING INDEX SCHEMA_R_PK ENABLE VALIDATE
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'PROJET_R');

CREATE TABLE PROJET_R (
	ID_PROJET NUMBER GENERATED ALWAYS AS IDENTITY,
	NOM_PROJET VARCHAR2(30)
);

CREATE UNIQUE INDEX PROJET_R_PK ON PROJET_R (ID_PROJET) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX PROJET_U_NOM ON PROJET_R (NOM_PROJET) TABLESPACE OGGDMDE_INDX;

ALTER TABLE PROJET_R ADD (
	CONSTRAINT PROJET_R_PK PRIMARY KEY (ID_PROJET)
 USING INDEX PROJET_R_PK ENABLE VALIDATE
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'CODE_EXT_FIC_E');

CREATE TABLE CODE_EXT_FIC_E (
	ID_CODE_EXT_FIC	NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_TYPE_CODE			NUMBER,
	ID_TYPE_EXT_FICHIER		NUMBER
);

CREATE UNIQUE INDEX CODE_EXT_FIC_PK ON CODE_EXT_FIC_E (ID_CODE_EXT_FIC) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX CODE_EXT_FIC_U_ID ON CODE_EXT_FIC_E (ID_TYPE_CODE, ID_TYPE_EXT_FICHIER) TABLESPACE OGGDMDE_INDX;

ALTER TABLE CODE_EXT_FIC_E ADD (
	CONSTRAINT CODE_EXT_FIC_PK PRIMARY KEY (ID_CODE_EXT_FIC)
 USING INDEX CODE_EXT_FIC_PK ENABLE VALIDATE
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'PARAMETRE_E');

CREATE TABLE PARAMETRE_E (
	ID_PARAMETRE NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_TYPE_PARAMETRE NUMBER,
	NOM_PARAMETRE VARCHAR2(30)
);

CREATE UNIQUE INDEX PARAMETRE_PK ON PARAMETRE_E (ID_PARAMETRE) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX PARAMETRE_U_NOM ON PARAMETRE_E (NOM_PARAMETRE) TABLESPACE OGGDMDE_INDX;

ALTER TABLE PARAMETRE_E ADD (
	CONSTRAINT PARAMETRE_PK PRIMARY KEY (ID_PARAMETRE)
 USING INDEX PARAMETRE_PK ENABLE VALIDATE
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'COMPOSANT_E');

CREATE TABLE COMPOSANT_E (
	ID_COMPOSANT NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_TYPE_COMPOSANT NUMBER,
	NOM_COMPOSANT VARCHAR2(256)
);

CREATE UNIQUE INDEX COMPOSANT_PK ON COMPOSANT_E (ID_COMPOSANT) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX COMPOSANT_U_NOM ON COMPOSANT_E (NOM_COMPOSANT) TABLESPACE OGGDMDE_INDX;

ALTER TABLE COMPOSANT_E ADD (
	CONSTRAINT COMPOSANT_PK PRIMARY KEY (ID_COMPOSANT)
 USING INDEX COMPOSANT_PK ENABLE VALIDATE
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

EXEC  SupprObjetSiExiste('OGGDMDE', 'COMPOSANT_PARAMETRE_A');

CREATE TABLE COMPOSANT_PARAMETRE_A (
	ID_COMPOSANT_PARAMETRE	NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_PROJET 				NUMBER,
	ID_TYPE_ENVIRONNEMENT	NUMBER,
	ID_COMPOSANT			NUMBER,
	ID_PARAMETRE			NUMBER,
	VALEUR					VARCHAR2(4000)
);

CREATE UNIQUE INDEX COMPOSANT_PARAMETRE_PK ON COMPOSANT_PARAMETRE_A (ID_COMPOSANT_PARAMETRE) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX COMPOSANT_PARAMETRE_U_ID ON COMPOSANT_PARAMETRE_A (ID_PROJET, ID_TYPE_ENVIRONNEMENT, ID_COMPOSANT, ID_PARAMETRE) TABLESPACE OGGDMDE_INDX;

ALTER TABLE COMPOSANT_PARAMETRE_A ADD (
	CONSTRAINT COMPOSANT_PARAMETRE_PK PRIMARY KEY (ID_COMPOSANT_PARAMETRE)
 USING INDEX COMPOSANT_PARAMETRE_PK ENABLE VALIDATE
);


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'TBS_E');
 
CREATE TABLE TBS_E (
	ID_TBS NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_TYPE_TBS NUMBER,
	NOM_TBS VARCHAR2(30)
);

CREATE UNIQUE INDEX TBS_PK ON TBS_E (ID_TBS) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TBS_U_NOM ON TBS_E (NOM_TBS) TABLESPACE OGGDMDE_INDX;

ALTER TABLE TBS_E ADD (
	CONSTRAINT TBS_PK PRIMARY KEY (ID_TBS)
 USING INDEX TBS_PK ENABLE VALIDATE
);


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'BASE_E');


CREATE TABLE BASE_E (
	ID_BASE NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_TYPE_BASE NUMBER,
	NOM_BASE  VARCHAR2(30)
);

CREATE UNIQUE INDEX BASE_E_PK ON BASE_E (ID_BASE) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TYPE_BASE_U_TYPE_NOM ON BASE_E (ID_TYPE_BASE, NOM_BASE) TABLESPACE OGGDMDE_INDX;

ALTER TABLE BASE_E ADD (
	CONSTRAINT BASE_E_PK PRIMARY KEY (ID_BASE)
 USING INDEX BASE_E_PK ENABLE VALIDATE
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'LIEN_BASE_E');

CREATE TABLE LIEN_BASE_E (
	ID_LIEN_BASE NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_BASE_CIBLE NUMBER,
	ID_SCHEMA_CIBLE NUMBER,
	NOM_LIEN_BASE VARCHAR2(30)
);

CREATE UNIQUE INDEX LIEN_BASE_PK ON LIEN_BASE_E (ID_LIEN_BASE) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX LIEN_BASE_U_NOM ON LIEN_BASE_E (ID_BASE_CIBLE, ID_SCHEMA_CIBLE, NOM_LIEN_BASE) TABLESPACE OGGDMDE_INDX;

ALTER TABLE LIEN_BASE_E ADD (
	CONSTRAINT LIEN_BASE_PK PRIMARY KEY (ID_LIEN_BASE)
 USING INDEX LIEN_BASE_PK ENABLE VALIDATE
);


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'BASE_SCHEMA_A');

CREATE TABLE BASE_SCHEMA_A (
	ID_BASE_SCHEMA NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_BASE NUMBER,
	ID_SCHEMA NUMBER
);

CREATE UNIQUE INDEX BASE_SCHEMA_A_PK ON BASE_SCHEMA_A (ID_BASE_SCHEMA) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX TYPE_BASE_U_IDBASE_IDSCHEMA ON BASE_SCHEMA_A (ID_BASE,ID_SCHEMA) TABLESPACE OGGDMDE_INDX;

ALTER TABLE BASE_SCHEMA_A ADD (
	CONSTRAINT BASE_SCHEMA_A_PK PRIMARY KEY (ID_BASE_SCHEMA)
 USING INDEX BASE_SCHEMA_A_PK ENABLE VALIDATE
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'BASE_SCHEMA_TBS_A');

CREATE TABLE BASE_SCHEMA_TBS_A (
	ID_BASE_SCHEMA_TBS NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_BASE_SCHEMA NUMBER,
	ID_TBS NUMBER
);

CREATE UNIQUE INDEX BASE_SCHEMA_TBS_A_PK ON BASE_SCHEMA_TBS_A (ID_BASE_SCHEMA_TBS) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX BASE_SCHEMA_TBS_U_IDBASE_TBS ON BASE_SCHEMA_TBS_A (ID_BASE_SCHEMA,ID_TBS) TABLESPACE OGGDMDE_INDX;

ALTER TABLE BASE_SCHEMA_TBS_A ADD (
	CONSTRAINT BASE_SCHEMA_TBS_A_PK PRIMARY KEY (ID_BASE_SCHEMA_TBS)
 USING INDEX BASE_SCHEMA_TBS_A_PK ENABLE VALIDATE
);


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'PROJET_DETAIL_A');

CREATE TABLE PROJET_DETAIL_A (
	ID_PROJET_DETAIL NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_BASE_SCHEMA_SOURCE NUMBER,
	ID_BASE_SCHEMA_CIBLE NUMBER,
	ID_PROJET NUMBER
);

CREATE UNIQUE INDEX PROJET_DETAIL_A_PK ON PROJET_DETAIL_A (ID_PROJET_DETAIL) TABLESPACE OGGDMDE_INDX;

CREATE UNIQUE INDEX PROJET_DETAIL_U_IDS ON PROJET_DETAIL_A (ID_PROJET, ID_BASE_SCHEMA_SOURCE,ID_BASE_SCHEMA_CIBLE ) TABLESPACE OGGDMDE_INDX;

ALTER TABLE PROJET_DETAIL_A ADD (
	CONSTRAINT PROJET_DETAIL_A_PK PRIMARY KEY (ID_PROJET_DETAIL)
 USING INDEX PROJET_DETAIL_A_PK ENABLE VALIDATE
);








-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'DEMANDES_E');

CREATE TABLE DEMANDES_E (
	ID_DEMANDE NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_PROJET NUMBER NOT NULL,
	DATE_DMDE DATE DEFAULT SYSDATE,
	DATE_TRAITEMENT DATE,
	COMMENTAIRE VARCHAR2(4000)
);

CREATE UNIQUE INDEX DEMANDES_E_PK
ON DEMANDES_E (ID_DEMANDE)
 TABLESPACE OGGDMDE_INDX;

ALTER TABLE DEMANDES_E ADD (
	CONSTRAINT DEMANDES_E_PK PRIMARY KEY (ID_DEMANDE)
 USING INDEX DEMANDES_E_PK ENABLE VALIDATE
);

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'DMDE_TABLES_E');

CREATE TABLE DMDE_TABLES_E (
	ID_DMDE_TABLE NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_DEMANDE NUMBER,
	ID_BASE_SCHEMA_SOURCE NUMBER,
	ID_BASE_SCHEMA_CIBLE NUMBER,
	ID_TYPE_ACTION NUMBER,
	ID_TYPE_CHARGEMENT NUMBER,
	NOM_TABLE VARCHAR2(30)
);

CREATE UNIQUE INDEX DMDE_TABLES_E_PK
ON DMDE_TABLES_E (ID_DMDE_TABLE)
 TABLESPACE OGGDMDE_INDX;

ALTER TABLE DMDE_TABLES_E ADD (
	CONSTRAINT DMDE_TABLES_E_PK PRIMARY KEY (ID_DMDE_TABLE)
 USING INDEX DMDE_TABLES_E_PK ENABLE VALIDATE
);

CREATE UNIQUE INDEX OGGDMDE.DMDE_TABLES_E_IDS ON OGGDMDE.DMDE_TABLES_E
(ID_DEMANDE, ID_BASE_SCHEMA_SOURCE, ID_BASE_SCHEMA_CIBLE, NOM_TABLE)
LOGGING
TABLESPACE OGGDMDE_INDX;


-- ----------------------------------------------------------------------------
-- ---------------------------------------------------------------------------- 
exec  SupprObjetSiExiste('OGGDMDE', 'DMDE_TAB_COLONNES_E');

CREATE TABLE DMDE_TAB_COLONNES_E (
	ID_DMDE_TAB_COL NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_DMDE_TABLE NUMBER,
	ID_TYPE_DEMANDE NUMBER,
	NOM_COL_SOURCE VARCHAR2(30),
	NOM_COL_CIBLE VARCHAR2(30)
);

CREATE UNIQUE INDEX DMDE_TAB_COLONNES_E_PK
ON DMDE_TAB_COLONNES_E (ID_DMDE_TAB_COL)
 TABLESPACE OGGDMDE_INDX;

ALTER TABLE DMDE_TAB_COLONNES_E ADD (
	CONSTRAINT DMDE_TAB_COLONNES_E_PK PRIMARY KEY (ID_DMDE_TAB_COL)
	USING INDEX DMDE_TAB_COLONNES_E_PK ENABLE VALIDATE
);

CREATE UNIQUE INDEX DMDE_TAB_COLONNES_E_U_IDS
ON DMDE_TAB_COLONNES_E (ID_DMDE_TABLE,ID_TYPE_DEMANDE,NOM_COL_SOURCE,NOM_COL_CIBLE)
	TABLESPACE OGGDMDE_INDX;


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
exec  SupprObjetSiExiste('OGGDMDE', 'DMDE_TAB_FILTRES_E');

CREATE TABLE DMDE_TAB_FILTRES_E (
	ID_DMDE_TAB_FILTRE NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_DMDE_TABLE NUMBER,
	NOM_COLONNE VARCHAR2(30),
	FILTRE VARCHAR2(512),
	OPERATEUR VARCHAR2(10)
);

CREATE UNIQUE INDEX DMDE_TAB_FILTRES_E_PK
ON DMDE_TAB_FILTRES_E (ID_DMDE_TAB_FILTRE)
 TABLESPACE OGGDMDE_INDX;

ALTER TABLE DMDE_TAB_FILTRES_E ADD (
	CONSTRAINT DMDE_TAB_FILTRES_E_PK PRIMARY KEY (ID_DMDE_TAB_FILTRE)
	USING INDEX DMDE_TAB_FILTRES_E_PK ENABLE VALIDATE
);

CREATE UNIQUE INDEX DMDE_TAB_FILTRES_E_U_IDS
ON DMDE_TAB_FILTRES_E (ID_DMDE_TABLE, NOM_COLONNE)
	TABLESPACE OGGDMDE_INDX;

-- ----------------------------------------------------------------------------
-- ---------------------------------------------------------------------------- 
exec  SupprObjetSiExiste('OGGDMDE', 'DMDE_TAB_CODE_E');

CREATE TABLE DMDE_TAB_CODE_E (
	ID_DME_TAB_CODE NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_DMDE_TABLE NUMBER,
	ID_TYPE_CODE NUMBER,
	CODE CLOB
);

CREATE UNIQUE INDEX DMDE_TAB_CODE_E_PK
ON DMDE_TAB_CODE_E (ID_DME_TAB_CODE)
 TABLESPACE OGGDMDE_INDX;

ALTER TABLE DMDE_TAB_CODE_E ADD (
	CONSTRAINT DMDE_TAB_CODE_E_PK PRIMARY KEY (ID_DME_TAB_CODE)
 USING INDEX DMDE_TAB_CODE_E_PK ENABLE VALIDATE
);

CREATE UNIQUE INDEX DMDE_TAB_CODE_U_IDS
ON DMDE_TAB_CODE_E (ID_DMDE_TABLE, ID_TYPE_CODE)
 TABLESPACE OGGDMDE_INDX;


-- ----------------------------------------------------------------------------
-- ---------------------------------------------------------------------------- 
exec  SupprObjetSiExiste('OGGDMDE', 'DMDE_TAB_A_TRAITER_E');

CREATE TABLE DMDE_TAB_A_TRAITER_E (
	ID_DMDE_TAB_A_TRAITER NUMBER GENERATED ALWAYS AS IDENTITY,
	ID_DMDE_TABLE NUMBER,
	ID_TYPE_STATUT_DMDE NUMBER,
	FAIT_LE DATE
);

CREATE UNIQUE INDEX DMDE_TAB_A_TRAITER_PK
ON DMDE_TAB_A_TRAITER_E (ID_DMDE_TAB_A_TRAITER)
 TABLESPACE OGGDMDE_INDX;

ALTER TABLE DMDE_TAB_A_TRAITER_E ADD (
	CONSTRAINT DMDE_TAB_A_TRAITER_PK PRIMARY KEY (ID_DMDE_TAB_A_TRAITER)
 USING INDEX DMDE_TAB_A_TRAITER_PK ENABLE VALIDATE
);

CREATE UNIQUE INDEX DMDE_TAB_A_TRAITER_U_IDS
ON DMDE_TAB_A_TRAITER_E (ID_DMDE_TABLE)
 TABLESPACE OGGDMDE_INDX;
