/atom/movable
	density = 1

	var/atom/movable/pulledby = null

// Previously known as Crossed()
// This is automatically called when something enters your square
/atom/movable/Crossed(atom/movable/AM)
	return

/atom/movable/Bump(atom/A)
	if(A)
		A.Bumped(src)

	. = ..()