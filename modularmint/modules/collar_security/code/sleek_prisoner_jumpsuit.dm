/obj/item/clothing/under/rank/prisoner
	name = "sleek prison jumpsuit"
	desc = "Standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon = 'modularmint/modules/collar_security/sprites/sleek_prisoner.dmi'
	icon_preview = 'modularmint/modules/collar_security/sprites/sleek_prisoner_preview.dmi'
	worn_icon = 'modularmint/modules/collar_security/sprites/sleek_prisoner.dmi'
	worn_icon_digi = 'modularmint/modules/collar_security/sprites/sleek_prisoner_digi.dmi'
	icon_state = "prisoner_sleek"
	icon_state_preview = "prisoner_sleek_preview"
	var/stripes_color = "#ff0000"
	greyscale_colors = NONE
	greyscale_config = NONE
	greyscale_config_worn = NONE
	greyscale_config_inhand_left = NONE
	greyscale_config_inhand_right = NONE
	greyscale_config_worn_digi = NONE
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	can_adjust = FALSE

/obj/item/clothing/under/rank/prisoner/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		var/mutable_appearance/stripes_overlay = mutable_appearance('modularmint/modules/collar_security/sprites/sleek_prisoner_overlay.dmi', "prisoner_sleek_emissive", src, alpha = src.alpha, appearance_flags = RESET_COLOR)
		stripes_overlay.color = stripes_color
		. += stripes_overlay

/obj/item/clothing/under/rank/prisoner/skirt
	name = "sleek prison jumpsuit"
	desc = "Standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon = 'modularmint/modules/collar_security/sprites/sleek_prisoner.dmi'
	icon_preview = 'modularmint/modules/collar_security/sprites/sleek_prisoner_preview.dmi'
	worn_icon = 'modularmint/modules/collar_security/sprites/sleek_prisoner.dmi'
	worn_icon_digi = 'modularmint/modules/collar_security/sprites/sleek_prisoner_digi.dmi'
	icon_state = "prisoner_sleek"
	icon_state_preview = "prisoner_sleek_preview"
	greyscale_colors = NONE
	greyscale_config = NONE
	greyscale_config_worn = NONE
	greyscale_config_inhand_left = NONE
	greyscale_config_inhand_right = NONE
	greyscale_config_worn_digi = NONE
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	can_adjust = FALSE
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	dying_key = "under"
	female_sprite_flags = 1
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION


/datum/outfit/job/prisoner/pre_equip(mob/living/carbon/human/H)
	. = ..()
	neck = /obj/item/clothing/neck/security_collar/
	shoes = /obj/item/clothing/shoes/sneakers/black/
