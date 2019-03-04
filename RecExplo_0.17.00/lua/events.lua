
require "lua/explo_gui"
require "lua/open_tech"
require "lua/history"

script.on_event(defines.events.on_tick, function(event)
	if game.tick % 31 == 0 then
		for i, player in pairs(game.connected_players) do
			recexplo.create_global_table(player.index)
		end

	end
	if recexplo.had_opened_tech then
		if recexplo.had_opened_tech > 1 then
			recexplo.had_opened_tech = recexplo.had_opened_tech - 1
		elseif recexplo.had_opened_tech == 1 then
			recexplo.gui.pasting_old_technology(event.player_index)
		end
	end
end)

script.on_event(defines.events.on_gui_click, function(event)
	--gui button
	local player_index = event.player_index
	local player = game.players[player_index]
	
	--game.print("gui name on_gui_click:" .. event.element.name)
	if event.element.name == "b_recexplo" then
		--player.print("clicked test button")
		if global[player_index].gui.is_open then
			recexplo.gui.close(player_index)		
		else
			recexplo.gui.open(player_index)
		end

	elseif global[player_index].gui.is_open then
	
		if	string.find(event.element.name, recexplo.prefix_item_button_product, 1) ~= nil then	
			--game.print("name 4 parents: " .. event.element.parent.parent.parent.parent.name)
			local product_name = string.sub(event.element.name, string.len(recexplo.prefix_item_button_product) + 1)
			recexplo.cal_gui.tray_add_recipe(event, product_name, "where_used")
			recexplo.gui.update_to_selectet_product(player_index, product_name, "where_used")
			recexplo.gui.update(player_index)
			return

		elseif string.find(event.element.name, recexplo.prefix_item_button_ingredient, 1) ~= nil then	
			--game.print("name 4 parents: " .. event.element.parent.parent.parent.parent.name)
			local product_name = string.sub(event.element.name, string.len(recexplo.prefix_item_button_ingredient) + 1)
			recexplo.cal_gui.tray_add_recipe(event, product_name, "recipe")
			recexplo.gui.update_to_selectet_product(player_index, product_name, "recipe")
			recexplo.gui.update(player_index)
			return
			
		elseif string.find(event.element.name, recexplo.prefix_made_in, 1) ~= nil then
			local entity_name = string.sub(event.element.name, string.len(recexplo.prefix_made_in) + 1)
			for _, item_prototypes in pairs(game.item_prototypes) do
				if item_prototypes.place_result and item_prototypes.place_result.name == entity_name then
					local product_name = item_prototypes.name
					recexplo.gui.update_to_selectet_product(player_index, product_name, "recipe")
					recexplo.gui.update(player_index)
					return
				end
			end
			return
						
		elseif string.find(event.element.name, recexplo.prefix_made_in_player, 1) ~= nil then
			local recipe_name = string.sub(event.element.name, string.len(recexplo.prefix_made_in_player) + 1)
			local recipe = player.force.recipes[recipe_name]
			if recipe and recipe.enabled then
				if event.button == defines.mouse_button_type.left then
					player.begin_crafting{
						count = 1,
						recipe = recipe,
						silent = false
					}
				elseif event.button == defines.mouse_button_type.right then
					player.begin_crafting{
						count = 5,
						recipe = recipe,
						silent = false
					}
				end
			else
				player.print({"recexplo-consol.you-have-not-unlockt-the-recipe"})
			end
			return
			
		elseif string.find(event.element.name, recexplo.prefix_history_itme, 1) ~= nil then
			local pos = tonumber(string.sub(event.element.name, string.len(recexplo.prefix_history_itme) + 1))
			if event.button == defines.mouse_button_type.left then
				global[player_index].history.pos = pos
			elseif event.button == defines.mouse_button_type.right then
				recexplo.history.delete_pos(player_index, pos)
			end
			
			recexplo.history.load_selected(player_index)
			recexplo.gui.update(player_index)
			return
			
		elseif string.find(event.element.name, recexplo.prefix_recipe, 1) ~= nil then
			local recipe = string.sub(event.element.name, string.len(recexplo.prefix_recipe) + 1)
			
			--game.print("recipe name: "..tostring(recipe))
			if game.recipe_prototypes[recipe] then
				for _, force in pairs(game.forces) do
					for _, player in pairs(force.players) do
						if player.index == player_index and force.recipes[recipe] and force.recipes[recipe].enabled then
							--game.print("copy recipy")
							global[player_index].pasting_recipe = force.recipes[recipe]
							global[player_index].pasting_enabled = true

							player.clean_cursor()
							player.cursor_stack.set_stack("recexplo-pasting-tool")

							goto exit
						end
					end 
				end 
			end
			player.print({"recexplo-consol.you-have-not-unlockt-the-recipe"}) 
			return
			
		elseif string.find(event.element.name, recexplo.prefix_technology, 1) ~= nil then
			if player.mod_settings["recexplo-enable-experimental-features"].value then
				local tech_name = string.sub(event.element.name, string.len(recexplo.prefix_technology) + 1)
				local tech = player.force.technologies[tech_name]
				if tech and recexplo.had_opened_tech and recexplo.had_opened_tech == 0 then
					recexplo.gui.open_tech(player, tech)
				end
			else
				player.print({"recexplo-consol.enable-experimental-features"})
			end
			return
			
		elseif string.find(event.element.name, recexplo.prefix_display_recipe, 1) then
			local recipe_name = string.sub(event.element.name, string.len(recexplo.prefix_display_recipe) + 1)
			recexplo.gui.update_to_selectet_product(player_index, recipe_name, "single_recipe")
			recexplo.gui.update(player_index)
			return

		elseif event.element.name == "recexplo_history_button_back" then
			recexplo.history.go_backward(player_index)
			recexplo.gui.update(player_index)
			return
			
		elseif event.element.name == "recexplo_history_button_forward" then
			recexplo.history.go_forward(player_index)
			recexplo.gui.update_product_selection(player_index)
			--recexplo.gui.update(player_index)
			return
			
		elseif event.element.name == "recexplo_open_cal_gui" then
			if global[player_index].cal_gui.is_open then
				recexplo.cal_gui.close(player_index)
			else
				recexplo.cal_gui.open(player_index)
			end
			return
		elseif event.element.name == "recexplo_recipe_choose_elem_button" then
			if event.button == defines.mouse_button_type.right then
				local delete_pos = global[player_index].history.pos
				recexplo.history.delete_pos(player_index, delete_pos)
				recexplo.history.load_selected(player_index)
				recexplo.gui.update(player_index)
			end
			return
		elseif event.element.name == "recexplo_del_history" then
			recexplo.history.delete(player_index)
			recexplo.history.load_selected(player_index)
			recexplo.gui.update(player_index)
			return
		end
	end
	if global[player_index].cal_gui.is_open and global[player_index].gui.is_open then
		if event.element.name == "recexplo_record" then
			if global[player_index].cal_gui.is_recording then
				recexplo.cal_gui.change_record_mode(player_index, false)
			else
				recexplo.cal_gui.change_record_mode(player_index, true)
			end
			return
		elseif event.element.name == "recexplo_remove_all_cal" then
			recexplo.cal_gui.remove_all_cal(player_index)
			return
		elseif string.find(event.element.name, recexplo.prefix_remove_cal, 1) then
			local cal_recipe_index = string.sub(event.element.name, string.len(recexplo.prefix_remove_cal) + 1)
			cal_recipe_index = tonumber(cal_recipe_index)
			recexplo.cal_gui.delete_at_index(player_index, cal_recipe_index)
			return
		elseif string.find(event.element.name, recexplo.prefix_cal_made_in, 1) then
			local data = string.sub(event.element.name, string.len(recexplo.prefix_cal_made_in) + 1)
			local seperator_index = string.find(data, "/")
			local cal_recipe_index = tonumber(string.sub(data, 1, seperator_index - 1))
			local made_in_index = tonumber(string.sub(data, seperator_index + 1))

			--game.print("cal_recipe_index: " .. cal_recipe_index .. ", made_in_index: " .. made_in_index)
			if event.button == defines.mouse_button_type.left then
				local cal_gui =  global[player_index].cal_gui
				local cal_recipe = cal_gui[cal_recipe_index]
				if made_in_index ~= cal_recipe.made_in.selected_entity_index then
					recexplo.cal_gui.select_made_in(player_index, cal_recipe_index, made_in_index, event.element)
				end
			elseif event.button == defines.mouse_button_type.right then
				local cal_gui = global[player_index].cal_gui
				local entity = cal_gui[cal_recipe_index].made_in[made_in_index]

				for _, item_prototypes in pairs(game.item_prototypes) do
					if item_prototypes.place_result and item_prototypes.place_result.name == entity.name then
						local product_name = item_prototypes.name
						recexplo.gui.update_to_selectet_product(player_index, product_name, "recipe")
						recexplo.gui.update(player_index)
						return
					end
				end
			end
			return
		elseif string.find(event.element.name, recexplo.prefix_cal_item_button, 1) then
			local product_name = string.sub(event.element.name, string.len(recexplo.prefix_cal_item_button) + 1)
			recexplo.gui.update_to_selectet_product(player_index, product_name, "recipe")
			recexplo.gui.update(player_index)
			return
		end
	end
	::exit::
end)
script.on_event(defines.events.on_gui_elem_changed, function(event)
	if event.element.name == "recexplo_choose_elem_button" then
		local player_index = event.player_index
		if event.element.elem_value then
			if event.element.elem_value.type == "virtual" then
				event.element.elem_value = global[player_index].selctet_product_signal

			elseif not(global[player_index].selctet_product_signal) or event.element.elem_value.name ~= global[player_index].selctet_product_signal.name then
				global[player_index].selctet_product_signal = event.element.elem_value

				recexplo.history.add_current_state(player_index)
				recexplo.gui.update(player_index)
			end
		else
			local delete_pos = global[player_index].history.pos
			recexplo.history.delete_pos(player_index, delete_pos)
			recexplo.history.load_selected(player_index)
			recexplo.gui.update(player_index)
		end
	end
end)
script.on_event(defines.events.on_gui_checked_state_changed, function(event)
	local player_index = event.player_index
	if global[player_index].gui.is_open then
		if event.element.name == "radiobutton_dm_recipe" then
			if global[player_index].display_mode == "where_used" then
				global[player_index].display_mode = "recipe"
			end
			recexplo.history.save_state(player_index, global[player_index].history.pos)
			recexplo.gui.update(player_index)
	
		elseif event.element.name == "radiobutton_dm_where_used" then
			if global[player_index].display_mode == "recipe" then
				global[player_index].display_mode = "where_used"
			end
			recexplo.history.save_state(player_index, global[player_index].history.pos)
			recexplo.gui.update(player_index)
	
		elseif event.element.name == "recexplo_insert_mode" then
			global[player_index].history.insert_mode = event.element.state
		elseif event.element.name == "recexplo_manual_input_radiobutton" or event.element.name == "recexplo_manual_output_radiobutton"then
			local io_type
			if event.element.name == "recexplo_manual_input_radiobutton" then
				io_type = "input"
			elseif  event.element.name == "recexplo_manual_output_radiobutton" then
				io_type = "output"
			end

			local cal_gui = global[player_index].cal_gui
			
			local gui_root =  game.players[player_index].gui.left.recexplo_flow.recexplo_cal_gui_frame.recexplo_cal_gui_scroll_plane.recexplo_cal_gui_table
			local index, io_cal_recipe, layout_table
			if io_type == "input" then
				index = cal_gui.begin_index
				io_cal_recipe = cal_gui[index]
				layout_table = gui_root.input_cal_recipe_frame.io_cal_recipe_table.io_cal_recipe_main_layout_table
			elseif  io_type == "output" then
				index = cal_gui.end_index
				io_cal_recipe = cal_gui[index]
				layout_table = gui_root.output_cal_recipe_frame.io_cal_recipe_table.io_cal_recipe_main_layout_table
			end

			io_cal_recipe.made_in.selected_entity_index = -1

			local cal_made_in_table = layout_table.cal_main_made_in_table.cal_made_in_table
			cal_made_in_table.clear()

			recexplo.cal_gui.draw_cal_recipe_made_in(cal_made_in_table, index, io_cal_recipe)

			recexplo.cal_gui.update_stats(player_index)
		end
	end
end)
script.on_event(defines.events.on_gui_text_changed, function(event)
	local player_index = event.player_index
	if string.find(event.element.name, recexplo.prefix_cal_factories_amount, 1) then
		local cal_recipe_index = string.sub(event.element.name, string.len(recexplo.prefix_cal_factories_amount) + 1)
		cal_recipe_index = tonumber(cal_recipe_index)
		if cal_recipe_index then
			recexplo.cal_gui.update_factories(player_index, cal_recipe_index, event.element.text)
		end
	elseif event.element.name == "recexplo_manual_input_textfield" then
		recexplo.cal_gui.update_manual_io(player_index, "input", event.element.text)
	elseif event.element.name == "recexplo_manual_output_textfield" then
		recexplo.cal_gui.update_manual_io(player_index, "output", event.element.text)
	end
end)


script.on_event(defines.events.on_player_selected_area,function(event)
	--game.print("on_player_selected_area was fired")
	if event.item == "recexplo-pasting-tool" then
		--game.print("recexplo-pasting-tool was used")
		if global[event.player_index].pasting_enabled and global[event.player_index].pasting_recipe then
			--game.print("pasting_enabled")
			local pasting_category = global[event.player_index].pasting_recipe.category

			for _, entity in pairs(event.entities) do
				if entity.type == "assembling-machine" then
					if entity.prototype.crafting_categories[pasting_category] then
						--game.print("faund same category: ".. pasting_category)
						--game.print("try paste recipe")
						
						entity.set_recipe(global[event.player_index].pasting_recipe)
						--game.print("copied reciepy: "..global[event.player_index].pasting_recipe.name)
						global[event.player_index].pasting_enabled = false
						--game.print("cursor_stack.name: "..player.cursor_stack.name)
					end
				end	
			end 
		end 
	end
end)

script.on_event(defines.events.on_player_main_inventory_changed, function(event)
	local player = game.players[event.player_index]
	local inventory = player.get_inventory(defines.inventory.player_main)
	
	if inventory == nil then
		inventory = player.get_inventory(defines.inventory.god_main)
	end
	
	inventory.remove({name ="recexplo-pasting-tool", count = 1000})
end)

script.on_event("recexplo-open-gui", function(event)
	if global[event.player_index].gui.is_open then
		recexplo.gui.close(event.player_index)		
	else
		recexplo.gui.open(event.player_index)
	end
end)


script.on_configuration_changed(function(configuration_changed_data)
	--game.print("on_configuration_changed")
	
	for player_index, value in ipairs(global) do
		--delete open windows
		local gui_root = game.players[player_index].gui.left
		if gui_root.recexplo_gui_frame then
			gui_root.recexplo_gui_frame.destroy()
		end
		
		--delete history
		if global[player_index].cal_gui then global[player_index].cal_gui = {} end		
		if global[player_index].cal_gui.is_open then global[player_index].cal_gui.is_open = false end
		if global[player_index].cal_gui.is_recording then global[player_index].cal_gui.is_recording = false end
		if global[player_index].gui.is_open then global[player_index].gui.is_open = false end	
		
		if global[player_index].selctet_product_signal then global[player_index].selctet_product_signal = nil end--{ type = "item", name = "piercing-rounds-magazine"} end --crude-oil
		if global[player_index].display_mode then global[player_index].display_mode = "recipe" end --recipe, where_used, single_recipe
		if global[player_index].pasting_enabled then global[player_index].pasting_enabled = true end
		if global[player_index].pasting_recipe then global[player_index].pasting_recipe = nil end


		if global[player_index].history then global[player_index].history = {} end	
		if global[player_index].history.length then global[player_index].history.length = 0 end	
		if global[player_index].history.pos then global[player_index].history.pos = 0 end
		if global[player_index].history.insert_mode then global[player_index].history.insert_mode = true end

		if global[player_index].selctet_product_signal then
			global[player_index].selctet_product_signal = nil
		end
	end
end)
