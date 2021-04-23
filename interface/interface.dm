/client/verb/toggle_focus()
	set name = ".toggle focus"
	set hidden = 1

	if(winget(usr, "outputwindow.input", "focus") == "true")
		winset(usr, "mapwindow.map", "focus=true")
	else
		winset(usr, "outputwindow.input", "focus=true")