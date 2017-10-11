/****VV Defines****/
#define VV_NUM "Number"
#define VV_TEXT "Text"
#define VV_MESSAGE "Mutiline Text"
#define VV_ICON "Icon"
#define VV_ATOM_REFERENCE "Atom Reference"
#define VV_DATUM_REFERENCE "Datum Reference"
#define VV_MOB_REFERENCE "Mob Reference"
#define VV_CLIENT "Client"
#define VV_ATOM_TYPE "Atom Typepath"
#define VV_DATUM_TYPE "Datum Typepath"
#define VV_TYPE "Custom Typepath"
#define VV_MATRIX "Matrix"
#define VV_FILE "File"
#define VV_LIST "List"
#define VV_NEW_ATOM "New Atom"
#define VV_NEW_DATUM "New Datum"
#define VV_NEW_TYPE "New Custom Typepath"
#define VV_NEW_LIST "New List"
#define VV_NULL "NULL"
#define VV_RESTORE_DEFAULT "Restore to Default"
#define VV_MARKED_DATUM "Marked Datum"
/******************/
/******TYPEIDS*****/
//Byond type ids
#define TYPEID_NULL "0"
#define TYPEID_NORMAL_LIST "f"
//helper macros
#define GET_TYPEID(ref) ( ( (lentext(ref) <= 10) ? "TYPEID_NULL" : copytext(ref, 4, lentext(ref) - 6) ) )
#define IS_NORMAL_LIST(L) (GET_TYPEID("\ref[L]") == TYPEID_NORMAL_LIST)
/******************/
/***FANCY TYPES****/
/proc/pick_closest_path(value, list/matches = get_fancy_list_of_atom_types())
	if(value == FALSE) //nothing should be calling us with a number, so this is safe
		value = input("Enter type to find (blank for all, cancel to cancel)", "Search for type") as null|text
		if(isnull(value))
			return
	value = trim(value)
	if(!isnull(value) && value != "")
		matches = filter_fancy_list(matches, value)

	if(matches.len == 0)
		return

	var/chosen
	if(matches.len == 1)
		chosen = matches[1]
	else
		chosen = input("Select a type", "Pick Type", matches[1]) as null|anything in matches
		if(!chosen)
			return
	chosen = matches[chosen]
	return chosen

/proc/make_types_fancy(var/list/types)
	if(ispath(types))
		types = list(types)
	. = list()
	for(var/type in types)
		var/typename = "[type]"
		var/static/list/TYPES_SHORTCUTS = list(
			/obj/item = "ITEM",
			/obj = "O",
			/datum = "D",
			/turf/wall = "WALL",
			/turf = "T",
			/mob = "M"
		)
		for(var/tn in TYPES_SHORTCUTS)
			if(copytext(typename, 1, length("[tn]/") + 1) == "[tn]/")
				typename = TYPES_SHORTCUTS[tn]+copytext(typename,length("[tn]/"))
				break
		.[typename] = type


/proc/get_fancy_list_of_atom_types()
	var/static/list/pre_generated_list
	if(!pre_generated_list) //init
		pre_generated_list = make_types_fancy(typesof(/atom))
	return pre_generated_list


/proc/get_fancy_list_of_datum_types()
	var/static/list/pre_generated_list
	if(!pre_generated_list) //init
		pre_generated_list = make_types_fancy(sortList(typesof(/datum) - typesof(/atom)))
	return pre_generated_list


/proc/filter_fancy_list(list/L, filter as text)
	var/list/matches = new
	for(var/key in L)
		var/value = L[key]
		if(findtext("[key]", filter) || findtext("[value]", filter))
			matches[key] = value
	return matches
/******************/
/****type2type*****/
//Argument: Give this a space-separated string consisting of 6 numbers. Returns null if you don't
/proc/text2matrix(var/matrixtext)
	var/list/matrixtext_list = splittext(matrixtext, " ")
	var/list/matrix_list = list()
	for(var/item in matrixtext_list)
		var/entry = text2num(item)
		if(entry == null)
			return null
		matrix_list += entry
	if(matrix_list.len < 6)
		return null
	var/a = matrix_list[1]
	var/b = matrix_list[2]
	var/c = matrix_list[3]
	var/d = matrix_list[4]
	var/e = matrix_list[5]
	var/f = matrix_list[6]
	return matrix(a, b, c, d, e, f)



//This is a weird one:
//It returns a list of all var names found in the string
//These vars must be in the [var_name] format
//It's only a proc because it's used in more than one place

//Takes a string and a datum
//The string is well, obviously the string being checked
//The datum is used as a source for var names, to check validity
//Otherwise every single word could technically be a variable!
/proc/string2listofvars(var/t_string, var/datum/var_source)
	if(!t_string || !var_source)
		return list()

	. = list()

	var/var_found = findtext(t_string, "\[") //Not the actual variables, just a generic "should we even bother" check
	if(var_found)
		//Find var names

		// "A dog said hi [name]!"
		// splittext() --> list("A dog said hi ","name]!"
		// jointext() --> "A dog said hi name]!"
		// splittext() --> list("A","dog","said","hi","name]!")

		t_string = replacetext(t_string, "\[", "\[ ")//Necessary to resolve "word[var_name]" scenarios
		var/list/list_value = splittext(t_string, "\[")
		var/intermediate_stage = jointext(list_value, null)

		list_value = splittext(intermediate_stage, " ")
		for(var/value in list_value)
			if(findtext(value, "]"))
				value = splittext(value, "]") //"name]!" --> list("name","!")
				for(var/A in value)
					if(var_source.vars.Find(A))
						. += A

/******************/

/datum
	var/var_edited = FALSE

/datum/proc/can_vv_get(var_name)
	return TRUE

/datum/proc/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("vars")
			return FALSE
		if("var_edited")
			return FALSE
	var_edited = TRUE
	vars[var_name] = var_value
	return TRUE

/datum/proc/vv_get_var(var_name)
	switch(var_name)
		if("vars")
			return debug_variable(var_name, list(), 0, src)
	return debug_variable(var_name, vars[var_name], 0, src)

/datum/proc/vv_get_dropdown()
	. = list()
	. += "---"
	.["Call Proc"] = "?_src_=vars;proc_call=\ref[src]"
	.["Mark Object"] = "?_src_=vars;mark_object=\ref[src]"
	.["Jump to Object"] = "?_src_=vars;jump_to=\ref[src]"
	.["Delete"] = "?_src_=vars;delete=\ref[src]"
	. += "---"

/client/var/datum/marked_datum = null
/client/proc/debug_variables(datum/D in world)
	set category = "Debug Verbs"
	set name = "View Variables"

	var/static/cookieoffset = rand(1, 9999) // force cookies to reset after round restart

	if(!D)
		return

	var/islist = islist(D)
	if(!islist && !istype(D))
		return

	var/title = ""
	var/refid = "\ref[D]"
	var/icon/sprite
	var/hash

	var/type = /list
	if(!islist)
		type = D.type

	if(istype(D, /atom))
		var/atom/A = D
		if(A.icon && A.icon_state)
			sprite = new /icon(A.icon, A.icon_state)
			hash = md5(A.icon)
			hash = md5(hash + A.icon_state)
			src << browse_rsc(sprite, "vv[hash].png")

	title = "[D] (\ref[D]) = [type]"

	var/sprite_text
	if(sprite)
		sprite_text = "<img src='vv[hash].png'>"

	var/list/atomsnowflake = list()
	if(istype(D, /atom))
		var/atom/A = D
		if(ismob(A))
			atomsnowflake += "<a href='?_src_=vars;rename=[refid]'><b>[D]</b></a>"

		if(A.dir)
			atomsnowflake += "<br><font size='1'><a href='?_src_=vars;rotatedatum=[refid];rotatedir=left'><<</a> <a href='?_src_=vars;datumedit=[refid];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='?_src_=vars;rotatedatum=[refid];rotatedir=right'>>></a></font>"


	var/formatted_type = "[type]"
	if(length(formatted_type) > 25)
		var/middle_point = length(formatted_type) / 2
		var/splitpoint = findtext(formatted_type, "/", middle_point)
		if(splitpoint)
			formatted_type = "[copytext(formatted_type,1,splitpoint)]<br>[copytext(formatted_type,splitpoint)]"
		else
			formatted_type = "Type too long" //No suitable splitpoint (/) found.

	var/marked
	if(marked_datum && marked_datum == D)
		marked = "<br><font size='1' color='red'><b>Marked Object</b></font>"

	var/varedited_line = ""
	if(!islist && D.var_edited)
		varedited_line = "<br><font size='1' color='red'><b>Var Edited</b></font>"

	var/list/dropdownoptions = list()
	if(islist)
		dropdownoptions = list(
			"---",
			"Add Item" = "?_src_=vars;listadd=[refid]",
			"Remove Nulls" = "?_src_=vars;listnulls=[refid]",
			"Remove Dupes" = "?_src_=vars;listdupes=[refid]",
			"Set len" = "?_src_=vars;listlen=[refid]",
			"Shuffle" = "?_src_=vars;listshuffle=[refid]"
			)
	else
		dropdownoptions = D.vv_get_dropdown()

	var/list/dropdownoptions_html = list()

	for(var/name in dropdownoptions)
		var/link = dropdownoptions[name]
		if(link)
			dropdownoptions_html += "<option value='[link]'>[name]</option>"
		else
			dropdownoptions_html += "<option value>[name]</option>"


	var/list/names = list()
	if(!islist)
		for(var/V in D.vars)
			names += V

	sleep(1)//For some reason, without this sleep, VVing will cause client to disconnect on certain objects.

	var/list/variable_html = list()
	if(islist)
		var/list/L = D
		for(var/i in 1 to L.len)
			var/key = L[i]
			var/value
			if(IS_NORMAL_LIST(L) && !isnum(key))
				value = L[key]
			variable_html += debug_variable(i, value, 0, D)
	else
		names = sortList(names)
		for(var/V in names)
			if(D.can_vv_get(V))
				variable_html += D.vv_get_var(V)


	var/html = {"
<html>
	<head>
		<title>[title]</title>
		<style>
			body {
				font-family: Verdana, sans-serif;
				font-size: 9pt;
			}
			.value {
				font-family: "Courier New", monospace;
				font-size: 8pt;
			}
		</style>
	</head>
	<body onload='selectTextField(); updateSearch()' onkeydown='return checkreload()' onkeyup='updateSearch()'>
		<script type="text/javascript">
			function checkreload() {
				if(event.keyCode == 116){	//F5 (to refresh properly)
					document.getElementById("refresh_link").click();
					event.preventDefault ? event.preventDefault() : (event.returnValue = false)
					return false;
				}
				return true;
			}
			function updateSearch(){
				var filter_text = document.getElementById('filter');
				var filter = filter_text.value.toLowerCase();
				if(event.keyCode == 13){	//Enter / return
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for ( var i = 0; i < lis.length; ++i )
					{
						try{
							var li = lis\[i\];
							if ( li.style.backgroundColor == "#ffee88" )
							{
								alist = lis\[i\].getElementsByTagName("a")
								if(alist.length > 0){
									location.href=alist\[0\].href;
								}
							}
						}catch(err) {   }
					}
					return
				}
				if(event.keyCode == 38){	//Up arrow
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for ( var i = 0; i < lis.length; ++i )
					{
						try{
							var li = lis\[i\];
							if ( li.style.backgroundColor == "#ffee88" )
							{
								if( (i-1) >= 0){
									var li_new = lis\[i-1\];
									li.style.backgroundColor = "white";
									li_new.style.backgroundColor = "#ffee88";
									return
								}
							}
						}catch(err) {  }
					}
					return
				}
				if(event.keyCode == 40){	//Down arrow
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for ( var i = 0; i < lis.length; ++i )
					{
						try{
							var li = lis\[i\];
							if ( li.style.backgroundColor == "#ffee88" )
							{
								if( (i+1) < lis.length){
									var li_new = lis\[i+1\];
									li.style.backgroundColor = "white";
									li_new.style.backgroundColor = "#ffee88";
									return
								}
							}
						}catch(err) {  }
					}
					return
				}
				//This part here resets everything to how it was at the start so the filter is applied to the complete list. Screw efficiency, it's client-side anyway and it only looks through 200 or so variables at maximum anyway (mobs).
				if(complete_list != null && complete_list != ""){
					var vars_ol1 = document.getElementById("vars");
					vars_ol1.innerHTML = complete_list
				}
				document.cookie="[refid][cookieoffset]search="+encodeURIComponent(filter);
				if(filter == ""){
					return;
				}else{
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for ( var i = 0; i < lis.length; ++i )
					{
						try{
							var li = lis\[i\];
							if ( li.innerText.toLowerCase().indexOf(filter) == -1 )
							{
								vars_ol.removeChild(li);
								i--;
							}
						}catch(err) {   }
					}
				}
				var lis_new = vars_ol.getElementsByTagName("li");
				for ( var j = 0; j < lis_new.length; ++j )
				{
					var li1 = lis\[j\];
					if (j == 0){
						li1.style.backgroundColor = "#ffee88";
					}else{
						li1.style.backgroundColor = "white";
					}
				}
			}
			function selectTextField() {
				var filter_text = document.getElementById('filter');
				filter_text.focus();
				filter_text.select();
				var lastsearch = getCookie("[refid][cookieoffset]search");
				if (lastsearch) {
					filter_text.value = lastsearch;
					updateSearch();
				}
			}
			function loadPage(list) {
				if(list.options\[list.selectedIndex\].value == ""){
					return;
				}
				location.href=list.options\[list.selectedIndex\].value;
			}
			function getCookie(cname) {
				var name = cname + "=";
				var ca = document.cookie.split(';');
				for(var i=0; i<ca.length; i++) {
					var c = ca\[i\];
					while (c.charAt(0)==' ') c = c.substring(1,c.length);
					if (c.indexOf(name)==0) return c.substring(name.length,c.length);
				}
				return "";
			}
		</script>
		<div align='center'>
			<table width='100%'>
				<tr>
					<td width='50%'>
						<table align='center' width='100%'>
							<tr>
								<td>
									[sprite_text]
									<div align='center'>
										[atomsnowflake.Join()]
									</div>
								</td>
							</tr>
						</table>
						<div align='center'>
							<b><font size='1'>[formatted_type]</font></b>
							[marked]
							[varedited_line]
						</div>
					</td>
					<td width='50%'>
						<div align='center'>
							<a id='refresh_link' href='?_src_=vars;datumrefresh=[refid]'>Refresh</a>
							<form>
								<select name="file" size="1"
									onchange="loadPage(this.form.elements\[0\])"
									target="_parent._top"
									onmouseclick="this.focus()"
									style="background-color:#ffffff">
									<option value selected>Select option</option>
									[dropdownoptions_html.Join()]
								</select>
							</form>
						</div>
					</td>
				</tr>
			</table>
		</div>
		<hr>
		<font size='1'>
			<b>E</b> - Edit, tries to determine the variable type by itself.<br>
			<b>C</b> - Change, asks you for the var type first.<br>
			<b>M</b> - Mass modify: changes this variable for all objects of this type.<br>
		</font>
		<hr>
		<table width='100%'>
			<tr>
				<td width='20%'>
					<div align='center'>
						<b>Search:</b>
					</div>
				</td>
				<td width='80%'>
					<input type='text' id='filter' name='filter_text' value='' style='width:100%;'>
				</td>
			</tr>
		</table>
		<hr>
		<ol id='vars'>
			[variable_html.Join()]
		</ol>
		<script type='text/javascript'>
			var vars_ol = document.getElementById("vars");
			var complete_list = vars_ol.innerHTML;
		</script>
	</body>
</html>
"}
	src << browse(html, "window=variables[refid];size=475x650")


#define VV_HTML_ENCODE(thing) ( sanitize ? html_encode(thing) : thing )
/proc/debug_variable(name, value, level, datum/DA = null, sanitize = TRUE)
	var/header
	if(DA)
		if(islist(DA))
			var/index = name
			if(value)
				name = DA[name] //name is really index until this line
			else
				value = DA[name]
			header =  "<li style='backgroundColor:white'>(<a href='?_src_=vars;listedit=\ref[DA];index=[index]'>E</a>) (<a href='?_src_=vars;listchange=\ref[DA];index=[index]'>C</a>) (<a href='?_src_=vars;listremove=\ref[DA];index=[index]'>-</a>) "
		else
			header = "<li style='backgroundColor:white'>(<a href='?_src_=vars;datumedit=\ref[DA];varnameedit=[name]'>E</a>) (<a href='?_src_=vars;datumchange=\ref[DA];varnamechange=[name]'>C</a>) (<a href='?_src_=vars;datummass=\ref[DA];varnamemass=[name]'>M</a>) "
	else
		header = "<li>"

	var/item
	if(isnull(value))
		item = "[VV_HTML_ENCODE(name)] = <span class='value'>null</span>"

	else if(istext(value))
		item = "[VV_HTML_ENCODE(name)] = <span class='value'>\"[VV_HTML_ENCODE(value)]\"</span>"

	else if(isicon(value))
		#ifdef VARSICON
		var/icon/I = new/icon(value)
		var/rnd = rand(1,10000)
		var/rname = "tmp\ref[I][rnd].png"
		usr << browse_rsc(I, rname)
		item = "[VV_HTML_ENCODE(name)] = (<span class='value'>[value]</span>) <img class=icon src=\"[rname]\">"
		#else
		item = "[VV_HTML_ENCODE(name)] = /icon (<span class='value'>[value]</span>)"
		#endif

	else if(isfile(value))
		item = "[VV_HTML_ENCODE(name)] = <span class='value'>'[value]'</span>"

	else if(istype(value, /datum))
		var/datum/D = value
		if("[D]" != "[D.type]") //if the thing has a name var, let's use it
			item = "<a href='?_src_=vars;Vars=\ref[value]'>[VV_HTML_ENCODE(name)] \ref[value]</a> = [D] [D.type]"
		else
			item = "<a href='?_src_=vars;Vars=\ref[value]'>[VV_HTML_ENCODE(name)] \ref[value]</a> = [D.type]"

	else if(islist(value))
		var/list/L = value
		var/list/items = list()

		if (L.len > 0 && !(name == "underlays" || name == "overlays" || name == "vars" || L.len > (IS_NORMAL_LIST(L) ? 50 : 250)))
			for(var/i in 1 to L.len)
				var/key = L[i]
				var/val
				if(IS_NORMAL_LIST(L) && !isnum(key))
					val = L[key]
				if(!val)
					val = key
					key = i

				items += debug_variable(key, val, level + 1, sanitize = sanitize)

			item = "<a href='?_src_=vars;Vars=\ref[value]'>[VV_HTML_ENCODE(name)] = /list ([L.len])</a><ul>[items.Join()]</ul>"
		else
			item = "<a href='?_src_=vars;Vars=\ref[value]'>[VV_HTML_ENCODE(name)] = /list ([L.len])</a>"

	else
		item = "[VV_HTML_ENCODE(name)] = <span class='value'>[VV_HTML_ENCODE(value)]</span>"

	return "[header][item]</li>"

#undef VV_HTML_ENCODE

/client/proc/view_var_Topic(href, href_list, hsrc)
	if(usr.client != src)
		return

	if(href_list["Vars"])
		debug_variables(locate(href_list["Vars"]))

	else if(href_list["rename"])
		var/mob/M = locate(href_list["rename"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/new_name = input(usr,"What would you like to name this mob?","Input a name",M.name,36)
		if( !new_name || !M )	return

		M.name = new_name
		href_list["datumrefresh"] = href_list["rename"]

	else if(href_list["varnameedit"] && href_list["datumedit"])
		var/D = locate(href_list["datumedit"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return

		modify_variables(D, href_list["varnameedit"], 1)

	else if(href_list["varnamechange"] && href_list["datumchange"])

		var/D = locate(href_list["datumchange"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return

		modify_variables(D, href_list["varnamechange"], 0)

	else if(href_list["delall"])
		var/obj/O = locate(href_list["delall"])
		if(!isobj(O))
			to_chat(usr, "This can only be used on instances of type /obj")
			return

		var/action_type = alert("Strict type ([O.type]) or type and all subtypes?",,"Strict type","Type and subtypes","Cancel")
		if(action_type == "Cancel" || !action_type)
			return

		if(alert("Are you really sure you want to delete all objects of type [O.type]?",,"Yes","No") != "Yes")
			return

		if(alert("Second confirmation required. Delete?",,"Yes","No") != "Yes")
			return

		var/O_type = O.type
		switch(action_type)
			if("Strict type")
				var/i = 0
				for(var/obj/Obj in world)
					if(Obj.type == O_type)
						i++
						del(Obj)
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
			if("Type and subtypes")
				var/i = 0
				for(var/obj/Obj in world)
					if(istype(Obj,O_type))
						i++
						del(Obj)
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return

	else if(href_list["rotatedatum"])
		var/atom/A = locate(href_list["rotatedatum"])
		if(!istype(A))
			to_chat(usr, "This can only be done to instances of type /atom")
			return

		switch(href_list["rotatedir"])
			if("right")	A.dir = turn(A.dir, -45)
			if("left")	A.dir = turn(A.dir, 45)
		href_list["datumrefresh"] = href_list["rotatedatum"]

	else if(href_list["mark_object"])
		var/datum/D = locate(href_list["mark_object"])
		if(!istype(D))
			to_chat(usr, "This can only be done to instances of type /datum")
			return

		marked_datum = D
		href_list["datumrefresh"] = href_list["mark_object"]

	else if(href_list["proc_call"])
		var/T = locate(href_list["proc_call"])

		if(T)
			callproc_datum(T)

	else if(href_list["delete"])
		var/datum/D = locate(href_list["delete"])
		if(!D)
			to_chat(usr, "Unable to locate item!")
		qdel(D)
		href_list["datumrefresh"] = href_list["delete"]

	// Lists
	else if(href_list["listedit"] && href_list["index"])
		var/index = text2num(href_list["index"])
		if(!index)
			return

		var/list/L = locate(href_list["listedit"])
		if (!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return

		mod_list(L, null, "list", "contents", index, autodetect_class = TRUE)

	else if(href_list["listchange"] && href_list["index"])
		var/index = text2num(href_list["index"])
		if (!index)
			return

		var/list/L = locate(href_list["listchange"])
		if (!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return

		mod_list(L, null, "list", "contents", index, autodetect_class = FALSE)

	else if(href_list["listremove"] && href_list["index"])
		var/index = text2num(href_list["index"])
		if (!index)
			return

		var/list/L = locate(href_list["listremove"])
		if (!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return

		var/variable = L[index]
		var/prompt = alert("Do you want to remove item number [index] from list?", "Confirm", "Yes", "No")
		if (prompt != "Yes")
			return
		L.Cut(index, index+1)
		log_world("### ListVarEdit by [src]: /list's contents: REMOVED=[html_encode("[variable]")]")

	else if(href_list["listadd"])
		var/list/L = locate(href_list["listadd"])
		if (!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return

		mod_list_add(L, null, "list", "contents")

	else if(href_list["listdupes"])
		var/list/L = locate(href_list["listdupes"])
		if (!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return

		uniqueList_inplace(L)
		log_world("### ListVarEdit by [src]: /list contents: CLEAR DUPES")

	else if(href_list["listnulls"])
		var/list/L = locate(href_list["listnulls"])
		if (!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return

		listclearnulls(L)
		log_world("### ListVarEdit by [src]: /list contents: CLEAR NULLS")

	else if(href_list["listlen"])
		var/list/L = locate(href_list["listlen"])
		if (!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return
		var/value = vv_get_value(VV_NUM)
		if (value["class"] != VV_NUM)
			return

		L.len = value["value"]
		log_world("### ListVarEdit by [src]: /list len: [L.len]")
	else if(href_list["listshuffle"])
		var/list/L = locate(href_list["listshuffle"])
		if (!istype(L))
			to_chat(usr, "This can only be used on instances of type /list")
			return

		shuffle_inplace(L)
		log_world("### ListVarEdit by [src]: /list contents: SHUFFLE")

	// This is at the bottom so the above elif can trigger it
	if(href_list["datumrefresh"])
		var/DAT = locate(href_list["datumrefresh"])
		if(!DAT)
			return
		debug_variables(DAT)


var/list/VVlocked = list("vars", "var_edited", "client", "firemut", "ishulk", "telekinesis", "xray", "ka", "virus", "viruses", "cuffed", "last_eaten", "unlock_content") // R_DEBUG
var/list/VVicon_edit_lock = list("icon", "icon_state", "overlays", "underlays", "resize") // R_EVENT | R_DEBUG
var/list/VVckey_edit = list("key", "ckey") // R_EVENT | R_DEBUG
var/list/VVpixelmovement = list("step_x", "step_y", "bound_height", "bound_width", "bound_x", "bound_y") // R_DEBUG + warning

/client/proc/vv_get_class(var_value)
	if(isnull(var_value))
		. = VV_NULL

	else if(isnum(var_value))
		. = VV_NUM

	else if(istext(var_value))
		if(findtext(var_value, "\n"))
			. = VV_MESSAGE
		else
			. = VV_TEXT

	else if(isicon(var_value))
		. = VV_ICON

	else if(ismob(var_value))
		. = VV_MOB_REFERENCE

	else if(isloc(var_value))
		. = VV_ATOM_REFERENCE

	else if(istype(var_value, /matrix))
		. = VV_MATRIX

	else if(istype(var_value,/client))
		. = VV_CLIENT

	else if(istype(var_value, /datum))
		. = VV_DATUM_REFERENCE

	else if(ispath(var_value))
		if(ispath(var_value, /atom))
			. = VV_ATOM_TYPE
		else if(ispath(var_value, /datum))
			. = VV_DATUM_TYPE
		else
			. = VV_TYPE

	else if(islist(var_value))
		. = VV_LIST

	else if(isfile(var_value))
		. = VV_FILE
	else
		. = VV_NULL


/client/proc/vv_get_value(class, default_class, current_value, list/restricted_classes, list/extra_classes, list/classes)
	. = list("class" = class, "value" = null)
	if(!class)
		if(!classes)
			classes = list(
				VV_NUM,
				VV_TEXT,
				VV_MESSAGE,
				VV_ICON,
				VV_ATOM_REFERENCE,
				VV_DATUM_REFERENCE,
				VV_MOB_REFERENCE,
				VV_CLIENT,
				VV_ATOM_TYPE,
				VV_DATUM_TYPE,
				VV_TYPE,
				VV_MATRIX,
				VV_FILE,
				VV_NEW_ATOM,
				VV_NEW_DATUM,
				VV_NEW_TYPE,
				VV_NEW_LIST,
				VV_NULL,
				VV_RESTORE_DEFAULT
				)

		if(marked_datum && !(VV_MARKED_DATUM in restricted_classes))
			classes += "[VV_MARKED_DATUM] ([marked_datum.type])"
		if(restricted_classes)
			classes -= restricted_classes

		if(extra_classes)
			classes += extra_classes

		.["class"] = input(src, "What kind of data?", "Variable Type", default_class) as null|anything in classes
		if(marked_datum && .["class"] == "[VV_MARKED_DATUM] ([marked_datum.type])")
			.["class"] = VV_MARKED_DATUM


	switch(.["class"])
		if(VV_TEXT)
			.["value"] = input("Enter new text:", "Text", current_value) as null|text
			if(.["value"] == null)
				.["class"] = null
				return
		if(VV_MESSAGE)
			.["value"] = input("Enter new text:", "Text", current_value) as null|message
			if(.["value"] == null)
				.["class"] = null
				return


		if(VV_NUM)
			.["value"] = input("Enter new number:", "Num", current_value) as null|num
			if(.["value"] == null)
				.["class"] = null
				return


		if(VV_ATOM_TYPE)
			.["value"] = pick_closest_path(FALSE)
			if(.["value"] == null)
				.["class"] = null
				return

		if(VV_DATUM_TYPE)
			.["value"] = pick_closest_path(FALSE, get_fancy_list_of_datum_types())
			if(.["value"] == null)
				.["class"] = null
				return

		if(VV_TYPE)
			var/type = current_value
			var/error = ""
			do
				type = input("Enter type:[error]", "Type", type) as null|text
				if(!type)
					break
				type = text2path(type)
				error = "\nType not found, Please try again"
			while(!type)
			if(!type)
				.["class"] = null
				return
			.["value"] = type

		if(VV_MATRIX)
			.["value"] = text2matrix(input("Enter a, b, c, d, e, and f, seperated by a space.", "Matrix", "1 0 0 0 1 0") as null|text)
			if(.["value"] == null)
				.["class"] = null
				return


		if(VV_ATOM_REFERENCE)
			var/type = pick_closest_path(FALSE)
			var/subtypes = vv_subtype_prompt(type)
			if(subtypes == null)
				.["class"] = null
				return
			var/list/things = vv_reference_list(type, subtypes)
			var/value = input("Select reference:", "Reference", current_value) as null|anything in things
			if(!value)
				.["class"] = null
				return
			.["value"] = things[value]

		if(VV_DATUM_REFERENCE)
			var/type = pick_closest_path(FALSE, get_fancy_list_of_datum_types())
			var/subtypes = vv_subtype_prompt(type)
			if(subtypes == null)
				.["class"] = null
				return
			var/list/things = vv_reference_list(type, subtypes)
			var/value = input("Select reference:", "Reference", current_value) as null|anything in things
			if(!value)
				.["class"] = null
				return
			.["value"] = things[value]

		if(VV_MOB_REFERENCE)
			var/type = pick_closest_path(FALSE, make_types_fancy(typesof(/mob)))
			var/subtypes = vv_subtype_prompt(type)
			if(subtypes == null)
				.["class"] = null
				return
			var/list/things = vv_reference_list(type, subtypes)
			var/value = input("Select reference:", "Reference", current_value) as null|anything in things
			if(!value)
				.["class"] = null
				return
			.["value"] = things[value]



		if(VV_CLIENT)
			.["value"] = input("Select reference:", "Reference", current_value) as null|anything in GLOB.clients
			if(.["value"] == null)
				.["class"] = null
				return


		if(VV_FILE)
			.["value"] = input("Pick file:", "File") as null|file
			if(.["value"] == null)
				.["class"] = null
				return


		if(VV_ICON)
			.["value"] = input("Pick icon:", "Icon") as null|icon
			if(.["value"] == null)
				.["class"] = null
				return


		if(VV_MARKED_DATUM)
			.["value"] = marked_datum
			if(.["value"] == null)
				.["class"] = null
				return

		if(VV_NEW_ATOM)
			var/type = pick_closest_path(FALSE)
			if(!type)
				.["class"] = null
				return
			.["type"] = type
			.["value"] = new type()

		if(VV_NEW_DATUM)
			var/type = pick_closest_path(FALSE, get_fancy_list_of_datum_types())
			if(!type)
				.["class"] = null
				return
			.["type"] = type
			.["value"] = new type()

		if(VV_NEW_TYPE)
			var/type = current_value
			var/error = ""
			do
				type = input("Enter type:[error]", "Type", type) as null|text
				if(!type)
					break
				type = text2path(type)
				error = "\nType not found, Please try again"
			while(!type)
			if(!type)
				.["class"] = null
				return
			.["type"] = type
			.["value"] = new type()


		if(VV_NEW_LIST)
			.["value"] = list()
			.["type"] = /list

/client/proc/vv_parse_text(O, new_var)
	if(O && findtext(new_var, "\["))
		var/process_vars = alert(usr, "\[] detected in string, process as variables?", "Process Variables?", "Yes", "No")
		if(process_vars == "Yes")
			. = string2listofvars(new_var, O)

//do they want you to include subtypes?
//FALSE = no subtypes, strict exact type pathing (or the type doesn't have subtypes)
//TRUE = Yes subtypes
//NULL = User cancelled at the prompt or invalid type given
/client/proc/vv_subtype_prompt(var/type)
	if(!ispath(type))
		return
	var/list/subtypes = subtypesof(type)
	if(!subtypes || !subtypes.len)
		return FALSE
	if(subtypes && subtypes.len)
		switch(alert("Strict object type detection?", "Type detection", "Strictly this type","This type and subtypes", "Cancel"))
			if("Strictly this type")
				return FALSE
			if("This type and subtypes")
				return TRUE
			else
				return

/client/proc/vv_reference_list(type, subtypes)
	. = list()
	var/list/types = list(type)
	if(subtypes)
		types = typesof(type)

	var/list/fancytypes = make_types_fancy(types)

	for(var/fancytype in fancytypes) //swap the assoication
		types[fancytypes[fancytype]] = fancytype

	var/things = get_all_of_type(type, subtypes)

	var/i = 0
	for(var/thing in things)
		var/datum/D = thing
		i++
		//try one of 3 methods to shorten the type text:
		//	fancy type,
		//	fancy type with the base type removed from the begaining,
		//	the type with the base type removed from the begaining
		var/fancytype = types[D.type]
		if(findtext(fancytype, types[type]))
			fancytype = copytext(fancytype, lentext(types[type])+1)
		var/shorttype = copytext("[D.type]", lentext("[type]")+1)
		if(lentext(shorttype) > lentext(fancytype))
			shorttype = fancytype
		if(!lentext(shorttype))
			shorttype = "/"

		.["[D]([shorttype])\ref[D]#[i]"] = D



/client/proc/mod_list_add_ass(atom/O) //haha
	var/list/L = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
	var/class = L["class"]
	if(!class)
		return
	var/var_value = L["value"]

	if(class == VV_TEXT || class == VV_MESSAGE)
		var/list/varsvars = vv_parse_text(O, var_value)
		for(var/V in varsvars)
			var_value = replacetext(var_value,"\[[V]]","[O.vars[V]]")

	return var_value

/client/proc/mod_list_add(list/L, atom/O, original_name, objectvar)
	var/list/LL = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
	var/class = LL["class"]
	if(!class)
		return
	var/var_value = LL["value"]

	if(class == VV_TEXT || class == VV_MESSAGE)
		var/list/varsvars = vv_parse_text(O, var_value)
		for(var/V in varsvars)
			var_value = replacetext(var_value,"\[[V]]","[O.vars[V]]")

	if(O)
		L = L.Copy()

	L += var_value

	switch(alert("Would you like to associate a value with the list entry?",,"Yes","No"))
		if("Yes")
			L[var_value] = mod_list_add_ass(O) //hehe
	if(O)
		if(!O.vv_edit_var(objectvar, L))
			to_chat(src, "Your edit was rejected by the object.")
			return
	log_world("### ListVarEdit by [src]: [(O ? O.type : "/list")] [objectvar]: ADDED=[var_value]")


/client/proc/mod_list(list/L, atom/O, original_name, objectvar, index, autodetect_class = FALSE)
	if(!istype(L, /list))
		to_chat(src, "Not a List.")
		return

	if(L.len > 1000)
		var/confirm = alert(src, "The list you're trying to edit is very long, continuing may crash the server.", "Warning", "Continue", "Abort")
		if(confirm != "Continue")
			return



	var/list/names = list()
	for(var/i in 1 to L.len)
		var/key = L[i]
		var/value
		if(IS_NORMAL_LIST(L) && !isnum(key))
			value = L[key]
		if(value == null)
			value = "null"
		names["#[i] [key] = [value]"] = i
	if(!index)
		var/variable = input("Which var?","Var") as null|anything in names + "(ADD VAR)" + "(CLEAR NULLS)" + "(CLEAR DUPES)" + "(SHUFFLE)"

		if(variable == null)
			return

		if(variable == "(ADD VAR)")
			mod_list_add(L, O, original_name, objectvar)
			return

		if(variable == "(CLEAR NULLS)")
			L = L.Copy()
			listclearnulls(L)
			if(!O.vv_edit_var(objectvar, L))
				to_chat(src, "Your edit was rejected by the object.")
				return
			log_world("### ListVarEdit by [src]: [O.type] [objectvar]: CLEAR NULLS")
			return

		if(variable == "(CLEAR DUPES)")
			L = uniqueList(L)
			if(!O.vv_edit_var(objectvar, L))
				to_chat(src, "Your edit was rejected by the object.")
				return
			log_world("### ListVarEdit by [src]: [O.type] [objectvar]: CLEAR DUPES")
			return

		if(variable == "(SHUFFLE)")
			L = shuffle(L)
			if(!O.vv_edit_var(objectvar, L))
				to_chat(src, "Your edit was rejected by the object.")
				return
			log_world("### ListVarEdit by [src]: [O.type] [objectvar]: SHUFFLE")
			return

		index = names[variable]


	var/assoc_key
	if(index == null)
		return
	var/assoc = 0
	var/prompt = alert(src, "Do you want to edit the key or it's assigned value?", "Associated List", "Key", "Assigned Value", "Cancel")
	if(prompt == "Cancel")
		return
	if(prompt == "Assigned Value")
		assoc = 1
		assoc_key = L[index]
	var/default
	var/variable
	if(assoc)
		variable = L[assoc_key]
	else
		variable = L[index]

	default = vv_get_class(variable)

	to_chat(src, "Variable appears to be <b>[uppertext(default)]</b>.")

	to_chat(src, "Variable contains: [L[index]]")

	if(default == VV_NUM)
		var/dir_text = ""
		if(dir < 0 && dir < 16)
			if(dir & 1)
				dir_text += "NORTH"
			if(dir & 2)
				dir_text += "SOUTH"
			if(dir & 4)
				dir_text += "EAST"
			if(dir & 8)
				dir_text += "WEST"

		if(dir_text)
			to_chat(src, "If a direction, direction is: [dir_text]")

	var/original_var
	if(assoc)
		original_var = L[assoc_key]
	else
		original_var = L[index]
	if(O)
		L = L.Copy()
	var/class
	if(autodetect_class)
		if(default == VV_TEXT)
			default = VV_MESSAGE
		class = default
	var/list/LL = vv_get_value(default_class = default, current_value = original_var, restricted_classes = list(VV_RESTORE_DEFAULT), extra_classes = list(VV_LIST, "DELETE FROM LIST"))
	class = LL["class"]
	if(!class)
		return
	var/new_var = LL["value"]

	if(class == VV_MESSAGE)
		class = VV_TEXT

	switch(class) //Spits a runtime error if you try to modify an entry in the contents list. Dunno how to fix it, yet.
		if(VV_LIST)
			mod_list(variable, O, original_name, objectvar)

		if("DELETE FROM LIST")
			L.Cut(index, index+1)
			if(O)
				if(!O.vv_edit_var(objectvar, L))
					to_chat(src, "Your edit was rejected by the object.")
					return
			log_world("### ListVarEdit by [src]: [O.type] [objectvar]: REMOVED=[html_encode("[original_var]")]")
			return

		if(VV_TEXT)
			var/list/varsvars = vv_parse_text(O, new_var)
			for(var/V in varsvars)
				new_var = replacetext(new_var,"\[[V]]","[O.vars[V]]")


	if(assoc)
		L[assoc_key] = new_var
	else
		L[index] = new_var
	if(O)
		if(!O.vv_edit_var(objectvar, L))
			to_chat(src, "Your edit was rejected by the object.")
			return
	log_world("### ListVarEdit by [src]: [(O ? O.type : "/list")] [objectvar]: [original_var]=[new_var]")



/client/proc/modify_variables(atom/O, param_var_name = null, autodetect_class = 0)
	var/class
	var/variable
	var/var_value

	if(param_var_name)
		if(!param_var_name in O.vars)
			to_chat(src, "A variable with this name ([param_var_name]) doesn't exist in this datum ([O])")
			return
		variable = param_var_name

	else
		var/list/names = list()
		for(var/V in O.vars)
			names += V

		names = sortList(names)

		variable = input("Which var?","Var") as null|anything in names
		if(!variable)
			return

	if(!O.can_vv_get(variable))
		return

	var_value = O.vars[variable]

	//if(variable in VVlocked)
	//if(variable in VVckey_edit)
	//if(variable in VVicon_edit_lock)
	if(variable in VVpixelmovement)
		var/prompt = alert(src, "Editing this var may irreparably break tile gliding for the rest of the round. THIS CAN'T BE UNDONE", "DANGER", "ABORT ", "Continue", " ABORT")
		if(prompt != "Continue")
			return

	var/default = vv_get_class(var_value)

	if(isnull(default))
		to_chat(src, "Unable to determine variable type.")
	else
		to_chat(src, "Variable appears to be <b>[uppertext(default)]</b>.")

	to_chat(src, "Variable contains: [var_value]")

	if(default == VV_NUM)
		var/dir_text = ""
		if(dir < 0 && dir < 16)
			if(dir & 1)
				dir_text += "NORTH"
			if(dir & 2)
				dir_text += "SOUTH"
			if(dir & 4)
				dir_text += "EAST"
			if(dir & 8)
				dir_text += "WEST"

		if(dir_text)
			to_chat(src, "If a direction, direction is: [dir_text]")

	if(autodetect_class && default != VV_NULL)
		if(default == VV_TEXT)
			default = VV_MESSAGE
		class = default

	var/list/value = vv_get_value(class, default, var_value, extra_classes = list(VV_LIST))
	class = value["class"]

	if(!class)
		return
	var/var_new = value["value"]

	if(class == VV_MESSAGE)
		class = VV_TEXT

	var/original_name = "[O]"

	switch(class)
		if(VV_LIST)
			if(!islist(var_value))
				mod_list(list(), O, original_name, variable)

			mod_list(var_value, O, original_name, variable)
			return

		if(VV_RESTORE_DEFAULT)
			var_new = initial(O.vars[variable])

		if(VV_TEXT)
			var/list/varsvars = vv_parse_text(O, var_new)
			for(var/V in varsvars)
				var_new = replacetext(var_new,"\[[V]]","[O.vars[V]]")

	if(!O.vv_edit_var(variable, var_new))
		to_chat(src, "Your edit was rejected by the object.")
		return
	log_world("### VarEdit by [src]: [O.type] [variable]=[html_encode("[var_new]")]")

/*

/client/proc/modify_variables(var/atom/O, var/param_var_name = null, var/autodetect_class = 0)
	for(var/p in forbidden_varedit_object_types)
		if( istype(O,p) )
			to_chat(usr, "<span class='warning'>It is forbidden to edit this object's variables.</span>")
			return

	if(istype(O, /client) && (param_var_name == "ckey" || param_var_name == "key"))
		to_chat(usr, "<span class='warning'>You cannot edit ckeys on client objects.</span>")
		return

	var/class
	var/variable
	var/var_value

	if(param_var_name)
		if(!param_var_name in O.vars)
			to_chat(src, "A variable with this name ([param_var_name]) doesn't exist in this atom ([O])")
			return

		variable = param_var_name

		var_value = O.vars[variable]

		if(autodetect_class)
			if(isnull(var_value))
				to_chat(usr, "Unable to determine variable type.")
				class = null
				autodetect_class = null
			else if(isnum(var_value))
				to_chat(usr, "Variable appears to be <b>NUM</b>.")
				class = "num"
				dir = 1

			else if(istext(var_value))
				to_chat(usr, "Variable appears to be <b>TEXT</b>.")
				class = "text"

			else if(isloc(var_value))
				to_chat(usr, "Variable appears to be <b>REFERENCE</b>.")
				class = "reference"

			else if(isicon(var_value))
				to_chat(usr, "Variable appears to be <b>ICON</b>.")
				var_value = "\icon[var_value]"
				class = "icon"

			else if(istype(var_value,/atom) || istype(var_value,/datum))
				to_chat(usr, "Variable appears to be <b>TYPE</b>.")
				class = "type"

			else if(istype(var_value,/list))
				to_chat(usr, "Variable appears to be <b>LIST</b>.")
				class = "list"

			else if(istype(var_value,/client))
				to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
				class = "cancel"

			else
				to_chat(usr, "Variable appears to be <b>FILE</b>.")
				class = "file"

	else

		var/list/names = list()
		for (var/V in O.vars)
			names += V

		names = sortList(names)

		variable = input("Which var?","Var") as null|anything in names
		if(!variable)	return
		var_value = O.vars[variable]

	if(!autodetect_class)

		var/dir
		var/default
		if(isnull(var_value))
			to_chat(usr, "Unable to determine variable type.")

		else if(isnum(var_value))
			to_chat(usr, "Variable appears to be <b>NUM</b>.")
			default = "num"
			dir = 1

		else if(istext(var_value))
			to_chat(usr, "Variable appears to be <b>TEXT</b>.")
			default = "text"

		else if(isloc(var_value))
			to_chat(usr, "Variable appears to be <b>REFERENCE</b>.")
			default = "reference"

		else if(isicon(var_value))
			to_chat(usr, "Variable appears to be <b>ICON</b>.")
			var_value = "\icon[var_value]"
			default = "icon"

		else if(istype(var_value,/atom) || istype(var_value,/datum))
			to_chat(usr, "Variable appears to be <b>TYPE</b>.")
			default = "type"

		else if(istype(var_value,/list))
			to_chat(usr, "Variable appears to be <b>LIST</b>.")
			default = "list"

		else if(istype(var_value,/client))
			to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
			default = "cancel"

		else
			to_chat(usr, "Variable appears to be <b>FILE</b>.")
			default = "file"

		to_chat(usr, "Variable contains: [var_value]")
		if(dir)
			switch(var_value)
				if(1)
					dir = "NORTH"
				if(2)
					dir = "SOUTH"
				if(4)
					dir = "EAST"
				if(8)
					dir = "WEST"
				if(5)
					dir = "NORTHEAST"
				if(6)
					dir = "SOUTHEAST"
				if(9)
					dir = "NORTHWEST"
				if(10)
					dir = "SOUTHWEST"
				else
					dir = null
			if(dir)
				to_chat(usr, "If a direction, direction is: [dir]")

		if(marked_datum)
			class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
				"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default","marked datum ([marked_datum.type])")
		else
			class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
				"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default")

		if(!class)
			return

	if(marked_datum && class == "marked datum ([marked_datum.type])")
		class = "marked datum"

	switch(class)

		if("list")
			if(variable=="color")
				var/list/color_default_matrix = list(1, 0, 0,
													 0, 1, 0,
													 0, 0, 1)
				O.vars[variable] = color_default_matrix
			mod_list(O.vars[variable])
			return

		if("restore to default")
			O.vars[variable] = initial(O.vars[variable])

		if("edit referenced object")
			return .(O.vars[variable])

		if("text")
			if(variable == "light_color")
				var/var_new = input("Enter new text:","Text",O.vars[variable]) as null|message
				if(var_new==null) return
				O.set_light(l_color = var_new)
			else
				var/var_new = input("Enter new text:","Text",O.vars[variable]) as null|message
				if(var_new==null) return
				O.vars[variable] = var_new

		if("num")
			if(variable=="light_range")
				var/var_new = input("Enter new number:","Num",O.vars[variable]) as null|num
				if(var_new == null) return
				O.set_light(var_new)

			else if(variable=="light_power")
				var/var_new = input("Enter new number:","Num",O.vars[variable]) as null|num
				if(var_new == null) return
				O.set_light(l_power = var_new)

			else
				var/var_new =  input("Enter new number:","Num",O.vars[variable]) as null|num
				if(var_new==null) return
				O.vars[variable] = var_new

		if("type")
			var/var_new = input("Enter type:","Type",O.vars[variable]) as null|anything in typesof(/obj,/mob,/area,/turf)
			if(var_new==null) return
			O.vars[variable] = var_new

		if("reference")
			var/var_new = input("Select reference:","Reference",O.vars[variable]) as null|mob|obj|turf|area in world
			if(var_new==null) return
			O.vars[variable] = var_new

		if("mob reference")
			var/var_new = input("Select reference:","Reference",O.vars[variable]) as null|mob in world
			if(var_new==null) return
			O.vars[variable] = var_new

		if("file")
			var/var_new = input("Pick file:","File",O.vars[variable]) as null|file
			if(var_new==null) return
			O.vars[variable] = var_new

		if("icon")
			var/var_new = input("Pick icon:","Icon",O.vars[variable]) as null|icon
			if(var_new==null) return
			O.vars[variable] = var_new

		if("marked datum")
			O.vars[variable] = marked_datum

	world.log << "### VarEdit by [src]: [O.type] [variable]=[html_encode("[O.vars[variable]]")]"
*/


/proc/get_all_of_type(var/T, subtypes = TRUE)
	var/list/typecache = list()
	typecache[T] = 1
	if(subtypes)
		typecache = typecacheof(typecache)
	. = list()
	if(ispath(T, /mob))
		for(var/mob/thing in mob_list)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else if(ispath(T, /obj))
		for(var/obj/thing in world)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else if(ispath(T, /atom/movable))
		for(var/atom/movable/thing in world)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else if(ispath(T, /turf))
		for(var/turf/thing in world)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else if(ispath(T, /atom))
		for(var/atom/thing in world)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else if(ispath(T, /client))
		for(var/client/thing in GLOB.clients)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else if(ispath(T, /datum))
		for(var/datum/thing)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else
		for(var/datum/thing in world)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK