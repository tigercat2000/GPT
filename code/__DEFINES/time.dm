#define TimeOfGame (get_game_time())
#define TimeOfTick (world.tick_usage * 0.01 * world.tick_lag)

/proc/get_game_time()
	var/static/time_offset = 0
	var/static/last_time = 0
	var/static/last_usage = 0

	var/wtime = world.time
	var/wusage = world.tick_usage * 0.01

	if(last_time < wtime && last_usage > 1)
		time_offset += last_usage - 1

	last_time = wtime
	last_usage = wusage

	return wtime + (time_offset + wusage) * world.tick_lag


/**
 * Returns "watch handle" (really just a timestamp :V)
 */
/proc/start_watch()
	return TimeOfGame

/**
 * Returns number of seconds elapsed.
 * @param wh number The "Watch Handle" from start_watch(). (timestamp)
 */
/proc/stop_watch(wh)
	return round(0.1 * (TimeOfGame - wh), 0.1)


GLOBAL_VAR_INIT(midnight_rollovers, 0)
GLOBAL_VAR_INIT(rollovercheck_last_timeofday, 0)
/proc/update_midnight_rollover()
	if (world.timeofday < GLOB.rollovercheck_last_timeofday) //TIME IS GOING BACKWARDS!
		return GLOB.midnight_rollovers++
	return GLOB.midnight_rollovers
