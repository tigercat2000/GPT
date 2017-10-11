/mob/var/next_click = 0

/atom/Click(location, control, params)
	usr.ClickOn(src, params)

/mob/proc/ClickOn(var/atom/A, var/params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	face_atom(A)

	if(handle_special_clicks(A, params))
		return 1

	if(next_move > world.time)
		return

	var/obj/item/W = get_active_hand()

	if(W == A)
		W.attack_self(src)
		update_slot_icon(get_slot(W))

	var/sdepth = A.storage_depth(src)
	if(A == loc || (A in loc) || (sdepth != -1 && sdepth <= 1))
		// No adjacency needed
		if(W)
			var/resolved = A.attackby(W, src, params)
			if(!resolved && A && W)
				W.afterattack(A, src, 1, params)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			UnarmedAttack(A, 1)

		return

	if(!isturf(loc))
		return

	sdepth = A.storage_depth_turf()
	if(isturf(A) || isturf(A.loc) || (sdepth != -1 && sdepth <= 1))
		if(A.Adjacent(src))
			if(W)
				var/resolved = A.attackby(W, src, params)
				if(!resolved && A && W)
					W.afterattack(A, src, 1, params)

			else
				if(ismob(A))
					changeNext_move(CLICK_CD_MELEE)
				UnarmedAttack(A, 1)
		else
			if(W)
				W.afterattack(A, src, 0, params)
			else
				RangedAttack(A, params)


/mob/proc/handle_special_clicks(var/atom/A, var/params)
	var/list/modifiers = params2list(params)
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		. = 1



/mob/proc/changeNext_move(num)
	next_move = world.time + num

/mob/proc/UnarmedAttack(var/atom/A, var/proximity_flag)
	A.attack_hand(src)

/mob/proc/RangedAttack(var/atom/A, var/params)
	return 0

/atom/proc/attack_hand(var/mob/user)
	return 0

// Simple helper to face what you clicked on, in case it should be needed in more than one place
/mob/proc/face_atom(var/atom/A)
	if(!A || !x || !y || !A.x || !A.y ) return
	var/dx = A.x - x
	var/dy = A.y - y
	if(!dx && !dy) return

	var/direction
	if(abs(dx) < abs(dy))
		if(dy > 0)	direction = NORTH
		else		direction = SOUTH
	else
		if(dx > 0)	direction = EAST
		else		direction = WEST
	src.dir = direction