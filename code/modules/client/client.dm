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

/client/New(TopicData)
	chatOutput = new /datum/chatOutput(src) // Right off the bat.

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = preferences_datums[ckey]
	if(!prefs)
		prefs = new /datum/preferences(src)
		preferences_datums[ckey] = prefs

	. = ..()

	chatOutput.start()
	GLOB.clients += src
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
	dir = newdir


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