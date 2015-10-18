/datum/hud/proc/basic_hud()
	adding = list()
	other = list()

	var/obj/screen/using

	using = new /obj/screen/speed()
	adding += using

	using = new /obj/screen/storage()
	adding += using

	using = new /obj/screen/drop()
	adding += using

	mymob.client.screen = list()
	mymob.client.screen += adding