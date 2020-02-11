/obj/item/proc/melee_attack_chain(mob/user, atom/target, params)
	//if(!tool_attack_chain(user, target) && pre_attack(target, user, params))
	if(pre_attack(target, user, params))
		// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
		var/resolved = target.attackby(src, user, params)
		if(!resolved && target && !QDELETED(src))
			afterattack(target, user, 1, params) // 1: clicking something Adjacent

//Checks if the item can work as a tool, calling the appropriate tool behavior on the target
// /obj/item/proc/tool_attack_chain(mob/user, atom/target)
// 	if(!tool_behaviour)
// 		return FALSE

// 	return target.tool_act(user, src, tool_behaviour)

// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user) & COMPONENT_NO_INTERACT)
		return
	interact(user)

/obj/item/proc/pre_attack(atom/A, mob/living/user, params) //do stuff before attackby!
	if(SEND_SIGNAL(src, COMSIG_ITEM_PRE_ATTACK, A, user, params) & COMPONENT_NO_ATTACK)
		return FALSE
	return TRUE //return FALSE to avoid calling attackby after this proc does stuff

// No comment
/atom/proc/attackby(obj/item/W, mob/user, params)
	if(SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, W, user, params) & COMPONENT_NO_AFTERATTACK)
		return TRUE
	user.changeNext_move(CLICK_CD_MELEE)
	return FALSE

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user, proximity_flag, click_parameters)

/mob/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I) && ismob(user))
		if(attempt_vr(src,"vore_attackby", args)) return //VOREStation Code
		I.attack(src, user)

/obj/item/proc/attack(mob/M, mob/user)
	SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, M, user)
	return 1