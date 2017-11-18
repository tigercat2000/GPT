/mob/living/verb/rest()
	set name = "Rest"
	set category = "IC"

	if(resting)
		StopResting()
	else
		StartResting()