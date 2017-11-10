#define ui_rhand	"CENTER:-16,SOUTH:5"
#define ui_lhand	"CENTER: 14,SOUTH:5"
#define ui_store	"CENTER + 2,SOUTH:5"
#define ui_w_uniform	"WEST + 1,SOUTH + 1:5"
#define ui_w_shoes	"WEST + 1,SOUTH:5"
#define ui_drop		"CENTER + 1:12,SOUTH:5"
#define ui_mov_sel	"EAST:-5,SOUTH:5"


//HUD styles. Please ensure HUD_VERSIONS is the same as the maximum index. Index order defines how they are cycled in F12.
#define HUD_STYLE_STANDARD 1
#define HUD_STYLE_REDUCED 2
#define HUD_STYLE_NOHUD 3


#define HUD_VERSIONS 3	//used in show_hud()
//1 = standard hud
//2 = reduced hud (just hands and intent switcher)
//3 = no hud (for screenshots)

#define INV_UPDATE_SHOW(slot, uislot) \
if(M.##slot){M.##slot.screen_loc = ##uislot;\
	M.client.screen += M.##slot;};

#define INV_UPDATE_HIDE(slot) \
if(M.##slot){M.##slot.screen_loc = null;};