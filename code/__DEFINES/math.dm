#define CEILING(x, y) ( -round(-(x) / (y)) * (y) )

#define Clamp(CLVALUE,CLMIN,CLMAX) ( max( (CLMIN), min((CLVALUE), (CLMAX)) ) )
#define CLAMP(CLVALUE,CLMIN,CLMAX) ( max( (CLMIN), min((CLVALUE), (CLMAX)) ) )
#define CLAMP01(x) (Clamp(x, 0, 1))

//"fancy" math for calculating time in ms from tick_usage percentage and the length of ticks
//percent_of_tick_used * (ticklag * 100(to convert to ms)) / 100(percent ratio)
//collapsed to percent_of_tick_used * tick_lag
#define TICK_DELTA_TO_MS(percent_of_tick_used) ((percent_of_tick_used) * world.tick_lag)
#define TICK_USAGE_TO_MS(starting_tickusage) (TICK_DELTA_TO_MS(TICK_USAGE_REAL - starting_tickusage))

#define PERCENT(val) (round(val*100, 0.1))

// Similar to clamp but the bottom rolls around to the top and vice versa. min is inclusive, max is exclusive
#define WRAP(val, min, max) clamp(( min == max ? min : (val) - (round(((val) - (min))/((max) - (min))) * ((max) - (min))) ),min,max)

//time of day but automatically adjusts to the server going into the next day within the same round.
//for when you need a reliable time number that doesn't depend on byond time.
#define REALTIMEOFDAY (world.timeofday + (MIDNIGHT_ROLLOVER * MIDNIGHT_ROLLOVER_CHECK))
#define MIDNIGHT_ROLLOVER	864000	//number of deciseconds in a day
#define MIDNIGHT_ROLLOVER_CHECK ( GLOB.rollovercheck_last_timeofday != world.timeofday ? update_midnight_rollover() : GLOB.midnight_rollovers )

#define INFINITY	1e31	//closer then enough