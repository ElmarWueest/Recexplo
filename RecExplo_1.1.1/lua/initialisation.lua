
if not recexplo then recexplo = {} end
if not recexplo.gui then recexplo.gui = {} end
if not recexplo.cal_gui then recexplo.cal_gui = {} end
if not recexplo.history then recexplo.history = {} end


if not recexplo.prefix_item_button_product then recexplo.prefix_item_button_product = "recexplo_item_button_product_" end
if not recexplo.prefix_item_button_ingredient then recexplo.prefix_item_button_ingredient = "recexplo_item_button_ingredient_" end
if not recexplo.prefix_made_in then recexplo.prefix_made_in = "recexplo_made_in_" end
if not recexplo.prefix_made_in_character then recexplo.prefix_made_in_character = "recexplo_character_made_in_" end
if not recexplo.prefix_recipe then recexplo.prefix_recipe = "recexplo_recipe_" end
if not recexplo.prefix_technology then recexplo.prefix_technology = "recexplo_technology_" end
if not recexplo.prefix_remove_cal then recexplo.prefix_remove_cal = "recexplo_remove_cal_" end
if not recexplo.prefix_cal_made_in then recexplo.prefix_cal_made_in = "recexplo_cal_made_in_index_" end
if not recexplo.prefix_cal_factories_amount then recexplo.prefix_cal_factories_amount = "recexplo_cal_factories_amount_" end
if not recexplo.prefix_display_recipe then recexplo.prefix_display_recipe = "recexplo_prefix_display_recipe_" end
if not recexplo.prefix_cal_item_button then recexplo.prefix_cal_item_button = "recexplo_prefix_cal_item_button_" end
if not recexplo.prefix_recipe_frame then recexplo.prefix_recipe_frame = "recexplo_recipe_frame_" end
if not recexplo.prefix_global_history_item then recexplo.prefix_global_history_item = "recexplo_global_history_item_" end
if not recexplo.prefix_local_history_item then recexplo.prefix_local_history_item = "recexplo_local_history_item_" end

if not recexplo.history.global_history_list then recexplo.history.global_history_list = {} end	
if not recexplo.history.global_history_list.length then recexplo.history.global_history_list.length = 0 end	

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

	recexplo.had_opened_tech = 0
	if not global[player_index] then global[player_index] = {} end
	if not global[player_index].gui then global[player_index].gui = {} end

	--top button
	recexplo.top_button(player_index)

	if not global[player_index].gui.is_open then global[player_index].gui.is_open = false end	
	if not global[player_index].search_mode then global[player_index].search_mode = "recipe" end --recipe, where_used, single_recipe
	if not global[player_index].filter_mode then global[player_index].filter_mode = "researched" end --researched, all
	if not global[player_index].pasting_enabled then global[player_index].pasting_enabled = true end
	

	--update flags
	if not global[player_index].update_flags then global[player_index].update_flags = {} end
	if not global[player_index].update_flags.local_history then global[player_index].update_flags.local_history = false end
	if not global[player_index].update_flags.global_history then global[player_index].update_flags.global_history = false end
	if not global[player_index].update_flags.results then global[player_index].update_flags.results = false end
	if not global[player_index].update_flags.radio_buttons_search_mode then global[player_index].update_flags.radio_buttons_search_mode = false end
	
	if not global[player_index].cal_gui_update_flags then global[player_index].cal_gui_update_flags = {} end
	if not global[player_index].cal_gui_update_flags.results then global[player_index].cal_gui_update_flags.results = false end
	if not global[player_index].cal_gui_update_flags.stats then global[player_index].cal_gui_update_flags.stats = false end
	if not global[player_index].cal_gui_update_flags.history then global[player_index].cal_gui_update_flags.history = false end
	
	if not global[player_index].global_history then global[player_index].global_history = {} end	
	if not global[player_index].global_history.name then global[player_index].global_history.name = "global" end
	if not global[player_index].global_history.list then global[player_index].global_history.list = recexplo.history.global_history_list end	
	if not global[player_index].global_history.list.length then global[player_index].global_history.list.length = 0 end	
	if not global[player_index].global_history.pos then global[player_index].global_history.pos = -1 end
	if not global[player_index].global_history.prefix_history_itme then global[player_index].global_history.prefix_history_itme = recexplo.prefix_global_history_item end
	if not global[player_index].global_history.placeholder_name then global[player_index].global_history.placeholder_name = "recexplo_global_history_placehodler" end

	if not global[player_index].local_history then global[player_index].local_history = {} end	
	if not global[player_index].local_history.name then global[player_index].local_history.name = "local" end
	if not global[player_index].local_history.list then global[player_index].local_history.list = {} end	
	if not global[player_index].local_history.list.length then global[player_index].local_history.list.length = 0 end	
	if not global[player_index].local_history.pos then global[player_index].local_history.pos = 0 end
	if not global[player_index].local_history.prefix_history_itme then global[player_index].local_history.prefix_history_itme = recexplo.prefix_local_history_item end
	if not global[player_index].local_history.placeholder_name then global[player_index].local_history.placeholder_name = "recexplo_local_history_placehodler" end


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

function recexplo.reset()
	for _, player in pairs(game.players) do
		local player_index = player.index
		recexplo.reset_player(player_index)
	end
end
function recexplo.reset_player(player_index)
	global[player_index] = {}
	recexplo.create_global_table(player_index)
	recexplo.destroy_frame(player_index)

end


function recexplo.destroy_frame(player_index)
	if game.players[player_index].gui.left.recexplo_flow then
		if game.players[player_index].gui.left.recexplo_flow.recexplo_gui_frame then
			game.players[player_index].gui.left.recexplo_flow.destroy()
		end
	end
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
				type = "sprite-button",
				name = "b_recexplo",
				sprite = "recipe-book",
				style = "recexplo_sprite_button"
			}
		end
	end
end