// So you can be all 10 SECONDS
#define SECONDS *10
#define MINUTES *600
#define HOURS   *36000

/proc/time_stamp()
	return time2text(world.timeofday, "hh:mm:ss")