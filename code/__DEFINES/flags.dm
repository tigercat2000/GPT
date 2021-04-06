#define OVERLAY_QUEUED_f1 2

GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768))

#define NONE 0

// Obj flags
#define BEING_REMOVED 1
#define IN_INVENTORY 2
#define DROPDEL 4
#define NODROP 8

// for /datum/var/datum_flags
#define DF_USE_TAG (1<<0)
#define DF_VAR_EDITED (1<<1)
#define DF_ISPROCESSING (1<<2)
/**
 * Is this datum capable of sending signals?
 * Set when a signal has been registered.
 */
#define DF_SIGNAL_ENABLED (1<<3)