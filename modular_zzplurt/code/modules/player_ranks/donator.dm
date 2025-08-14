#define DONATOR_TOML_FILE "[global.config.directory]/splurt/donator.toml"

/datum/player_rank_controller/donator/load_from_query(datum/db_query/query)
	if(IsAdminAdvancedProcCall())
		return

	clear_existing_rank_data()

	while(query.NextRow())
		var/ckey = ckey(query.item[1])
		var/tier = text2num(query.item[2])
		if(isnull(tier) || tier <= 0)
			continue

		GLOB.supporter_list[ckey] = tier

	load_from_toml()

/datum/player_rank_controller/donator/clear_existing_rank_data()
	if(IsAdminAdvancedProcCall())
		return

	GLOB.supporter_list.Cut()

/datum/player_rank_controller/donator/proc/load_from_toml()
	var/list/donators = rustg_read_toml_file(DONATOR_TOML_FILE)
	if(!donators)
		CRASH("Attempted to read toml donator file, but none was found!")

	for(var/tier in donators["donators"])
		var/tier_num = text2num(replacetext(tier, "tier_", ""))
		if(isnull(tier_num))
			CRASH("Invalid tier found in toml donator file: [tier]")

		for(var/ckey in donators["donators"][tier])
			GLOB.supporter_list[ckey] = tier_num
