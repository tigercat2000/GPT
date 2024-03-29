/hook/mobNewLogin/proc/__map_fluff_primary(mob/M)
	return
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

		to_chat(M, "<span class='warning'>Welcome to the void...</span>")
		M.canmove = 0

		var/matrix/end1 = new
		end1.Scale(world.view * 5, 13)
		end1.Translate(0, -(world.view * (world.icon_size * 2)) - world.icon_size)

		var/matrix/end2 = new
		end2.Scale(world.view * 5, 13)
		end2.Translate(0, (world.view * (world.icon_size * 2)) + world.icon_size)

		sleep(20)
		animate(O, transform = end1, time = 50)
		animate(O2, transform = end2, time = 50)
		sleep(51)
		animate(M.client, color = "#FFFFFF", time = 20)
		sleep(20)

		to_chat(M, "<span class='alien'>Enjoy your stay...</span>")
		M.canmove = 1

		M.client.screen -= O
		M.client.screen -= O2

		return 1
	return 0