/proc/do_after(mob/user, var/delay, needhand = 1, atom/target = null, progress = 1)
	if(!user)
		return 0

	var/atom/Tloc = null
	if(target && !isturf(target))
		Tloc = target.loc

	var/atom/Uloc = user.loc

	var/holding = user.get_active_hand()

	var/holdingnull = 1 // user's hand started out empty, check for an empty hand
	if(holding)
		holdingnull = 0 // Users hand started holding something, check to see if it's still holding that

	var/datum/progressbar/progbar
	if(progress)
		progbar = new(user, delay, target)

	var/endtime = world.time + delay
	var/starttime = world.time
	. = 1
	while(world.time < endtime)
		stoplag(1)
		if(progress)
			progbar.update(world.time - starttime)

		if(QDELETED(user) || user.stat || user.effects.stunned || user.loc != Uloc)
			. = 0
			break

		if(!QDELETED(Tloc) && (QDELETED(target) || Tloc != target.loc))
			if(Uloc != Tloc || Tloc != user)
				. = 0
				break

		if(needhand)
			//This might seem like an odd check, but you can still need a hand even when it's empty
			//i.e the hand is used to pull some item/tool out of the construction
			if(!holdingnull)
				if(!holding)
					. = 0
					break
			if(user.get_active_hand() != holding)
				. = 0
				break
	if(progress)
		qdel(progbar)