/var/global/datum/topic_state/default/default_state = new()

/datum/topic_state/default/href_list(var/mob/user)
	return list()

/datum/topic_state/default/can_use_topic(var/src_object, var/mob/user)
	return user.default_can_use_topic(src_object)

/mob/proc/default_can_use_topic(var/src_object)
	. = shared_nano_interaction(src_object)
	if(. != STATUS_CLOSE)
		. = min(., shared_living_nano_distance(src_object))


//Some atoms such as vehicles might have special rules for how mobs inside them interact with NanoUI.
/atom/proc/contents_nano_distance(var/src_object, var/mob/user)
	return user.shared_living_nano_distance(src_object)

/mob/proc/shared_living_nano_distance(var/atom/movable/src_object)
	if (!(src_object in view(4, src))) 	// If the src object is not in visable, disable updates
		return STATUS_CLOSE

	var/dist = get_dist(src_object, src)
	if (dist <= 1)
		return STATUS_INTERACTIVE	// interactive (green visibility)
	else if (dist <= 2)
		return STATUS_UPDATE 		// update only (orange visibility)
	else if (dist <= 4)
		return STATUS_DISABLED 		// no updates, completely disabled (red visibility)
	return STATUS_CLOSE