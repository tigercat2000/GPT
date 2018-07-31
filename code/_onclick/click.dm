/mob/var/next_click = 0

/atom/Click(location, control, params)
	SEND_SIGNAL(src, COMSIG_CLICK, location, control, params, usr)
	usr.ClickOn(src, params)

/atom/DblClick(location, control, params)
	usr.DblClickOn(src, params)

/mob/proc/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	face_atom(A)

	if(handle_special_clicks(A, params))
		return 1

	if(next_move > world.time)
		return

	/*if(in_throw_mode)
		throw_item(A)
		return*/

	var/obj/item/W = get_active_hand()

	if(W == A)
		W.attack_self(src)
		update_slot(get_slot_by_item(W))
		return

	//These are always reachable.
	//User itself, current loc, and user inventory
	if(A in DirectAccess())
		if(W)
			W.melee_attack_chain(src, A, params)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			UnarmedAttack(A)
		return

	//Can't reach anything else in lockers or other weirdness
	if(!loc.AllowClick())
		return

	//Standard reach turf to turf or reaching inside storage
	if(CanReach(A,W))
		if(W)
			W.melee_attack_chain(src, A, params)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			UnarmedAttack(A,1)
	else
		if(W)
			W.afterattack(A,src,0,params)
		else
			RangedAttack(A,params)

/mob/proc/DblClickOn(atom/A, params)
	return

/mob/proc/handle_special_clicks(atom/A, params)
	var/list/modifiers = params2list(params)
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return 1
	if(modifiers["alt"])
		AltClickOn(A)
		return 1
	return 0


/mob/proc/changeNext_move(num)
	next_move = world.time + num

/mob/proc/UnarmedAttack(atom/A, proximity_flag)
	A.attack_hand(src)

/mob/proc/RangedAttack(atom/A, params)
	return 0

/atom/proc/attack_hand(mob/user)
	. = FALSE
	// if(!(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND))
		// add_fingerprint(user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_NO_ATTACK_HAND)
		. = TRUE
	if(interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND)
		. = _try_interact(user)

//Return a non FALSE value to cancel whatever called this from propagating, if it respects it.
/atom/proc/_try_interact(mob/user)
	// if(IsAdminGhost(user))		//admin abuse
		// return interact(user)
	if(can_interact(user))
		return interact(user)
	return FALSE

/atom/proc/can_interact(mob/user)
	if(!user.can_interact_with(src))
		return FALSE
	// if((interaction_flags_atom & INTERACT_ATOM_REQUIRES_DEXTERITY) && !user.IsAdvancedToolUser())
	// 	to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
	// 	return FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_IGNORE_INCAPACITATED) && user.incapacitated((interaction_flags_atom & INTERACT_ATOM_IGNORE_RESTRAINED), !(interaction_flags_atom & INTERACT_ATOM_CHECK_GRAB)))
		return FALSE
	return TRUE

/atom/proc/interact(mob/user)
	//if(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_INTERACT)
	//	add_hiddenprint(user)
	//else
	//	add_fingerprint(user)
	//if(interaction_flags_atom & INTERACT_ATOM_UI_INTERACT)
	//	return ui_interact(user)
	return FALSE

// Simple helper to face what you clicked on, in case it should be needed in more than one place
/mob/proc/face_atom(atom/A)
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
	set_dir(direction)

/atom/movable/proc/CanReach(atom/ultimate_target, obj/item/tool, view_only = FALSE)
	// A backwards depth-limited breadth-first-search to see if the target is
	// logically "in" anything adjacent to us.
	var/list/direct_access = DirectAccess()
	var/depth = 1 + (view_only ? STORAGE_VIEW_DEPTH : INVENTORY_DEPTH)

	var/list/closed = list()
	var/list/checking = list(ultimate_target)
	while (checking.len && depth > 0)
		var/list/next = list()
		--depth

		for(var/atom/target in checking)  // will filter out nulls
			if(closed[target] || isarea(target))  // avoid infinity situations
				continue
			closed[target] = TRUE
			if(isturf(target) || isturf(target.loc) || (target in direct_access)) //Directly accessible atoms
				if(Adjacent(target)) //  || (tool && CheckToolReach(src, target, tool.reach)) //Adjacent or reaching attacks
					return TRUE

			if (!target.loc)
				continue
			GET_COMPONENT_FROM(storage, /datum/component/storage, target.loc)
			if (storage)
				var/datum/component/storage/concrete/master = storage.master()
				if (master)
					next += master.parent
					for(var/S in master.slaves)
						var/datum/component/storage/slave = S
						next += slave.parent
				else
					next += target.loc
			else
				next += target.loc

		checking = next
	return FALSE

/atom/movable/proc/DirectAccess()
	return list(src, loc)

/mob/DirectAccess(atom/target)
	return ..() + contents

/mob/living/DirectAccess(atom/target)
	return ..() + GetAllContents()

/atom/proc/AllowClick()
	return FALSE

/turf/AllowClick()
	return TRUE
