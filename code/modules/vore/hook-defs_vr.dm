
//New() hooks
/hook/mobNew
/hook/living_new

//
//Hook helpers to expand hooks to others
//
/hook/mobNew/proc/chain_hooks(mob/M)
	var/result = 1
	if(isliving(M))
		if(!hook_vr("living_new",args))
			result = 0

	/*if(iscarbon(M))
		if(!hook_vr("carbon_new",args))
			result = 0

	if(ishuman(M))
		if(!hook_vr("human_new",args))
			result = 0*/

	//Return 1 to superhook
	return result