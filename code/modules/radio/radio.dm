/datum/signal
	var/obj/source

	var/transmission_method = 0 //unused at the moment
	//0 = wire
	//1 = radio transmission
	//2 = subspace transmission

	var/list/data = list()
	var/encryption

	var/frequency = 0

/datum/signal/New(sourceobj)
	. = ..()
	source = sourceobj

/datum/signal/proc/copy_from(datum/signal/S)
	source = S.source
	transmission_method = S.transmission_method
	data = S.data.Copy()
	encryption = S.encryption
	frequency = S.frequency

/datum/signal/proc/debug_print()
	if(source)
		. = "signal = {source = '[source]' ([source.x],[source.y],[source.z])\n"
	else
		. = "signal = {source = '[source]' ()\n"
	. += json_encode(data)

/datum/signal/proc/set_field(field, field_data)
	if(field_data)
		data[field] = field_data
	else
		data[field] = null
	return TRUE

/datum/signal/proc/get_field(field)
	if(data["[field]"])
		return data["[field]"]
	return null

/datum/signal/proc/serialize()
	. = {"{"source" = "\ref[source]","}
	. += "\"data\" = [json_encode(data)]"
	. += "}"


GLOBAL_LIST_INIT(radios, list())

/datum/radio_connection
	var/obj/source

/datum/radio_connection/New(obj/S)
	source = S
	GLOB.radios += src
	. = ..()

/datum/radio_connection/proc/post(datum/signal/S)
	for(var/r in (GLOB.radios - src))
		var/datum/radio_connection/R = r
		R.recieve(S)

/datum/radio_connection/proc/recieve(datum/signal/S)
	if(!source)
		return qdel(src)
	return source.radio_recieve(S)


/obj
	var/radio_enabled = FALSE
	var/datum/radio_connection/rconn

/obj/Initialize()
	. = ..()
	if(radio_enabled)
		rconn = new(src)

/obj/proc/radio_recieve(datum/signal/S)

/obj/item/radio
	name = "generic radio"
	icon = 'icons/obj/obj.dmi'
	icon_state = "immrod"
	radio_enabled = TRUE

/obj/item/radio/transmitter
	name = "test transmit"

/obj/item/radio/transmitter/attack_self(mob/user)
	var/datum/signal/S = new(src)
	S.set_field("user", "\ref[user]")
	S.set_field("message", input(user, "enter a message"))
	to_chat(user, S.serialize())
	rconn.post(S)