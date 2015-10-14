/mob/verb/say_verb(var/message as text)
	set name = "Say"
	set desc = "Diss someone's mama!"

	if(lentext(message) < 1024)
		say(message)

//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"

	if(AM.Adjacent(src))
		src.start_pulling(AM)
	return

/mob/proc/start_pulling(atom/movable/AM)
	if(!AM || !src || src == AM || !isturf(AM.loc))	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return

	// If we're pulling something then drop what we're currently pulling and pull this instead.
	if(pulling)
		// Are we trying to pull something we are already pulling? Then just stop here, no need to continue.
		if(AM == pulling)
			return
		stop_pulling()

	src.pulling = AM
	AM.pulledby = src

/mob/verb/stop_pulling()

	set name = "Stop Pulling"
	set category = "IC"

	if(pulling)
		pulling.pulledby = null
		pulling = null