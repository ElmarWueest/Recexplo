require "lua/initialisation"
require "lua/history"
require "lua/helperfunctions"

--open/close gui
function recexplo.gui.open(player_index)
	global[player_index].gui.is_open = true
	local gui = game.players[player_index].gui.left
	if gui["recexplo_flow"] == nil then
		gui = gui.add{
			type = "flow",
			name = "recexplo_flow",
			direction = "horizontal",
			style = "recexplo_flow"
		}
	else
		gui = gui.recexplo_flow
	end
	if gui["recexplo_gui_frame"] == nil then
		local window = gui.add{
			type = "frame",
			name = "recexplo_gui_frame",
			direction = "vertical",
			style = "recexplo_frame"
		}.add{
			type = "table",
			name = "recexplo_gui_table",
			column_count = 1
		}
		
		--title
		recexplo.gui.draw_title(window)

		--item selection
		recexplo.gui.draw_history_and_container(player_index, window)

		--controlls
		recexplo.gui.draw_controlls(player_index, window)
		
		--draw result	
		local result_gui_root = window.add{
			type = "table",
			name = "table_result_cpl",
			style = "table",
			column_count = 1
		}
		recexplo.gui.create_results(player_index, result_gui_root)
	end
	--if global[player_index].cal_gui.is_open then
		recexplo.cal_gui.open(player_index)
	--end
end
function recexplo.gui.close(player_index)
	global[player_index].gui.is_open = false
	if game.players[player_index].gui.left.recexplo_flow then
		if game.players[player_index].gui.left.recexplo_flow.recexplo_gui_frame then
			game.players[player_index].gui.left.recexplo_flow.destroy()
		end
	end
end
function recexplo.gui.update()
	--game.print("update gui")
	for _, player in pairs(game.players) do
		local player_index = player.index
		local update_flags = global[player_index].update_flags
		local cal_gui_update_flags = global[player_index].cal_gui_update_flags

		if global[player_index].gui.is_open then
			if update_flags.local_history then
				recexplo.gui.update_local_history(player_index)
			end
			if update_flags.global_history then
				if game.players[player_index].mod_settings["recexplo-enable-experimental-features"].value then
					recexplo.gui.update_global_history(player_index)
				end
			end
			if update_flags.results then
				recexplo.gui.update_results(player_index)
			end
			if update_flags.radio_buttons_display_mode then
				recexplo.gui.update_radio_buttons_display_mode(player_index)
			end
			if cal_gui_update_flags.results then
				recexplo.cal_gui.update(player_index)
			end
			if cal_gui_update_flags.stats then
				recexplo.cal_gui.update_stats(player_index)
			end
		end

		update_flags.local_history = false
		update_flags.global_history = false
		update_flags.results = false
		update_flags.radio_buttons_display_mode = false

		cal_gui_update_flags.results = false
		cal_gui_update_flags.stats = false
		cal_gui_update_flags.history = false
	end
end
--draw/update controlls
function recexplo.gui.draw_title(gui_root)
	local flow_title = gui_root.add{
		type = "flow",
		name = "flow_title",
		direction = "horizontal"
	}
	flow_title.add{
		type = "label",
		name = "window_title",
		caption = {"recexplo-gui.recipe-explorer"},
		style = "recexplo_gui_title"
	}
	flow_title.add{
		type = "button",
		name = "recexplo_open_cal_gui",
		caption = {"recexplo-gui.open-recipe-cal"},
		style = "recexplo_button_midium_font"
	}

end
function recexplo.gui.draw_history_and_container(player_index, gui_root)
	local gui_root = gui_root.add{
		type = "table",
		name = "table_item_selection",
		column_count = 2,
		style = "recexplo_table"
	}

	if game.players[player_index].mod_settings["recexplo-enable-experimental-features"].value then
		gui_root.add{
			type = "label",
			name = "lable_global_history",
			style = "recexplo_title_lst",
			caption = {"recexplo-gui.global-history"}
		}
		local global_history = gui_root.add{
			type = "table",
			name = "global_history_table",
			column_count = 1000,
			style = "recexplo_table"
		}
		recexplo.gui.draw_history(player_index, global[player_index].global_history, global_history)
	end

	gui_root.add{
		type = "label",
		name = "lable_local_history",
		style = "recexplo_title_lst",
		caption = {"recexplo-gui.local-history"}
	}
	local local_history = gui_root.add{
		type = "table",
		name = "local_history_table",
		column_count = 1000,
		style = "recexplo_table"
	}
	recexplo.gui.draw_history(player_index, global[player_index].local_history, local_history)

end
function recexplo.gui.draw_product_selection(player_index, gui_root)
	game.print("error funktion(draw_product_selection) no longer exist: " .. debug.traceback())
end
function recexplo.gui.draw_history(player_index, history, gui_root)
	--game.print("draw_product_selection")
	--game.print(tostring(gui_root))
	--recexplo.history.debug(history)

	if history.list.length > 0 then
		for i = 1, history.list.length,1 do
			if history.pos ~= -1 and i == history.pos then
				--game.print("draw_select_button i:"..tostring(i))
				recexplo.gui.draw_select_button(player_index, history, gui_root)
			else
				--game.print("draw_history_item i:"..tostring(i))
				recexplo.gui.draw_history_item(history, gui_root, i)
			end
		end
	else
		if history.pos ~= -1 then
			recexplo.gui.draw_select_button(player_index, history, gui_root)
		else
			gui_root.add{
				type = "choose-elem-button",
				name = history.placeholder_name,
				elem_type = "signal",
				style = "recexplo_not_selected_button"
			}
		end
	end
end
function recexplo.gui.draw_select_button(player_index, history, gui_root)
	--recexplo.gui.debug(player_index)

	--game.print("draw_select_button:")
	--recexplo.history.debug(history)

	local signal
	if history.pos ~= -1 and history.pos ~= 0 then
		signal = global[player_index].selctet_product_signal
	else
		signal = nil
	end	
	--recexplo.gui.debug_signal(signal)
	
	local frame = gui_root.add{
		type = "frame",
		name = "selected_history_item_frame",
		style = "recexplo_selection_frame"
	}

	if signal and signal.type == "recipe" then
		frame.add{
			type = "choose-elem-button",
			name = "recexplo_recipe_choose_elem_button",
			elem_type = "recipe",
			recipe = signal.name,
			style = "red_slot_button"
		}

	else
		frame.add{
			type = "choose-elem-button",
			name = "recexplo_signal_choose_elem_button",
			elem_type = "signal",
			signal = signal,
			style = "slot_button"
		}		
	end

	
end
function recexplo.gui.draw_history_item(history, gui_root, i)
	--recexplo.history.debug(history)
	--game.print(i)
	--game.print(tostring(gui_root))
	local i_signal = history.list[i].signal
	local button = {
		type = "sprite-button",
		name = history.prefix_history_itme .. tostring(i)
	}
	
	if i_signal.type == "item" then
		button.sprite = "item/" .. i_signal.name
		button.tooltip = game.item_prototypes[i_signal.name].localised_name
		button.style = "recexplo_not_selected_button"
	elseif i_signal.type == "fluid" then
		button.sprite = "fluid/" .. i_signal.name
		button.tooltip = game.fluid_prototypes[i_signal.name].localised_name
		button.style = "recexplo_not_selected_button"
	elseif i_signal.type == "recipe" then
		button.sprite = "recipe/" .. i_signal.name
		button.tooltip = game.recipe_prototypes[i_signal.name].localised_name
		button.style = "recexplo_red_not_selected_button"
	end
	--game.print("i: " .. i .. ", i_signal.type: " .. i_signal.type)
	gui_root.add(button)
end

function recexplo.gui.update_history(player_index)
	game.print("error funktion(update_history) no longer exist: " .. debug.traceback())
end
function recexplo.gui.update_local_history(player_index)
	local gui_root = game.players[player_index].gui.left.recexplo_flow.recexplo_gui_frame.recexplo_gui_table.table_item_selection.local_history_table
	gui_root.clear()
	recexplo.gui.draw_history(player_index, global[player_index].local_history, gui_root)
end
function recexplo.gui.update_global_history(player_index)
	local gui_root = game.players[player_index].gui.left.recexplo_flow.recexplo_gui_frame.recexplo_gui_table.table_item_selection.global_history_table
	gui_root.clear()
	recexplo.gui.draw_history(player_index, global[player_index].global_history, gui_root)
end


function recexplo.gui.draw_controlls(player_index, gui_root)
	--radiobutton test
	local controlls_table = gui_root.add{
		type = "table",
		name = "controlls_table",
		column_count = 10
	}
	recexplo.gui.draw_move_history_button(controlls_table)
	controlls_table.add{
		type = "sprite-button",
		name = "recexplo_del_history",
		sprite = "remove-icon",
		style = "recexplo_sprite_button"
	}

	local radiobutton_table = controlls_table.add{
		type = "table",
		name = "display_mode_table",
		column_count = 2,
		style = "recexplo_table"
	}
	recexplo.gui.draw_radio_buttons_display_mode(player_index, radiobutton_table)
end
function recexplo.gui.draw_move_history_button(gui_root)
	gui_root.add{
		type = "button",
		name = "recexplo_history_button_back",
		caption = "",
		style = "recexplo_back_button"
	}
	gui_root.add{
		type = "button",
		name = "recexplo_history_button_forward",
		caption = "",
		style = "recexplo_forward_button"
	}
end

function recexplo.gui.draw_radio_buttons_display_mode(player_index, gui_root)
	gui_root.add{
		type = "label",
		name = "display_mode_label_recipe",
		caption = {"recexplo-gui.find-recipe"}
	}
	gui_root.add{
		type = "radiobutton",
		name = "radiobutton_dm_recipe",
		state = true
	}
	gui_root.add{
		type = "label",
		name = "display_mode_label_where_used",
		caption = {"recexplo-gui.find-where-it-is-used"}
	}
	gui_root.add{
		type = "radiobutton",
		name = "radiobutton_dm_where_used",
		state = false
	}
	
	recexplo.gui.update_radio_buttons_display_mode(player_index)
end
function recexplo.gui.update_radio_buttons_display_mode(player_index)
	if global[player_index].gui.is_open then
		local gui_root = game.players[player_index].gui.left.recexplo_flow.recexplo_gui_frame.recexplo_gui_table.controlls_table.display_mode_table
		if global[player_index].display_mode == "recipe" then
			gui_root["radiobutton_dm_recipe"].state = true
			gui_root["radiobutton_dm_where_used"].state = false
		elseif global[player_index].display_mode == "where_used" then
			gui_root["radiobutton_dm_recipe"].state = false
			gui_root["radiobutton_dm_where_used"].state = true
		else
			gui_root["radiobutton_dm_recipe"].state = false
			gui_root["radiobutton_dm_where_used"].state = false
		end
	end
end




--create/update results/product
function recexplo.gui.update_to_selectet_product(player_index, name, display_mode)
	--game.print("update_to_selectet_product: " .. name .. " / " .. display_mode,{b=1})
	local signal = global[player_index].selctet_product_signal
	local history = recexplo.history.active_recipe_history(player_index)
	local signal_type
	if display_mode == "single_recipe" then
		signal_type = "recipe"
	else
		if game.item_prototypes[name] then
			signal_type = "item"
		elseif game.fluid_prototypes[name] then
			signal_type = "fluid"				
		else
			game.print("recexplo.gui.draw_poduct_button / this is no item or fluid: " .. name)
		end
	end

	local do_update = false
	if signal then
		if signal.name ~= name or signal.type ~= signal_type then
			do_update = true
		end
		for	i, product in pairs(history) do
			if tonumber(i) ~= nil then
				--game.print(debug.traceback())
				--game.print("product.name: " .. tostring(product.name) .. ", name: " .. tostring(name) .. ", product.type: " .. tostring(product.type) .. ", signal_type: " .. tostring(ignal_type))
				if product.name == name and product.type == signal_type then
					history.pos = i
					recexplo.history.load_selected(history)
				end
			end
		end
	else
		global[player_index].selctet_product_signal = {}
		signal = global[player_index].selctet_product_signal
		do_update = true
	end
	
	local do_gui_update = false
	if do_update then
		do_gui_update = true
		signal.name = name
		signal.type = signal_type
		global[player_index].display_mode = display_mode

		--game.print("signal.name: ".. signal.name,{g=0.3,b=1})
		--game.print("signal.type: ".. signal.type,{g=0.3,b=1})
		--game.print("global[player_index].display_mode: ".. global[player_index].display_mode,{g=0.3,b=1})

		recexplo.history.add_state(history, player_index, recexplo.history.explo_gui_pack_data(player_index))

	elseif display_mode ~= global[player_index].display_mode then
		do_gui_update = true
		global[player_index].display_mode = display_mode
		recexplo.history.save_state(history, recexplo.history.explo_gui_pack_data(player_index))
	end

	if do_gui_update then
		local update_flags = global[player_index].update_flags

		if history.name == "local" then
			update_flags.local_history = true
		elseif history.name == "global" then
			update_flags.global_history = true
		end

		update_flags.results = true
		update_flags.radio_buttons_display_mode = true

		if history.name == "global" then
			for _, player in pairs(game.players) do
				other_player_index = player.index

				if player_index ~= other_player_index then
					global[other_player_index].update_flags.global_history = true

					if global[other_player_index].global_history.pos == global[player_index].global_history.pos then
						global[other_player_index].global_history.pos = global[other_player_index].global_history.pos +1
					end
				end
			end
		end
	end

end
function recexplo.gui.update_results(player_index)
	--game.print("update results")
	local window_root = game.players[player_index].gui.left.recexplo_flow.recexplo_gui_frame.recexplo_gui_table
	
	window_root.table_result_cpl.clear()
	recexplo.gui.create_results(player_index, window_root.table_result_cpl)
end

function recexplo.gui.create_results(player_index, gui_root)
	if global[player_index].selctet_product_signal then
		recexplo.gui.create_all_recipes_container(player_index, gui_root)
	end
end
function recexplo.gui.create_all_recipes_container(player_index, gui_root)
	
	local style_name = "recexplo_recipes_scroll_plane_" .. game.players[player_index].mod_settings["recexplo-window-resolution-height"].value
	gui_root.add{
		type = "scroll-pane",
		name = "scroll_pane_recipes",
		style = style_name,
		vertical_scroll_policy = "auto",
		horizontal_scroll_policy = "auto"
	}
	local recipes_display_columns = game.players[player_index].mod_settings["recexplo-amount-of-recipes-columns"].value
	local recipe_gui_root = gui_root.scroll_pane_recipes.add{
		type = "table",
		name = "table_recipes",
		direction = "vertical",
		column_count = recipes_display_columns,
		style = "recexplo_recipe_table"
	}
	--search for recipes(recipes)
	if global[player_index].display_mode == "recipe" then
		recexplo.gui.create_all_recipes(player_index, recipe_gui_root)
	elseif global[player_index].display_mode == "where_used" then
		recexplo.gui.create_all_where_used(player_index, recipe_gui_root)		
	elseif global[player_index].display_mode == "single_recipe" then
		local recipe_name = global[player_index].selctet_product_signal.name
		local recipe = game.recipe_prototypes[recipe_name]
		recexplo.gui.draw_recipe(player_index, recipe_gui_root, recipe)
	else
		if global[player_index].display_mode then
			game.print("create_all_recipes_container display_mode: " .. global[player_index].display_mode)
		else
			game.print("create_all_recipes_container display_mode: nil")
		end
	end

end
function recexplo.gui.create_all_recipes(player_index, gui_root)
	local i = 0
	local display_hidden = game.players[player_index].mod_settings["recexplo-show-hidden"].value
	local max_recipes_count = game.players[player_index].mod_settings["recexplo-amount-displayed-recipes"].value
	--search for recipes
	--game.print("create_all_recipes")
	for _, recipe in pairs(game.players[player_index].force.recipes) do
		if recipe.valid and (display_hidden or (not(recipe.hidden) and not(display_hidden))) then
			for _, product in pairs(recipe.products) do
				if product.name == global[player_index].selctet_product_signal.name then
					if display_hidden or (recexplo.gui.is_researchable(player_index, recipe) and not(display_hidden)) then					
						recexplo.gui.draw_recipe(player_index, gui_root, recipe)
						i = i + 1

						if i > max_recipes_count then
							game.players[player_index].print({"recexplo-consol.only-the-first-recipes-are-displayed", max_recipes_count})
							goto done
						end
					end
				end
			end
		end
	end
	::done::
end
function recexplo.gui.create_all_where_used(player_index, gui_root)
	local i = 1
	local display_hidden = game.players[player_index].mod_settings["recexplo-show-hidden"].value
	local max_recipes_count = game.players[player_index].mod_settings["recexplo-amount-displayed-recipes"].value
	--game.print("create_all_where_used")
	--search for recipes(where used)
	for _, recipe in pairs(game.players[player_index].force.recipes) do
		if recipe.valid then
			if display_hidden or (not(recipe.hidden) and not(display_hidden)) then
				for _,  ingredient in pairs(recipe.ingredients) do
					if  ingredient.name == global[player_index].selctet_product_signal.name then
						if display_hidden or (recexplo.gui.is_researchable(player_index, recipe) and not(display_hidden)) then
							recexplo.gui.draw_recipe(player_index, gui_root, recipe)
							i = i + 1

							if i > max_recipes_count then
								game.players[player_index].print({"recexplo-consol.only-the-first-recipes-are-displayed", max_recipes_count})
								goto done
							end
						end
					end
				end
			end
		end
	end
	::done::
end
function recexplo.gui.is_researchable(player_index, recipe)
	local force = game.players[player_index].force
	if not(recipe.enabled) then
		for _,technology in pairs(force.technologies) do
			if technology.enabled then
				for _,modifier in pairs(technology.effects) do
					if modifier.type == "unlock-recipe" and modifier.recipe == recipe.name then
						return true
					end
				end
			end
		end
		return false
	else
		return true
	end
end


--draw recipe
function recexplo.gui.draw_recipe(player_index, gui_root, recipe)
	--game.print("draw recipe: " .. recipe.name)
	if gui_root[recexplo.prefix_recipe_frame .. recipe.name] then
		return
	end
	local frame = gui_root.add{
		type = "frame",
		name = recexplo.prefix_recipe_frame .. recipe.name,
		direction = "vertical",
		style = "recexplo_recipe_frame"
	}.add{
		type = "table",
		name = "recipe_table_".. recipe.name,
		column_count = 1
	}
	local table = frame.add{
		type = "table",
		name = "recipe_flow_title",
		column_count = 3
	}
	table.add{
		type = "label",
		name = "recipe_label_name",
		single_line = false,
		style = "recexplo_title_lst",
		caption = {"", recipe.localised_name, ":"}
	}

	recexplo.gui.draw_recipe_button(table, recipe)
	
	table.add{
		type = "sprite-button",
		name = recexplo.prefix_display_recipe .. recipe.name,
		sprite = "add-to-history-icon",
		tooltip = {"recexplo-gui.add-to-history"},
		style = "recexplo_sprite_button"
	}
	
	recexplo.gui.draw_recipe_energy(frame, recipe.energy)

	--products
	frame.add{
		type = "label",
		name = "label_product",
		style = "recexplo_sub_title_lst",
		caption = {"recexplo-gui.product"}
	}
	local i = 0
	for _, product in pairs(recipe.products) do
		recexplo.gui.draw_product(player_index, frame, product, i)
		i = i + 1
	end
	
	--ingredients
	frame.add{
		type = "label",
		name = "label_ingredients",
		style = "recexplo_sub_title_lst",
		caption = {"recexplo-gui.ingredients"}
	}
	for _, ingredient in pairs(recipe.ingredients) do
		recexplo.gui.draw_ingredient(player_index, frame, ingredient, i)
		i = i + 1
	end
	
	--made in
	recexplo.gui.draw_made_in (player_index, frame, recipe)
	--required technology
	recexplo.gui.draw_required_technologies(frame, recipe, player_index)
end
function recexplo.gui.draw_product(player_index, gui_root, product, i)
	--game.print(product.name)
	local product_table = gui_root.add{
		type = "table",
		name = "product_table_" .. tostring(i),
		column_count = 2,
		style = "table"
	}
	
	--calculate amount
	local amount
	if product.amount then
		amount = product.amount	
	else
		amount = ((product.amount_min + product.amount_max) / 2) * product.probability
	end
	
	recexplo.gui.draw_product_button(player_index, product_table, product, amount, "product")
end
function recexplo.gui.draw_ingredient(player_index, gui_root, ingredient, i)
	local ingredient_table = gui_root.add{
		type = "table",
		name = "ingredient_table_" .. tostring(i),
		column_count = 2,
		style = "table"
	}

	recexplo.gui.draw_product_button(player_index, ingredient_table, ingredient, ingredient.amount, "ingredient")
end
function recexplo.gui.draw_product_button(player_index, gui_root, product, amount, item_type)
	local item_button_name


	local sprite_button = {
		type = "sprite-button",
		style = "slot_button",
		tooltip = product.localised_name
	}

	if game.item_prototypes[product.name] then
		sprite_button.sprite = "item/" .. product.name
	elseif game.fluid_prototypes[product.name] then
		sprite_button.sprite = "fluid/" .. product.name
	end

	if item_type == "product" then
		sprite_button.name = recexplo.prefix_item_button_product .. product.name
	elseif item_type == "ingredient" then
		sprite_button.name = recexplo.prefix_item_button_ingredient .. product.name
	end
	gui_root.add(sprite_button)
	


	local label_amount = {
		type = "label",
		name = "label_amount_" .. product.name,
		style = "recexplo_object_naming_lst",
	}
	
	if product.type == "item" then
		label_amount.caption = {"", tostring(amount), " x ", game.item_prototypes[product.name].localised_name}
	elseif product.type == "fluid" then
		label_amount.caption = {"", tostring(amount), " x ", game.fluid_prototypes[product.name].localised_name}
	end
	gui_root.add(label_amount)

end
function recexplo.gui.draw_recipe_button(gui_root, recipe)
	local recipe_button = gui_root.add{
		type = "sprite-button",
		name = recexplo.prefix_recipe .. recipe.name,
		sprite = "recipe/".. recipe.name,
		tooltip = recipe.localised_name,
		style = "recexplo_sprite_button"
	}
end
function recexplo.gui.draw_recipe_energy(gui_root, recipe_energy)
	local table = gui_root.add{
		type = "table",
		name = "recexplo_table_recipe_energy",
		column_count = 2,
		style = "table"
	}
	table.add{
		type = "sprite-button",
		name = "recexplo_button_recipe_energy",
		style = "slot_button",
		sprite = "clock",
		tooltip = {"recexplo-gui.used-time"}
	}
	table.add{
		type = "label",
		name = "recexplo_label_recipe_energy",
		style = "recexplo_object_naming_lst",
		caption = {"",recipe_energy}
	}
end
function recexplo.gui.draw_made_in (player_index, gui_root, recipe)
	gui_root.add{
		type = "label",
		name = "label_made_in",
		style = "recexplo_sub_title_lst",
		caption = {"recexplo-gui.made-in"}
	}
	local made_in_table = gui_root.add{
		type = "table",
		name = "table_made_in_" .. recipe.name,
		style = "table",
		column_count = 5
	}
	--game.print("recipe.category: " .. recipe.category)
	local entity_list = recexplo.find_all_made_in_entity(player_index, recipe)
	
	for i = 0,entity_list.length do
		if entity_list[i].name == "character" then
			made_in_table.add{
				type = "sprite-button",
				name = recexplo.prefix_made_in_character .. recipe.name,
				style = "slot_button",
				sprite = "entity/" .. entity_list[i].name,
				tooltip = entity_list[i].localised_name
			}
		else
			made_in_table.add{
				type = "sprite-button",
				name = recexplo.prefix_made_in .. entity_list[i].name,
				style = "slot_button",
				sprite = "entity/" .. entity_list[i].name,
				tooltip = entity_list[i].localised_name
			}
		end 
	end
end
function recexplo.gui.draw_required_technologies(gui_root, recipe, player_index)
	gui_root.add{
		type = "label",
		name = "label_required_technologies",
		style = "recexplo_sub_title_lst",
		caption = {"recexplo-gui.unlocked-thru"}

	}
	local table = gui_root.add{
		type = "table",
		name = "technologies_table",
		column_count = 3,
		style = "table"
	}
	for _, technology in pairs(game.players[player_index].force.technologies) do
		if technology.enabled then
			--game.print("gefundene technologien: "..technology.name)
			for _,modifier in pairs(technology.effects) do
				if modifier.type == "unlock-recipe" and modifier.recipe == recipe.name then
					--game.print("draw technology button: ".. technology.mame)
					--hir i know that technology is required
					local tech_button = {
						type = "sprite-button",
						name = recexplo.prefix_technology..technology.name,
						sprite = "technology/"..technology.name,
						tooltip = technology.localised_name
					}
					--find style
					if technology.researched then
						tech_button.style = "recexplo_researched_technology_slot"
					else
						for _, prerequisite in pairs(technology.prerequisites) do
							if prerequisite and not prerequisite.researched then
								tech_button.style = "recexplo_unavailable_technology_slot"
								goto done
							end
						end
						tech_button.style = "recexplo_available_technology_slot"
						::done::
					end

					--prevent adding same history button twice
					local is_single = true
					for _, child in pairs(table.children) do 
						--game.print("child.name: " .. child.name .. ", tech_button.name, " .. tech_button.name)
						if child.name == tech_button.name then
							is_single = false
						end
					end
					if is_single then
						
						table.add(tech_button)
					end
				end
			end
		end
	end
end

--debug
function recexplo.gui.debug(player_index)
	local color = {r=math.random(0,255);g=math.random(0,255);b=math.random(0,255)}
	game.print("recexplo.gui variables:", color)

	local signal = global[player_index].selctet_product_signal
	recexplo.gui.debug_signal(signal, color)

	game.print("display_mode: " .. global[player_index].display_mode, color)
end
function recexplo.gui.debug_signal(signal, color)
	if color == nil then
		color =  {r=math.random(0,255);g=math.random(0,255);b=math.random(0,255)}
	end

	if signal then
		local text = "signal / pos: " .. signal.type .. " / name: " .. signal.name
		game.print(text, color)
	else
		game.print("signal: nil", color)
	end
end