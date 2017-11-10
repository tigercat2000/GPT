/mob/living/can_equip(obj/item/I, slot, disable_warning = 0)
	. = ..()
	switch(slot)
		if(slot_w_uniform)
			if(w_uniform)
				return 0
			if(!(slot_w_uniform in I.slot_list))
				return 0
			return 1
		if(slot_w_shoes)
			if(w_shoes)
				return 0
			if(!(slot_w_shoes in I.slot_list))
				return 0
			return 1