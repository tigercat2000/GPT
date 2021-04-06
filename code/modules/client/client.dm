#define TOPIC_SPAM_DELAY 2

/client
	parent_type = /datum

	var/ambience_played = 0
	var/next_allowed_topic_time

	var/ghosting = 0

	// Their chat window, sort of important.
	// See /goon/code/datums/browserOutput.dm
	var/datum/chatOutput/chatOutput
	//datum that controls the displaying and hiding of tooltips
	var/datum/tooltip/tooltips

	var/datum/preferences/prefs = null

	///world.time they connected
	var/connection_time
	///world.realtime they connected
	var/connection_realtime
	///world.timeofday they connected
	var/connection_timeofday

/client/New(TopicData)
	chatOutput = new /datum/chatOutput(src) // Right off the bat.

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = preferences_datums[ckey]
	if(!prefs)
		prefs = new /datum/preferences(src)
		preferences_datums[ckey] = prefs

	. = ..()
	connection_time = world.time
	connection_realtime = world.realtime
	connection_timeofday = world.timeofday

	chatOutput.start()
	GLOB.clients += src

	if(!winexists(src, "asset_cache_browser")) // The client is using a custom skin, tell them.
		to_chat(src, "<span class='warning'>Unable to access asset cache browser, if you are using a custom skin file, please allow DS to download the updated version, if you are not, then make a bug report. This is not a critical issue but can cause issues with resource downloading, as it is impossible to know when extra resources arrived to you.</span>")

	//load info on what assets the client has
	src << browse('code/modules/asset_cache/validate_assets.html', "window=asset_cache_browser")

	if(!tooltips)
		tooltips = new /datum/tooltip(src)

	callHook("clientNew", list(src))

/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob)
		return

	if(href_list["_src_"] == "chat")
		return chatOutput.Topic(href, href_list)

	if(next_allowed_topic_time > world.time)
		return
	next_allowed_topic_time = world.time + TOPIC_SPAM_DELAY

	if(findtext(href,"<script",1,0))
		world.log << "Attempted use of scripts within a topic call, by [src]"
		return

	// asset_cache
	var/asset_cache_job
	if(href_list["asset_cache_confirm_arrival"])
		asset_cache_job = asset_cache_confirm_arrival(href_list["asset_cache_confirm_arrival"])
		if (!asset_cache_job)
			return

	// Tgui Topic middleware
	if(tgui_Topic(href_list))
		return

	//byond bug ID:2256651
	if (asset_cache_job && (asset_cache_job in completed_asset_jobs))
		to_chat(src, "<span class='danger'>An error has been detected in how your client is receiving resources. Attempting to correct.... (If you keep seeing these messages you might want to close byond and reconnect)</span>")
		src << browse("...", "window=asset_cache_browser")
		return
	if (href_list["asset_cache_preload_data"])
		asset_cache_preload_data(href_list["asset_cache_preload_data"])
		return

	switch(href_list["_src_"])
		if("usr")
			hsrc = mob
		#if defined(DEBUGGING) //this HAS to be here, but shouldn't keep debugging turned on
		if("vars")
			return view_var_Topic(href, href_list, hsrc)
		#endif

	switch(href_list["action"])
		if("openLink")
			src << link(href_list["link"])

	. = ..()


//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration=3000)
	if(inactivity > duration)	return inactivity
	return 0


//ROTATIUM
/client/verb/rotate_left()
	set name = "Spin View (CCW)"
	set category = "Preferences"
	set_dir(turn(dir, 90))

/client/verb/rotate_right()
	set name = "Spin View (CW)"
	set category = "Preferences"
	set_dir(turn(dir, -90))

/client/verb/rotate_reset()
	set name = "Spin View (Reset)"
	set category = "Preferences"
	set_dir(NORTH)

/client/proc/set_dir(newdir)
	var/obj/screen/fullscreen/F = mob.overlay_fullscreen("client_dir_rotation", /obj/screen/fullscreen/dirchange, 1)

	var/const/spintime = 10

	var/angle = SimplifyDegrees(dir2angle(newdir) - dir2angle(dir))
	if(angle == 90)
		animate(F, transform = turn(matrix(), 120), time = spintime/3)
		animate(transform = turn(matrix(), 240), time = spintime/3)
		animate(transform = null, time = spintime/3)
	else if(angle == 270)
		animate(F, transform = turn(matrix(), -120), time = spintime/3)
		animate(transform = turn(matrix(), -240), time = spintime/3)
		animate(transform = null, time = spintime/3)
	else
		var/matrix/M = matrix()
		M.Scale(1.25)
		animate(F, transform = M, time = spintime/2)
		animate(transform = null, time = spintime/2)

	spawn(1)
		dir = newdir
	spawn(spintime)
		mob.clear_fullscreen("client_dir_rotation")


// FPS
/client/verb/change_fps(new_fps as null|num)
	set name = "Set FPS"
	set category = "Preferences"

	if(new_fps == null)
		fps = world.fps
		to_chat(src, "FPS Reset to [world.fps]")
		return

	new_fps = Clamp(new_fps, 10, 144)
	fps = new_fps
	if(fps > world.fps)
		glide_size = 4
		mob.glide_size = 4
	else
		glide_size = 0
		mob.glide_size = 0
	to_chat(src, "Your FPS has been set to [fps].")