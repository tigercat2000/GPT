/turf/icon/asteroid
	icon_state = "asteroid"

/turf/icon/asteroid/rand/New() //RAND
	var/ico = rand(0, 9)
	icon_state = "asteroid[ico]"

	..()
/turf/icon/asteroid/states/s1/icon_state = "asteroid1"
/turf/icon/asteroid/states/s2/icon_state = "asteroid2"
/turf/icon/asteroid/states/s3/icon_state = "asteroid3"
/turf/icon/asteroid/states/s4/icon_state = "asteroid4"
/turf/icon/asteroid/states/s5/icon_state = "asteroid5"
/turf/icon/asteroid/states/s6/icon_state = "asteroid6"
/turf/icon/asteroid/states/s7/icon_state = "asteroid7"
/turf/icon/asteroid/states/s8/icon_state = "asteroid8"
/turf/icon/asteroid/states/s9/icon_state = "asteroid9"
/turf/icon/asteroid/states/s10/icon_state = "asteroid10"
/turf/icon/asteroid/states/s11/icon_state = "asteroid11"