#define FOR_DVIEW(type, range, center, invis_flags) \
	dview_mob.loc = center; \
	dview_mob.see_invisible = invis_flags; \
	for(type in view(range, dview_mob))
#define END_FOR_DVIEW dview_mob.loc = null

#define STATUS_INTERACTIVE 2 // GREEN Visability
#define STATUS_UPDATE 1 // ORANGE Visability
#define STATUS_DISABLED 0 // RED Visability
#define STATUS_CLOSE -1 // Close the interface

#define PROCESS_KILL 26	//Used to trigger removal from a processing list

//Human Overlays Indexes/////////
#define MUTANTRACE_LAYER		1
#define TAIL_UNDERLIMBS_LAYER	2	//Tail split-rendering.
#define LIMBS_LAYER				3
#define MARKINGS_LAYER			4
#define UNDERWEAR_LAYER			5
#define MUTATIONS_LAYER			6
#define DAMAGE_LAYER			7
#define SHOES_LAYER				8
#define ID_LAYER				9
#define UNIFORM_LAYER			10
#define GLOVES_LAYER			11
#define EARS_LAYER				12
#define SUIT_LAYER				13
#define BELT_LAYER				14	//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		15
#define BACK_LAYER				16
#define HEAD_ACCESSORY_LAYER	17
#define FHAIR_LAYER				18
#define GLASSES_LAYER			19
#define HAIR_LAYER				20	//TODO: make part of head layer?
#define HEAD_ACC_OVER_LAYER		21	//Select-layer rendering.
#define FHAIR_OVER_LAYER		22	//Select-layer rendering.
#define GLASSES_OVER_LAYER		23	//Select-layer rendering.
#define TAIL_LAYER				24	//bs12 specific. this hack is probably gonna come back to haunt me
#define FACEMASK_LAYER			25
#define HEAD_LAYER				26
#define COLLAR_LAYER			27
#define HANDCUFF_LAYER			28
#define LEGCUFF_LAYER			29
#define L_HAND_LAYER			30
#define R_HAND_LAYER			31
#define TARGETED_LAYER			32	//BS12: Layer for the target overlay from weapon targeting system
#define FIRE_LAYER				33	//If you're on fire
#define TOTAL_LAYERS	33

// Filters
#define AMBIENT_OCCLUSION filter(type="drop_shadow", x=0, y=-2, size=4, border=4, color="#04080FAA")