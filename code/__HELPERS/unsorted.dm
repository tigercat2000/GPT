/proc/get_turf(atom/A)
	if (!istype(A))
		return
	for(A, A && !isturf(A), A=A.loc); //semicolon is for the empty statement
	return A

/proc/subtypesof(var/path) //Returns a list containing all subtypes of the given path, but not the given path itself.
	if(!path || !ispath(path))
		CRASH("Invalid path, failed to fetch subtypes of \"[path]\".")
	return (typesof(path) - path)


var/mob/dview/dview_mob = new

//Version of view() which ignores darkness, because BYOND doesn't have it.
/proc/dview(var/range = world.view, var/center, var/invis_flags = 0)
	if(!center)
		return

	dview_mob.loc = center

	dview_mob.see_invisible = invis_flags

	. = view(range, dview_mob)
	dview_mob.loc = null

/mob/dview
	invisibility = 101
	density = 0

	see_in_dark = 1e6

/mob/dview/New() //For whatever reason, if this isn't called, then BYOND will throw a type mismatch runtime when attempting to add this to the mobs list. -Fox

/proc/IsValidSrc(var/A)
	if(istype(A, /datum))
		var/datum/B = A
		return isnull(B.gc_destroyed)
	if(istype(A, /client))
		return 1
	return 0

/proc/get_area(O)
	var/turf/loc = get_turf(O)
	if(loc)
		var/area/res = loc.loc
		.= res

/proc/format_text(text)
	return replacetext(replacetext(text,"\proper ",""),"\improper ","")

//gives us the stack trace from CRASH() without ending the current proc.
/proc/stack_trace(msg)
	CRASH(msg)



#define QDEL_IN(item, time) addtimer(CALLBACK(GLOBAL_PROC, .proc/qdel, item), time, TIMER_STOPPABLE)
#define QDEL_IN_CLIENT_TIME(item, time) addtimer(CALLBACK(GLOBAL_PROC, .proc/qdel, item), time, TIMER_STOPPABLE | TIMER_CLIENT_TIME)
#define QDEL_NULL(item) qdel(item); item = null
#define QDEL_LIST(L) if(L) { for(var/I in L) qdel(I); L.Cut(); }
#define QDEL_LIST_IN(L, time) addtimer(CALLBACK(GLOBAL_PROC, .proc/______qdel_list_wrapper, L), time, TIMER_STOPPABLE)
#define QDEL_LIST_ASSOC(L) if(L) { for(var/I in L) { qdel(L[I]); qdel(I); } L.Cut(); }
#define QDEL_LIST_ASSOC_VAL(L) if(L) { for(var/I in L) qdel(L[I]); L.Cut(); }

/proc/______qdel_list_wrapper(list/L) //the underscores are to encourage people not to use this directly.
	QDEL_LIST(L)


//Key thing that stops lag. Cornerstone of performance in ss13, Just sitting here, in unsorted.dm.

//Increases delay as the server gets more overloaded,
//as sleeps aren't cheap and sleeping only to wake up and sleep again is wasteful
#define DELTA_CALC max(((max(TICK_USAGE, world.cpu) / 100) * max(Master.sleep_delta-1,1)), 1)

//returns the number of ticks slept
/proc/stoplag(initial_delay)
	if (!Master || !(Master.current_runlevel & RUNLEVELS_DEFAULT))
		sleep(world.tick_lag)
		return 1
	if (!initial_delay)
		initial_delay = world.tick_lag
	. = 0
	var/i = DS2TICKS(initial_delay)
	do
		. += Ceiling(i*DELTA_CALC)
		sleep(i*world.tick_lag*DELTA_CALC)
		i *= 2
	while (TICK_USAGE > min(TICK_LIMIT_TO_RUN, Master.current_ticklimit))

#undef DELTA_CALC


/*
 Gets the turf this atom's *ICON* appears to inhabit
 It takes into account:
 * Pixel_x/y
 * Matrix x/y
 NOTE: if your atom has non-standard bounds then this proc
 will handle it, but:
 * if the bounds are even, then there are an even amount of "middle" turfs, the one to the EAST, NORTH, or BOTH is picked
 (this may seem bad, but you're atleast as close to the center of the atom as possible, better than byond's default loc being all the way off)
 * if the bounds are odd, the true middle turf of the atom is returned
*/

/proc/get_turf_pixel(atom/movable/AM)
	if(!istype(AM))
		return

	//Find AM's matrix so we can use it's X/Y pixel shifts
	var/matrix/M = matrix(AM.transform)

	var/pixel_x_offset = AM.pixel_x + M.get_x_shift()
	var/pixel_y_offset = AM.pixel_y + M.get_y_shift()

	//Irregular objects
	var/icon/AMicon = icon(AM.icon, AM.icon_state)
	var/AMiconheight = AMicon.Height()
	var/AMiconwidth = AMicon.Width()
	if(AMiconheight != world.icon_size || AMiconwidth != world.icon_size)
		pixel_x_offset += ((AMiconwidth/world.icon_size)-1)*(world.icon_size*0.5)
		pixel_y_offset += ((AMiconheight/world.icon_size)-1)*(world.icon_size*0.5)

	//DY and DX
	var/rough_x = round(round(pixel_x_offset,world.icon_size)/world.icon_size)
	var/rough_y = round(round(pixel_y_offset,world.icon_size)/world.icon_size)

	//Find coordinates
	var/turf/T = get_turf(AM) //use AM's turfs, as it's coords are the same as AM's AND AM's coords are lost if it is inside another atom
	if(!T)
		return null
	var/final_x = T.x + rough_x
	var/final_y = T.y + rough_y

	if(final_x || final_y)
		return locate(final_x, final_y, T.z)

//Centers an image.
//Requires:
//The Image
//The x dimension of the icon file used in the image
//The y dimension of the icon file used in the image
// eg: center_image(I, 32,32)
// eg2: center_image(I, 96,96)

/proc/center_image(var/image/I, x_dimension = 0, y_dimension = 0)
	if(!I)
		return

	if(!x_dimension || !y_dimension)
		return

	if((x_dimension == world.icon_size) && (y_dimension == world.icon_size))
		return I

	//Offset the image so that it's bottom left corner is shifted this many pixels
	//This makes it infinitely easier to draw larger inhands/images larger than world.iconsize
	//but still use them in game
	var/x_offset = -((x_dimension/world.icon_size)-1)*(world.icon_size*0.5)
	var/y_offset = -((y_dimension/world.icon_size)-1)*(world.icon_size*0.5)

	//Correct values under world.icon_size
	if(x_dimension < world.icon_size)
		x_offset *= -1
	if(y_dimension < world.icon_size)
		y_offset *= -1

	I.pixel_x = x_offset
	I.pixel_y = y_offset

	return I

/atom/proc/GetAllContents(var/T)
	var/list/processing_list = list(src)
	var/list/assembled = list()
	if(T)
		while(processing_list.len)
			var/atom/A = processing_list[1]
			processing_list.Cut(1, 2)
			//Byond does not allow things to be in multiple contents, or double parent-child hierarchies, so only += is needed
			//This is also why we don't need to check against assembled as we go along
			processing_list += A.contents
			if(istype(A,T))
				assembled += A
	else
		while(processing_list.len)
			var/atom/A = processing_list[1]
			processing_list.Cut(1, 2)
			processing_list += A.contents
			assembled += A
	return assembled

/proc/REF(input)
	if(istype(input, /datum))
		var/datum/thing = input
		if(thing.datum_flags & DF_USE_TAG)
			if(!thing.tag)
				stack_trace("A ref was requested of an object with DF_USE_TAG set but no tag: [thing]")
				thing.datum_flags &= ~DF_USE_TAG
			else
				return "\[[url_encode(thing.tag)]\]"
	return "\ref[input]"

/atom/proc/contains(atom/A)
	if(!A)
		return FALSE
	for(var/atom/location = A.loc, location, location = location.loc)
		if(location == src)
			return TRUE

/// Returns the md5 of a file at a given path.
/proc/md5filepath(path)
	. = md5(file(path))

/// Save file as an external file then md5 it.
/// Used because md5ing files stored in the rsc sometimes gives incorrect md5 results.
/proc/md5asfile(file)
	var/static/notch = 0
	// its importaint this code can handle md5filepath sleeping instead of hard blocking, if it's converted to use rust_g.
	var/filename = "tmp/md5asfile.[world.realtime].[world.timeofday].[world.time].[world.tick_usage].[notch]"
	notch = WRAP(notch+1, 0, 2^15)
	fcopy(file, filename)
	. = md5filepath(filename)
	fdel(filename)

//Repopulates sortedAreas list
/proc/repopulate_sorted_areas()
	GLOB.sortedAreas = list()

	for(var/area/A in world)
		GLOB.sortedAreas.Add(A)

	sortTim(GLOB.sortedAreas, /proc/cmp_name_asc)

/area/proc/addSorted()
	GLOB.sortedAreas.Add(src)
	sortTim(GLOB.sortedAreas, /proc/cmp_name_asc)

//datum may be null, but it does need to be a typed var
#define NAMEOF(datum, X) (#X || ##datum.##X)

/proc/CallAsync(datum/source, proctype, list/arguments)
	set waitfor = FALSE
	return call(source, proctype)(arglist(arguments))

#define UNTIL(X) while(!(X)) stoplag()

/atom/proc/GetAllContentsIgnoring(list/ignore_typecache)
	if(!length(ignore_typecache))
		return GetAllContents()
	var/list/processing = list(src)
	. = list()
	var/i = 0
	while(i < length(processing))
		var/atom/A = processing[++i]
		if(!ignore_typecache[A.type])
			processing += A.contents
			. += A
