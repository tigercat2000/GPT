//DEFINITIONS FOR ASSET DATUMS START HERE.
/datum/asset/simple/tgui_common
	keep_local_name = TRUE
	assets = list(
		"tgui-common.bundle.js" = 'tgui/public/tgui-common.bundle.js',
	)

/datum/asset/simple/tgui
	keep_local_name = TRUE
	assets = list(
		"tgui.bundle.js" = 'tgui/public/tgui.bundle.js',
		"tgui.bundle.css" = 'tgui/public/tgui.bundle.css',
	)

/datum/asset/simple/tgui_panel
	keep_local_name = TRUE
	assets = list(
		"tgui-panel.bundle.js" = 'tgui/public/tgui-panel.bundle.js',
		"tgui-panel.bundle.css" = 'tgui/public/tgui-panel.bundle.css',
	)

/datum/asset/simple/jquery
	legacy = TRUE
	assets = list(
		"jquery.min.js" = 'html/jquery.min.js',
	)

/datum/asset/simple/namespaced/fontawesome
	assets = list(
		"fa-regular-400.eot"  = 'html/font-awesome/webfonts/fa-regular-400.eot',
		"fa-regular-400.woff" = 'html/font-awesome/webfonts/fa-regular-400.woff',
		"fa-solid-900.eot"    = 'html/font-awesome/webfonts/fa-solid-900.eot',
		"fa-solid-900.woff"   = 'html/font-awesome/webfonts/fa-solid-900.woff',
		"v4shim.css"          = 'html/font-awesome/css/v4-shims.min.css'
	)
	parents = list("font-awesome.css" = 'html/font-awesome/css/all.min.css')

/datum/asset/simple/namespaced/tgfont
	assets = list(
		"tgfont.eot" = 'tgui/packages/tgfont/dist/tgfont.eot',
		"tgfont.woff2" = 'tgui/packages/tgfont/dist/tgfont.woff2',
	)
	parents = list("tgfont.css" = 'tgui/packages/tgfont/dist/tgfont.css')

/datum/asset/spritesheet/chat
	name = "chat"

/datum/asset/spritesheet/chat/register()
	// InsertAll("emoji", 'icons/emoji.dmi')
	// // pre-loading all lanugage icons also helps to avoid meta
	// InsertAll("language", 'icons/misc/language.dmi')
	// // catch languages which are pulling icons from another file
	// for(var/path in typesof(/datum/language))
	// 	var/datum/language/L = path
	// 	var/icon = initial(L.icon)
	// 	if (icon != 'icons/misc/language.dmi')
	// 		var/icon_state = initial(L.icon_state)
	// 		Insert("language-[icon_state]", icon, icon_state=icon_state)
	..()