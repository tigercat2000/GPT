/client/proc/admin_ghost()
	set name = "Aghost"
	set category = "Admin"

	if(istype(mob, /mob/ghost))
		var/mob/ghost/G = mob
		G.reenter_corpse()

	else
		var/mob/M = mob
		M.ghostize(1)
		if(M && !M.ckey)
			M.ckey = "@[ckey]"



/client/proc/admin_delete(var/atom/A in view())
	set name = "Delete"
	set category = "Admin"
	if(istype(A))
		if(isturf(A))
			var/turf/T = A
			T.ChangeTurf(world.turf)
		else
			qdel(A)


/client/proc/view_runtimes()
	set category = "Debug Verbs"
	set name = "View Runtimes"
	set desc = "Open the Runtime Viewer"

	error_cache.showTo(usr)