// There, now `stat` is a proper state-machine

/mob/living/proc/KnockOut(updating = 1)
	if(stat == DEAD)
		log_runtime(EXCEPTION("KnockOut called on a dead mob."), src)
		return 0
	else if(stat == UNCONSCIOUS)
		return 0
	//add_logs(src, null, "fallen unconscious at [atom_loc_line(get_turf(src))]", admin=0, print_attack_log = 0)
	stat = UNCONSCIOUS
	if(updating)
		update_blind_effects()
		update_canmove()
	return 1

/mob/living/proc/WakeUp(updating = 1)
	if(stat == DEAD)
		log_runtime(EXCEPTION("WakeUp called on a dead mob."), src)
		return 0
	else if(stat == CONSCIOUS)
		return 0
	//add_logs(src, null, "woken up at [atom_loc_line(get_turf(src))]", admin=0, print_attack_log = 0)
	stat = CONSCIOUS
	if(updating)
		update_blind_effects()
		update_canmove()
	return 1


// death() is used to make a mob die

// handles revival through other means than cloning or adminbus (defib, IPC repair)
/mob/living/proc/update_revive(updating = TRUE)
	if(stat != DEAD)
		return 0
	/*if(!can_be_revived())
		return 0*/
	//add_logs(src, null, "came back to life at [atom_loc_line(get_turf(src))]", admin=0, print_attack_log = 0)
	stat = CONSCIOUS
	//dead_mob_list -= src
	//living_mob_list += src
	//timeofdeath = null
	if(updating)
		update_canmove()
	update_blind_effects()
	//updatehealth()

	/*for(var/s in ownedSoullinks)
		var/datum/soullink/S = s
		S.ownerRevives(src)
	for(var/s in sharedSoullinks)
		var/datum/soullink/S = s
		S.sharerRevives(src)*/
	return 1
