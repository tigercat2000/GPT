/turf/wall
	opacity = 1
	density = 1

	icon = 'icons/smooth/walls/wall.dmi'
	icon_state = "wall"

	canSmoothWith = list(
	/turf/wall,
	/turf/wall/reinforced)
	smooth = SMOOTH_TRUE

/turf/wall/reinforced
	icon = 'icons/smooth/walls/reinforced_wall.dmi'
	icon_state = "r_wall"

/turf/wall/abductor
	icon = 'icons/smooth/walls/abductor_wall.dmi'
	icon_state = "abductor"
	canSmoothWith = list(/turf/wall/abductor)
	smooth = SMOOTH_MORE|SMOOTH_DIAGONAL

/turf/wall/bananium
	icon = 'icons/smooth/walls/bananium_wall.dmi'
	icon_state = "bananium"
	canSmoothWith = list(/turf/wall/bananium)

/turf/wall/cult
	icon = 'icons/smooth/walls/cult_wall.dmi'
	icon_state = "cult"
	canSmoothWith = list(/turf/wall/cult)

/turf/wall/diamond
	icon = 'icons/smooth/walls/diamond_wall.dmi'
	icon_state = "diamond"
	canSmoothWith = list(/turf/wall/diamond)

/turf/wall/gold
	icon = 'icons/smooth/walls/gold_wall.dmi'
	icon_state = "gold"
	canSmoothWith = list(/turf/wall/gold)

/turf/wall/iron
	icon = 'icons/smooth/walls/iron_wall.dmi'
	icon_state = "iron"
	canSmoothWith = list(/turf/wall/iron)

/turf/wall/plasma
	icon = 'icons/smooth/walls/plasma_wall.dmi'
	icon_state = "plasma"
	canSmoothWith = list(/turf/wall/plasma)

/turf/wall/rusty
	icon = 'icons/smooth/walls/rusty_wall.dmi'
	icon_state = "arust"
	canSmoothWith = list(
		/turf/wall/rusty,
		/turf/wall/rusty/reinforced)

/turf/wall/rusty/reinforced
	icon = 'icons/smooth/walls/rusty_reinforced_wall.dmi'
	icon_state = "rrust"

/turf/wall/sandstone
	icon = 'icons/smooth/walls/sandstone_wall.dmi'
	icon_state = "sandstone"
	canSmoothWith = list(/turf/wall/sandstone)

/turf/wall/silver
	icon = 'icons/smooth/walls/silver_wall.dmi'
	icon_state = "silver"
	canSmoothWith = list(/turf/wall/silver)

/turf/wall/uranium
	icon = 'icons/smooth/walls/uranium_wall.dmi'
	icon_state = "uranium"
	canSmoothWith = list(/turf/wall/uranium)

/turf/wall/wood
	icon = 'icons/smooth/walls/wood_wall.dmi'
	icon_state = "wood"
	canSmoothWith = list(/turf/wall/wood)