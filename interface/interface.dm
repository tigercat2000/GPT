/client/verb/toggle_focus()
	set name = ".toggle focus"
	set hidden = 1

	if(winget(usr, "mainwindow.input", "focus") == "true")
		winset(usr, "mapwindow.map", "focus=true")
	else
		winset(usr, "mainwindow.input", "focus=true")