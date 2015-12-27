#define TOPIC_SPAM_DELAY 2

/client

	var/ambience_played = 0
	var/next_allowed_topic_time

	var/ghosting = 0


/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob)
		return

	if(next_allowed_topic_time > world.time)
		return
	next_allowed_topic_time = world.time + TOPIC_SPAM_DELAY

	if(findtext(href,"<script",1,0))
		world.log << "Attempted use of scripts within a topic call, by [src]"
		return

	switch(href_list["_src_"])
		if("usr")		hsrc = mob
		#if defined(DEBUGGING) //this HAS to be here, but shouldn't keep debugging turned on
		if("vars")		return view_var_Topic(href, href_list, hsrc)
		#endif

	. = ..()