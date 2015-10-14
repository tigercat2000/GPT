/atom/movable
	density = 1

/atom/movable/Bump(atom/A)
	if(A)
		A.Bumped(src)

	. = ..()