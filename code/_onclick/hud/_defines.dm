#define ui_rhand	"CENTER:-16,SOUTH:5"
#define ui_lhand	"CENTER: 14,SOUTH:5"
#define ui_store	"CENTER + 2,SOUTH:5"
#define ui_w_uniform	"WEST + 1,SOUTH + 1:5"
#define ui_w_shoes	"WEST + 1,SOUTH:5"
#define ui_drop		"CENTER + 1:12,SOUTH:5"
#define ui_mov_sel	"EAST:-5,SOUTH:5"

#define ui_alert1 "EAST-1:28,CENTER+4:27"
#define ui_alert2 "EAST-1:28,CENTER+3:25"
#define ui_alert3 "EAST-1:28,CENTER+2:23"
#define ui_alert4 "EAST-1:28,CENTER+1:21"
#define ui_alert5 "EAST-1:28,CENTER:19"


//HUD styles. Please ensure HUD_VERSIONS is the same as the maximum index. Index order defines how they are cycled in F12.
#define HUD_STYLE_STANDARD 1
#define HUD_STYLE_REDUCED 2
#define HUD_STYLE_NOHUD 3


#define HUD_VERSIONS 3	//used in show_hud()
//1 = standard hud
//2 = reduced hud (just hands and intent switcher)
//3 = no hud (for screenshots)

#define INV_UPDATE_SHOW(invslot) \
if(##invslot && ##invslot.contained){##invslot.contained.screen_loc = ##invslot.hud_position;\
	M.client.screen += ##invslot.contained;};

#define INV_UPDATE_HIDE(invslot) \
if(##invslot && ##invslot.contained){##invslot.contained.screen_loc = null;};