/mob/proc/CtrlClickOn(var/atom/movable/A)
	if(istype(A))
		A.CtrlClick(src)

/atom/movable/proc/CtrlClick(mob/user)
	if(user.pulling == src)
		user.stop_pulling()
	else
		user.start_pulling(src)

/atom/proc/AltClick(mob/user)
	return

/mob/proc/AltClickOn(atom/A)
	A.AltClick(src)