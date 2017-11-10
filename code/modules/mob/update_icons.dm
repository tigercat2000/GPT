/mob/proc/update_icons()
	return

/mob/proc/update_inv_l_hand()
	if(l_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.screen_loc = ui_lhand
			client.screen += l_hand

/mob/proc/update_inv_r_hand()
	if(r_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.screen_loc = ui_rhand
			client.screen += r_hand

/mob/proc/update_inv_store()
	if(store)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			store.screen_loc = ui_store
			client.screen += store

/mob/proc/update_inv_w_uniform()
	if(w_uniform)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			w_uniform.screen_loc = ui_w_uniform
			client.screen += w_uniform

/mob/proc/update_inv_w_shoes()
	if(w_shoes)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			w_shoes.screen_loc = ui_w_shoes
			client.screen += w_shoes