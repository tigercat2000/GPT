/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"

	if(lentext(message) < 1024)
		say(message)

//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"

	if(AM.Adjacent(src))
		src.start_pulling(AM)

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

/mob/verb/activate_held_item()
	set name = "Activate Held Object"
	set category = null
	set src = usr

	if(hand)
		var/obj/item/W = l_hand
		if(W)
			W.attack_self(src)
			update_inv_l_hand()
	else
		var/obj/item/W = r_hand
		if(W)
			W.attack_self(src)
			update_inv_r_hand()

/mob/verb/drop_held_item()
	set name = ".drop-held"
	set category = null
	set src = usr

	drop_item()

/mob/verb/swap_hand_verb()
	set name = ".swap-hands"
	set category = null
	set src = usr

	swap_hand()

/mob/verb/toggle_walk_verb()
	set name = ".toggle-walk"
	set category = null
	set src = usr

	toggle_walk()