/mob/proc/say(message, force_noncap)
	var/formatted_message = ""

	message = trim(message)

	if(!force_noncap)
		message = capitalize(message)

	if(length(message) < 1)
		return 0

	formatted_message += "<b>[src]</b> says,"
	formatted_message += " \"[message]\""

	say_broadcast(formatted_message)

/mob/proc/say_broadcast(formatted_message)
	for(var/mob/M in hearers(world.view, get_turf(src)))
		M.hear_say(formatted_message, src)
	return 1

/mob/proc/hear_say(formatted_message, mob/speaker)
	to_chat(src, formatted_message)
	return 1