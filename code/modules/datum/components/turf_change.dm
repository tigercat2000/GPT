/datum/component/turfchange
	var/turf/myturf = null

/datum/component/turfchange/Initialize(turf/T)
	myturf = T
	RegisterSignal(list(COMSIG_TURF_CHANGED), .proc/callback)

/datum/component/turfchange/proc/callback()
	myturf.update_icon()