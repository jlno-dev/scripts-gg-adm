/*
DECLARE
nomprojet     VARCHAR2(512):='ALLBIRDS';
libTypeenv    VARCHAR2(512) := 'RCT';
nomComposant  VARCHAR2(512) := 'EAB001S1';

BEGIN
oggdmde.pkg_ogg_config.ajouter_composant_parametre (
		nomprojet,
		libTypeenv,
		nomComposant,
		'EXTRACT',
		'EAB001S1');
 oggdmde.pkg_ogg_config.ajouter_composant_parametre (
		nomprojet,
		libTypeenv,
		nomComposant,
		Upper('Exttrail'),
		'./dirdat/ALLBIRDS/SOURCE/OSM001/r1');
 oggdmde.pkg_ogg_config.ajouter_composant_parametre (
		nomprojet,
		libTypeenv,
		nomComposant,
		Upper('TranlogOptions'),
		'IntegratedParams (max_sga_size 256)');
 oggdmde.pkg_ogg_config.ajouter_composant_parametre (
		nomprojet,
		libTypeenv,
		nomComposant,
		Upper('UPDATERECORDFORMAT'),
		'COMPACT');
 oggdmde.pkg_ogg_config.ajouter_composant_parametre (
		nomprojet,
		libTypeenv,
		nomComposant,
		Upper('LOGALLSUPCOLS'),
		'');

END;
/
*/



/*

DECLARE
nomprojet     VARCHAR2(512):='ALLBIRDS';
libTypeenv    VARCHAR2(512) := 'RCT';
nomComposant  VARCHAR2(512) := 'RAB001T1';

BEGIN
oggdmde.pkg_ogg_config.ajouter_composant_parametre (
		nomprojet,
		libTypeenv,
		nomComposant,
		'REPLICAT',
		'RAB001T1');

 oggdmde.pkg_ogg_config.ajouter_composant_parametre (
		nomprojet,
		libTypeenv,
		nomComposant,
		Upper('DBOPTIONS'),
		'INTEGRATEDPARAMS(parallelism 6)');

 oggdmde.pkg_ogg_config.ajouter_composant_parametre (
		nomprojet,
		libTypeenv,
		nomComposant,
		Upper('DiscardFile'),
		'./dirrpt/RAB001T1.dsc, Purge, MEGABYTES 100');
 oggdmde.pkg_ogg_config.ajouter_composant_parametre (
		nomprojet,
		libTypeenv,
		nomComposant,
		Upper('DISCARDROLLOVER'),
		'AT 18:30');
 oggdmde.pkg_ogg_config.ajouter_composant_parametre (
		nomprojet,
		libTypeenv,
		nomComposant,
		Upper('UserIdAlias'),
		'OGGADM_ALLBIRDS');

END;
/

*/
























