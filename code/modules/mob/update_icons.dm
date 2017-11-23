/mob/proc/update_icons()
	return

/mob/proc/update_slot(slot)
	var/datum/inventory_slot/S = get_slot_datum(slot)
	if(S && S.contained)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			S.contained.screen_loc = S.hud_position
			client.screen += S.contained
	. = S

/mob/proc/update_transform()
	return