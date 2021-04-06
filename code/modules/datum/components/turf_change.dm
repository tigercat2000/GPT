/datum/component/turfchange
	var/turf/myturf = null

/datum/component/turfchange/Initialize(turf/T)
	myturf = T
	RegisterSignal(T, list(COMSIG_TURF_CHANGE), .proc/callback)

/datum/component/turfchange/proc/callback()
	myturf.update_icon()