/* MintStation EDIT START -  DISCORD WHITELIST
#define WHITELISTFILE "[global.config.directory]/whitelist.txt"

GLOBAL_LIST(whitelist)

/proc/load_whitelist()
	GLOB.whitelist = list()
	for(var/line in world.file2list(WHITELISTFILE))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.whitelist += ckey(line)

	if(!GLOB.whitelist.len)
		GLOB.whitelist = null

/proc/check_whitelist(ckey)
	if(!GLOB.whitelist)
		return FALSE
	. = (ckey in GLOB.whitelist)

#undef WHITELISTFILE
MintStation EDIT END -  DISCORD WHITELIST */

// MintStation EDIT START || DISCORD WHITELIST
/proc/check_whitelist(key)
	if(!SSdbcore.Connect())
		log_world("Failed to connect to database in check_whitelist(). Disabling whitelist for current round.")
		log_game("Failed to connect to database in check_whitelist(). Disabling whitelist for current round.")
		CONFIG_SET(flag/usewhitelist, FALSE)
		return TRUE

	var/datum/db_query/query_get_whitelist = SSdbcore.NewQuery({"
		SELECT id FROM [format_table_name("whitelist")]
		WHERE ckey = :ckey and deleted = 0
	"}, list("ckey" = key)
	)

	if(!query_get_whitelist.Execute())
		log_sql("Whitelist check for ckey [key] failed to execute. Rejecting")
		message_admins("Whitelist check for ckey [key] failed to execute. Rejecting")
		qdel(query_get_whitelist)
		return FALSE

	var/allow = query_get_whitelist.NextRow()

	qdel(query_get_whitelist)

	return allow

/datum/tgs_chat_command/whitelist
	name = "whitelist"
	help_text = "Usage: whitelist (add ckey (comment)|remove ckey (comment)|reload|list (limit)|logs (limit)|managerlog manager_id (limit)|useraudit ckey (limit))"
	admin_only = TRUE

/datum/tgs_chat_command/whitelist/Run(datum/tgs_chat_user/sender, params)
	var/start_time = world.realtime
	log_world("[sender.friendly_name] issued command: [params] at [start_time]")

	try
		var/default_limit = 100
		var/ckey_width = 20
		var/manager_width = 20
		var/manager_id_width = 20
		var/action_width = 10
		var/date_width = 19
		var/comment_width = 30

		var/limit
		var/comment
		var/manager_id
		var/key

		if(!CONFIG_GET(flag/usewhitelist))
			log_world("Whitelist is not enabled, but command is being processed.")

		if(!SSdbcore.Connect())
			log_world("Failed to connect to database.")
			return new /datum/tgs_message_content("Error: Could not connect to the database.")

		var/list/all_params = splittext(params, " ")
		if(length(all_params) < 1)
			return new /datum/tgs_message_content(src.help_text)

		switch(all_params[1])
			if("add")
				if(length(all_params) < 2)
					return new /datum/tgs_message_content("Invalid argument: ckey is required.")

				key = ckey(all_params[2])

				// Extract comment if any
				comment = ""
				if(length(all_params) > 2)
					var/pos = findtext(params, all_params[2]) + length(all_params[2]) + 1
					comment = copytext(params, pos)

				log_world("Adding [key] to whitelist with comment: [comment]")

				// Check if the ckey already exists
				var/datum/db_query/query_get_whitelist = SSdbcore.NewQuery({"
					SELECT id FROM [format_table_name("whitelist")]
					WHERE ckey = :ckey
				"}, list("ckey" = key))

				if(!query_get_whitelist.Execute())
					log_world("Failed to execute query_get_whitelist: [query_get_whitelist.ErrorMsg()]")
					qdel(query_get_whitelist)
					return new /datum/tgs_message_content("Failed to add ckey `[key]`.\n[query_get_whitelist.ErrorMsg()]")

				if(query_get_whitelist.NextRow())
					// ckey exists, update it
					qdel(query_get_whitelist)
					var/datum/db_query/query_update_whitelist = SSdbcore.NewQuery({"
						UPDATE [format_table_name("whitelist")]
						SET deleted = 0, manager = :manager, manager_id = :manager_id, comment = :comment
						WHERE ckey = :ckey
					"}, list("ckey" = key, "manager" = sender.friendly_name, "manager_id" = sender.id, "comment" = comment))

					if(!query_update_whitelist.Execute())
						log_world("Failed to execute query_update_whitelist: [query_update_whitelist.ErrorMsg()]")
						qdel(query_update_whitelist)
						return new /datum/tgs_message_content("Failed to update ckey `[key]`.\n[query_update_whitelist.ErrorMsg()]")

					qdel(query_update_whitelist)
					log_world("[key] has been re-added to the whitelist successfully.")
					return new /datum/tgs_message_content("`[key]` has been re-added to the whitelist!")
				else
					// ckey does not exist, insert it
					qdel(query_get_whitelist)

					var/datum/db_query/query_add_whitelist = SSdbcore.NewQuery({"
						INSERT INTO [format_table_name("whitelist")] (ckey, manager, manager_id, comment)
						VALUES (:ckey, :manager, :manager_id, :comment)
					"}, list("ckey" = key, "manager" = sender.friendly_name, "manager_id" = sender.id, "comment" = comment))

					if(!query_add_whitelist.Execute())
						log_world("Failed to execute query_add_whitelist: [query_add_whitelist.ErrorMsg()]")
						qdel(query_add_whitelist)
						return new /datum/tgs_message_content("Failed to add ckey `[key]`.\n[query_add_whitelist.ErrorMsg()]")

					qdel(query_add_whitelist)
					log_world("[key] has been added to the whitelist successfully.")
					return new /datum/tgs_message_content("`[key]` has been added to the whitelist!")
			if("remove")
				if(length(all_params) < 2)
					return new /datum/tgs_message_content("Invalid argument: ckey is required.")

				key = ckey(all_params[2])

				// Extract comment if any
				comment = ""
				if(length(all_params) > 2)
					var/pos = findtext(params, all_params[2]) + length(all_params[2]) + 1
					comment = copytext(params, pos)

				log_world("[sender.friendly_name] requested removal of [key] with comment: [comment]")

				var/datum/db_query/query_remove_whitelist = SSdbcore.NewQuery({"
					UPDATE [format_table_name("whitelist")]
					SET deleted = 1, manager = :manager, manager_id = :manager_id, comment = :comment
					WHERE ckey = :ckey
				"}, list("ckey" = key, "manager" = sender.friendly_name, "manager_id" = sender.id, "comment" = comment))

				if(!query_remove_whitelist.Execute())
					log_world("Failed to execute query_remove_whitelist: [query_remove_whitelist.ErrorMsg()]")
					qdel(query_remove_whitelist)
					return new /datum/tgs_message_content("Failed to remove ckey `[key]`.\n[query_remove_whitelist.ErrorMsg()]")

				qdel(query_remove_whitelist)
				log_world("[key] has been removed from the whitelist successfully.")
				return new /datum/tgs_message_content("`[key]` has been removed from the whitelist!")
			if("list")
				limit = default_limit  // Use default limit
				if(length(all_params) > 2)
					limit = text2num(all_params[2])
					if(!limit || limit <= 0)
						limit = default_limit

				log_world("[sender.friendly_name] requested whitelist list with limit: [limit]")

				var/datum/db_query/query_get_all_whitelist = SSdbcore.NewQuery({"
					SELECT ckey FROM [format_table_name("whitelist")]
					WHERE deleted = 0
					ORDER BY last_modified DESC
					LIMIT :limit
				"}, list("limit" = limit))

				if(!query_get_all_whitelist.Execute())
					log_world("Failed to execute query_get_all_whitelist: [query_get_all_whitelist.ErrorMsg()]")
					qdel(query_get_all_whitelist)
					return new /datum/tgs_message_content("Failed to get all whitelisted keys.\n[query_get_all_whitelist.ErrorMsg()]")

				var/list/whitelisted_keys = list()
				while(query_get_all_whitelist.NextRow())
					var/key_result = query_get_all_whitelist.item[1]
					whitelisted_keys += key_result

				qdel(query_get_all_whitelist)

				if(!whitelisted_keys.len)
					return new /datum/tgs_message_content("Whitelist is empty.")

				var/message = "Whitelisted keys:\n" + jointext(whitelisted_keys, "\n")
				return new /datum/tgs_message_content(message)
			if("logs")
				limit = default_limit  // Use default limit
				if(length(all_params) > 2)
					limit = text2num(all_params[2])
					if(!limit || limit <= 0)
						limit = default_limit

				log_world("[sender.friendly_name] requested whitelist logs with limit: [limit]")

				var/datum/db_query/query_get_logs = SSdbcore.NewQuery({"
					SELECT ckey, manager, manager_id, action, date, comment FROM [format_table_name("whitelist_log")]
					ORDER BY date DESC
					LIMIT :limit
				"}, list("limit" = limit))

				if(!query_get_logs.Execute())
					log_world("Failed to execute query_get_logs: [query_get_logs.ErrorMsg()]")
					qdel(query_get_logs)
					return new /datum/tgs_message_content("Failed to get whitelist logs.\n[query_get_logs.ErrorMsg()]")

				var/message = "```\n"
				message += "Whitelist Log (last [limit] entries):\n"
				message += pad_string("ckey", ckey_width) + pad_string("manager", manager_width) + pad_string("manager_id", manager_id_width) + pad_string("action", action_width) + pad_string("date", date_width) + pad_string("comment", comment_width) + "\n"

				while(query_get_logs.NextRow())
					var/ckey_value = query_get_logs.item[1]
					var/manager_value = query_get_logs.item[2]
					var/manager_id_value = query_get_logs.item[3]
					var/action_value = query_get_logs.item[4]
					var/date_value = query_get_logs.item[5]
					var/comment_value = query_get_logs.item[6]
					message += pad_string(ckey_value, ckey_width) + pad_string(manager_value, manager_width) + pad_string(manager_id_value, manager_id_width) + pad_string(action_value, action_width) + pad_string(date_value, date_width) + pad_string(comment_value, comment_width) + "\n"

				message += "```\n"
				qdel(query_get_logs)
				return new /datum/tgs_message_content(message)
			if("managerlog")
				if(length(all_params) < 2)
					return new /datum/tgs_message_content("Invalid argument: manager_id is required.")

				manager_id = all_params[2]
				limit = default_limit  // Use default limit
				if(length(all_params) > 3)
					limit = text2num(all_params[3])
					if(!limit || limit <= 0)
						limit = default_limit

				log_world("[sender.friendly_name] requested manager log for manager_id: [manager_id] with limit: [limit]")

				var/datum/db_query/query_get_logs = SSdbcore.NewQuery({"
					SELECT ckey, manager, manager_id, action, date, comment FROM [format_table_name("whitelist_log")]
					WHERE manager_id = REPLACE(REPLACE(:manager_id, '<@', ''), '>', '')
					ORDER BY date DESC
					LIMIT :limit
				"}, list("manager_id" = manager_id, "limit" = limit))

				if(!query_get_logs.Execute())
					log_world("Failed to execute query_get_logs for manager_id [manager_id]: [query_get_logs.ErrorMsg()]")
					qdel(query_get_logs)
					return new /datum/tgs_message_content("Failed to get logs for manager_id `[manager_id]`.\n[query_get_logs.ErrorMsg()]")

				var/message = "```\n"
				message += "Whitelist Log for manager_id `[manager_id]` (last [limit] entries):\n"
				message += pad_string("ckey", ckey_width) + pad_string("manager", manager_width) + pad_string("manager_id", manager_id_width) + pad_string("action", action_width) + pad_string("date", date_width) + pad_string("comment", comment_width) + "\n"

				while(query_get_logs.NextRow())
					var/ckey_value = query_get_logs.item[1]
					var/manager_value = query_get_logs.item[2]
					var/manager_id_value = query_get_logs.item[3]
					var/action_value = query_get_logs.item[4]
					var/date_value = query_get_logs.item[5]
					var/comment_value = query_get_logs.item[6]
					message += pad_string(ckey_value, ckey_width) + pad_string(manager_value, manager_width) + pad_string(manager_id_value, manager_id_width) + pad_string(action_value, action_width) + pad_string(date_value, date_width) + pad_string(comment_value, comment_width) + "\n"

				message += "```\n"
				qdel(query_get_logs)
				return new /datum/tgs_message_content(message)
			if("useraudit")
				if(length(all_params) < 2)
					return new /datum/tgs_message_content("Invalid argument: ckey is required.")

				key = ckey(all_params[2])
				limit = default_limit  // Use default limit
				if(length(all_params) > 3)
					limit = text2num(all_params[3])
					if(!limit || limit <= 0)
						limit = default_limit

				log_world("[sender.friendly_name] requested user audit for ckey: [key] with limit: [limit]")

				var/datum/db_query/query_get_logs = SSdbcore.NewQuery({"
					SELECT ckey, manager, manager_id, action, date, comment FROM [format_table_name("whitelist_log")]
					WHERE ckey = :ckey
					ORDER BY date DESC
					LIMIT :limit
				"}, list("ckey" = key, "limit" = limit))

				if(!query_get_logs.Execute())
					log_world("Failed to execute query_get_logs for ckey [key]: [query_get_logs.ErrorMsg()]")
					qdel(query_get_logs)
					return new /datum/tgs_message_content("Failed to get logs for ckey `[key]`.\n[query_get_logs.ErrorMsg()]")

				var/message = "```\n"
				message += "Whitelist Log for ckey `[key]` (last [limit] entries):\n"
				message += pad_string("ckey", ckey_width) + pad_string("manager", manager_width) + pad_string("manager_id", manager_id_width) + pad_string("action", action_width) + pad_string("date", date_width) + pad_string("comment", comment_width) + "\n"

				while(query_get_logs.NextRow())
					var/ckey_value = query_get_logs.item[1]
					var/manager_value = query_get_logs.item[2]
					var/manager_id_value = query_get_logs.item[3]
					var/action_value = query_get_logs.item[4]
					var/date_value = query_get_logs.item[5]
					var/comment_value = query_get_logs.item[6]
					message += pad_string(ckey_value, ckey_width) + pad_string(manager_value, manager_width) + pad_string(manager_id_value, manager_id_width) + pad_string(action_value, action_width) + pad_string(date_value, date_width) + pad_string(comment_value, comment_width) + "\n"

				message += "```\n"
				qdel(query_get_logs)
				return new /datum/tgs_message_content(message)
			else
				log_world("[sender.friendly_name] requested unknown command: [params]")
				return new /datum/tgs_message_content("Unknown command!\n[src.help_text]")
	catch
		log_world("Error while processing command [params]: [src]")
		return new /datum/tgs_message_content("An error occurred while processing your command.")

	var/end_time = world.realtime
	log_world("Command [params] processed in [end_time - start_time] seconds")

/proc/pad_string(str, width)
	var/padded_str = "[str]"
	while(length(padded_str) < width)
		padded_str += " "
	return padded_str

// MintStation EDIT END || DISCORD WHITELIST
