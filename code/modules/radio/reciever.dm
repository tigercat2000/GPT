/obj/structure/radio_reciever
	name = "radio"
	icon_state = "safe"
	radio_enabled = TRUE
	var/datum/ntsl2_configuration/conf
	var/window_id

/obj/structure/radio_reciever/Initialize()
	. = ..()
	conf = new

/obj/structure/radio_reciever/attack_hand(mob/user)
	interact(user)

/datum/asset/simple/ntsl2
	assets = list(
		"bundle.css" = 'html/ntsl2/dist/bundle.css',
		"bundle.js" = 'html/ntsl2/dist/bundle.js',
		"tab_home.html" = 'html/ntsl2/dist/tab_home.html',
		"tab_filtering.html" = 'html/ntsl2/dist/tab_filtering.html',
		"tab_regex.html" = 'html/ntsl2/dist/tab_regex.html',
		"uiTitleFluff.png" = 'html/ntsl2/dist/uiTitleFluff.png'
	)

// Hacky. Ass. Shit.
/datum/browser/ntsl2/add_stylesheet()
	return
/datum/browser/ntsl2/get_header()
	return
/datum/browser/ntsl2/get_footer()
	var/obj/structure/radio_reciever/source = ref
	return {"
<script type="text/javascript">
window.byondSrc = "byond://?src=\ref[ref];";
window.config = [source.conf.serialize()];
window.updateConfig = function(config) { window.config = JSON.parse(config); window.reload_tab() };
</script>
"}

/datum/ntsl2_configuration
	// Toggles
	var/toggle_activated = TRUE
	var/toggle_jobs = TRUE

	// Tables
	var/list/regex = list("lol2" = "meow2")

	// Meta
	var/list/tables = list(
		"regex"
	)
	var/list/to_serialize = list(
	"toggle_activated",
	"toggle_jobs",
	"regex")

/datum/ntsl2_configuration/proc/serialize()
	var/list/all_vars = list()
	for(var/variable in to_serialize)
		all_vars[variable] = vars[variable]
	. = json_encode(all_vars)

/datum/ntsl2_configuration/proc/deserialize(text)
	var/list/var_list = json_decode(text)
	for(var/variable in var_list)
		if(variable in to_serialize) // Don't just accept any random vars jesus christ!
			vars[variable] = var_list[variable]

/datum/ntsl2_configuration/proc/modify_signal(datum/signal/S)
	if(!toggle_activated)
		return null

	var/datum/signal/newSignal = new()
	newSignal.copy_from(S)

	if(toggle_jobs)
		var/original = newSignal.get_field("message")
		var/source = newSignal.get_field("user")
		if(source)
			var/mob/M = locate(source)
			if(istype(M))
				newSignal.set_field("message", "[M] JOB: [original]")

	if(islist(regex) && length(regex) > 0)
		var/original = newSignal.get_field("message")
		var/new_message
		for(var/reg in regex)
			var/replacepattern = regex[reg]
			var/regex/start = new(reg, "g")
			new_message = start.Replace(original, replacepattern)
		newSignal.set_field("message", new_message)

	to_chat(world, newSignal.serialize())
	return newSignal


/datum/ntsl2_configuration/Topic(mob/user, href_list, window_id)
	to_chat(world, "TOPIC [json_encode(href_list)]")
	// Toggles
	if(href_list["toggle_activated"])
		toggle_activated = !toggle_activated

	if(href_list["toggle_jobs"])
		toggle_jobs = !toggle_jobs

	// Tables
	if(href_list["create_row"])
		to_chat(world, "create_row [href_list["table"]]")
		if(href_list["table"] && href_list["table"] in tables)
			var/new_key = input(user, "Provide a key for the new row.", "New Row") as text|null
			if(!new_key)
				return
			var/new_value = input(user, "Provide a new value for the key [new_key]", "New Row") as text|null
			if(new_value == null)
				return
			vars[href_list["table"]][new_key] = new_value

	if(href_list["delete_row"])
		if(href_list["table"] && href_list["table"] in tables)
			vars[href_list["table"]].Remove(href_list["delete_row"])
			to_chat(user, "Removed row [href_list["delete_row"]] from [href_list["table"]]")


	// Spit out the serialized config to the user
	if(href_list["save_config"])
		user << browse(serialize(), "window=save_ntsl2")

	if(href_list["load_config"])
		deserialize(input(user, "Provide configuration JSON below.", "Load Config", serialize()) as message)

	user << output(list2params(list(serialize())), "[window_id].browser:updateConfig")

/obj/structure/radio_reciever/interact(mob/user)
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/ntsl2)
	assets.send(user)

	var/dat = file2text("html/ntsl2/dist/index.html")
	var/datum/browser/ntsl2/popup = new(user, name, "NTSL2", 720, 480, src)
	popup.set_content(dat)
	popup.open()
	window_id = popup.window_id


/obj/structure/radio_reciever/radio_recieve(datum/signal/S)
	. = ..()
	if(!conf.toggle_activated)
		to_chat(world, "reciever disabled...")
		return
	var/datum/signal/newSignal = conf.modify_signal(S)
	to_chat(world, newSignal.get_field("message"))


/obj/structure/radio_reciever/Topic(href, href_list)
	if(..())
		return 1

	var/mob/user = usr
	if(!istype(user))
		return 0

	conf.Topic(user, href_list, window_id)