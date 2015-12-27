/*/hook/clientNewLogin/proc/__map_fluff_primary(mob/M) //snowflakey but better than a whole datum system for this shit
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

		animate(O, alpha = 0, time = 50)
		sleep(50)

		M << "<span class='alien'>Enjoy your stay...</span>"
		M.canmove = 1
		M.client.screen -= O

		return 1
	return 0*/

/hook/clientNewLogin/proc/__map_fluff_primary(mob/M)
	if(istype(M) && M.client)

		M.client.color = "#FF7777"

		var/obj/O = new
		O.icon = 'icons/effects/effects.dmi'
		O.icon_state = "black"
		O.screen_loc = "WEST,SOUTH"
		O.layer = EFFECTS_LAYER

		var/obj/O2 = new
		O2.icon = 'icons/effects/effects.dmi'
		O2.icon_state = "black"
		O2.screen_loc = "WEST,NORTH"
		O2.layer = EFFECTS_LAYER

		var/matrix/start = new
		start.Scale(world.view*5, 13) //start just resizes them so they can use the same thing
		O.transform = start
		O2.transform = start
		M.client.screen += O
		M.client.screen += O2

		M << "<span class='warning'>Welcome to the void...</span>"
		M.canmove = 0

		var/matrix/end1 = new
		end1.Scale(world.view*5, 13)
		end1.Translate(0, -(world.view*world.icon_size)-world.icon_size)

		var/matrix/end2 = new
		end2.Scale(world.view*5, 13)
		end2.Translate(0, (world.view*world.icon_size)+world.icon_size)

		sleep(20)
		animate(O, transform = end1, time = 50)
		animate(O2, transform = end2, time = 50)
		sleep(50)
		animate(M.client, color = "#FFFFFF", time = 20)

		M << "<span class='alien'>Enjoy your stay...</span>"
		M.canmove = 1

		M.client.screen -= O
		M.client.screen -= O2

		return 1
	return 0