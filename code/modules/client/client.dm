#define TOPIC_SPAM_DELAY 2

/client
	var/ambience_played = 0
	var/next_allowed_topic_time

	var/ghosting = 0

	// Their chat window, sort of important.
	// See /goon/code/datums/browserOutput.dm
	var/datum/chatOutput/chatOutput

	parent_type = /datum

/client/New(TopicData)
	chatOutput = new /datum/chatOutput(src) // Right off the bat.
	. = ..()
	chatOutput.start()
	GLOB.clients += src

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
	dir = turn(dir, 90)

/client/verb/rotate_right()
	set name = "Spin View (CW)"
	dir = turn(dir, -90)

