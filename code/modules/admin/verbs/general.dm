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
			M.ckey = "@[key]"



/client/proc/admin_delete(var/atom/A in view())
	set name = "Delete"
	set category = "Admin"
	if(istype(A))
		qdel(A)


/client/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Open the Runtime Viewer"

	error_cache.showTo(usr)