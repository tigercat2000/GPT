/mob/living/update_blind_effects()
	if(!has_vision())
		overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
		throw_alert("blind", /obj/screen/alert/blind)
		return 1
	else
		clear_fullscreen("blind")
		clear_alert("blind")
		return 0

/mob/living/update_blurry_effects()
	if(eyes_blurred())
		overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
		return 1
	else
		clear_fullscreen("blurry")
		return 0

/mob/living/update_druggy_effects()
	if(effects.druggy)
		overlay_fullscreen("high", /obj/screen/fullscreen/high)
		throw_alert("high", /obj/screen/alert/high)
	else
		clear_fullscreen("high")
		clear_alert("high")

/*
/mob/living/update_nearsighted_effects()
	if(disabilities & NEARSIGHTED)
		overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen("nearsighted")
*/

/mob/living/update_sleeping_effects(no_alert = FALSE)
	if(effects.sleeping)
		if(!no_alert)
			throw_alert("asleep", /obj/screen/alert/asleep)
	else
		clear_alert("asleep")


/mob/living/has_vision()
	return !(effects.eye_blind || stat)// || (disabilities & BLIND))

/mob/living/proc/eyes_blurred()
	return effects.eye_blurry

// Whether the mob is capable of standing or not
/mob/living/proc/can_stand()
	return !(effects.weakened || effects.paralysis || stat) //|| (effects.status_flags & FAKEDEATH))

/mob/living/proc/drop_ground()
	lying = pick(90, 270)
	playsound(src, "bodyfall", 50, 1)

/mob/living/update_canmove()
	var/fall_over = !can_stand()
	if(fall_over || resting || effects.stunned)
		drop_hands()
	else
		lying = 0
		canmove = 1

	if((fall_over || resting) && !lying)
		drop_ground(fall_over)

	canmove = !(fall_over || resting || effects.stunned)
	density = !lying
	if(lying)
		if(layer == initial(layer))
			layer = LYING_MOB_LAYER
	else
		if(layer == LYING_MOB_LAYER)
			layer = initial(layer)

	update_transform()
	return canmove