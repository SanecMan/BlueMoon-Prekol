/**
 * Creates a TGUI input list window and returns the user's response.
 *
 * This proc should be used to create alerts that the caller will wait for a response from.
 * Arguments:
 * * user - The user to show the input box to.
 * * message - The content of the input box, shown in the body of the TGUI window.
 * * title - The title of the input box, shown on the top of the TGUI window.
 * * items - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * default - The option with this value will be selected on first paint of the TGUI window.
 * * timeout - The timeout of the input box, after which the input box will close and qdel itself. Set to zero for no timeout.
 * * strict_modern - Disabled the preference check of the input box, only allowing the TGUI window to show.
 */
/proc/tgui_input_list(mob/user, message, title = "Select", list/items, default, timeout = 0, strict_modern = FALSE)
	if (istext(user))
		stack_trace("tgui_alert() received text for user instead of mob")
		return
	if (!user)
		user = usr
	if(!length(items))
		return
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	/// Client does NOT have tgui_input on: Returns regular input
	if(!user.client.prefs.tgui_input_mode && !strict_modern)
		return input(user, message, title, default) as null|anything in items
	var/datum/tgui_list_input/input = new(user, message, title, items, default, timeout)
	input.ui_interact(user)
	input.wait()
	if (input)
		. = input.choice
		qdel(input)

/**
 * # tgui_list_input
 *
 * Datum used for instantiating and using a TGUI-controlled list input that prompts the user with
 * a message and shows a list of selectable options
 */
/datum/tgui_list_input
	/// The title of the TGUI window
	var/title
	/// The textual body of the TGUI window
	var/message
	/// The list of items (responses) provided on the TGUI window
	var/list/items
	/// Items (strings specifically) mapped to the actual value (e.g. a mob or a verb)
	var/list/items_map
	/// The button that the user has pressed, null if no selection has been made
	var/choice
	/// The default item to be selected
	var/default
	/// The time at which the tgui_list_input was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the tgui_list_input, after which the window will close and delete itself.
	var/timeout
	/// Boolean field describing if the tgui_list_input was closed by the user.
	var/closed

/datum/tgui_list_input/New(mob/user, message, title, list/items, default, timeout)
	src.title = title
	src.message = message
	src.items = list()
	src.items_map = list()
	src.default = default
	var/list/repeat_items = list()

	// Gets rid of illegal characters
	var/static/regex/whitelistedWords = regex(@{"([^\u0020-\u8000]+)"})

	for(var/i in items)
		if(isnull(i))
			stack_trace("Null in a tgui_input_list() items")
			continue

		var/string_key = whitelistedWords.Replace_char("[i]", "")

		//avoids duplicated keys E.g: when areas have the same name
		string_key = avoid_assoc_duplicate_keys(string_key, repeat_items)

		src.items += string_key
		src.items_map[string_key] = i


	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_list_input/Destroy(force, ...)
	SStgui.close_uis(src)
	QDEL_NULL(items)
	. = ..()

/**
 * Waits for a user's response to the tgui_list_input's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_list_input/proc/wait()
	while (!choice && !closed)
		stoplag(1)

/datum/tgui_list_input/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ListInputModal")
		ui.open()

/datum/tgui_list_input/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_list_input/ui_state(mob/user)
	return GLOB.always_state

/datum/tgui_list_input/ui_static_data(mob/user)
	var/list/data = list()
	data["init_value"] = default || items[1]
	data["items"] = items
	data["large_buttons"] = user.client.prefs.tgui_large_buttons
	data["message"] = message
	data["swapped_buttons"] = !user.client.prefs.tgui_swapped_buttons
	data["title"] = title
	return data

/datum/tgui_list_input/ui_data(mob/user)
	var/list/data = list()
	if(timeout)
		data["timeout"] = clamp((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS), 0, 1)
	return data

/datum/tgui_list_input/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("submit")
			if (!(params["entry"] in items))
				return
			set_choice(items_map[params["entry"]])
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			SStgui.close_uis(src)
			closed = TRUE
			return TRUE

/datum/tgui_list_input/proc/set_choice(choice)
	src.choice = choice

/**
 * Creates an asynchronous TGUI input list window with an associated callback.
 *
 * This proc should be used to create inputs that invoke a callback with the user's chosen option.
 * Arguments:
 * * user - The user to show the input box to.
 * * message - The content of the input box, shown in the body of the TGUI window.
 * * title - The title of the input box, shown on the top of the TGUI window.
 * * items - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * default - The option with this value will be selected on first paint of the TGUI window.
 * * callback - The callback to be invoked when a choice is made.
 * * timeout - The timeout of the input box, after which the menu will close and qdel itself. Set to zero for no timeout.
 */
/proc/tgui_input_list_async(mob/user, message, title, list/items, default, datum/callback/callback, timeout = 60 SECONDS)
	if (istext(user))
		stack_trace("tgui_alert() received text for user instead of mob")
		return
	if (!user)
		user = usr
	if(!length(items))
		return
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	var/datum/tgui_list_input/async/input = new(user, message, title, items, default, callback, timeout)
	input.ui_interact(user)

/**
 * # async tgui_list_input
 *
 * An asynchronous version of tgui_list_input to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_list_input/async
	/// The callback to be invoked by the tgui_list_input upon having a choice made.
	var/datum/callback/callback

/datum/tgui_list_input/async/New(mob/user, message, title, list/items, default, callback, timeout)
	..(user, title, message, items, default, timeout)
	src.callback = callback

/datum/tgui_list_input/async/Destroy(force, ...)
	QDEL_NULL(callback)
	. = ..()

///datum/tgui_list_input/async/tgui_close(mob/user)
//	. = ..()
//	qdel(src)

/datum/tgui_list_input/async/set_choice(choice)
	. = ..()
	if(!isnull(src.choice))
		callback?.InvokeAsync(src.choice)

/datum/tgui_list_input/async/wait()
	return
