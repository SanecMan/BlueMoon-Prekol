/obj/item/sensor_device
	name = "Handheld Crew Monitor" //Thanks to Gun Hog for the name!
	desc = "A miniature machine that tracks suit sensors across the station."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_price = PRICE_ABOVE_EXPENSIVE

/obj/item/sensor_device/attack_self(mob/user)
	GLOB.crewmonitor.show(user,src) //Proc already exists, just had to call it
