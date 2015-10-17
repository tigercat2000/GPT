/proc/__MAP_MOB_INTRO(mob/M) //snowflakey but better than a whole datum system for this shit
	if(istype(M) && M.client)

		var/obj/O = new                                  //
		O.icon = 'icons/effects/effects.dmi'             // This basically gives a 'fading in from black' effect
		O.icon_state = "black"                           // It uses a 32x32 black icon
		O.screen_loc = "EAST,NORTH to WEST,SOUTH"        // Then uses screen_loc to stretch it to client.view_size, which isn't a problem for flat color icons
		O.layer = EFFECTS_LAYER                          // Clear the name and move it to the effects layer to make sure it's actually 'fade in' and not 'why can I see lampposts'
		O.name = ""                                      // Note, I intentionally left mouse opacity set to default, don't want any clicks until they are done

		M.client.screen += O
		M << "<span class='warning'>Welcome to the void...</span>"
		M.canmove = 0

		animate(O, alpha = 0, time = 100)
		sleep(100)

		M << "<span class='alien'>Enjoy your stay...</span>"
		M.canmove = 1
		M.client.screen -= O
