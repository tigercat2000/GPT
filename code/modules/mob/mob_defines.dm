/mob
	icon = 'icons/mob/mob.dmi'
	icon_state = "human"
	density = 1

	var/movement_delay = 2
	var/next_move = null
	var/atom/movable/pulling = null

	see_invisible = 21

	animate_movement = 2 //SLIDE