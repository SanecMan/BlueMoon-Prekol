// Honker

/obj/item/projectile/bullet/honker
	damage = 0
	knockdown = 60
	movement_type = FLYING
	projectile_piercing = ALL
	nodamage = TRUE
	candink = FALSE
	hitsound = 'sound/items/bikehorn.ogg'
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana"
	range = 200

/obj/item/projectile/bullet/honker/Initialize(mapload)
	. = ..()
	SpinAnimation()

// Mime

/obj/item/projectile/bullet/mime
	damage = 25

/obj/item/projectile/bullet/mime/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.silent = max(M.silent, 10)
