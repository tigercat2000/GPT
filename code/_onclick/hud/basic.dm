/datum/hud/proc/basic_hud()
	adding = list()
	other = list()

	var/obj/screen/using

	using = new /obj/screen/speed()
	adding += using

	mymob.client.screen = list()
	mymob.client.screen += adding