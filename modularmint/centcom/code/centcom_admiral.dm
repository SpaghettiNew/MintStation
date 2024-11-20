/datum/job/centcom_admiral
	title = JOB_CCNT_ADMIRAL
	description = "A high-ranking official holding the highest executive power in Central Command."
	department_head = list(JOB_CENTCOM)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "NanoTrasen Supreme Command"
	minimal_player_age = 14
	exp_requirements = 600
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_COMMAND
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CENTCOM_ADMIRAL"

	mind_traits = (MARTIALART_CQC) //MINT EDIT (possibly broken)
	department_for_prefs = /datum/job_department/captain

	departments_list = list(
		/datum/job_department/command,
		/datum/job_department/central_command
	)

	outfit = /datum/outfit/centcom/naval/commander

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_CMD

	display_order = JOB_DISPLAY_ORDER_NANOTRASEN_CONSULTANT
	bounty_types = CIV_JOB_SEC

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law)

	mail_goodies = list(
		/obj/item/cigarette/cigar/havana = 20,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 15,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 10
	)

	banned_quirks = list(HEAD_RESTRICTED_QUIRKS)
	banned_augments = list(HEAD_RESTRICTED_AUGMENTS)

	veteran_only = TRUE
	allow_bureaucratic_error = FALSE
	req_admin_notify = TRUE
	job_flags = STATION_JOB_FLAGS | JOB_BOLD_SELECT_TEXT | JOB_CANNOT_OPEN_SLOTS


	/datum/outfit/job/centcom_admiral //MINT EDIT: START (possibly broken)
	name = "Central Command Admiral"
	jobtype = /datum/job/centcom_admiral
	backpack_contents = list(
		/obj/item/modular_computer/pda/nanotrasen_consultant = 1,
		/obj/item/clipboard = 1,
		/obj/item/folder = 1,
		/obj/item/gun/ballistic/revolver/ocelot = 1 ,
	) //MINT EDIT: END

/*
/obj/effect/landmark/start/centcom_admiral
	name = "CentCom Admiral"
	icon_state = "admiral"
	icon = 'modularmint/centcom/icons/landmarks.dmi'

	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/centcom_admiral/after_round_start()
	return
*/
