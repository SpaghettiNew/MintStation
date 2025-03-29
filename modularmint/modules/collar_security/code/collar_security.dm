GLOBAL_LIST_EMPTY_TYPED(tracked_security_collar, /obj/item/clothing/neck/security_collar)
#define SECCOLLAR_FIRSTMODE "pain"
#define SECCOLLAR_SECONDMODE "supression"
#define SECCOLLAR_THIRDMODE "agony"



///
// ITEMS
///



/obj/item/clothing/neck/security_collar
	name = "Stun-collar"
	desc = "Bulky and very uncomfortable collar made of casted iron. Has a magnetic lock and a constantly blinking red light."
	icon = 'modular_nova/modules/modular_items/lewd_items/icons/obj/lewd_clothing/lewd_neck.dmi'
	worn_icon = 'modular_nova/modules/modular_items/lewd_items/icons/mob/lewd_clothing/lewd_neck.dmi'
	icon_state = "shockcollar"
	inhand_icon_state = null
	resistance_flags = ACID_PROOF | FIRE_PROOF
	var/shock_cooldown = FALSE
	var/supression_mode = FALSE
	var/restraint_cooldown = FALSE
	var/restraint_cooldown_time = 60 SECONDS
	//requiered acces for stripping the collar
	var/access_strip = ACCESS_SECURITY
	var/prisoner_assignment = "Security department"
	var/encollar_time = 4 SECONDS
	var/encollar_time_mod = 1
	///Sound that plays when starting to put handcuffs on someone
	var/encollarsound = 'sound/items/weapons/handcuffs.ogg'
	///Sound that plays when restrain is successful
	var/encollarsuccesssound = 'sound/items/handcuff_finish.ogg'

/obj/item/security_collar_controller
	name = "Painpointer"
	desc = "A small remote for sending signals to prisoner collars."
	icon = 'icons/obj/devices/new_assemblies.dmi'
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	icon_state = "signaller"
	w_class = WEIGHT_CLASS_SMALL
	var/mode = SECCOLLAR_FIRSTMODE

/obj/item/clothing/neck/security_collar/Initialize()
	. = ..()
	GLOB.tracked_security_collar += src

/obj/item/beacon/Destroy()
	GLOB.tracked_security_collar -= src
	return ..()

///
// PUNISHMENT PROCS
///




// PULT PART PROCS
/obj/item/security_collar_controller/attack_self(mob/user)
	var/static/list/desc = list(SECCOLLAR_FIRSTMODE = "Pain mode", SECCOLLAR_SECONDMODE = "Supression mode", SECCOLLAR_THIRDMODE = "Agony mode")
	switch(mode)
		if(SECCOLLAR_FIRSTMODE)
			mode = SECCOLLAR_SECONDMODE
		if(SECCOLLAR_SECONDMODE)
			mode = SECCOLLAR_THIRDMODE
		if(SECCOLLAR_THIRDMODE)
			mode = SECCOLLAR_FIRSTMODE
	update_icon_state()
	balloon_alert(user, "mode: [desc[mode]]")

// LMB INTERACT PRE-PART
/obj/item/security_collar_controller/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /mob/living/carbon/) && !in_range(user, interacting_with)) // Проверяем, чтобы пленник был недалеко от игрока.
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers) // Если всё хорошо, переходим к интересной части

// LMB INTERACT MAIN PART
/obj/item/security_collar_controller/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)

	var/mob/living/carbon/collar_prisoner
	collar_prisoner = interacting_with

	if (!istype(interacting_with, /mob/living/carbon/)) // Удостоверяемся, что это человек
		return ITEM_INTERACT_BLOCKING

	if (isnull(interacting_with)) // Избавляемся от рантаймов
		return ITEM_INTERACT_BLOCKING

	var/obj/item/clothing/neck/security_collar/affected_collar = collar_prisoner.get_item_by_slot(ITEM_SLOT_NECK)
	if (!affected_collar || !(istype(affected_collar,/obj/item/clothing/neck/security_collar))) // Проверяем наличие ошейника на шее
		return ITEM_INTERACT_BLOCKING

	switch (mode) // Выполняем наказание в зависимости от режима
		if (SECCOLLAR_FIRSTMODE) // Самый лайтовый режим
			affected_collar.first_mode_punishment(collar_prisoner, user)

		if (SECCOLLAR_SECONDMODE) // Пассивный дебафф
			affected_collar.second_mode_punishment(collar_prisoner, user)

		if (SECCOLLAR_THIRDMODE) // БОЛЬ. Заставь его пожалеть о содеянном
			affected_collar.third_mode_punishment(collar_prisoner, user)

	return ITEM_INTERACT_SUCCESS

// LMB INTERATIONCOLLAR PART PROCS

// Легкий режим
/obj/item/clothing/neck/security_collar/proc/first_mode_punishment(mob/living/carbon/wearer, mob/living/user) // FIRST MODE
	if(shock_cooldown == TRUE)
		balloon_alert(user, "Recharging") // К/д
		return
	shock_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, shock_cooldown, FALSE), 100)
	step(wearer, pick(GLOB.cardinals)) // Эффект как от обычного шокового ошейника

	to_chat(wearer, span_danger("You feel a sharp shock from the collar!"))
	var/datum/effect_system/spark_spread/created_sparks = new /datum/effect_system/spark_spread
	created_sparks.set_up(5, 1, wearer)
	created_sparks.start()
	if(prob(80))
		INVOKE_ASYNC(wearer, TYPE_PROC_REF(/mob, emote), "scream")

	wearer.Paralyze(30)
	wearer.apply_damage(5, BURN, BODY_ZONE_HEAD)
	wearer.adjustStaminaLoss(50)
	wearer.adjustOxyLoss(30)
	wearer.adjust_pain(10)
	wearer.adjust_stutter(60 SECONDS)
	var/mob/living/carbon/human/human_target = wearer
	human_target.electrocution_animation(LIGHTNING_BOLT_ELECTROCUTION_ANIMATION_LENGTH)

// Режим подавителя
/obj/item/clothing/neck/security_collar/proc/second_mode_punishment(mob/living/carbon/wearer, mob/living/user) // SECOND MODE
	switch(supression_mode)
		if(FALSE)
			if(restraint_cooldown == TRUE)
				balloon_alert(user, "Recharging") // К/д
				return
			if(wearer.handcuffed)
				playsound(src.loc, 'sound/machines/buzz/buzz-two.ogg', 15, TRUE)
				return
			if(!wearer.canBeHandcuffed())
				return
			var/obj/item/restraints/handcuffs/cuffs = new /obj/item/restraints/handcuffs/security_collar_restraints
			wearer.equip_to_slot(cuffs, ITEM_SLOT_HANDCUFFED)
			supression_mode = TRUE
			playsound(src.loc, 'sound/items/handcuff_finish.ogg', 15, TRUE)
		if(TRUE)
			qdel(wearer.get_item_by_slot(ITEM_SLOT_HANDCUFFED))
			restraint_cooldown = TRUE
			addtimer(VARSET_CALLBACK(src, restraint_cooldown, FALSE), restraint_cooldown_time / 2)
			supression_mode = FALSE

/obj/item/restraints/handcuffs/security_collar_restraints
	name = "Supression Device's restraints"
	item_flags = DROPDEL
	handcuff_time_mod = 0

/obj/item/restraints/handcuffs/security_collar_restraints/attack()
	return

/obj/item/restraints/handcuffs/security_collar_restraints/dropped(mob/user, silent = FALSE)
	var/obj/item/clothing/neck/security_collar/affected_collar = user.get_item_by_slot(ITEM_SLOT_NECK)
	affected_collar.set_restraint_cooldown()
	affected_collar.supression_mode = FALSE
	. = ..()

/obj/item/clothing/neck/security_collar/dropped(mob/living/carbon/human/user) // Если с нас снимают ошейник, со включенным подавителем
	var/restr = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
	if(restr == /obj/item/restraints/handcuffs/security_collar_restraints)
		qdel(restr)

	supression_mode = FALSE
	. = ..()

/obj/item/clothing/neck/security_collar/proc/set_restraint_cooldown()
	restraint_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, restraint_cooldown, FALSE), restraint_cooldown_time)

// Режим агонии
/obj/item/clothing/neck/security_collar/proc/third_mode_punishment(mob/living/carbon/wearer, mob/living/user) // THIRD MODE
	playsound(src.loc, 'sound/machines/buzz/buzz-two.ogg', 15, TRUE)
	return




///
// RIGHT CLICK CONTROLLER PROCS
///




// RIGHT CLICK CONTROLLER ON PRISONER

// RIGHT CLICK PRE-PART
/obj/item/security_collar_controller/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers) // Функционал на ПКМ
	if(!istype(interacting_with, /mob/living/carbon/) && !in_range(user, interacting_with)) // Проверяем, чтобы пленник был недалеко от игрока.
		return NONE
	return ranged_interact_with_atom_secondary(interacting_with, user, modifiers) // Если всё хорошо, переходим к интересной части

// RIGHT CLICK MAIN PART
/obj/item/security_collar_controller/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers) // Продолжение функционала на ПКМ

	var/mob/living/carbon/collar_prisoner
	collar_prisoner = interacting_with

	if (!istype(interacting_with, /mob/living/carbon/))
		return ITEM_INTERACT_BLOCKING

	if (isnull(interacting_with)) // Избавляемся от рантаймов
		return ITEM_INTERACT_BLOCKING

	var/obj/item/clothing/neck/security_collar/affected_collar = collar_prisoner.get_item_by_slot(ITEM_SLOT_NECK)
	if (!affected_collar || !(istype(affected_collar,/obj/item/clothing/neck/security_collar))) // Проверяем наличие ошейника на шее
		return ITEM_INTERACT_BLOCKING

	if(user.can_read(src) && !user.is_blind())
		to_chat(user, custom_boxed_message("blue_box", affected_collar.return_info(collar_prisoner, user)))

	return ITEM_INTERACT_SUCCESS

// RIGHT CLICK COLLAR PART PROCS

// Get info from prisoner collar
/obj/item/clothing/neck/security_collar/proc/return_info(mob/living/carbon/collar_prisoner, mob/living/user)

	var/supression_mode_status_name
	switch(supression_mode)
		if(FALSE)
			supression_mode_status_name = "OFF"
		if(TRUE)
			supression_mode_status_name = "ON"

	var/floor_text = "<span class='info'>Prisoner info: <b>[collar_prisoner.name]</b> ([station_time_timestamp()]):</span><br>"
	floor_text += "<span class='info ml-1'>Restrictions: <b>[supression_mode_status_name]</b></span><br>"
	floor_text += "<span class='info ml-1'>Assignment: <b>[prisoner_assignment]</b></span></span><br>"
	floor_text += "<span class='info ml-1'>THERE CAN BE YOUR ADVERTISEMENT</span><br>"

	return floor_text

// RIGHT CLICK CONTROLLER ON SELF

// Get location of all people who wear collar
/obj/item/security_collar_controller/attack_self_secondary(mob/living/user, modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(user.can_read(src) && !user.is_blind())
		var/prisoners_location = get_prisoner_displacement_info(user)
		if(!prisoners_location || prisoners_location == null || prisoners_location == list())
			prisoners_location = "No prisoner detected"
		to_chat(user, boxed_message(jointext(prisoners_location, "<br>")))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/security_collar_controller/proc/get_prisoner_displacement_info(mob/living/user)
	var/floor_text = list()

	if(user)

		for(var/obj/item/clothing/neck/security_collar/collar as anything in GLOB.tracked_security_collar)

			if(collar == null || !collar.loc.type || collar.loc.type != /mob/living/carbon/human)
				continue
			else
				var/mob/living/carbon/prisoner = collar.loc
				var/obj/item/clothing/neck/neck = prisoner.wear_neck
				if(prisoner.type == /mob/living/carbon/human && neck.type == collar.type)
					var/turf/trac = get_turf(prisoner)
					floor_text += "<span class='info ml-1'><b>[prisoner.name]</b> - [trac.loc.name]</span>"
				else
					floor_text += null
				continue

	return floor_text



///
// MISC PROCS
///



// COLLAR DROP PROCS

/obj/item/clothing/neck/security_collar/allow_attack_hand_drop(mob/user)
	if(user.get_item_by_slot(ITEM_SLOT_NECK) == src)
		to_chat(user, span_warning("The collar is fastened tight! There's no way you can take it off!"))
		return FALSE
	return ..()

// Check requiered acces for striping collar
/obj/item/clothing/neck/security_collar/canStrip(mob/stripper, mob/owner)
	var/mob/living/living_user = stripper
	var/obj/item/card/id/id_card = living_user.get_idcard(TRUE)

	if(!istype(id_card))
		return FALSE

	var/list/access = id_card.GetAccess()
	if(src.access_strip && !(src.access_strip in access))
		return FALSE

	return TRUE

// Защита от снятия драг&дропом
/obj/item/clothing/neck/security_collar/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(user.get_item_by_slot(ITEM_SLOT_NECK) == src)
		return
	return ..()

///
// ENCOLLARING PROCS
///

/obj/item/clothing/neck/security_collar/attack(mob/living/target_mob, mob/living/user)
	if(!iscarbon(target_mob))
		return

	handle_encollaring(target_mob, user)

/obj/item/clothing/neck/security_collar/proc/handle_encollaring(mob/living/carbon/human/victim, mob/user, dispense = FALSE, var/obj/item/clothing/neck/theirneckwear)

	if(SEND_SIGNAL(victim, COMSIG_CARBON_CUFF_ATTEMPTED, user) & COMSIG_CARBON_CUFF_PREVENT)
		victim.balloon_alert(user, "can't be handcuffed!")
		return

	theirneckwear = victim.wear_neck

	if(victim.wear_neck)
		if(HAS_TRAIT(theirneckwear, TRAIT_NODROP) || !theirneckwear.canStrip(user, victim))
			to_chat(user, span_warning("[theirneckwear] on [victim]'s neck is fastened tight!"))
			return

	victim.visible_message(span_warning("[user] starts encollaring [victim]!"),\
		span_userdanger("[user] starts encollaring you!"),\
		span_hear("You hear metal clank near your neck."))

	playsound(loc, encollarsound, 30, TRUE, -2)
	log_combat(user, victim, "attempted to encollar")

	if(HAS_TRAIT(user, TRAIT_FAST_CUFFING))
		encollar_time_mod = 0.75
	else
		encollar_time_mod = 1

	if(!do_after(user, encollar_time * encollar_time_mod, victim, timed_action_flags = IGNORE_SLOWDOWNS))
		victim.balloon_alert(user, "failed to encollar!")
		to_chat(user, span_warning("You fail to encollar [victim]!"))
		log_combat(user, victim, "failed to encollar")
		return

	apply_collar(victim, user, dispense = iscyborg(user))
	playsound(loc, encollarsuccesssound, 30, TRUE, -2)

	victim.visible_message(
		span_notice("[user] encollars [victim]."),
		span_userdanger("[user] encollars you."),
	)

	log_combat(user, victim, "successfully encollared")
	SSblackbox.record_feedback("tally", "encollars", 1, type)

/obj/item/clothing/neck/security_collar/proc/apply_collar(mob/living/carbon/target, mob/user, dispense = FALSE)

	if(target.wear_neck)
		target.dropItemToGround(target.wear_neck)

	if(!user.temporarilyRemoveItemFromInventory(src) && !dispense)
		return

	var/obj/item/clothing/neck/security_collar/collar = new src.type()
	if(dispense)
		collar = new type()

	target.equip_to_slot(collar, ITEM_SLOT_NECK)

	if(!dispense)
		GLOB.tracked_security_collar -= src
		qdel(src)

///
// SCRYER EBENT FIX
///

// Без фикса - скраер спавнится на шее заключенных, вместо ошейника.
/datum/station_trait/scryers/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	if(job == /datum/job/prisoner)
		return
	. = ..()
