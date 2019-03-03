
if not recexplo then recexplo = {} end
if not recexplo.gui then recexplo.gui = {} end
if not recexplo.cal_gui then recexplo.cal_gui = {} end

if not recexplo.prefix_item_button_product then recexplo.prefix_item_button_product = "recexplo_item_button_product_" end
if not recexplo.prefix_item_button_ingredient then recexplo.prefix_item_button_ingredient = "recexplo_item_button_ingredient_" end
if not recexplo.prefix_made_in then recexplo.prefix_made_in = "recexplo_made_in_" end
if not recexplo.prefix_made_in_player then recexplo.prefix_made_in_player = "recexplo_player_made_in_" end
if not recexplo.prefix_recipe then recexplo.prefix_recipe = "recexplo_recipi_" end
if not recexplo.prefix_technology then recexplo.prefix_technology = "recexplo_technology_" end
--if not recexplo.prefix_recipe_frame then recexplo.prefix_recipe_frame = "recexplo_recipe_frame_" end
if not recexplo.prefix_remove_cal then recexplo.prefix_remove_cal = "recexplo_remove_cal_" end
if not recexplo.prefix_cal_made_in then recexplo.prefix_cal_made_in = "recexplo_cal_made_in_index_" end
if not recexplo.prefix_cal_factories_amount then recexplo.prefix_cal_factories_amount = "recexplo_cal_factories_amount_" end
if not recexplo.prefix_display_recipe then recexplo.prefix_display_recipe = "prefix_display_recipe_" end
if not recexplo.prefix_cal_item_button then recexplo.prefix_cal_item_button = "prefix_cal_item_button_" end

if not recexplo.prefix_recipe_frame then recexplo.prefix_recipe_frame = "recipe_frame" end


if not recexplo.history then recexplo.history = {} end	
	

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

	--update versons
	recexplo.version_update(player_index)
	--top button
	recexplo.top_button(player_index)

	if not global[player_index].gui.is_open then global[player_index].gui.is_open = false end	
	if not global[player_index].selctet_product_signal then global[player_index].selctet_product_signal = nil end--{ type = "item", name = "piercing-rounds-magazine"} end --crude-oil
	if not global[player_index].display_mode then global[player_index].display_mode = "recipe" end --recipe, where_used, single_recipe
	if not global[player_index].pasting_enabled then global[player_index].pasting_enabled = true end
	if not global[player_index].pasting_recipe then global[player_index].pasting_recipe = nil end
	
	
	if not global[player_index].global_history then global[player_index].global_history = {} end	
	if not global[player_index].global_history.length then global[player_index].global_history.length = 0 end	
	if not global[player_index].global_history.pos then global[player_index].global_history.pos = nil end
	if not global[player_index].global_history.prefix_history_itme then global[player_index].global_history.prefix_history_itme = "recexplo_global_history_item_" end
	if not global[player_index].global_history.placeholder_name then global[player_index].global_history.placeholder_name = "global_history_placehodler" end

	if not global[player_index].local_history then global[player_index].local_history = {} end	
	if not global[player_index].local_history.length then global[player_index].local_history.length = 0 end	
	if not global[player_index].local_history.pos then global[player_index].local_history.pos = 0 end
	if not global[player_index].local_history.prefix_history_itme then global[player_index].local_history.prefix_history_itme = "recexplo_local_history_item_" end
	if not global[player_index].local_history.placeholder_name then global[player_index].local_history.placeholder_name = "local_history_placehodler" end


	local was_set = 0

	if not global[player_index].cal_gui then global[player_index].cal_gui = {} end		
	if not global[player_index].cal_gui.is_open then global[player_index].cal_gui.is_open = false end
	if not global[player_index].cal_gui.is_recording then global[player_index].cal_gui.is_recording = false end
	if not global[player_index].cal_gui.begin_index then
		global[player_index].cal_gui.begin_index = 0 
		was_set = 1
	end
	if not global[player_index].cal_gui.end_index then
		global[player_index].cal_gui.end_index = 1
		was_set = was_set + 1
	end
	if was_set == 2 then 
		recexplo.cal_gui.add_io(player_index, "input")
		recexplo.cal_gui.add_io(player_index, "output")
	end
end

function recexplo.version_update(player_index)
	if global.verison == nil then
		local gui_root = game.players[player_index].gui.left
		if gui_root.recexplo_gui_frame then
			gui_root.recexplo_gui_frame.destroy()
		end
	end
	global.version = "0.16.6"
end

function recexplo.top_button(player_index)
	local button_gui_root = game.players[player_index].gui.top
	local enable_top_button = game.players[player_index].mod_settings["recexplo-enable-top-button"].value
	
	if button_gui_root.b_recexplo then
		if enable_top_button == false then
			button_gui_root.b_recexplo.destroy()
		end
	else
		if enable_top_button == true then
			button_gui_root.add{
				type = "button",
				name = "b_recexplo",
				caption = {"recexplo-gui.recipe-explorer"}
			}
		end
	end
end