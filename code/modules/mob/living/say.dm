/mob/living/say_broadcast(formatted_message)
	for(var/mob/M in hearers(world.view, src))
		M.hear_say(formatted_message, src)