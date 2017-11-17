/obj/item/clothing/uniform
	name = "uniform"
	slot_list = list(INV_W_UNIFORM)

/obj/item/clothing/uniform/bluedress
	name = "blue dress"

	icon_state = "bluezippo"
	item_state = "w_suit"
	item_color = "bride_blue_s"


/obj/item/clothing/uniform/chameleon
	name = "Chameleon Jumpsuit"

	icon_state = "bluezippo"
	item_state = "w_suit"
	item_color = "bride_blue_s"

	actions_types = list(/datum/action/item_action/pick_color)

/obj/item/clothing/uniform/chameleon/item_action_slot_check(slot, mob/user)
	if(slot == INV_W_UNIFORM)
		return TRUE
	return FALSE

/obj/item/clothing/uniform/chameleon/attack_self()
	var/list/possible_options = list(
	"Blue Dress" = "bride_blue_s",
	"Orange Dress" = "bride_orange_s",
	"Purple Dress" = "bride_purple_s",
	"Red Dress" = "bride_red_s",
	"White Dress" = "bride_white_s",
	"Bridesmaid Dress" = "bridesmaid_s",
	"Sailor Dress" = "sailor_dress_s",
	"Black Schoolgirl Dress" = "schoolgirl_black_s",
	"Schoolgirl Dress" = "schoolgirl_s"
	)

	var/choice = input(usr, "What do you want to change the jumpsuit to?", "Changing", "bride_blue_s") as null|anything in possible_options
	if(!choice)
		return
	item_color = possible_options[choice]
	if(loc == usr)
		usr.update_slot(INV_W_UNIFORM)