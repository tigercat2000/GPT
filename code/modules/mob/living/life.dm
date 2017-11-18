/mob/living/Life()
	. = ..()
	handle_status_effects()

/mob/living/proc/handle_status_effects()
	handle_stunned()
	handle_weakened()
	handle_stuttering()
	handle_silent()
	handle_drugged()
	handle_slurring()
	handle_paralysed()
	handle_sleeping()
	handle_slowed()
	handle_drunk()


/mob/living/proc/handle_stunned()
	if(effects.stunned)
		AdjustStunned(-1, updating = 1, force = 1)
		if(!effects.stunned)
			update_icons()
	return effects.stunned

/mob/living/proc/handle_weakened()
	if(effects.weakened)
		AdjustWeakened(-1, updating = 1, force = 1)
		if(!effects.weakened)
			update_icons()
	return effects.weakened

/mob/living/proc/handle_stuttering()
	if(effects.stuttering)
		AdjustStuttering(-1)
	return effects.stuttering

/mob/living/proc/handle_silent()
	if(effects.silent)
		AdjustSilence(-1)
	return effects.silent

/mob/living/proc/handle_drugged()
	if(effects.druggy)
		AdjustDruggy(-1)
	return effects.druggy

/mob/living/proc/handle_slurring()
	if(effects.slurring)
		AdjustSlur(-1)
	return effects.slurring

/mob/living/proc/handle_paralysed()
	if(effects.paralysis)
		AdjustParalysis(-1, updating = 1, force = 1)
	return effects.paralysis

/mob/living/proc/handle_sleeping()
	if(effects.sleeping)
		AdjustSleeping(-1)
		throw_alert("asleep", /obj/screen/alert/asleep)
	else
		clear_alert("asleep")
	return effects.sleeping

/mob/living/proc/handle_slowed()
	if(effects.slowed)
		AdjustSlowed(-1)
	return effects.slowed

/mob/living/proc/handle_drunk()
	if(effects.drunk)
		AdjustDrunk(-1)
	return effects.drunk