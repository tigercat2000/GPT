#define UPGRADE_COOLDOWN  40
#define UPGRADE_KILL_TIMER  100

//times it takes for a mob to eat
#define EAT_TIME_XENO 30
#define EAT_TIME_FAT 100

//time it takes for a mob to be eaten (in deciseconds) (overrides mob eat time)
#define EAT_TIME_ANIMAL 30

/obj/item/weapon/grab
	name = "grab"
	//flags = NOBLUDGEON | ABSTRACT
	var/obj/screen/grab/hud = null
	var/mob/living/affecting = null
	var/mob/living/assailant = null
	var/state = GRAB_PASSIVE

	var/allow_upgrade = 1
	var/last_upgrade = 0
	var/dancing //determines if assailant and affecting keep looking at each other. Basically a wrestling position

	layer = ABOVE_HUD_LAYER
	plane = HUD_PLANE
	item_state = "nothing"
	icon = 'icons/mob/screen_gen.dmi'


/obj/item/weapon/grab/New(var/mob/user, var/mob/victim)
	..()

	//Okay, first off, some fucking sanity checking. No user, or no victim, or they are not mobs, no grab.
	if(!istype(user) || !istype(victim))
		return

	loc = user
	assailant = user
	affecting = victim

	if(affecting.anchored)
		qdel(src)
		return

	affecting.grabbed_by += src

	hud = new /obj/screen/grab(src)
	hud.icon_state = "reinforce"
	icon_state = "grabbed"
	hud.name = "reinforce grab"
	hud.master = src

	//check if assailant is grabbed by victim as well
	if(assailant.grabbed_by)
		for(var/obj/item/weapon/grab/G in assailant.grabbed_by)
			if(G.assailant == affecting && G.affecting == assailant)
				G.dancing = 1
				G.adjust_position()
				dancing = 1

	adjust_position()
	START_PROCESSING(SSobj, src)


/obj/item/weapon/grab/override_throw(mob/user, target)
	if(affecting && user.Adjacent(affecting))
		if(state >= GRAB_AGGRESSIVE)
			user.__throw(target, affecting)
	return TRUE

//Used by throw code to hand over the mob, instead of throwing the grab. The grab is then deleted by the throw code.
/obj/item/weapon/grab/proc/get_mob_if_throwable()
	if(affecting && assailant.Adjacent(affecting))
		/*if(affecting.buckled)
			return null*/
		if(state >= GRAB_AGGRESSIVE)
			return affecting
	return null

//This makes sure that the grab screen object is displayed in the correct hand.
/obj/item/weapon/grab/proc/synch()
	if(affecting)
		if(assailant.get_slot(INV_R_HAND) == src)
			hud.screen_loc = ui_rhand
		else
			hud.screen_loc = ui_lhand
		if(assailant.hud_used && assailant.hud_used.hud_version != HUD_STYLE_NOHUD)
			assailant.client.screen += hud

/obj/item/weapon/grab/process()
	if(!confirm())
		return //If the confirm fails, the grab is about to be deleted. That means it shouldn't continue processing.

	if(assailant.client)
		if(!hud)
			return //this somehow can runtime under the right circumstances
		synch()

	if(assailant.pulling == affecting)
		assailant.stop_pulling()

	if(state <= GRAB_AGGRESSIVE)
		allow_upgrade = 1
		//disallow upgrading if we're grabbing more than one person
		var/l_hand = assailant.get_slot(INV_L_HAND)
		if(l_hand != src && istype(l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = l_hand
			if(G.affecting != affecting)
				allow_upgrade = 0

		var/r_hand = assailant.get_slot(INV_R_HAND)
		if(r_hand != src && istype(r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = r_hand
			if(G.affecting != affecting)
				allow_upgrade = 0

		//disallow upgrading past aggressive if we're being grabbed aggressively
		for(var/obj/item/weapon/grab/G in affecting.grabbed_by)
			if(G == src) continue
			if(G.state >= GRAB_AGGRESSIVE)
				allow_upgrade = 0

		if(allow_upgrade)
			if(state < GRAB_AGGRESSIVE)
				hud.icon_state = "reinforce"
			else
				hud.icon_state = "reinforce1"
		else
			hud.icon_state = "!reinforce"

	if(state >= GRAB_AGGRESSIVE)
		affecting.drop_hands()

	if(state >= GRAB_NECK)
		affecting.Stun(5)  //It will hamper your voice, being choked and all.
		//if(isliving(affecting))
			//var/mob/living/L = affecting
			//L.adjustOxyLoss(1)

	if(state >= GRAB_KILL)
		affecting.Stuttering(5) //It will hamper your voice, being choked and all.
		affecting.Weaken(5)	//Should keep you down unless you get help.
		affecting.AdjustLoseBreath(2, bound_lower = 0, bound_upper = 3)

	adjust_position()


/obj/item/weapon/grab/attack_self(mob/user)
	s_click(hud)

//Updating pixelshift, position and direction
//Gets called on process, when the grab gets upgraded or the assailant moves
/obj/item/weapon/grab/proc/adjust_position()
	if(affecting.lying && state != GRAB_KILL)
		animate(affecting, pixel_x = 0, pixel_y = 0, 5, 1, LINEAR_EASING)
		return

	var/shift = 0
	var/adir = get_dir(assailant, affecting)
	affecting.layer = MOB_LAYER
	switch(state)
		if(GRAB_PASSIVE)
			shift = 8
			if(dancing) //look at partner
				shift = 10
				assailant.set_dir(get_dir(assailant, affecting))
		if(GRAB_AGGRESSIVE)
			shift = 12
		if(GRAB_NECK, GRAB_UPGRADING)
			shift = -10
			adir = assailant.dir
			affecting.set_dir(assailant.dir)
			affecting.loc = assailant.loc
		if(GRAB_KILL)
			shift = 0
			adir = 1
			affecting.set_dir(SOUTH)//face up
			affecting.loc = assailant.loc

	switch(adir)
		if(NORTH)
			animate(affecting, pixel_x = 0, pixel_y =-shift, 5, 1, LINEAR_EASING)
			affecting.layer = BELOW_MOB_LAYER
		if(SOUTH)
			animate(affecting, pixel_x = 0, pixel_y = shift, 5, 1, LINEAR_EASING)
			affecting.layer = ABOVE_MOB_LAYER
		if(WEST)
			animate(affecting, pixel_x = shift, pixel_y = 0, 5, 1, LINEAR_EASING)
			affecting.layer = ABOVE_MOB_LAYER
		if(EAST)
			animate(affecting, pixel_x =-shift, pixel_y = 0, 5, 1, LINEAR_EASING)
			affecting.layer = ABOVE_MOB_LAYER

/obj/item/weapon/grab/proc/s_click(obj/screen/S)
	if(!affecting)
		return
	if(state == GRAB_UPGRADING)
		return
	if(assailant.next_move > world.time)
		return
	if(world.time < (last_upgrade + UPGRADE_COOLDOWN))
		return
	if(!assailant.canmove || assailant.lying)
		qdel(src)
		return

	last_upgrade = world.time

	if(state < GRAB_AGGRESSIVE)
		if(!allow_upgrade)
			return
		assailant.visible_message("<span class='warning'>[assailant] has grabbed [affecting] aggressively (now hands)!</span>")
		state = GRAB_AGGRESSIVE
		icon_state = "grabbed1"
		hud.icon_state = "reinforce1"
	else if(state < GRAB_NECK)
		assailant.visible_message("<span class='warning'>[assailant] has reinforced \his grip on [affecting] (now neck)!</span>")
		state = GRAB_NECK
		icon_state = "grabbed+1"
		assailant.set_dir(get_dir(assailant, affecting))
		hud.icon_state = "kill"
		hud.name = "kill"
		affecting.Stun(10) //10 ticks of ensured grab
	else if(state < GRAB_UPGRADING)
		assailant.visible_message("<span class='danger'>[assailant] starts to tighten \his grip on [affecting]'s neck!</span>")
		hud.icon_state = "kill1"
		state = GRAB_KILL
		assailant.visible_message("<span class='danger'>[assailant] has tightened \his grip on [affecting]'s neck!</span>")
		assailant.next_move = world.time + 10
		affecting.set_dir(WEST)
	adjust_position()

//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/grab/proc/confirm()
	if(!assailant || !affecting)
		qdel(src)
		return 0

	if(affecting)
		if(!isturf(assailant.loc) || (!isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1))
			qdel(src)
			return 0
	return 1


/obj/item/weapon/grab/attack(mob/living/M, mob/living/user)
	if(!affecting)
		return

/obj/item/weapon/grab/dropped()
	if(!QDELETED(src))
		qdel(src)

/obj/item/weapon/grab/Destroy()
	if(affecting)
		affecting.pixel_x = 0
		affecting.pixel_y = 0 //used to be an animate, not quick enough for del'ing
		affecting.layer = initial(affecting.layer)
		affecting.grabbed_by -= src
		affecting = null
	if(assailant)
		if(assailant.client)
			assailant.client.screen -= hud
		assailant = null
	QDEL_NULL(hud)
	. = ..()

#undef EAT_TIME_XENO
#undef EAT_TIME_FAT
#undef EAT_TIME_ANIMAL

/mob/proc/grabbedby(mob/living/user, var/supress_message = 0)
	if(user == src || anchored)
		return 0

	for(var/obj/item/weapon/grab/G in grabbed_by)
		if(G.assailant == user)
			to_chat(user, "<span class='notice'>You already grabbed [src].</span>")
			return

	var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(user, src)
	if(!G)	//the grab will delete itself in New if src is anchored
		return 0
	user.put_in_active_hand(G)
	G.synch()

	playsound(src.loc, 'sound/effects/thudswoosh.ogg', 50, 1, -1)
	if(!supress_message)
		visible_message("<span class='warning'>[user] has grabbed [src] passively!</span>")

	return G

/mob/CtrlClick(mob/living/user)
	grabbedby(user)

/mob/proc/grabbed()
	. = list()

	var/l_hand = get_slot(INV_L_HAND)
	if(istype(l_hand, /obj/item/weapon/grab))
		. += l_hand

	var/r_hand = get_slot(INV_R_HAND)
	if(istype(r_hand, /obj/item/weapon/grab))
		. += r_hand

/mob/proc/grabbed_mobs()
	. = list()

	var/list/grabbing = grabbed()
	if(grabbing.len)
		for(var/obj/item/weapon/grab/G in grabbing)
			. += G.affecting

/mob/set_dir()
	. = ..()
	for(var/obj/item/weapon/grab/G in grabbed())
		if(!G.dancing)
			G.adjust_position()