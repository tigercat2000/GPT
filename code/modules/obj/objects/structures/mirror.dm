/obj/structure/mirror
	name = "mirror"
	icon_state = "alientable_full"

/obj/structure/mirror/Initialize()
	. = ..()
	process()

/obj/structure/mirror/process()
	while(TRUE)
		cut_overlays()

		for(var/mob/M in get_step(src, SOUTH))
			var/image/I = image(M, dir = M.dir & (NORTH|SOUTH) ? GLOB.reverse_dir[M.dir] : M.dir)
			add_overlay(I)

		add_overlay(mutable_appearance(icon, "[icon_state]_overlay", ABOVE_MOB_LAYER))
		sleep(1)