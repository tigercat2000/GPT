/mob/Logout()
	GLOB.players -= src
	. = ..()