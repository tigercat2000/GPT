//Here are the procs used to modify status effects of a mob.

// We use these to automatically apply their effects when they are changed, as
// opposed to setting them manually and having to either wait for the next `Life`
// or update by hand

// The `updating` argument is only available on effects that cause a visual/physical effect on the mob itself
// when applied, such as Stun, Weaken, and Jitter - stuff like Blindness, which has a client-side effect,
// lacks this argument.

// Ideally, code should only read the vars in this file, and not ever directly
// modify them

// If you want a mob type to ignore a given status effect, just override the corresponding
// `SetSTATE` proc - since all of the other procs are wrappers around that,
// calling them will have no effect

// BOOLEAN STATES

/*
	* EyesBlocked
		Your eyes are covered somehow
	* EarsBlocked
		Your ears are covered somehow
	* Resting
		You are lying down of your own volition
	* Flying
		For some reason or another you can move while not touching the ground
*/


// STATUS EFFECTS
// All of these decrement over time - at a rate of 1 per life cycle unless otherwise noted
// Status effects sorted alphabetically:
/*
	*	Confused				*
			Movement is scrambled
	*	Dizzy						*
			The screen goes all warped
	*	Drowsy
			You begin to yawn, and have a chance of incrementing "Paralysis"
	*	Druggy					*
			A trippy overlay appears.
	*	Drunk						*
			Essentially what your "BAC" is - the higher it is, the more alcohol you have in you
	* EarDamage				*
			Doesn't do much, but if it's 25+, you go deaf. Heals much slower than other statuses - 0.05 normally
	*	EarDeaf					*
			You cannot hear. Prevents EarDamage from healing naturally.
	*	EyeBlind				*
			You cannot see. Prevents EyeBlurry from healing naturally.
	*	EyeBlurry				*
			A hazy overlay appears on your screen.
	*	Hallucination		*
			Your character will imagine various effects happening to them, vividly.
	*	Jitter					*
			Your character will visibly twitch. Higher values amplify the effect.
	* LoseBreath			*
			Your character is unable to breathe.
	*	Paralysis				*
			Your character is knocked out.
	* Silent					*
			Your character is unable to speak.
	*	Sleeping				*
			Your character is asleep.
	*	Slowed					*
			Your character moves slower.
	*	Slurring				*
			Your character cannot enunciate clearly.
	*	CultSlurring			*
			Your character cannot enunciate clearly while mumbling about elder codes.
	*	Stunned					*
			Your character is unable to move, and drops stuff in their hands. They keep standing, though.
	* Stuttering			*
			Your character stutters parts of their messages.
	*	Weakened				*
			Your character collapses, but is still conscious.
*/

// DISABILITIES
// These are more permanent than the above.
// Disabilities sorted alphabetically
/*
	*	Blind	(32)
			Can't see. EyeBlind does not heal when this is active.
	*	Coughing	(4)
			Cough occasionally, causing you to drop your items
	*	Deaf	(128)7
			Can't hear. EarDeaf does not heal when this is active
	*	Epilepsy	(2)
			Occasionally go "Epileptic", causing you to become very twitchy, drop all items, and fall to the floor
	*	Mute	(64)
			Cannot talk.
	*	Nearsighted	(1)
			My glasses! I can't see without my glasses! (Nearsighted overlay when not wearing prescription eyewear)
	*	Nervous	(16)
			Occasionally begin to stutter.
	*	Tourettes	(8)
			SHIT (say bad words, and drop stuff occasionally)
*/

#define CHANGE_VALUE(value, amt) effects.##value = ##amt
#define GET_VALUE(value) effects.##value

/datum/effects_holder
	//Metadata
	var/mob/owner
	//Effects
	var/confused = 0
	var/cultslurring = 0
	var/dizziness = 0
	var/drowsyness = 0
	var/druggy = 0
	var/drunk = 0
	var/ear_damage = 0
	var/ear_deaf = 0
	var/eye_blind = 0
	var/eye_blurry = 0
	var/hallucination = 0
	var/jitteriness = 0
	var/losebreath = 0
	var/paralysis = 0
	var/silent = 0
	var/sleeping = 0
	var/slowed = 0
	var/slurring = 0
	var/stunned = 0
	var/stuttering = 0
	var/status_flags = CANSTUN|CANWEAKEN|CANPARALYSE|CANPUSH	//bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)
	var/weakened = 0

/datum/effects_holder/New(mob/M)
	owner = M
	. = ..()

/datum/effects_holder/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("weakened")
			owner.SetWeakened(var_value)
		if("stunned")
			owner.SetStunned(var_value)
		if("paralysis")
			owner.SetParalysis(var_value)
		if("sleeping")
			owner.SetSleeping(var_value)
		if("eye_blind")
			owner.SetEyeBlind(var_value)
		if("eye_blurry")
			owner.SetEyeBlurry(var_value)
		if("ear_deaf")
			owner.SetEarDeaf(var_value)
		if("ear_damage")
			owner.SetEarDamage(var_value)
		if("druggy")
			owner.SetDruggy(var_value)
	. = ..()

/mob
	// Booleans
	var/flying = FALSE
	var/resting = FALSE
	var/lying = 0

	// Bitfields
	var/disabilities = 0

	// Holders
	var/datum/effects_holder/effects

	// Other
	var/stat = 0 //Whether a mob is alive or dead. TODO: Move this to living - Nodrak

/mob/New()
	effects = new(src)
	. = ..()

/*
STATUS EFFECTS
*/
// RESTING

/mob/living/proc/StartResting(updating = 1)
	var/val_change = !resting
	resting = TRUE

	if(updating && val_change)
		update_canmove()

/mob/living/proc/StopResting(updating = 1)
	var/val_change = !!resting
	resting = FALSE

	if(updating && val_change)
		update_canmove()

/mob/living/proc/StartFlying()
	var/val_change = !flying
	flying = TRUE
	if(val_change)
		update_animations()

/mob/living/proc/StopFlying()
	var/val_change = !!flying
	flying = FALSE
	if(val_change)
		update_animations()


// SCALAR STATUS EFFECTS

// CONFUSED

/mob/living/Confused(amount)
	SetConfused(max(GET_VALUE(confused), amount))

/mob/living/SetConfused(amount)
	CHANGE_VALUE(confused, max(amount, 0))

/mob/living/AdjustConfused(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(GET_VALUE(confused), amount, bound_lower, bound_upper)
	SetConfused(new_value)

// DIZZY

/mob/living/Dizzy(amount)
	SetDizzy(max(GET_VALUE(dizziness), amount))

/mob/living/SetDizzy(amount)
	CHANGE_VALUE(dizziness, max(amount, 0))

/mob/living/AdjustDizzy(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(GET_VALUE(dizziness), amount, bound_lower, bound_upper)
	SetDizzy(new_value)

// DROWSY

/mob/living/Drowsy(amount)
	SetDrowsy(max(GET_VALUE(drowsyness), amount))

/mob/living/SetDrowsy(amount)
	CHANGE_VALUE(drowsyness, max(amount, 0))

/mob/living/AdjustDrowsy(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(GET_VALUE(drowsyness), amount, bound_lower, bound_upper)
	SetDrowsy(new_value)

// DRUNK

/mob/living/Drunk(amount)
	SetDrunk(max(GET_VALUE(drunk), amount))

/mob/living/SetDrunk(amount)
	CHANGE_VALUE(drunk, max(amount, 0))

/mob/living/AdjustDrunk(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(GET_VALUE(drunk), amount, bound_lower, bound_upper)
	SetDrunk(new_value)

// DRUGGY

/mob/living/Druggy(amount)
	SetDruggy(max(GET_VALUE(druggy), amount))

/mob/living/SetDruggy(amount)
	var/old_val = GET_VALUE(druggy)
	CHANGE_VALUE(druggy, max(amount, 0))
	// We transitioned to/from 0, so update the druggy overlays
	if((old_val == 0 || GET_VALUE(druggy) == 0) && (old_val != GET_VALUE(druggy)))
		update_druggy_effects()

/mob/living/AdjustDruggy(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(GET_VALUE(druggy), amount, bound_lower, bound_upper)
	SetDruggy(new_value)

// EAR_DAMAGE

/mob/living/EarDamage(amount)
	SetEarDamage(max(GET_VALUE(ear_damage), amount))

/mob/living/SetEarDamage(amount)
	CHANGE_VALUE(ear_damage, max(amount, 0))

/mob/living/AdjustEarDamage(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(GET_VALUE(ear_damage), amount, bound_lower, bound_upper)
	SetEarDamage(new_value)

// EAR_DEAF

/mob/living/EarDeaf(amount)
	SetEarDeaf(max(GET_VALUE(ear_deaf), amount))

/mob/living/SetEarDeaf(amount)
	CHANGE_VALUE(ear_deaf, max(amount, 0))

/mob/living/AdjustEarDeaf(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(GET_VALUE(ear_deaf), amount, bound_lower, bound_upper)
	SetEarDeaf(new_value)

// EYE_BLIND

/mob/living/EyeBlind(amount)
	SetEyeBlind(max(GET_VALUE(eye_blind), amount))

/mob/living/SetEyeBlind(amount)
	var/old_val = GET_VALUE(eye_blind)
	CHANGE_VALUE(eye_blind, max(amount, 0))
	// We transitioned to/from 0, so update the eye blind overlays
	if((old_val == 0 || GET_VALUE(eye_blind) == 0) && (old_val != GET_VALUE(eye_blind)))
		update_blind_effects()

/mob/living/AdjustEyeBlind(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(GET_VALUE(eye_blind), amount, bound_lower, bound_upper)
	SetEyeBlind(new_value)

// EYE_BLURRY

/mob/living/EyeBlurry(amount)
	SetEyeBlurry(max(GET_VALUE(eye_blurry), amount))

/mob/living/SetEyeBlurry(amount)
	var/old_val = GET_VALUE(eye_blurry)
	CHANGE_VALUE(eye_blurry, max(amount, 0))
	// We transitioned to/from 0, so update the eye blur overlays
	if((old_val == 0 || GET_VALUE(eye_blurry) == 0) && (old_val != GET_VALUE(eye_blurry)))
		update_blurry_effects()

/mob/living/AdjustEyeBlurry(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(GET_VALUE(eye_blurry), amount, bound_lower, bound_upper)
	SetEyeBlurry(new_value)

// HALLUCINATION

/mob/living/Hallucinate(amount)
	SetHallucinate(max(GET_VALUE(hallucination), amount))

/mob/living/SetHallucinate(amount)
	CHANGE_VALUE(hallucination, max(amount, 0))

/mob/living/AdjustHallucinate(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(GET_VALUE(hallucination), amount, bound_lower, bound_upper)
	SetHallucinate(new_value)

// JITTER

/mob/living/Jitter(amount, force = 0)
	SetJitter(max(GET_VALUE(jitteriness), amount), force)

/mob/living/SetJitter(amount, force = 0)
	// Jitter is also associated with stun
	if(GET_VALUE(status_flags) & CANSTUN || force)
		CHANGE_VALUE(jitteriness, max(amount, 0))

/mob/living/AdjustJitter(amount, bound_lower = 0, bound_upper = INFINITY, force = 0)
	var/new_value = directional_bounded_sum(GET_VALUE(jitteriness), amount, bound_lower, bound_upper)
	SetJitter(new_value, force)

// LOSE_BREATH

/mob/living/LoseBreath(amount)
	SetLoseBreath(max(GET_VALUE(losebreath), amount))

/mob/living/SetLoseBreath(amount)
	CHANGE_VALUE(losebreath, max(amount, 0))

/mob/living/AdjustLoseBreath(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(GET_VALUE(losebreath), amount, bound_lower, bound_upper)
	SetLoseBreath(new_value)

// PARALYSE

/mob/living/Paralyse(amount, updating = 1, force = 0)
	SetParalysis(max(GET_VALUE(paralysis), amount), updating, force)

/mob/living/SetParalysis(amount, updating = 1, force = 0)
	if((!!amount) == (!!GET_VALUE(paralysis))) // We're not changing from + to 0 or vice versa
		updating = FALSE
	if(GET_VALUE(status_flags) & CANPARALYSE || force)
		CHANGE_VALUE(paralysis, max(amount, 0))
		if(updating)
			update_canmove()
			update_stat()

/mob/living/AdjustParalysis(amount, bound_lower = 0, bound_upper = INFINITY, updating = 1, force = 0)
	var/new_value = directional_bounded_sum(GET_VALUE(paralysis), amount, bound_lower, bound_upper)
	SetParalysis(new_value, updating, force)

// SILENT

/mob/living/Silence(amount)
	SetSilence(max(GET_VALUE(silent), amount))

/mob/living/SetSilence(amount)
	CHANGE_VALUE(silent, max(amount, 0))

/mob/living/AdjustSilence(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(GET_VALUE(silent), amount, bound_lower, bound_upper)
	SetSilence(new_value)

// SLEEPING

/mob/living/Sleeping(amount, updating = 1, no_alert = FALSE)
	SetSleeping(max(GET_VALUE(sleeping), amount), updating, no_alert)

/mob/living/SetSleeping(amount, updating = 1, no_alert = FALSE)
	if((!!amount) == (!!GET_VALUE(sleeping))) // We're not changing from + to 0 or vice versa
		updating = FALSE
	CHANGE_VALUE(sleeping, max(amount, 0))
	if(updating)
		update_sleeping_effects(no_alert)
		update_stat()
		update_canmove()

/mob/living/AdjustSleeping(amount, bound_lower = 0, bound_upper = INFINITY, updating = 1, no_alert = FALSE)
	var/new_value = directional_bounded_sum(GET_VALUE(sleeping), amount, bound_lower, bound_upper)
	SetSleeping(new_value, updating, no_alert)

// SLOWED

/mob/living/Slowed(amount, updating = 1)
	SetSlowed(max(GET_VALUE(slowed), amount), updating)

/mob/living/SetSlowed(amount, updating = 1)
	CHANGE_VALUE(slowed, max(amount, 0))

/mob/living/AdjustSlowed(amount, bound_lower = 0, bound_upper = INFINITY, updating = 1)
	var/new_value = directional_bounded_sum(GET_VALUE(slowed), amount, bound_lower, bound_upper)
	SetSlowed(new_value, updating)

// SLURRING

/mob/living/Slur(amount)
	SetSlur(max(GET_VALUE(slurring), amount))

/mob/living/SetSlur(amount)
	CHANGE_VALUE(slurring, max(amount, 0))

/mob/living/AdjustSlur(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(GET_VALUE(slurring), amount, bound_lower, bound_upper)
	SetSlur(new_value)

// STUN

/mob/living/Stun(amount, updating = 1, force = 0)
	SetStunned(max(GET_VALUE(stunned), amount), updating, force)

/mob/living/SetStunned(amount, updating = 1, force = 0) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if((!!amount) == (!!GET_VALUE(stunned))) // We're not changing from + to 0 or vice versa
		updating = FALSE
	if(GET_VALUE(status_flags) & CANSTUN || force)
		CHANGE_VALUE(stunned, max(amount, 0))
		if(updating)
			update_canmove()

/mob/living/AdjustStunned(amount, bound_lower = 0, bound_upper = INFINITY, updating = 1, force = 0)
	var/new_value = directional_bounded_sum(GET_VALUE(stunned), amount, bound_lower, bound_upper)
	SetStunned(new_value, updating, force)

// STUTTERING


/mob/living/Stuttering(amount, force = 0)
	SetStuttering(max(GET_VALUE(stuttering), amount), force)

/mob/living/SetStuttering(amount, force = 0)
	//From mob/living/apply_effect: "Stuttering is often associated with Stun"
	if(GET_VALUE(status_flags) & CANSTUN || force)
		CHANGE_VALUE(stuttering, max(amount, 0))

/mob/living/AdjustStuttering(amount, bound_lower = 0, bound_upper = INFINITY, force = 0)
	var/new_value = directional_bounded_sum(GET_VALUE(stuttering), amount, bound_lower, bound_upper)
	SetStuttering(new_value, force)

// WEAKEN

/mob/living/Weaken(amount, updating = 1, force = 0)
	SetWeakened(max(GET_VALUE(weakened), amount), updating, force)

/mob/living/SetWeakened(amount, updating = 1, force = 0)
	if((!!amount) == (!!GET_VALUE(weakened))) // We're not changing from + to 0 or vice versa
		updating = FALSE
	if(GET_VALUE(status_flags) & CANWEAKEN || force)
		CHANGE_VALUE(weakened, max(amount, 0))
		if(updating)
			update_canmove()	//updates lying, canmove and icons

/mob/living/AdjustWeakened(amount, bound_lower = 0, bound_upper = INFINITY, updating = 1, force = 0)
	var/new_value = directional_bounded_sum(GET_VALUE(weakened), amount, bound_lower, bound_upper)
	SetWeakened(new_value, updating, force)

/mob/living/proc/IsKnockdown()
	return GET_VALUE(paralysis) || GET_VALUE(sleeping)

/mob/living/update_stat()
	if(stat != DEAD)
		if(effects.paralysis || effects.sleeping)
			if(stat == CONSCIOUS)
				KnockOut()
		else
			if(stat == UNCONSCIOUS)
				WakeUp()