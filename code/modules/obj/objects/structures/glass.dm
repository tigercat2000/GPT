/obj/structure/window
	name = "window"
	icon_state = "window"
	anchored = 1
	density = 1

/obj/structure/window/CanPass(atom/movable/mover, turf/target, height=0)
	if(dir == SOUTHWEST || dir == SOUTHEAST || dir == NORTHWEST || dir == NORTHEAST)
		return 0	//full tile window, you can't move into it!
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/structure/window/CheckExit(atom/movable/O as mob|obj, target)
	if(get_dir(O.loc, target) == dir)
		return 0
	return 1

/obj/structure/window/opaque
	opacity = TRUE