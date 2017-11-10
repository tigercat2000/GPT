/obj
	icon = 'icons/obj/obj.dmi'
	var/in_use = 0

/obj/Topic(href, href_list, var/nowindow = 0, var/datum/topic_state/state = default_state)
	if(!nowindow && ..())
		return 1

	usr.set_machine(src)

	if(CanUseTopic(usr, state, href_list) == STATUS_INTERACTIVE)
		CouldUseTopic(usr)
		return 0

	CouldNotUseTopic(usr)
	return 1

/obj/proc/CouldUseTopic(var/mob/user)
/obj/proc/CouldNotUseTopic(var/mob/user)

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if(M.client && M.machine == src)
				is_in_use = 1
				attack_hand(M)

		in_use = is_in_use


/mob/proc/unset_machine()
	machine = null

/mob/proc/set_machine(var/obj/O)
	if(machine)
		unset_machine()
	machine = O
	if(istype(O))
		O.in_use = 1