
if not recexplo then recexplo = {} end
if not recexplo.gui then recexplo.gui = {} end

if not recexplo.prefix_item_button_product then recexplo.prefix_item_button_product = "recexplo_item_button_product_" end
if not recexplo.prefix_item_button_ingredient then recexplo.prefix_item_button_ingredient = "recexplo_item_button_ingredient_" end
if not recexplo.prefix_made_in then recexplo.prefix_made_in = "recexplo_made_in_" end
if not recexplo.prefix_made_in_player then recexplo.prefix_made_in_player = "recexplo_player_made_in_" end
if not recexplo.prefix_history_itme then recexplo.prefix_history_itme = "recexplo_history_itme_" end
if not recexplo.prefix_recipe then recexplo.prefix_recipe = "recexplo_recipi_" end
if not recexplo.prefix_technology then recexplo.prefix_technology = "recexplo_technology_" end



if not recexplo.history then recexplo.history = {} end	
--if not recexplo.history.max_length then recexplo.history.max_length = 30 end	
--if not recexplo.history.max_delta then recexplo.history.max_delta = 5 end	

if not recexplo.gui.recipes_display_columns then recexplo.gui.recipes_display_columns = 4 end



--prepare variables
script.on_init(function(event)
	for i, player in pairs(game.players) do
		recexplo.create_global_table(player.index)
	end
end)

script.on_event(defines.events.on_player_created, function(event)
	recexplo.create_global_table(event.player_index)
end)
script.on_event(defines.events.on_player_joined_game, function(event)
	recexplo.create_global_table(event.player_index)
end)
script.on_event(defines.events.on_player_respawned, function(event)
	recexplo.create_global_table(event.player_index)
end)

function recexplo.create_global_table(player_index)
	if not global then recexplo = {} end
	recexplo.had_opened_tech = 0
	if not global[player_index] then global[player_index] = {} end
	if not global[player_index].gui then global[player_index].gui = {} end

	
	if not global[player_index].gui.is_open then global[player_index].gui.is_open = false end	
	if not global[player_index].selctet_product_signal then global[player_index].selctet_product_signal = nil end--{ type = "item", name = "piercing-rounds-magazine"} end --crude-oil
	if not global[player_index].display_mode then global[player_index].display_mode = "recipe" end --recipe, where_used
	if not global[player_index].pasting_enabled then global[player_index].pasting_enabled = true end
	if not global[player_index].pasting_recipe then global[player_index].pasting_recipe = nil end
	
	
	if not global[player_index].history then global[player_index].history = {} end	
	if not global[player_index].history.length then global[player_index].history.length = 0 end	
	if not global[player_index].history.pos then global[player_index].history.pos = 0 end
	if not global[player_index].history.insert_mode then global[player_index].history.insert_mode = false end
	--if not global[player_index].history[1] then global[player_index].history[1] = nil end --{}
	--if not global[player_index].history[1].signal then global[player_index].history[1].signal = nil end --{ type = "item", name = "piercing-rounds-magazine"}
	--if not global[player_index].history[1].display_mode then global[player_index].history[1].display_mode = nil end ----recipe, where_used
	
end

