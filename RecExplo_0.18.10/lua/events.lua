
require "lua/explo_gui"
require "lua/history"

script.on_event(defines.events.on_tick, function(event)
	if game.tick % 31 == 0 then
		--[[for i, player in pairs(game.connected_players) do
			recexplo.create_global_table(event.player_index)
		end]]

		--debugg
		--game.print(global[event.player_index].filter_mode)
	end
	if recexplo.had_opened_tech then
		if recexplo.had_opened_tech > 1 then
			recexplo.had_opened_tech = recexplo.had_opened_tech - 1
		elseif recexplo.had_opened_tech == 1 then
			recexplo.gui.pasting_old_technology(event.player_index)
		end
	end
end)
script.on_event(defines.events.on_player_joined_game, function(event)
	recexplo.create_global_table(event.player_index)
end)

script.on_event(defines.events.on_gui_click, function(event)
	recexplo.create_global_table(event.player_index)

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
			goto exit

		elseif string.find(event.element.name, recexplo.prefix_item_button_ingredient, 1) ~= nil then	
			--game.print("name 4 parents: " .. event.element.parent.parent.parent.parent.name)
			local product_name = string.sub(event.element.name, string.len(recexplo.prefix_item_button_ingredient) + 1)
			recexplo.cal_gui.tray_add_recipe(event, product_name, "recipe")
			recexplo.gui.update_to_selectet_product(player_index, product_name, "recipe")
			goto exit
			
		elseif string.find(event.element.name, recexplo.prefix_made_in, 1) ~= nil then
			local entity_name = string.sub(event.element.name, string.len(recexplo.prefix_made_in) + 1)
			for _, item_prototypes in pairs(game.item_prototypes) do
				if item_prototypes.place_result and item_prototypes.place_result.name == entity_name then
					local product_name = item_prototypes.name
					recexplo.gui.update_to_selectet_product(player_index, product_name, "recipe")
					goto exit
				end
			end
			goto exit
						
		elseif string.find(event.element.name, recexplo.prefix_made_in_character, 1) ~= nil then
			local recipe_name = string.sub(event.element.name, string.len(recexplo.prefix_made_in_character) + 1)
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
			goto exit
			
		elseif string.find(event.element.name, recexplo.prefix_global_history_item, 1) ~= nil then
			local pos = tonumber(string.sub(event.element.name, string.len(recexplo.prefix_global_history_item) + 1))
			local history = global[player_index].global_history

			
			if event.button == defines.mouse_button_type.left then
				if history.pos == -1 then
					global[player_index].local_history.pos = -1
					global[other_player_index].update_flags.local_history = true
				end
				history.pos = pos

			elseif event.button == defines.mouse_button_type.right then
				recexplo.history.delete_pos(history, pos)

				for _, player in pairs(game.players) do
					local other_player_index = player.index
					global[other_player_index].update_flags.global_history = true

					if other_player_index ~= player_index and
					global[other_player_index].global_history.pos == pos then

						global[other_player_index].update_flags.results = true
					end
				end
			else
				goto exit
			end
	
			recexplo.history.explo_gui_unpack_data(player_index, history.list[history.pos])

			global[player_index].update_flags.global_history = true
			global[player_index].update_flags.results = true
			global[player_index].update_flags.radio_buttons_search_mode = true

			goto exit

		elseif string.find(event.element.name, recexplo.prefix_local_history_item, 1) ~= nil then
			local pos = tonumber(string.sub(event.element.name, string.len(recexplo.prefix_local_history_item) + 1))
			local history = global[player_index].local_history

			if event.button == defines.mouse_button_type.left then
				if history.pos == -1 then
					global[player_index].global_history.pos = -1
					global[other_player_index].update_flags.global_history = true
				end
				history.pos = pos
			elseif event.button == defines.mouse_button_type.right then
				recexplo.history.delete_pos(history, pos)

			end
			
			recexplo.history.explo_gui_unpack_data(player_index, history.list[history.pos])
			
			global[player_index].update_flags.local_history = true
			global[player_index].update_flags.results = true
			global[player_index].update_flags.radio_buttons_search_mode = true

			goto exit

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
			goto exit
			
		elseif string.find(event.element.name, recexplo.prefix_technology, 1) ~= nil then
			local tech_name = string.sub(event.element.name, string.len(recexplo.prefix_technology) + 1)
			local tech = player.force.technologies[tech_name]
			game.players[player_index].open_technology_gui(tech_name)
	
			goto exit
			
		elseif string.find(event.element.name, recexplo.prefix_display_recipe, 1) then
			local recipe_name = string.sub(event.element.name, string.len(recexplo.prefix_display_recipe) + 1)
			recexplo.gui.update_to_selectet_product(player_index, recipe_name, "single_recipe")
			goto exit

		elseif event.element.name == "recexplo_history_button_back" then
			local history = recexplo.history.active_recipe_history(player_index)
			
			if history.name == "global" then
				local pos = global[player_index].global_history.pos
				for _, player in pairs(game.players) do
					other_player_index = player.index

					if player_index ~= other_player_index then
						global[other_player_index].update_flags.global_history = true

						if global[other_player_index].global_history.pos == pos then
							global[other_player_index].global_history.pos = global[other_player_index].global_history.pos -1
						end
					end
				end
			end

			recexplo.history.go_backward(history)

			local update_flags = global[player_index].update_flags
			if history.name == "local" then
				update_flags.local_history = true
			elseif history.name == "global" then
				update_flags.global_history = true
			end
			goto exit
			
		elseif event.element.name == "recexplo_history_button_forward" then
			local history = recexplo.history.active_recipe_history(player_index)

			if history.name == "global" then
				local pos = global[player_index].global_history.pos
				for _, player in pairs(game.players) do
					other_player_index = player.index

					if player_index ~= other_player_index then
						global[other_player_index].update_flags.global_history = true

						if global[other_player_index].global_history.pos == pos then
							global[other_player_index].global_history.pos = global[other_player_index].global_history.pos +1
						end
					end
				end
			end

			recexplo.history.go_forward(history)
			local update_flags = global[player_index].update_flags
			if history.name == "local" then
				update_flags.local_history = true
			elseif history.name == "global" then
				update_flags.global_history = true
			end
			goto exit
			
		elseif event.element.name == "recexplo_open_cal_gui" then
			if global[player_index].cal_gui.is_open then
				recexplo.cal_gui.close(player_index)
			else
				recexplo.cal_gui.open(player_index)
			end
			goto exit
		elseif event.element.name == "recexplo_del_history" then
			local history = recexplo.history.active_recipe_history(player_index)
			recexplo.history.delete(history)
			recexplo.history.explo_gui_unpack_data(player_index, nil)

			local update_flags = global[player_index].update_flags
			if history.name == "local" then
				update_flags.local_history = true
			elseif history.name == "global" then
				update_flags.global_history = true
			end
			global[player_index].update_flags.results = true
			global[player_index].update_flags.radio_buttons_search_mode = true

			if history.name == "global" then
				for _, player in pairs(game.players) do
					other_player_index = player.index

					if player_index ~= other_player_index then
						global[other_player_index].update_flags.global_history = true

						if global[other_player_index].global_history.pos ~= -1 then
							recexplo.history.explo_gui_unpack_data(player_index, nil)
							global[other_player_index].update_flags.results = true
							global[other_player_index].update_flags.radio_buttons_search_mode = true
						end
					end
				end
			end
			goto exit

		end
	end
	if global[player_index].cal_gui.is_open and global[player_index].gui.is_open then
		if event.element.name == "recexplo_record" then
			if global[player_index].cal_gui.is_recording then
				recexplo.cal_gui.change_record_mode(player_index, false)
			else
				recexplo.cal_gui.change_record_mode(player_index, true)
			end
			goto exit
		elseif event.element.name == "recexplo_remove_all_cal" then
			recexplo.cal_gui.remove_all_cal(player_index)
			goto exit
		elseif string.find(event.element.name, recexplo.prefix_remove_cal, 1) then
			local cal_recipe_index = string.sub(event.element.name, string.len(recexplo.prefix_remove_cal) + 1)
			cal_recipe_index = tonumber(cal_recipe_index)
			recexplo.cal_gui.delete_at_index(player_index, cal_recipe_index)
			goto exit
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
						goto exit
					end
				end
			end
			goto exit
		elseif string.find(event.element.name, recexplo.prefix_cal_item_button, 1) then
			local product_name = string.sub(event.element.name, string.len(recexplo.prefix_cal_item_button) + 1)
			recexplo.gui.update_to_selectet_product(player_index, product_name, "recipe")
			goto exit
		end
	end
	::exit::
	recexplo.gui.update()
end)
script.on_event(defines.events.on_gui_elem_changed, function(event)
	recexplo.create_global_table(event.player_index)

	local was_chaned = false
	local history
	local player_index = event.player_index
	
	--game.print("on_gui_elem_changed")
	--game.print("global_history")
	--recexplo.history.debug(global[player_index].global_history)
	--game.print("local_history")
	--recexplo.history.debug(global[player_index].local_history)

	if event.element.name == "recexplo_recipe_choose_elem_button" or event.element.name == "recexplo_signal_choose_elem_button" then
		--game.print("clickt on button: recexplo_choose_elem_button")
		was_chaned = true
		history = recexplo.history.active_recipe_history(player_index)
	elseif event.element.name == global[player_index].global_history.placeholder_name then
		--chanching selected history to global history
		--game.print("clickt on button: " .. 	global[player_index].global_history.placeholder_name)
		was_chaned = true
		global[player_index].global_history.pos = 0
		global[player_index].local_history.pos = -1
		history = global[player_index].global_history

		local update_flags = global[player_index].update_flags
		update_flags.local_history = true
		update_flags.global_history = true

	elseif event.element.name == global[player_index].local_history.placeholder_name then
		--chanching selected history to local history
		--game.print("clickt on button: " .. global[player_index].local_history.placeholder_name)
		was_chaned = true
		global[player_index].global_history.pos = -1
		global[player_index].local_history.pos = 0
		history = global[player_index].local_history

		local update_flags = global[player_index].update_flags
		update_flags.local_history = true
		update_flags.global_history = true

	end


	--game.print("was_chaned: " .. tostring(was_chaned))
	--recexplo.history.debug(history)

	if was_chaned == true then
		local player_index = event.player_index
		if event.element.elem_value then
			--if new element is awailebel.
			if event.element.elem_value.type == "virtual" then
				event.element.elem_value = global[player_index].selctet_product_signal

			elseif not(global[player_index].selctet_product_signal) or event.element.elem_value.name ~= global[player_index].selctet_product_signal.name then
				if event.element.name == "recexplo_recipe_choose_elem_button" then
					global[player_index].selctet_product_signal.type = "recipe"
					global[player_index].selctet_product_signal.name = event.element.elem_value					
				elseif event.element.name == "recexplo_signal_choose_elem_button" or event.element.name == global[player_index].global_history.placeholder_name or event.element.name == global[player_index].local_history.placeholder_name then
					global[player_index].selctet_product_signal = event.element.elem_value
				end

				local data = recexplo.history.explo_gui_pack_data(player_index)
				
				recexplo.history.add_state(history, player_index, data)
				--recexplo.history.explo_gui_unpack_data(player_index, history.list[history.pos])
					
				local update_flags = global[player_index].update_flags
				if history.name == "local" then
					update_flags.local_history = true
				elseif history.name == "global" then
					update_flags.global_history = true
				end
	
				global[player_index].update_flags.results = true
				--global[player_index].update_flags.radio_buttons_search_mode = true
				if history.name == "global" then
					for _, player in pairs(game.players) do
						other_player_index = player.index

						if player_index ~= other_player_index then
							global[other_player_index].update_flags.global_history = true

							if global[other_player_index].global_history.pos >= global[player_index].global_history.pos then
								global[other_player_index].global_history.pos = global[other_player_index].global_history.pos +1								
							end
						end
					end
				end

			end
		else
			--if button is empty
			recexplo.history.delete_active_pos(history)
			recexplo.history.explo_gui_unpack_data(player_index, history.list[history.pos])

			local update_flags = global[player_index].update_flags
			if history.name == "local" then
				update_flags.local_history = true
			elseif history.name == "global" then
				update_flags.global_history = true
			end

			global[player_index].update_flags.results = true
			global[player_index].update_flags.radio_buttons_search_mode = true
			
			if history.name == "global" then
				for _, player in pairs(game.players) do
					other_player_index = player.index

					if player_index ~= other_player_index then
						global[other_player_index].update_flags.global_history = true

						if global[other_player_index].global_history.pos > global[player_index].global_history.pos then
							global[other_player_index].global_history.pos = global[other_player_index].global_history.pos -1
						end
						if global[other_player_index].global_history.pos == global[player_index].global_history.pos +1 then
							global[other_player_index].update_flags.results = true
							global[other_player_index].update_flags.radio_buttons_search_mode = true
						end
					end
				end
			end

		end
	end

	recexplo.gui.update()
	--recexplo.history.debug(history)
							
	--game.print("global_history")
	--recexplo.history.debug(global[player_index].global_history)
	--game.print("local_history")
	--recexplo.history.debug(global[player_index].local_history)

end)
script.on_event(defines.events.on_gui_checked_state_changed, function(event)
	recexplo.create_global_table(event.player_index)

	local player_index = event.player_index
	if global[player_index].gui.is_open then
		if event.element.name == "recexplo_radiobutton_dm_recipe" then
			if global[player_index].search_mode == "where_used" then
				global[player_index].search_mode = "recipe"
			end
			local history = recexplo.history.active_recipe_history(player_index)
			recexplo.history.save_state(history, recexplo.history.explo_gui_pack_data(player_index))

			global[player_index].update_flags.results = true
			global[player_index].update_flags.radio_buttons_search_mode = true

			for _, player in pairs(game.players) do
				other_player_index = player.index

				if player_index ~= other_player_index and
				global[other_player_index].global_history.pos == global[player_index].global_history.pos then
					global[other_player_index].update_flags.results = true
					global[other_player_index].update_flags.radio_buttons_search_mode = true
					
				end
			end

	
		elseif event.element.name == "recexplo_radiobutton_dm_where_used" then
			if global[player_index].search_mode == "recipe" then
				global[player_index].search_mode = "where_used"
			end
			local history = recexplo.history.active_recipe_history(player_index)
			recexplo.history.save_state(history, recexplo.history.explo_gui_pack_data(player_index))

			global[player_index].update_flags.results = true
			global[player_index].update_flags.radio_buttons_search_mode = true

			for _, player in pairs(game.players) do
				other_player_index = player.index

				if player_index ~= other_player_index and
				global[other_player_index].global_history.pos == global[player_index].global_history.pos then
					global[other_player_index].update_flags.results = true
					global[other_player_index].update_flags.radio_buttons_search_mode = true
					
				end
			end

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

			global[player_index].cal_gui_update_flags.stats = true
		elseif event.element.name == "recexplo_filter_checkbox" then
			if event.element.state then
				global[player_index].filter_mode = "researched"
			else
				global[player_index].filter_mode = "all"
			end
			global[player_index].update_flags.results = true
		end
	end

	recexplo.gui.update()
end)
script.on_event(defines.events.on_gui_text_changed, function(event)
	recexplo.create_global_table(event.player_index)

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
	recexplo.create_global_table(event.player_index)

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
	recexplo.create_global_table(event.player_index)

	--local inventory = game.players[event.player_index].get_inventory(defines.inventory.player_main)
	
	local player = game.players[event.player_index]
	local inventory = player.get_inventory(defines.inventory.character_main)

	if inventory == nil then
		inventory = player.get_inventory(defines.inventory.god_main)
	end

	inventory.remove({name ="recexplo-pasting-tool", count = 1000})
end)

script.on_event("recexplo-open-gui", function(event)
	recexplo.create_global_table(event.player_index)
	if global[event.player_index].gui.is_open then
		recexplo.gui.close(event.player_index)		
	else
		recexplo.gui.open(event.player_index)
	end
end)


script.on_configuration_changed(function(configuration_changed_data)
	recexplo.reset()
end)