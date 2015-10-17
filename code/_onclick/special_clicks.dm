/mob/proc/CtrlClickOn(var/atom/A)
	if(pulling == A)
		stop_pulling()
	else
		start_pulling(A)