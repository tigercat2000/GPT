//wrapper macros for easier grepping
#define DIRECT_OUTPUT(A, B) A << B
#define SEND_IMAGE(target, image) DIRECT_OUTPUT(target, image)
#define SEND_SOUND(target, sound) DIRECT_OUTPUT(target, sound)
#define SEND_TEXT(target, text) DIRECT_OUTPUT(target, text)
#define WRITE_FILE(file, text) DIRECT_OUTPUT(file, text)

//print a warning message to world.log
#define WARNING(MSG) warning("[MSG] in [__FILE__] at line [__LINE__] src: [src] usr: [usr].")
/proc/warning(msg)
	msg = "## WARNING: [msg]"
	log_world(msg)

//not an error or a warning, but worth to mention on the world log, just in case.
#define NOTICE(MSG) notice(MSG)
/proc/notice(msg)
	msg = "## NOTICE: [msg]"
	log_world(msg)

//print a testing-mode debug message to world.log and world
#ifdef TESTING
#define testing(msg) log_world("## TESTING: [msg]"); to_chat(world, "## TESTING: [msg]")
#else
#define testing(msg)
#endif


/proc/log_qdel(text)
	WRITE_FILE(GLOB.world_qdel_log, "\[[time_stamp()]]QDEL: [text]")

/proc/log_sql(text)
	WRITE_FILE(GLOB.sql_error_log, "\[[time_stamp()]]SQL: [text]")

/proc/log_config(text)
	WRITE_FILE(GLOB.config_error_log, text)
	SEND_TEXT(world.log, text)

//This replaces world.log so it displays both in DD and the file
/proc/log_world(text)
	WRITE_FILE(GLOB.world_runtime_log, text)
	SEND_TEXT(world.log, text)

// Helper procs for building detailed log lines

/proc/datum_info_line(datum/D)
	if(!istype(D))
		return
	if(!ismob(D))
		return "[D] ([D.type])"
	var/mob/M = D
	return "[M] ([M.ckey]) ([M.type])"

/proc/atom_loc_line(atom/A)
	if(!istype(A))
		return
	var/turf/T = get_turf(A)
	if(istype(T))
		return "[A.loc] [COORD(T)] ([A.loc.type])"
	else if(A.loc)
		return "[A.loc] (0, 0, 0) ([A.loc.type])"

/proc/error(msg)
	SEND_TEXT(world.log, "## ERROR: [msg]")

/proc/log_debug(msg)
	SEND_TEXT(world, "Debug: [msg]")

/proc/message_admins(msg)
	SEND_TEXT(world, "Admin: [msg]")

#define LOG_SMC(msg) log_smc(msg)
/proc/log_smc(msg)
#ifdef DEBUGGING
	to_chat(world, "## MSC: [msg]")
#endif
	SEND_TEXT(world.log, "## MSC: [msg]")