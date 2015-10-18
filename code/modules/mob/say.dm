/mob/proc/say(var/message, var/force_noncap)
	var/formatted_message = ""

	message = trim(message)

	if(!force_noncap)
		message = capitalize(message)

	if(length(message) < 1)
		return 0

	formatted_message += "<b>[src]</b> says,"
	formatted_message += " \"[message]\""

	for(var/mob/M in hearers(world.view, src))
		M.hear_say(formatted_message, src)

/mob/proc/hear_say(var/formatted_message, var/mob/speaker)
	src << formatted_message
	return 1