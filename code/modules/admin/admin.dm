GLOBAL_LIST_EMPTY(ackey)
GLOBAL_PROTECT(ackey)

/hook/startup/proc/load_admins()
	var/list/lines = file2list("config/admins.txt")

	for(var/line in lines)
		if(!length(line))
			continue
		if(findtextEx(line, "#", 1, 2,))
			continue

		var/ckey = ckey(line)
		if(!ckey)
			continue

		GLOB.ackey += ckey

	return 1

/hook/mobLogin/proc/promote_admin(mob/M)
	if(M.client && (M.client in GLOB.admins))
		return 1
	#ifdef DEBUGGING
	M.client.load_admin()
	#else
	if(M.ckey in GLOB.ackey)
		M.client.load_admin()
	#endif
	return 1


/client/proc/load_admin()
	to_chat(src, "<span class='admin'>-- Admin Loaded</span>")
	GLOB.admins |= src
	give_admin_verbs()
