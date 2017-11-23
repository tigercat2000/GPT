var/list/preferences_datums = list()

/datum/preferences
	var/path
	var/default_slot = 1	//Holder so it doesn't default to slot 1, rather the last one used
	var/savefile_version = 0

	var/client/client = null
	var/client_ckey = null

/datum/preferences/New(client/C)
	if(istype(C))
		client = C
		client_ckey = C.ckey
		load_path(C.ckey)