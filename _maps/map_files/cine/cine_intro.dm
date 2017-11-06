var/cinematic_playing = 0

/hook/mobNewLogin/proc/__cinematic_map_trigger(mob/M)
	if(!cinematic_playing)
		spawn(1)
			show_cinematic()
	wait_for_cine_canmove(M)
	return 1


/proc/show_cinematic()
	var/syndicate_position = get_turf(locate("landmark*syndSpawn"))
	var/synd_walk = get_turf(locate("landmark*syndWalk"))
	var/scientist_position = get_turf(locate("landmark*sciSpawn"))
	var/sci_walk = get_turf(locate("landmark*sciWalk"))

	if(!syndicate_position || !scientist_position)
		world << "NO SCI/SYND SPAWN POS"
		return 0

	if(!synd_walk || !sci_walk)
		world << "NO SCI/SYND WALK POS"
		return 0

	cinematic_playing = 1

	var/ARBITRARY_CINE_DELAY = 20
	sleep(ARBITRARY_CINE_DELAY)

	var/mob/syndie/M = new(syndicate_position)
	var/mob/scientist/sci = new(scientist_position)

	var/list/players = GLOB.players.Copy()
	for(var/mob/player in players)
		if(!(player.loc in starting_pos))
			players -= player

	players -= M
	players -= sci

	if(!players.len || !M || !sci)
		world << "NO PLAYERS | NO SYND | NO SCI"
		cinematic_playing = 0
		return 0


	sleep(ARBITRARY_CINE_DELAY)
	walk_to(M, synd_walk, 0, 7)
	sleep(get_dist(syndicate_position, synd_walk) * 7)
	M.face_atom(pick(players))
	sleep(ARBITRARY_CINE_DELAY)
	M.say("Oh. Hello there.")

	sleep(ARBITRARY_CINE_DELAY)
	M.say("I see we captured [players.len==1 ? "only" : ""] [players.len] test [players.len==1 ? "subject" : "subjects"] this time.")
	sleep(ARBITRARY_CINE_DELAY)
	M.face_atom(sci)
	M.say("What [players.len==1 ? "is" : "are"] their name[players.len==1 ? "?" : "s?"]")
	sleep(ARBITRARY_CINE_DELAY)
	walk_to(sci, sci_walk, 0, 7)
	sleep(get_dist(sci, sci_walk)*7)
	sci.say("Hmm. Let's see.")
	sci.face_atom(M)
	M.face_atom(sci)
	sleep(ARBITRARY_CINE_DELAY*2)
	var/scitext = ""
	var/iterator = 0
	for(var/mob/pl in players - M)
		iterator++
		if(players.len == 1)
			scitext = "[pl.name]"
			break
		if(iterator == players.len)
			scitext += "and [pl.name]"
		else
			scitext += "[pl.name], "

	sci.say("According to my list, we have [scitext].")
	sci.face_atom(pick(players))
	M.face_atom(pick(players))
	M.allow_pissy = 1
	sleep(ARBITRARY_CINE_DELAY)
	sci.say("[players.len==1?"They":"These"] will do quite nicely, don't you think?")
	sci.face_atom(M)
	sleep(ARBITRARY_CINE_DELAY)
	var/mob/picked_player = pick(players)
	M.visible_message("<b>[M]</b> stares at [picked_player].")
	sleep(ARBITRARY_CINE_DELAY)
	M.face_atom(sci)
	if(M.pissed_at["[picked_player.name]"] && M.pissed_at["[picked_player.name]"] > 2)
		M.visible_message("<b>[M]</b> glares at [picked_player].")
		sleep(ARBITRARY_CINE_DELAY)
		M.say("If I had a choice, this one would be thrown out of an airlock.")
		sleep(ARBITRARY_CINE_DELAY)
		sci.say("You <b>don't</b> have a choice, get out of my lab.")
		sleep(ARBITRARY_CINE_DELAY)
		M.say("Hmph. Fine.")
		walk_to(M, syndicate_position, 0, 7)
		M.allow_pissy = 0
		sleep(ARBITRARY_CINE_DELAY)
		sci.face_atom(pick(players))
		sci.say("I'm sorry. The grunts are always so rude to new subjects.")
		sleep(ARBITRARY_CINE_DELAY)
		sci.say("So, any questions?...")
		sci.wait_for_input(100)
		sci.say("Okay then. Moving on.")

	else
		M.say("Mm. Yes. They will.")
		sleep(ARBITRARY_CINE_DELAY)
		M.say("Anyhow. I suppose I shall be going.")
		sleep(ARBITRARY_CINE_DELAY)
		sci.say("Alright.")
		walk_to(M, syndicate_position, 0, 7)
		M.allow_pissy = 0
		sleep(ARBITRARY_CINE_DELAY)
		sci.face_atom(pick(players))
		sci.say("So! Any questions?")
		sci.wait_for_input(100)
		sci.say("Okay then. Moving on.")

	cinematic_playing = 0

/proc/wait_for_cine_canmove(mob/M)
	while(cinematic_playing)
		if(M.canmove)
			M.canmove = 0

	M.canmove = 1