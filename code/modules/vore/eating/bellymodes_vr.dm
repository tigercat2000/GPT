// Process the predator's effects upon the contents of its belly (i.e digestion/transformation etc)
// Called from /mob/living/Life() proc.

var/macro_to_proc_mapping = list(
	DM_HOLD = /datum/belly/proc/_dm_hold,
	DM_DIGEST = /datum/belly/proc/_dm_digest,
	DM_DIGEST_NUMB = /datum/belly/proc/_dm_digest,
	DM_ITEMWEAK = /datum/belly/proc/_dm_digest,
	DM_ABSORB = /datum/belly/proc/_dm_absorb,
	DM_UNABSORB = /datum/belly/proc/_dm_unabsorb,
	DM_DRAIN = /datum/belly/proc/_dm_drain,
	DM_SHRINK = /datum/belly/proc/_dm_shrink,
	DM_GROW = /datum/belly/proc/_dm_grow,
	DM_SIZE_STEAL = /datum/belly/proc/_dm_sizesteal,
	DM_HEAL = /datum/belly/proc/_dm_heal//,
	//DM_EGG = /datum/belly/proc/_dm_egg
)

/datum/belly/proc/process_Life()
	//Automatic Emotes
	if((digest_mode in emote_lists) && !emotePend)
		emotePend = 1

		spawn(emoteTime)
			var/list/EL = emote_lists[digest_mode]
			for(var/mob/living/L in internal_contents)
				to_chat(L, "<span class='notice'>[pick(EL)]</span>")
			emotePend = 0

	// Handle absorption victims
	for(var/mob/living/M in internal_contents)
		if(M.absorbed)
			M.Weaken(5)

	handle_screenalerts()
	call(src, macro_to_proc_mapping[digest_mode])()

/datum/belly/proc/handle_screenalerts()
	switch(digest_mode)
		if(DM_DIGEST, DM_DIGEST_NUMB, DM_ITEMWEAK, DM_ABSORB, DM_DRAIN, DM_SHRINK, DM_GROW, DM_SIZE_STEAL)
			for(var/mob/living/L in internal_contents)
				if(!L.absorbed)
					var/obj/screen/alert/digestion/D = owner.throw_alert("digestion_[L.name]", /obj/screen/alert/digestion, override = TRUE)
					if(istype(D))
						alerts += "digestion_[L.name]"
						D.set_target(L, owner)
		else
			for(var/A in alerts)
				owner.clear_alert(A, clear_override = TRUE)
				to_chat(owner, "owner.clear_alert([A])")
				alerts -= A
		//owner.clear_alert("digestion_[M.name]")
		//var/obj/screen/alert/digestion/D = owner.throw_alert("digestion_[M.name]", /obj/screen/alert/digestion)
		//if(istype(D))
		//	D.set_target(M, owner)


/*** DM_HOLD ***/
/datum/belly/proc/_dm_hold()
	return

/*** DM_DIGEST ***/
/datum/belly/proc/_dm_digest()
	var/list/touchable_items = internal_contents - items_preserved

	if(prob(50)) //Was SO OFTEN. AAAA.
		var/churnsound = pick(GLOB.digestion_sounds)
		for(var/mob/hearer in range(1,owner))
			hearer << sound(churnsound,volume=80)

	for(var/mob/living/M in internal_contents)
		//Pref protection!
		if(!M.digestable || M.absorbed)
			continue

		//Person just died in guts!
		if(M.stat == DEAD)
			var/digest_alert_owner = pick(digest_messages_owner)
			var/digest_alert_prey = pick(digest_messages_prey)

			//Replace placeholder vars
			digest_alert_owner = replacetext(digest_alert_owner, "%pred", owner)
			digest_alert_owner = replacetext(digest_alert_owner, "%prey", M)
			digest_alert_owner = replacetext(digest_alert_owner, "%belly", lowertext(name))

			digest_alert_prey = replacetext(digest_alert_prey, "%pred", owner)
			digest_alert_prey = replacetext(digest_alert_prey, "%prey", M)
			digest_alert_prey = replacetext(digest_alert_prey, "%belly", lowertext(name))

			//Send messages
			to_chat(owner, "<span class='notice'>" + digest_alert_owner + "</span>")
			to_chat(M, "<span class='notice'>" + digest_alert_prey + "</span>")

			//owner.nutrition += 20 // so eating dead mobs gives you *something* (that's 0.66u nutriment yo)
			var/deathsound = pick(GLOB.death_sounds)
			for(var/mob/hearer in range(1,owner))
				hearer << deathsound
			digestion_death(M)
			owner.update_icons()
			continue

		// Deal digestion damage (and feed the pred)
		/*if(!(M.status_flags & GODMODE))
			//M.adjustBruteLoss(digest_brute)
			//M.adjustFireLoss(digest_burn)

			var/offset = (1 + ((M.weight - 137) / 137)) // 130 pounds = .95 140 pounds = 1.02
			var/difference = owner.size_multiplier / M.size_multipli
			if(offset) // If any different than default weight, multiply the % of offset.
				owner.nutrition += offset*(2*(digest_brute+digest_burn)/difference) // 9.5 nutrition per digestion tick if they're 130 pounds and it's same size. 10.2 per digestion tick if they're 140 and it's same size. Etc etc.
			else
				owner.nutrition += 2*(digest_brute+digest_burn)/difference*/
		M.updateVRPanel()

	// Handle leftovers.
	if(digest_mode == DM_ITEMWEAK)
		var/obj/item/T = pick(touchable_items)
		if(istype(T, /obj/item))
			if(istype(T, /obj/item) && !(T in items_preserved))
				if(T in items_preserved)// Doublecheck just in case.
					return

				/*for(var/obj/item/SubItem in T)
					SubItem.gurglecontaminate()*/
				items_preserved += T
				//T.gurglecontaminate() // Someone got gurgled in this crap. You wouldn't wear/use it unwashed. :v
	else
		var/obj/item/T = pick(touchable_items)
		if(istype(T, /obj/item))
			if(istype(T, /obj/item) && !(T in items_preserved))
				if(T in items_preserved)// Doublecheck just in case.
					return
				for(var/obj/item/SubItem in T)
					SubItem.forceMove(owner)
					internal_contents += SubItem
				//owner.nutrition += (1 * T.w_class)
				internal_contents -= T
				qdel(T)

	owner.updateVRPanel()

/*** DM_STRIP_DIGEST ***/
/datum/belly/proc/_dm_strip_digest()
	var/list/touchable_items = internal_contents - items_preserved

	if(prob(50))
		var/churnsound = pick(GLOB.digestion_sounds)
		for(var/mob/hearer in range(1,owner))
			hearer << sound(churnsound,volume=80)

	// Handle loose items first.
	var/obj/item/T = pick(touchable_items)
	if(istype(T, /obj/item))
		if(istype(T, /obj/item) && !(T in items_preserved))
			if(T in items_preserved)// Doublecheck just in case.
				return

			for(var/obj/item/SubItem in T)
				SubItem.forceMove(owner)
				internal_contents += SubItem

			//owner.nutrition += (1 * T.w_class)
			internal_contents -= T
			qdel(T)
			for(var/mob/living/L in internal_contents)
				L.updateVRPanel()

	for(var/mob/living/M in internal_contents)
		if(!M)
			M = owner
		//Pref protection!
		if(!M.digestable || M.absorbed)
			continue
		if(length(slots - checked_slots) < 1)
			checked_slots.Cut()
		var/validslot = pick(slots - checked_slots)
		checked_slots += validslot // Avoid wasting cycles on already checked slots.
		var/obj/item/I = M.get_slot(validslot)
		if(!I)
			return
		M.unEquip(I, force = 1)
		internal_contents += I
		M.updateVRPanel()

	owner.updateVRPanel()


/*** DM_ABSORB ***/
/datum/belly/proc/_dm_absorb()
	for(var/mob/living/M in internal_contents)
		if(prob(10)) //Less often than gurgles. People might leave this on forever.
			var/absorbsound = pick(GLOB.digestion_sounds)
			M << sound(absorbsound,volume=80)
			owner << sound(absorbsound,volume=80)

		if(M.absorbed)
			continue

		/*if(M.nutrition >= 100) //Drain them until there's no nutrients left. Slowly "absorb" them.
			var/oldnutrition = (M.nutrition * 0.05)
			M.nutrition = (M.nutrition * 0.95)
			owner.nutrition += oldnutrition
		else if(M.nutrition < 100) //When they're finally drained.
		*/
		absorb_living(M)

/*** DM_UNABSORB ***/
/datum/belly/proc/_dm_unabsorb()
	for(var/mob/living/M in internal_contents)
		if(M.absorbed) //&& owner.nutrition >= 100)
			M.absorbed = 0
			to_chat(M, "<span class='notice'>You suddenly feel solid again.</span>")
			to_chat(owner, "<span class='notice'>You feel like a part of you is missing.</span>")
			//owner.nutrition -= 100

/*** DM_DRAIN ***/
/datum/belly/proc/_dm_drain()
	/*for (var/mob/living/M in internal_contents)

		if(prob(10)) //Less often than gurgles. People might leave this on forever.
			var/drainsound = pick(digestion_sounds)
			M << sound(drainsound,volume=80)
			owner << sound(drainsound,volume=80)

		if(M.nutrition >= 100) //Drain them until there's no nutrients left.
			var/oldnutrition = (M.nutrition * 0.05)
			M.nutrition = (M.nutrition * 0.95)
			owner.nutrition += oldnutrition
			return*/
	return

/*** DM_SHRINK ***/
/datum/belly/proc/_dm_shrink()
	for (var/mob/living/M in internal_contents)

		if(prob(10)) //Infinite gurgles!
			var/shrinksound = pick(GLOB.digestion_sounds)
			M << sound(shrinksound,volume=80)
			owner << sound(shrinksound,volume=80)

		/*if(M.size_multiplier > shrink_grow_size) //Shrink until smol.
			M.resize(M.size_multiplier-0.01) //Shrink by 1% per tick.
			if(M.nutrition >= 100) //Absorbing bodymass results in nutrition if possible.
				var/oldnutrition = (M.nutrition * 0.05)
				M.nutrition = (M.nutrition * 0.95)
				owner.nutrition += oldnutrition
			return*/
	return

/*** DM_GROW ***/
/datum/belly/proc/_dm_grow()
	for (var/mob/living/M in internal_contents)

		if(prob(10))
			var/growsound = pick(GLOB.digestion_sounds)
			M << sound(growsound,volume=80)
			owner << sound(growsound,volume=80)

		/*if(M.size_multiplier < shrink_grow_size) //Grow until large.
			M.resize(M.size_multiplier+0.01) //Grow by 1% per tick.
			if(M.nutrition >= 100)
				owner.nutrition = (owner.nutrition * 0.95)*/
	return

/*** DM_SIZE_STEAL ***/
/datum/belly/proc/_dm_sizesteal()
	for(var/mob/living/M in internal_contents)

		if(prob(10))
			var/growsound = pick(GLOB.digestion_sounds)
			M << sound(growsound,volume=80)
			owner << sound(growsound,volume=80)

		/*if(M.size_multiplier > shrink_grow_size && owner.size_multiplier < 2) //Grow until either pred is large or prey is small.
			owner.resize(owner.size_multiplier+0.01) //Grow by 1% per tick.
			M.resize(M.size_multiplier-0.01) //Shrink by 1% per tick
			if(M.nutrition >= 100)
				var/oldnutrition = (M.nutrition * 0.05)
				M.nutrition = (M.nutrition * 0.95)
				owner.nutrition += oldnutrition*/
	return

/*** DM_HEAL ***/
/datum/belly/proc/_dm_heal()
	if(prob(50)) //Wet heals!
		var/healsound = pick(GLOB.digestion_sounds)
		for(var/mob/hearer in range(1,owner))
			hearer << sound(healsound,volume=80)

	/*for (var/mob/living/M in internal_contents)
		if(M.stat != DEAD)
			if(owner.nutrition > 90 && (M.health < M.maxHealth))
				M.adjustBruteLoss(-5)
				M.adjustFireLoss(-5)
				owner.nutrition -= 2
				if(M.nutrition <= 400)
					M.nutrition += 1
			else if(owner.nutrition > 90 && (M.nutrition <= 400))
				owner.nutrition -= 1
				M.nutrition += 1*/
	return