/datum/action/changeling/digitalcamo
	name = "Digital Camouflage"
	desc = "By evolving the ability to distort our form and proportions, we defeat common algorithms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera or seen by AI units while using this skill. However, humans looking at us will find us... uncanny. This ability is somewhat loud, and carries a small risk of our blood gaining violent sensitivity to heat."
	button_icon_state = "digital_camo"
	dna_cost = 1
	loudness = 1

//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/datum/action/changeling/digitalcamo/sting_action(mob/user)

	if(user.digitalcamo)
		to_chat(user, "<span class='notice'>We return to normal.</span>")
		user.digitalinvis = FALSE
		user.digitalcamo = FALSE
	else
		to_chat(user, "<span class='notice'>We distort our form to hide from the AI.</span>")
		user.digitalcamo = TRUE
		user.digitalinvis = TRUE
	return TRUE

/datum/action/changeling/digitalcamo/Remove(mob/user)
	user.digitalcamo = FALSE
	user.digitalinvis = FALSE
	..()
