ALTER SESSION SET current_schema=OGGDMDE;

/*
===============================================================================
Alimentation de la table sqlldr_dmde_t via 
-----------------------------------------------------------
    sqlloader :
        depose du fichier csv dans ~/admin/goldengate/admin/livraison/demandes
        lancement de charger_table_demandes.sh (sqllrd)
        sqlplus.pkg_ogg_sqlldr.valider_sqlldr_dmde(nomprojet, basesource,basecible);
    web : Alimente directement la table sqlldr_dmde_t et effectue les controles
===============================================================================
Alimentation des tables dmde_tab_xxx :
--------------------------------------
pkg_ogg_demandes.creer_demandes(nomprojet, basecible, commentaire);

===============================================================================
Selection des demandes a faire
-------------------------------
pkg_ogg_demandes.generer_liste_dmde_a_traiter(liste_bases, liste_schemas, liste_tables)
ou
pkg_ogg_demandes.generer_liste_dmde_a_traiter(id_demande)

===============================================================================
Deploiement
    ---------- TRANDATA SOURCE----------
    Generer trandata source

    foreach base
        ggsci > obey fichier.trandata_source


    ---------- ARRET DES SERVICES ---------
    ggsci > obey fichier.stop_process_extract_source
    ggsci > obey fichier.stop_process_replicat_source
    ggsci > obey fichier.stop_process_extract_staging
    ggsci > obey fichier.stop_process_replicat_staging
    
    ---------- DDL Tables ----------
    pkg_ogg_demandes.CREER_DMDE_TAB_CODE_DDL(id_demande)
    passer les ddl via make ou exec immediate

    ---------- TRANDATA SOURCE----------
    Generer trandata staging
    foreach schemas
            ggsci > obey fichier.trandata_staging_schema


    ---------- SQL INIT/ EXTRACT SOURCE/ REPLICAT SOURCE/EXTRACT STAGING/REPLICAT STAGING ----------
    pkg_ogg_demandes.creer_dmde_tab_code_init();
    pkg_ogg_demandes.creer_dmde_tab_code_extract();
    pkg_ogg_demandes.creer_dmde_tab_code_replicat();


    ---------- Demarrage DES SERVICES ---------
    ggsci > obey fichier.start_process_extract_source
    ggsci > obey fichier.start_process_replicat_source
    ggsci > obey fichier.start_process_extract_staging
    ggsci > obey fichier.start_process_replicat_staging

    ---------- CHARGEMENT DES DONNEES : initialload ----------
    foreach dmde
        sqlplus init.*.sql

---------------------------------------------------------------
*/

declare
	nomprojet oggdmde.projet_r.nom_projet%type := 'ALLBIRDS';
	nomBaseCible varchar2(30) := 'ALLBIRDS';
	pcommentaire  oggdmde.demandes_e.commentaire%type;
	listeBases varchar2(1024):='ALLBIRDS';
	listeSchemas varchar2(2048):='OSMEXP';
	listeTables varchar2(16000):='*';
	siCreerDmde boolean := true;
	siGenListeDmde boolean := false;
begin 
    IF (siCreerDmde) THEN
        oggdmde.pkg_ogg_demandes.creer_demandes(nomProjet, nomBaseCible, pCommentaire);
    END IF;
    IF (siGenListeDmde) THEN
        oggdmde.pkg_ogg_demandes.GENERER_LISTE_DMDE_A_TRAITER(listeBases, listeSchemas, listeTables);
    END IF;
    
    commit;
    
    exception
        when no_data_found then
            rollback;
			raise;
end;
/

