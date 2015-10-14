/mob/proc/say(var/message)
	var/formatted_message = ""

	formatted_message += "<b>[src]</b> says,"
	formatted_message += " \"[message]\""

	visible_message(formatted_message)