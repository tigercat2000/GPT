/mob/syndie
	name = "unknown"
	icon_state = "syndicate"

	var/list/pissed_at = list()
	var/allow_pissy = 0

/mob/syndie/hear_say(var/formatted_message, var/mob/speaker)
	if(speaker.type == /mob && allow_pissy)
		spawn(2) //to make their text appear AFTER the mob's text
			face_atom(speaker)
			say("Shutup, Subject [speaker], or I will be forced to terminate you.")
			pissed_at["[speaker.name]"]++
	. = ..()

/mob/scientist
	name = "Syndicate Scientist"
	icon_state = "scientist"

	var/waiting_for_input = 0
	var/last_heard_message = ""

/mob/scientist/proc/wait_for_input(var/time_to_wait)
	last_heard_message = ""
	sleep(time_to_wait)
	if(last_heard_message)
		if(findtext(last_heard_message, "why"))
			say("Why are you here, you ask? It's simple.")
			say("You are here to serve as a subject for the syndicate.")
		if(findtext(last_heard_message, "fuck you"))
			say("Just going to be rude? I suppose I expected nothing less.")
		if(findtext(last_heard_message, "susan"))
			say(".... How do you know my name? GUARDS!")

/mob/scientist/hear_say(var/formatted_message, var/mob/speaker)
	last_heard_message

	= formatted_message