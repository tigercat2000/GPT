/datum/hud
	var/mob/mymob

	var/hud_shown = 1

	var/list/adding
	var/list/other

/datum/hud/New(mob/owner)
	mymob = owner
	instantiate()

/datum/hud/proc/instantiate()
	if(!ismob(mymob)) return 0
	if(!mymob.client) return 0

	basic_hud()


/mob/verb/button_pressed_F12(var/full = 0 as null)
	set name = "F12"
	set hidden = 1

	if(hud_used)
		hud_used.toggle_hud_hidden(src)

/datum/hud/proc/toggle_hud_hidden(mob/M)
	if(hud_shown)
		hud_shown = 0
		if(adding)
			M.client.screen -= adding
		if(other)
			M.client.screen -= other

	else
		hud_shown = 1
		if(adding)
			M.client.screen += adding
		if(other)
			M.client.screen += other