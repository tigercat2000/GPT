/mob/proc/CtrlClickOn(var/atom/A)
	if(pulling == A)
		stop_pulling()
	else
		start_pulling(A)

/atom/proc/AltClick(mob/user)
	return

/mob/proc/AltClickOn(atom/A)
	A.AltClick(src)
	return