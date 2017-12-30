
require "lua/explo_gui"
require "lua/open_tech"

script.on_event(defines.events.on_tick, function(event)
	if game.tick % 20 == 0 then
		for i, player in pairs(game.connected_players) do
			--gui button
			--[[if player.gui.top.b_recexplo == nil then
				player.gui.top.add{type="button", name="b_recexplo", caption = "Recipe Explorer"}
			end]]
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
	
	--game.print("gui name:"..event.element.name)
	if event.element.name == "b_recexplo" then
		--player.print("clicked test button")
		if global[player_index].gui.is_open then
			recexplo.gui.close(player_index)		
		else
			recexplo.gui.open(player_index)
		end

	elseif global[player_index].gui.is_open then
	
		if	string.find(event.element.name, recexplo.prefix_item_button_product, 1) ~= nil then	
			local product_name = string.sub(event.element.name, string.len(recexplo.prefix_item_button_product) + 1)
			recexplo.gui.update_selectet_product(player_index, product_name, "where_used")
			recexplo.gui.update_radio_buttons_display_mode(player_index)

		elseif string.find(event.element.name, recexplo.prefix_item_button_ingredient, 1) ~= nil then	
			local product_name = string.sub(event.element.name, string.len(recexplo.prefix_item_button_ingredient) + 1)
			recexplo.gui.update_selectet_product(player_index, product_name, "recipe")
			recexplo.gui.update_radio_buttons_display_mode(player_index)

		elseif string.find(event.element.name, recexplo.prefix_made_in, 1) ~= nil then
			local entity_name = string.sub(event.element.name, string.len(recexplo.prefix_made_in) + 1)
			for _, item_prototypes in pairs(game.item_prototypes) do
				if item_prototypes.place_result and item_prototypes.place_result.name == entity_name then
					local product_name = item_prototypes.name
					recexplo.gui.update_selectet_product(player_index, product_name, "recipe")
					goto done
				end
			end
			::done::

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

							goto done
						end
					end 
				end 
			end
			player.print({"recexplo-consol.you-have-not-unlockt-the-recipe"}) 
			::done::
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
		elseif event.element.name == "recexplo_history_button_back" then
			recexplo.gui.history_go_backward(player_index)

		elseif event.element.name == "recexplo_history_button_forward" then
			recexplo.gui.history_go_forward(player_index)
		

		end
	end
end)
script.on_event(defines.events.on_gui_elem_changed, function(event)	
	if event.element.elem_value then
		if event.element.elem_value.type == "virtual" then
			event.element.elem_value = global[event.player_index].selctet_product_signal

		elseif event.element.elem_value.name ~= global[event.player_index].selctet_product_signal.name then
			global[event.player_index].selctet_product_signal = event.element.elem_value

			recexplo.gui.update_results(event.player_index)
			recexplo.gui.add_current_state_to_history(event.player_index)
		end
	else
		event.element.elem_value = global[event.player_index].selctet_product_signal
	end
end)
script.on_event(defines.events.on_gui_checked_state_changed, function(event)
	local player_index = event.player_index
	if event.element.name == "radiobutton_dm_recipe" then
		global[player_index].display_mod = "recipe"
	elseif event.element.name == "radiobutton_dm_where_used" then
		global[player_index].display_mod = "where_used"
	else
		return
	end
	recexplo.gui.update_radio_buttons_display_mode(player_index)
	recexplo.gui.update_results(player_index)
	recexplo.gui.save_state_in_history(player_index, global[player_index].history.pos)
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
						
						entity.recipe = global[event.player_index].pasting_recipe
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
	local inventory = game.players[event.player_index].get_inventory(defines.inventory.player_main)
	inventory.remove({name ="recexplo-pasting-tool", count = 1000})
end)

script.on_event("recexplo-open-gui", function(event)
	if global[event.player_index].gui.is_open then
		recexplo.gui.close(event.player_index)		
	else
		recexplo.gui.open(event.player_index)
	end
end)
