///
// DEFAULT COLLAR (REPLACE FOR HANDCUFFS)
///
/obj/item/clothing/neck/security_collar/light_security_collar
	name = "Electronic Supression Device"
	desc = "Bulky and very uncomfortable collar made of casted iron. Has a magnetic lock and a constantly blinking red light."
	icon = 'modular_nova/modules/modular_items/lewd_items/icons/obj/lewd_clothing/lewd_neck.dmi'
	worn_icon = 'modular_nova/modules/modular_items/lewd_items/icons/mob/lewd_clothing/lewd_neck.dmi'
	icon_state = "shockcollar"
	inhand_icon_state = null
	//requiered acces for stripping the collar
	access_strip = ACCESS_SECURITY
	prisoner_assignment = "Security department"

///
// ORANGE PRISONER COLLAR
///

/obj/item/clothing/neck/security_collar/prisoner_security_collar
	name = "Prisoner Supression Device"
	desc = "Bulky and very uncomfortable collar made of casted iron. Has a magnetic lock and a constantly blinking red light."
	icon = 'modular_nova/modules/modular_items/lewd_items/icons/obj/lewd_clothing/lewd_neck.dmi'
	worn_icon = 'modular_nova/modules/modular_items/lewd_items/icons/mob/lewd_clothing/lewd_neck.dmi'
	icon_state = "shockcollar"
	inhand_icon_state = null
	//requiered acces for stripping the collar
	access_strip = ACCESS_HOS
	prisoner_assignment = "Security department"
	var/depleeted = FALSE

/obj/structure/closet/secure_closet/brig/orange_collar_locker
	name = "sentence locker"
	var/imprisonment_time = 0 MINUTES
	var/imprisoned_person = null
	var/registered_id = null
	var/vending_unifrom = null

/obj/structure/closet/secure_closet/brig/orange_collar_locker/before_open(mob/living/user, force)
	imprisonment_time = tgui_input_number(user, "Declare sentence in minutes", pick("New prisoner", "New inmate", "Fresh meat"), max_value = 60, min_value = 1, default = 30)
	if(!imprisonment_time)
		return FALSE
	imprisonment_time = imprisonment_time * 1 MINUTES
	return TRUE

/obj/structure/closet/secure_closet/brig/orange_collar_locker/before_close(mob/living/user)
	if(!imprisonment_time)
		return TRUE
	if(can_unlock(user, user.get_idcard()))
		return TRUE
	if(user.dna.species.type == /mob/living/carbon/human/species/plasma)
		return TRUE
	if(user.w_uniform || user.wear_suit || user.shoes || user.gloves || user.head || user.wear_neck || user.wear_mask || user.belt || user.back)
		to_chat(user, span_warning("[pick("New", "Fresh", "Current")] [pick("prisoner", "inmate", "convict")] must be [pick("unclothed", "naked", "exposed")]"))
		return FALSE

/obj/structure/closet/secure_closet/brig/orange_collar_locker/after_close(mob/living/user)
	
	if(imprisonment_time >= 1 )
		if(!user.dna.species.type == /mob/living/carbon/human/species/plasma)
			new /obj/item/clothing/under/rank/prisoner( src.loc )
			new /obj/item/clothing/shoes/sneakers/black( src.loc )

		if(user.dna.species.type == /mob/living/carbon/human/species/akula)
			new /obj/item/clothing/accessory/vaporizer( src.loc )

		if(user.dna.species.type == /mob/living/carbon/human/species/vox || user.dna.species.type == /mob/living/carbon/human/species/vox_primalis)
			new /obj/item/tank/internals/nitrogen/belt( src.loc )

		var/newcollar = new /obj/item/clothing/neck/security_collar/prisoner_security_collar
		if(user.equip_to_slot(newcollar, ITEM_SLOT_NECK))
			src.say("Sentence now in effect. [pick("Have a secure day", "Have a productive shift", "Have a nice day")]")
		else
			qdel(newcollar)


///
//
///

///
// INTERACTION PROCS
///

// /obj/item/clothing/neck/security_collar/light_security_collar/second_mode_punishment(mob/living/carbon/wearer, mob/living/user) // SECOND MODE
// 	switch(supression_mode)
// 		if(FALSE)
// 			wearer.apply_status_effect(/datum/status_effect/security_collar_restriction)
// 		if(TRUE)
// 			wearer.remove_status_effect(/datum/status_effect/security_collar_restriction)



///
// STATUS EFFECT
///

// /datum/status_effect/security_collar_restriction
// 	id = "security_collar_restriction"
// 	alert_type = null
// 	var/pult = null
// 		/// Cooldown for proximity checks so we don't spam a range 7 view every two seconds.
// 	COOLDOWN_DECLARE(check_cooldown)

// /datum/status_effect/security_collar_restriction/on_creation(mob/living/new_owner, duration = 10 SECONDS)
// 	src.duration = duration
// 	return ..()

// /datum/status_effect/security_collar_restriction/on_life(seconds_per_tick)
// 	..()

// 	if(!COOLDOWN_FINISHED(src, check_cooldown))
// 		return

// 	COOLDOWN_START(src, check_cooldown, 5 SECONDS)
// 	var/list/seen_atoms = view(7, owner)
// 	if(LAZYLEN(trigger_objs))
// 		for(var/obj/seen_item in seen_atoms)
// 			if(is_scary_item(seen_item))
// 				freak_out(seen_item)
// 				return
// 		for(var/mob/living/carbon/human/nearby_guy in seen_atoms) //check equipment for trigger items
// 			for(var/obj/item/equipped as anything in nearby_guy.get_visible_items())
// 				if(is_scary_item(equipped))
// 					freak_out(equipped)
// 					return

