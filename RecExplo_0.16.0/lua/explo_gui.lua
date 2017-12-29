require "lua/initialisation"

--open/close gui
function recexplo.gui.open(player_index)
	global[player_index].gui.is_open = true
	local gui = game.players[player_index].gui.left
	if gui["recexplo_gui_frame"] == nil then
		local window = gui.add{
			type = "frame",
			name = "recexplo_gui_frame",
			caption = {"recexplo-gui.recipe-explorer"},
			direction = "vertical" --horizontal		vertical
		}.add{
			type = "table",
			name = "recexplo_gui_table",
			column_count = 1
		}
	
		--item selection
		recexplo.gui.draw_product_selection(player_index, window)
	
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
end
function recexplo.gui.close (player_index)
	global[player_index].gui.is_open = false
	if game.players[player_index].gui.left.recexplo_gui_frame then
		game.players[player_index].gui.left.recexplo_gui_frame.destroy()
	end
end



--draw/update controlls
function recexplo.gui.draw_controlls(player_index, gui_root)
		--radiobutton test
	gui_root.add{
		type = "table",
		name = "controlls_table",
		column_count = 2
	}
	
	local radiobutton_table = gui_root.controlls_table.add{
		type = "table",
		name = "display_mod_table",
		column_count = 6,
		style = "table"
	}
	--todo add history arrow button
	recexplo.gui.draw_radio_buttons_display_mode(player_index, radiobutton_table)

	recexplo.gui.draw_history_button(radiobutton_table)
	
end

function recexplo.gui.draw_product_selection(player_index, gui_root)
	local table = gui_root.add{
		type = "table",
		name = "recexplo_table_item_selection",
		column_count = 2,
		style = "table"
	}
	table.add{
		type = "label",
		name = "lable_selcted_item",
		style = "recexplo_title_lst",
		caption = {"recexplo-gui.selected-item", ":"}
	}
	
	table.add{
		type = "choose-elem-button",
		name = "choose_elem_button",
		elem_type = "signal",
		signal = global[player_index].selctet_product_signal
	}

end

function recexplo.gui.draw_radio_buttons_display_mode(player_index, gui_root)
	gui_root.add{
		type = "label",
		name = "display_mod_label_recipe",
		caption = {"recexplo-gui.find-recipe",":"}
	}
	gui_root.add{
		type = "radiobutton",
		name = "radiobutton_dm_recipe",
		state = true
	}
	gui_root.add{
		type = "label",
		name = "display_mod_label_where_used",
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
		local gui_root = game.players[player_index].gui.left.recexplo_gui_frame.recexplo_gui_table.controlls_table.display_mod_table
		if global[player_index].display_mod == "recipe" then
			gui_root["radiobutton_dm_recipe"].state = true
			gui_root["radiobutton_dm_where_used"].state = false
		elseif global[player_index].display_mod == "where_used" then
			gui_root["radiobutton_dm_recipe"].state = false
			gui_root["radiobutton_dm_where_used"].state = true
		end
	end
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

function recexplo.gui.add_current_state_to_history(player_index)
	if global[player_index].history.length == global[player_index].history.pos then
		if global[player_index].history.length == recexplo.history.max_length then
			--hidden limit
			for i = (recexplo.history.max_delta + 1), recexplo.history.max_length, 1 do
				global[player_index].history[i - recexplo.history.max_delta] = global[player_index].history[i]
			end
			global[player_index].history.length = recexplo.history.max_length - recexplo.history.max_delta + 1
			global[player_index].history.pos = global[player_index].history.length
			local pos = global[player_index].history.pos

			recexplo.gui.save_state_in_history(player_index, pos)
		else
			-- grow in size
			global[player_index].history.length = global[player_index].history.length + 1
			global[player_index].history.pos = global[player_index].history.pos + 1
			local pos = global[player_index].history.pos
			
			recexplo.gui.save_state_in_history(player_index, pos)
		end
	else
		--backward, add_current_state_to_history
		global[player_index].history.pos = global[player_index].history.pos + 1
		global[player_index].history.length = global[player_index].history.pos
		local pos = global[player_index].history.length
		
		recexplo.gui.save_state_in_history(player_index, pos)
	end	
	
	--game.print("add history")
	recexplo.gui.history_debug(player_index)
end
function recexplo.gui.save_state_in_history(player_index, pos)
	global[player_index].history[pos] = {}
	global[player_index].history[pos].signal = {}
	global[player_index].history[pos].signal.name = global[player_index].selctet_product_signal.name
	global[player_index].history[pos].signal.type = global[player_index].selctet_product_signal.type
	global[player_index].history[pos].display_mod = global[player_index].display_mod
end

function recexplo.gui.history_go_forward(player_index)
	if global[player_index].history.pos < global[player_index].history.length then
		global[player_index].history.pos = global[player_index].history.pos + 1
		local pos = global[player_index].history.pos
		recexplo.gui.load_from_history(player_index, pos)

		recexplo.gui.update_results(player_index)
		recexplo.gui.update_radio_buttons_display_mode(player_index)

		--game.print("history_go_forward")
		recexplo.gui.history_debug(player_index)
	end
end
function recexplo.gui.history_go_backward(player_index)
	if global[player_index].history.pos > 1 then
		global[player_index].history.pos = global[player_index].history.pos - 1
		local pos = global[player_index].history.pos
		recexplo.gui.load_from_history(player_index, pos)

		recexplo.gui.update_results(player_index)
		recexplo.gui.update_radio_buttons_display_mode(player_index)

		--game.print("history_go_backward")
		recexplo.gui.history_debug(player_index)
	end
end
function recexplo.gui.load_from_history(player_index, pos)
	global[player_index].selctet_product_signal.name = global[player_index].history[pos].signal.name
	global[player_index].selctet_product_signal.type = global[player_index].history[pos].signal.type
	global[player_index].display_mod = global[player_index].history[pos].display_mod
end

function recexplo.gui.history_debug(player_index)
		local pos = global[player_index].history.pos
		local length = global[player_index].history.length
		local name = global[player_index].history[pos].signal.name
		local display_mod = tostring(global[player_index].history[pos].display_mod)
		--game.print("length: " .. length)
		--game.print("pos: " .. pos)
		--game.print("name: " .. name)
		--game.print("display_mod: " .. display_mod)
		local i = 1
		local text = ""
		::start::
		if global[player_index].history[i] then
			text = text .. "/ " .. tostring(i).. " " .. global[player_index].history[i].signal.name
			i = i + 1
			goto start
		end
		--game.print("stack: " .. text)
end


--create/update results/product
function recexplo.gui.update_selectet_product(player_index, product_name, display_mod)
	if global[player_index].selctet_product_signal.name ~= product_name then
		global[player_index].selctet_product_signal.name = product_name
		
		if game.item_prototypes[product_name] then
			global[player_index].selctet_product_signal.type = "item"
		elseif game.fluid_prototypes[product_name] then
			global[player_index].selctet_product_signal.type = "fluid"
		else
			game.print("recexplo.gui.draw_poduct_button / this is no item or fluid: " .. product_name)
		end
		
		global[player_index].display_mod = display_mod

		recexplo.gui.update_results(player_index)
		recexplo.gui.add_current_state_to_history(player_index)

	elseif display_mod ~= global[player_index].display_mod then
		global[player_index].display_mod = display_mod
		recexplo.gui.update_results(player_index)
		recexplo.gui.update_radio_buttons_display_mode(player_index)
	end
end
function recexplo.gui.update_results(player_index)
	--game.print("update results")
	local window_root = game.players[player_index].gui.left.recexplo_gui_frame.recexplo_gui_table
	
	window_root.table_result_cpl.clear()
	recexplo.gui.create_results(player_index, window_root.table_result_cpl)

	window_root.recexplo_table_item_selection.choose_elem_button.elem_value = global[player_index].selctet_product_signal
end


function recexplo.gui.create_results(player_index, gui_root)

	if global[player_index].display_mod == "recipe" then
		recexplo.gui.create_all_recipes_container(player_index, gui_root)
		
	elseif global[player_index].display_mod == "where_used" then
		recexplo.gui.create_all_where_used_container(player_index, gui_root)
		
	end
end

function recexplo.gui.create_all_recipes_container(player_index, gui_root)
	--game.print("create_all_recipes_container")
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
	recexplo.gui.create_all_recipes(player_index, recipe_gui_root)

end
function recexplo.gui.create_all_recipes(player_index, gui_root)
	local i = 0
	local display_hidden = game.players[player_index].mod_settings["recexplo-show-hidden"].value
	local max_recipes_count = game.players[player_index].mod_settings["recexplo-amount-displayed-recipes"].value
	--search for recipes
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

function recexplo.gui.create_all_where_used_container(player_index, gui_root)
	--game.print("create_all_where_used_container")
	local style_name = "recexplo_recipes_scroll_plane_" .. game.players[player_index].mod_settings["recexplo-window-resolution-height"].value
	gui_root.add{
		type = "scroll-pane",
		name = "scroll_pane_where_used",
		direction = "horizontal",
		style = style_name,
		vertical_scroll_policy = "auto",
		horizontal_scroll_policy = "auto"
	}
	local recipes_display_columns = game.players[player_index].mod_settings["recexplo-amount-of-recipes-columns"].value
	local where_used_gui_root = gui_root.scroll_pane_where_used.add{
		type = "table",
		name = "table_recies",
		direction = "horizontal",
		column_count = recipes_display_columns
	}

	--search for recipes(where used)
	recexplo.gui.create_all_where_used(player_index, where_used_gui_root)

end
function recexplo.gui.create_all_where_used(player_index, gui_root)
	local i = 1
	local display_hidden = game.players[player_index].mod_settings["recexplo-show-hidden"].value
	local max_recipes_count = game.players[player_index].mod_settings["recexplo-amount-displayed-recipes"].value
	--search for recipes(where used)
	for _, recipe in pairs(game.players[player_index].force.recipes) do
		if recipe.valid then
			if display_hidden or (not(recipe.hidden) and not(display_hidden)) then
				for _,  ingredient in pairs(recipe. ingredients) do
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
	local frame = gui_root.add{
		type = "frame",
		name = "recipe_frame_" .. recipe.name,
		direction = "vertical"
	}.add{
		type = "table",
		name = "recipe_table_".. recipe.name,
		column_count = 1
	}
	local table = frame.add{
		type = "table",
		name = "recipe_flow_title",
		column_count = 2,
		style = "table"
	}
	table.add{
		type = "label",
		name = "recipe_label_name",
		single_line = false,
		style = "recexplo_title_lst",
		caption = {"", recipe.localised_name, ": "}
	}
	recexplo.gui.draw_recipe_button(table, recipe)
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
	for i, product in pairs(recipe.products) do
		recexplo.gui.draw_product(player_index, product_table, product)
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

function recexplo.gui.draw_product(player_index, gui_root, product)
	local product_table = gui_root.add{
		type = "table",
		name = "product_table_" .. product.name,
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
		style = "slot_button",
		sprite = "recipe/".. recipe.name,
		tooltip = recipe.localised_name
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
	for _, entity in pairs(game.entity_prototypes) do
		if entity.crafting_categories ~= nil then
			for entity_crafting_categories, v in next, entity.crafting_categories do
				--game.print("entity_crafting_categories: " .. entity_crafting_categories)
				if entity_crafting_categories == recipe.category then
					--game.print("found entity_crafting_categories: " .. entity_crafting_categories)
					--game.print("found entity: " .. entity.name)
					
					if entity.name == "player" then
						made_in_table.add{
							type = "sprite-button",
							name = recexplo.prefix_made_in_player .. recipe.name,
							style = "slot_button",
							sprite = "entity/" .. entity.name,
							tooltip = entity.localised_name
						}
					else
						made_in_table.add{
							type = "sprite-button",
							name = recexplo.prefix_made_in .. entity.name,
							style = "slot_button",
							sprite = "entity/" .. entity.name,
							tooltip = entity.localised_name
						}
					end 
				end
			end
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
					table.add(tech_button)
				end
			end
		end
	end
end

