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
			direction = "horizontal"
		}
	else
		gui = gui.recexplo_flow
	end
	if gui["recexplo_gui_frame"] == nil then
		local window = gui.add{
			type = "frame",
			name = "recexplo_gui_frame",
			direction = "vertical" --horizontal		vertical
		}.add{
			type = "table",
			name = "recexplo_gui_table",
			column_count = 1
		}
		
		--title
		recexplo.gui.draw_title(window)

		--item selection
		local table_item_selection = window.add{
			type = "table",
			name = "table_item_selection",
			column_count = 2000000,
			style = "table"
		}
		recexplo.gui.draw_product_selection(player_index, table_item_selection)
	
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
	if global[player_index].cal_gui.is_open then
		recexplo.cal_gui.open(player_index)
	end
end
function recexplo.gui.close(player_index)
	global[player_index].gui.is_open = false
	if game.players[player_index].gui.left.recexplo_flow then
		if game.players[player_index].gui.left.recexplo_flow.recexplo_gui_frame then
			game.players[player_index].gui.left.recexplo_flow.destroy()
		end
	end
end
function recexplo.gui.update(player_index)
	--game.print("update gui")
	recexplo.gui.update_product_selection(player_index)
	recexplo.gui.update_radio_buttons_display_mode(player_index)
	recexplo.gui.update_results(player_index)
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
function recexplo.gui.draw_product_selection(player_index, gui_root)
	--game.print("draw_product_selection")
	gui_root.add{
		type = "label",
		name = "lable_selcted_item",
		style = "recexplo_title_lst",
		caption = {"recexplo-gui.selected-item", ":"}
	}
	--recexplo.history.debug(player_index)
	local history = global[player_index].history
	if history.pos > 0 then
		for i = 1, history.length,1 do
			if i == history.pos then
				--game.print("draw_select_button i:"..tostring(i))
				recexplo.gui.draw_select_button(player_index, gui_root)
			else
				--game.print("draw_history_item i:"..tostring(i))
				recexplo.gui.draw_history_item(player_index, gui_root, i)
			end
		end
	else
		recexplo.gui.draw_select_button(player_index, gui_root)
	end
end
function recexplo.gui.draw_select_button(player_index, gui_root)
	local signal = global[player_index].selctet_product_signal
	local frame = gui_root.add{
		type = "frame",
		name = "selected_history_item_frame",
		style = "recexplo_selection_frame"
	}
	if signal and signal.type == "recipe" then
		local button = {
			type = "sprite-button",
			name = "recexplo_recipe_choose_elem_button",
			
			sprite = "recipe/" .. signal.name,
			tooltip = game.recipe_prototypes[signal.name].localised_name
		}
		if signal.type == "item" or signal.type == "fluid" then
			button.style = "slot_button"
		else
			button.style = "red_slot_button"
		end
		frame.add(button)
		return
	end

	frame.add{
		type = "choose-elem-button",
		name = "recexplo_choose_elem_button",
		elem_type = "signal",
		signal = global[player_index].selctet_product_signal
	}
	
end
function recexplo.gui.draw_history_item(player_index, gui_root, i)
	--recexplo.history.debug(player_index)
	local i_signal = global[player_index].history[i].signal
	local button = {
		type = "sprite-button",
		name = recexplo.prefix_history_itme .. tostring(i)
	}
	
	if i_signal.type == "item" then
		button.sprite = "item/" .. i_signal.name
		button.tooltip = game.item_prototypes[i_signal.name].localised_name
		button.style = "slot_button"
	elseif i_signal.type == "fluid" then
		button.sprite = "fluid/" .. i_signal.name
		button.tooltip = game.fluid_prototypes[i_signal.name].localised_name
		button.style = "slot_button"
	elseif i_signal.type == "recipe" then
		button.sprite = "recipe/" .. i_signal.name
		button.tooltip = game.recipe_prototypes[i_signal.name].localised_name
		button.style = "red_slot_button"
	end
	--game.print("i: " .. i .. ", i_signal.type: " .. i_signal.type)
	gui_root.add(button)
end

function recexplo.gui.update_product_selection(player_index)
	local gui_root = game.players[player_index].gui.left.recexplo_flow.recexplo_gui_frame.recexplo_gui_table.table_item_selection
	gui_root.clear()
	recexplo.gui.draw_product_selection(player_index, gui_root)
end


function recexplo.gui.draw_controlls(player_index, gui_root)
	--radiobutton test
	gui_root.add{
		type = "table",
		name = "controlls_table",
		column_count = 1
	}
	local insert_mode_table = gui_root.controlls_table.add{
		type = "table",
		name = "insert_mode_table",
		column_count = 5,
		style = "table"
	}
	recexplo.gui.draw_insert_mode(player_index, insert_mode_table)
	recexplo.gui.draw_history_button(insert_mode_table)
	insert_mode_table.add{
		type = "sprite-button",
		name = "recexplo_del_history",
		sprite = "remove-icon"
	}

	local radiobutton_table = gui_root.controlls_table.add{
		type = "table",
		name = "display_mode_table",
		column_count = 4,
		style = "table"
	}
	recexplo.gui.draw_radio_buttons_display_mode(player_index, radiobutton_table)
end
function recexplo.gui.draw_insert_mode(player_index, gui_root)
	gui_root.add{
		type = "label",
		name = "insert_mode_label",
		caption = {"recexplo-gui.insert-mode"}
	}
	gui_root.add{
		type = "checkbox",
		name = "recexplo_insert_mode",
		state = global[player_index].history.insert_mode
	}
end
function recexplo.gui.draw_history_button(gui_root)
	gui_root.add{
		type = "button",
		name = "recexplo_history_button_back",
		caption = "◄"
	}
	gui_root.add{
		type = "button",
		name = "recexplo_history_button_forward",
		caption = "►"
	}
end

function recexplo.gui.draw_radio_buttons_display_mode(player_index, gui_root)
	gui_root.add{
		type = "label",
		name = "display_mode_label_recipe",
		caption = {"recexplo-gui.find-recipe",":"}
	}
	gui_root.add{
		type = "radiobutton",
		name = "radiobutton_dm_recipe",
		state = true
	}
	gui_root.add{
		type = "label",
		name = "display_mode_label_where_used",
		caption = {"recexplo-gui.find-where-it-is-used",":"}
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
		for	i, product in pairs(global[player_index].history) do
			if tonumber(i) ~= nil then
				--game.print(debug.traceback())
				--game.print("product.name: " .. tostring(product.name) .. ", name: " .. tostring(name) .. ", product.type: " .. tostring(product.type) .. ", signal_type: " .. tostring(ignal_type))
				if product.name == name and product.type == signal_type then
					global[player_index].history.pos = i
					recexplo.history.load_selected(player_index)
				end
			end
		end
	else
		global[player_index].selctet_product_signal = {}
		signal = global[player_index].selctet_product_signal
		do_update = true
	end

	if do_update then
		signal.name = name
		signal.type = signal_type
		global[player_index].display_mode = display_mode

		--game.print("signal.name: ".. signal.name,{g=0.3,b=1})
		--game.print("signal.type: ".. signal.type,{g=0.3,b=1})
		--game.print("global[player_index].display_mode: ".. global[player_index].display_mode,{g=0.3,b=1})

		recexplo.history.add_current_state(player_index)

	elseif display_mode ~= global[player_index].display_mode then
		global[player_index].display_mode = display_mode
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
		name = "table_recies",
		direction = "vertical",
		column_count = recipes_display_columns
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
	if gui_root["recipe_frame" .. recipe.name] then
		return
	end
	local frame = gui_root.add{
		type = "frame",
		name = "recipe_frame" .. recipe.name,
		direction = "vertical"
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
		style = "recexplo_sprite_button"
	}
	
	recexplo.gui.draw_recipe_energy(frame, recipe.energy)

	--products
	local product_table = frame.add{
		type = "table",
		name = "products_flow_" .. recipe.name,
		column_count = 1,
		style = "table"
	}
	product_table.add{
		type = "label",
		name = "label_product",
		style = "recexplo_sub_title_lst",
		caption = {"recexplo-gui.product",":"}
	}
	local i = 0
	for _, product in pairs(recipe.products) do
		i = i + 1
		recexplo.gui.draw_product(player_index, product_table, product, i)
	end
	
	--ingredients
	local ingredient_table = frame.add{
		type = "table",
		name = "ingredients_flow_" .. recipe.name,
		style = "table",
		column_count = 1
	}
	ingredient_table.add{
		type = "label",
		name = "label_ingredients",
		style = "recexplo_sub_title_lst",
		caption = {"recexplo-gui.ingredients",":"}
	}
	for _, ingredient in pairs(recipe.ingredients) do
		recexplo.gui.draw_ingredient(player_index, ingredient_table, ingredient)
	end
	
	--made in
	recexplo.gui.draw_made_in (frame, recipe)
	--required technology
	recexplo.gui.draw_required_technologies(frame, recipe, player_index)
end
function recexplo.gui.draw_product(player_index, gui_root, product, i)
	--game.print(product.name)
	local product_table = gui_root.add{
		type = "table",
		name = "product_table_" .. product.name .. i,
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
function recexplo.gui.draw_ingredient(player_index, gui_root, ingredient)
	local ingredient_table = gui_root.add{
		type = "table",
		name = "ingredient_table_" .. ingredient.name,
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
function recexplo.gui.draw_made_in (gui_root, recipe)
	gui_root.add{
		type = "label",
		name = "label_ingredients",
		style = "recexplo_sub_title_lst",
		caption = {"recexplo-gui.made-in",":"}
	}
	local made_in_table = gui_root.add{
		type = "table",
		name = "table_made_in_" .. recipe.name,
		style = "table",
		column_count = 5
	}
	--game.print("recipe.category: " .. recipe.category)
	local entity_list = recexplo.find_all_made_in_entity(recipe)

	for i = 0,entity_list.length do
		if entity_list[i].name == "player" then
			made_in_table.add{
				type = "sprite-button",
				name = recexplo.prefix_made_in_player .. recipe.name,
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
		caption = {"recexplo-gui.unlocked-thru",":"}

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
						tech_button.style = "researched_technology_slot"
					else
						for _, prerequisite in pairs(technology.prerequisites) do
							if prerequisite and not prerequisite.researched then
								tech_button.style = "not_available_technology_slot"
								goto done
							end
						end
						tech_button.style = "available_technology_slot"
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