/mob
	icon = 'icons/mob/mob.dmi'
	icon_state = "human"
	density = 1

	var/movement_delay = 2
	var/next_move = null
	var/canmove = 1
	var/walking = 1

	animate_movement = 2 //SLIDE

	var/atom/movable/pulling = null
	var/datum/hud/hud_used = null

	var/obj/machine = null

	see_invisible = 21