/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/datum/hud
	var/mob/mymob

	var/hud_shown = 1			//Used for the HUD toggle (F12)
	var/hud_version = 1			//Current displayed version of the HUD
	var/inventory_shown = 1		//the inventory

	//special screen objects
	var/obj/screen/action_intent

	var/list/static_inventory = list()		//the screen objects which are static
	var/list/toggleable_inventory = list()	//the screen objects which can be hidden
	var/list/hotkeybuttons = list()			//the buttons that can be used via hotkeys
	var/list/infodisplay = list()			//the screen objects that display mob info (health, alien plasma, etc...)
	var/list/inv_slots[slots_amt]			// /obj/screen/inventory objects, ordered by their slot ID.

/mob/proc/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/basic(src)

/datum/hud/New(mob/owner)
	mymob = owner

/datum/hud/Destroy()
	if(mymob.hud_used == src)
		mymob.hud_used = null

	if(static_inventory.len)
		for(var/thing in static_inventory)
			qdel(thing)
		static_inventory.Cut()

	inv_slots.Cut()

	if(toggleable_inventory.len)
		for(var/thing in toggleable_inventory)
			qdel(thing)
		toggleable_inventory.Cut()

	if(hotkeybuttons.len)
		for(var/thing in hotkeybuttons)
			qdel(thing)
		hotkeybuttons.Cut()

	if(infodisplay.len)
		for(var/thing in infodisplay)
			qdel(thing)
		infodisplay.Cut()

	mymob = null
	return ..()


/datum/hud/proc/show_hud(version = 0)
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0

	mymob.client.screen = list()

	var/display_hud_version = version
	if(!display_hud_version)	//If 0 or blank, display the next hud version
		display_hud_version = hud_version + 1
	if(display_hud_version > HUD_VERSIONS)	//If the requested version number is greater than the available versions, reset back to the first version
		display_hud_version = 1

	switch(display_hud_version)
		if(HUD_STYLE_STANDARD)	//Default HUD
			hud_shown = 1	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen += static_inventory
			if(toggleable_inventory.len && inventory_shown)
				mymob.client.screen += toggleable_inventory
			if(hotkeybuttons.len)
				mymob.client.screen += hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen += infodisplay

		if(HUD_STYLE_REDUCED)	//Reduced HUD
			hud_shown = 0	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				mymob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				mymob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen += infodisplay

			//These ones are a part of 'static_inventory', 'toggleable_inventory' or 'hotkeybuttons' but we want them to stay
			if(inv_slots[slot_l_hand])
				mymob.client.screen += inv_slots[slot_l_hand]	//we want the hands to be visible
			if(inv_slots[slot_r_hand])
				mymob.client.screen += inv_slots[slot_r_hand]	//we want the hands to be visible

		if(HUD_STYLE_NOHUD)	//No HUD
			hud_shown = 0	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				mymob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				mymob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen -= infodisplay

	hud_version = display_hud_version
	persistant_inventory_update()
	//mymob.update_action_buttons()
	//reorganize_alerts()
	//reload_fullscreen()

/datum/hud/proc/hidden_inventory_update()
	return

/datum/hud/proc/persistant_inventory_update()
	if(!mymob)
		return

	var/mob/M = mymob

	if(hud_shown)
		if(M.store)
			M.store.screen_loc = ui_store
			M.client.screen += M.store
	else
		if(M.store)
			M.store.screen_loc = null


	if(hud_version != HUD_STYLE_NOHUD)
		if(M.r_hand)
			M.r_hand.screen_loc = ui_rhand
			M.client.screen += M.r_hand
		if(M.l_hand)
			M.l_hand.screen_loc = ui_lhand
			M.client.screen += M.l_hand
	else
		if(M.r_hand)
			M.r_hand.screen_loc = null
		if(M.l_hand)
			M.l_hand.screen_loc = null

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = 1

	if(hud_used && client)
		hud_used.show_hud() //Shows the next hud preset
		to_chat(usr, "<span class ='info'>Switched HUD mode. Press F12 to toggle.</span>")
	else
		to_chat(usr, "<span class ='warning'>This mob type does not use a HUD.</span>")
