/world/New()
	log_world("World loaded at [time_stamp()]")
	. = ..()

	callHook("startup")
	SetupLogs()

	Master.Initialize(2, FALSE)


/world/proc/SetupLogs()
	GLOB.log_directory = "data/logs/[time2text(world.realtime, "YYYY/MM/DD")]/round-"
	GLOB.log_directory += "[replacetext(time_stamp(), ":", ".")]"
	GLOB.world_game_log = file("[GLOB.log_directory]/game.log")
	GLOB.world_attack_log = file("[GLOB.log_directory]/attack.log")
	GLOB.world_runtime_log = file("[GLOB.log_directory]/runtime.log")
	GLOB.world_qdel_log = file("[GLOB.log_directory]/qdel.log")
	GLOB.world_href_log = file("[GLOB.log_directory]/hrefs.html")
	GLOB.world_pda_log = file("[GLOB.log_directory]/pda.log")
	GLOB.sql_error_log = file("[GLOB.log_directory]/sql.log")
	WRITE_FILE(GLOB.world_game_log, "\n\nStarting up round ID [GLOB.round_id]. [time_stamp()]\n---------------------")
	WRITE_FILE(GLOB.world_attack_log, "\n\nStarting up round ID [GLOB.round_id]. [time_stamp()]\n---------------------")
	WRITE_FILE(GLOB.world_runtime_log, "\n\nStarting up round ID [GLOB.round_id]. [time_stamp()]\n---------------------")
	WRITE_FILE(GLOB.world_pda_log, "\n\nStarting up round ID [GLOB.round_id]. [time_stamp()]\n---------------------")