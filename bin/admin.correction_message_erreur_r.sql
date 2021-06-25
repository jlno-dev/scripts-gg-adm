ALTER session SET CURRENT_SCHEMA=ADMIN;

MERGE INTO ADMIN.MESSAGE_ERREUR_R A USING (
	SELECT 'code_err_ogg_dmde_base_source_invalide' as CODE_MSG_ERREUR,
		'Echec lors de la verification des demandes sur  la base source ' as LIB_MSG_ERREUR  from dual
	UNION
	SELECT 'code_err_ogg_dmde_base_cible_invalide',
		'Echec lors de la verification des demandes sur  la base cible '  from dual
	UNION
	SELECT 'code_err_ogg_dmde_schema_invalide',
		'Echec lors de la verification des demandes schema inexistant'  from dual
	UNION
	SELECT 'code_err_ogg_dmde_choix_interface',
		'Choix de l''interface de traitement incorrect'  from dual
) B
	ON (A.CODE_MSG_ERREUR = B.CODE_MSG_ERREUR)
	WHEN NOT MATCHED THEN
		INSERT ( CODE_MSG_ERREUR, LIB_MSG_ERREUR) VALUES (B.CODE_MSG_ERREUR, B.LIB_MSG_ERREUR)
WHEN MATCHED THEN
	UPDATE SET A.LIB_MSG_ERREUR = B.LIB_MSG_ERREUR;

COMMIT;

