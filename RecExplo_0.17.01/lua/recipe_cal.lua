require "lua/initialisation"
require "lua/helperfunctions"


function recexplo.cal_gui.open(player_index)
	global[player_index].cal_gui.is_open = true

	recexplo.cal_gui.calculat_stats(player_index)

	local gui = game.players[player_index].gui.left
	if gui.recexplo_flow == nil then
		gui = gui.add{
			type = "flow",
			name = "recexplo_flow",
			style = "recexplo_flow"
		}
	else
		gui = gui.recexplo_flow
	end
	if gui.recexplo_cal_gui_frame == nil then
		local window = gui.add{
			type = "frame",
			name = "recexplo_cal_gui_frame",
			direction = "vertical"
		}
		recexplo.cal_gui.title(player_index, window)
		
		--container for recipy cal
		recexplo.cal_gui.create_all_recipe_cal_container(player_index, window)
		

	end
end
function recexplo.cal_gui.close(player_index)
	global[player_index].cal_gui.is_open = false
	recexplo.cal_gui.change_record_mode(player_index, false)
	
	local gui = game.players[player_index].gui.left
	if gui.recexplo_flow then
		gui = gui.recexplo_flow
		if gui.recexplo_cal_gui_frame then
			gui.recexplo_cal_gui_frame.destroy()
		end
	end
end
function recexplo.cal_gui.update(player_index)
	recexplo.cal_gui.calculat_stats(player_index)
	local table = game.players[player_index].gui.left.recexplo_flow.recexplo_cal_gui_frame.recexplo_cal_gui_scroll_plane.recexplo_cal_gui_table
	table.clear()
	recexplo.cal_gui.draw_cal(player_index, table)
end


function recexplo.cal_gui.change_record_mode(player_index, new_mode)
	--game.print("change_record_mode to: " .. tostring(new_mode))

	global[player_index].cal_gui.is_recording = new_mode
	if global[player_index].cal_gui.is_open then
		local gui = game.players[player_index].gui.left
		if gui.recexplo_flow then
			gui = gui.recexplo_flow 
			if gui.recexplo_cal_gui_frame then
				gui = gui.recexplo_cal_gui_frame.flow_title.recexplo_record
				if	new_mode then
					gui.caption = {"recexplo-gui.stop"}
				else
					gui.caption = {"recexplo-gui.record"}
				end
			end
		end
	end
end
function recexplo.cal_gui.select_made_in(player_index, cal_recipe_index, made_in_index, gui_element)
	--game.print(debug.traceback())
	local cal_gui = global[player_index].cal_gui
	local cal_recipe = cal_gui[cal_recipe_index]
	local io_type
	if cal_recipe_index == cal_gui.begin_index then
		io_type = "input"
	elseif cal_recipe_index == cal_gui.end_index then
		io_type = "output"
	end
	--game.print("cal_recipe_index: " .. cal_recipe_index .. ", made_in_index: " .. made_in_index .. ", io_type: " .. io_type)
	local cal_recipe = cal_gui[tonumber(cal_recipe_index)]
	local made_in_list = cal_recipe.made_in
	made_in_list.selected_entity_index = tonumber(made_in_index)

	local entity = made_in_list[made_in_list.selected_entity_index]
	
	if entity.name == "player" or entity.crafting_speed == nil then
		made_in_list.crafting_speed = 1
	else
		made_in_list.crafting_speed = entity.crafting_speed
	end

	recexplo.cal_gui.update_stats(player_index)

	local gui_root = gui_element.parent
	gui_root.clear()
	recexplo.cal_gui.draw_cal_recipe_made_in(gui_root, cal_recipe_index, cal_recipe)
	
	if io_type == "input" then
		gui_root.parent.manual_io_table.recexplo_manual_input_radiobutton.state = false
	elseif io_type == "output" then
		gui_root.parent.manual_io_table.recexplo_manual_output_radiobutton.state = false
	end
end
function recexplo.cal_gui.update_factories(player_index, cal_recipe_index, text)
	--game.print("update_factories: " .. player_index .. ", " .. cal_recipe_index .. ", " .. text)
	local factories_amoutn = tonumber(text)
	if factories_amoutn then
		local cal_gui = global[player_index].cal_gui
		cal_gui[cal_recipe_index].stats.factories_selected = factories_amoutn
		recexplo.cal_gui.update_stats(player_index)
	else
		if text ~= "" and text ~= nil then
			game.players[player_index].print({"recexplo-consol.enter-a-number"})
		end
	end

end

--add products and cal_recipe
function recexplo.cal_gui.tray_add_recipe(event, product_name, insert_mode)
	--game.print("cal_gui.tray_add_recipe")
	local player_index = event.player_index
	
	--game.print("event.element.parent.parent.parent.name: " .. event.element.parent.parent.parent.name)
	local recipe_name = string.sub(event.element.parent.parent.parent.name, string.len(recexplo.prefix_recipe_frame) + 1)
	local recipe = game.recipe_prototypes[recipe_name]

	if global[player_index].cal_gui.is_recording then
		--game.print("	is_recording")
		local check = recexplo.cal_gui.check_insertebility(player_index, recipe, product_name, insert_mode)
		--game.print("	inseting check: " .. check .. ", insert_mode: " .. insert_mode)
		if check == "both" then
			recexplo.cal_gui.add_recipe(player_index, recipe, product_name, insert_mode)
		elseif check == "only_product_name" then
			recexplo.cal_gui.add_only_product_name(player_index, product_name, insert_mode)
		--elseif check == "revers" then
			
		end

		recexplo.cal_gui.update(player_index)
	else
		--game.print("	is not recording")
	end

end
function recexplo.cal_gui.check_insertebility(player_index, recipe, product_name, insert_mode)
	--posible return value none, both, only_product_name
	local cal_gui = global[player_index].cal_gui
	
	--when this is the first element eg. list is empty
	if cal_gui.begin_index == 0 and cal_gui.end_index == 1 then
		return "both"
	end

	
	local index, previous_offset

	if insert_mode == "recipe" then
		index = cal_gui.begin_index
		previous_offset = 1
		
	elseif insert_mode == "where_used" then
		index = cal_gui.end_index
		previous_offset = -1

	else
		return "error"
	end

	local previous_product_index = index + (0.5 * previous_offset)
	local previous_recipe_index = index + previous_offset
	local previous_recipe_name = cal_gui[previous_recipe_index].recipe.name
	local previous_product_name = cal_gui[previous_product_index]

	if recipe.name == previous_recipe_name then
		return "only_product_name"
	end

	if insert_mode == "recipe" then
		for _, product in ipairs(recipe.products) do
			if product.name == previous_product_name then
				return "both"
			end
		end
		
	elseif insert_mode == "where_used" then
		for _, ingredient in ipairs(recipe.ingredients) do
			if ingredient.name == previous_product_name then
				return "both"
			end
		end
	else
		return "error"
	end



	return "none"
end
function recexplo.cal_gui.add_recipe(player_index, recipe, product_name, insert_mode)
	--game.print("cal_gui.add_recipe")
	local cal_gui = global[player_index].cal_gui
	
	recexplo.cal_gui.add_implicit_product(player_index, recipe, insert_mode)
	
	local index, product_index	
	if insert_mode == "recipe" then
		index = cal_gui.begin_index
		product_index = index - 0.5

		cal_gui[index - 1] = cal_gui[index]
		
		cal_gui.begin_index = cal_gui.begin_index - 1
	elseif insert_mode == "where_used" then
		index = cal_gui.end_index
		product_index = index + 0.5

		cal_gui[index + 1] = cal_gui[index]

		cal_gui.end_index = cal_gui.end_index + 1
	end

	local made_in_list = recexplo.cal_gui.get_production_facilities(player_index, recipe)

	local stats = {
		standard_consumption_rate = 0,
		standard_production_rate = 0,
		consumption_rate = 0,
		production_rate = 0,
		factories_selected = 1,
		factories_for_demand = 0,
		factories_for_consumption = 0
	}

	cal_gui[index] = {
		recipe = recipe,
		made_in = made_in_list,
		stats = stats
	}
	cal_gui[product_index] = product_name

	--game.print("begin_index: " .. cal_gui.begin_index .. ", end_index: " .. cal_gui.end_index)
end
function recexplo.cal_gui.add_implicit_product(player_index, recipe, insert_mode)
	local cal_gui = global[player_index].cal_gui

	local index, product_index, product_name
	local i = 0
	if insert_mode == "recipe" then
		index = cal_gui.begin_index
		product_index = index + 0.5
	
		for _,product in pairs(recipe.products) do
			product_name = product.name
			i = i + 1
		end
		
	elseif insert_mode == "where_used" then
		index = cal_gui.end_index
		product_index = index - 0.5
		
		for _,ingredient in pairs(recipe.ingredients) do
			product_name = ingredient.name
			i = i + 1
		end
	end
	if i > 1 then
		return
	end

	if cal_gui[product_index] == nil then
		cal_gui[product_index] = product_name
	end
end
function recexplo.cal_gui.add_only_product_name(player_index, product_name, insert_mode)
	local cal_gui = global[player_index].cal_gui
	if insert_mode == "recipe" then
		cal_gui[cal_gui.begin_index + 0.5] = product_name
	elseif insert_mode == "where_used" then
		cal_gui[cal_gui.end_index - 0.5] = product_name
	end
end
function recexplo.cal_gui.get_production_facilities(player_index, recipe)
	local made_in_list = recexplo.find_all_made_in_entity(player_index, recipe)
	made_in_list.selected_entity_index = 0

	local entity = made_in_list[made_in_list.selected_entity_index]
	if entity.name == "player"  or entity.crafting_speed == nil then
		made_in_list.crafting_speed = 1
	else
		made_in_list.crafting_speed = entity.crafting_speed
	end
	
	return made_in_list
end

--delete products and cal_recipe
function recexplo.cal_gui.remove_all_cal(player_index)
	local cal_gui = global[player_index].cal_gui
	for i = cal_gui.begin_index, cal_gui.end_index do
		if cal_gui[i]then
			cal_gui[i] = nil
		end
		if cal_gui[i + 0.5]then
			cal_gui[i + 0.5] = nil
		end
	end
	cal_gui.begin_index = 0
	cal_gui.end_index = 1
	recexplo.cal_gui.add_io(player_index, "input")
	recexplo.cal_gui.add_io(player_index, "output")
	recexplo.cal_gui.update(player_index)
end
function recexplo.cal_gui.delete_at_index(player_index, cal_recipe_index)
	local cal_gui = global[player_index].cal_gui
	local length = cal_gui.end_index - cal_gui.begin_index
	if length == 2 then
		recexplo.cal_gui.remove_all_cal(player_index)
	elseif cal_recipe_index - cal_gui.begin_index <= cal_gui.end_index - cal_recipe_index then
		--delete to begin
		for i = cal_recipe_index, cal_gui.begin_index + 0.5, -0.5 do
			if cal_gui[i] then
				cal_gui[i] = nil
			end
		end
		cal_gui[cal_recipe_index] = cal_gui[cal_gui.begin_index]
		cal_gui.begin_index = cal_recipe_index
	else
		--delete to end
		for i = cal_recipe_index, cal_gui.end_index - 0.5, 0.5 do
			if cal_gui[i] then
				cal_gui[i] = nil
			end
		end
		cal_gui[cal_recipe_index] = cal_gui[cal_gui.end_index]
		cal_gui.end_index = cal_recipe_index
	end
	recexplo.cal_gui.update(player_index)
end
--cal stats & update stats gui
function recexplo.cal_gui.update_stats(player_index)
	recexplo.cal_gui.calculat_stats(player_index)

	local cal_gui = global[player_index].cal_gui
	local begin_index = cal_gui.begin_index + 1
	local end_index = cal_gui.end_index - 1

	recexplo.cal_gui.update_stats_gui(player_index, begin_index - 1, "input")
	for i = begin_index, end_index do
		recexplo.cal_gui.update_stats_gui(player_index, i)
	end
	recexplo.cal_gui.update_stats_gui(player_index, end_index + 1, "output")
end
function recexplo.cal_gui.calculat_stats(player_index)
	local cal_gui = global[player_index].cal_gui
	if cal_gui.end_index - cal_gui.begin_index > 0 then
		local begin_index = cal_gui.begin_index + 1
		local end_index = cal_gui.end_index - 1
		
		for i = begin_index, end_index do
			recexplo.cal_gui.calculat_recipes(cal_gui[i], cal_gui[i+0.5], cal_gui[i-0.5])
		end
		recexplo.cal_gui.update_io(player_index, "input")
		recexplo.cal_gui.update_io(player_index, "output")
		for i = begin_index, end_index do
			recexplo.cal_gui.calculat_factories(player_index, i)
		end
	end
end
function recexplo.cal_gui.calculat_recipes(cal_recipe, product_name, ingredient_name)
	local stats = cal_recipe.stats
	--game.print("debug log !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	if product_name then
		local product_amount
		-- calculate product_amount
		for _, product in pairs(cal_recipe.recipe.products) do
			if product.name == product_name then
				if product.amount then
					product_amount = product.amount	
				else
					product_amount = ((product.amount_min + product.amount_max) / 2) * product.probability
				end
			end
		end
		stats.standard_production_rate = (product_amount * cal_recipe.made_in.crafting_speed) / cal_recipe.recipe.energy
		stats.production_rate = stats.standard_production_rate * stats.factories_selected
	end
	if ingredient_name then
		local ingredient_amount
		for _, ingredient in pairs(cal_recipe.recipe.ingredients) do
			if ingredient.name == ingredient_name then
				ingredient_amount = ingredient.amount
			end
		end
		stats.standard_consumption_rate = (ingredient_amount * cal_recipe.made_in.crafting_speed) / cal_recipe.recipe.energy
		stats.consumption_rate = stats.standard_consumption_rate * stats.factories_selected
	end

end
function recexplo.cal_gui.calculat_factories(player_index, cal_recipe_index)
	local cal_gui = global[player_index].cal_gui
	if cal_gui[cal_recipe_index - 1] then
		local production_rate = cal_gui[cal_recipe_index - 1].stats.production_rate
		local standard_consumption_rate = cal_gui[cal_recipe_index].stats.standard_consumption_rate
		cal_gui[cal_recipe_index].stats.factories_for_consumption = production_rate / standard_consumption_rate
	end
	if cal_gui[cal_recipe_index + 1] then
		local consumption_rate = cal_gui[cal_recipe_index + 1].stats.consumption_rate
		local standard_production_rate = cal_gui[cal_recipe_index].stats.standard_production_rate
		cal_gui[cal_recipe_index].stats.factories_for_demand = consumption_rate / standard_production_rate 
	end
end

function recexplo.cal_gui.update_stats_gui(player_index, cal_recipe_index, io_type)
	local cal_gui = global[player_index].cal_gui
	local cal_recipe = cal_gui[cal_recipe_index]
	local stats = cal_recipe.stats
	
	local gui_root = game.players[player_index].gui.left.recexplo_flow.recexplo_cal_gui_frame.recexplo_cal_gui_scroll_plane.recexplo_cal_gui_table
	local layout_table
	if io_type == nil then
		layout_table = gui_root["cal_recipe_frame_" .. cal_recipe.recipe.name]["cal_recipe_table" .. cal_recipe.recipe.name].cal_recipe_main_layout_table
	elseif io_type == "input" then
		--if no input return
		local i = cal_gui.begin_index + 0.5
		if not cal_gui[i] then
			return
		end
		layout_table = gui_root.input_cal_recipe_frame.io_cal_recipe_table.io_cal_recipe_main_layout_table
	elseif io_type == "output" then
		--if no output return
		local i = cal_gui.end_index - 0.5
		if not cal_gui[i] then
			return
		end	
		layout_table = gui_root.output_cal_recipe_frame.io_cal_recipe_table.io_cal_recipe_main_layout_table
	end
		
	local stats_table = layout_table.production_stats_table
	--2,2
	stats_table.label_standard_consumption_rate.caption = round(stats.standard_consumption_rate, 2)
	--3,2
	stats_table.label_consumption_rate.caption = round(stats.consumption_rate, 2)
	--2,3
	stats_table.label_standard_production_rate.caption = round(stats.standard_production_rate, 2)
	--3,3
	stats_table.label_production_rate.caption = round(stats.production_rate, 2)
	
	local cal_factories_table = layout_table.layout_table
	--2,1
	cal_factories_table.table_pos_2_1.caption = round(stats.factories_for_consumption, 2)
	--2,2
	cal_factories_table.table_pos_2_2.caption = round(stats.factories_for_demand, 2)
end


--draw
function recexplo.cal_gui.title(player_index, gui_root)
	local flow = gui_root.add{
		type = "flow",
		name = "flow_title",
		direction = "horizontal"
	}
	flow.add{
		type = "label",
		name = "title",
		style = "recexplo_gui_title",
		caption = {"recexplo-gui.recipe-calculator"}
	}
	flow.add{
		type = "sprite-button",
		name = "recexplo_remove_all_cal",
		sprite = "remove-icon",
		style = "recexplo_sprite_button"
	}
	flow.add{
		type = "button",
		name = "recexplo_record",
		style = "recexplo_button_midium_font"
	}
	if global[player_index].cal_gui.is_recoding then
		flow.recexplo_record.caption = {"recexplo-gui.stop"}
	else
		flow.recexplo_record.caption = {"recexplo-gui.record"}
	end
end
function recexplo.cal_gui.create_all_recipe_cal_container(player_index, gui_root)
	local style_name = "recexplo_recipes_scroll_plane_" .. tostring(game.players[player_index].mod_settings["recexplo-window-resolution-height"].value + 110)
	local frame = gui_root.add{
		type = "scroll-pane",
		name = "recexplo_cal_gui_scroll_plane",
		style = style_name
	}
	local container = frame.add{
		type = "table",
		name = "recexplo_cal_gui_table",
		column_count = 1
	}
	container.style.column_alignments[1] = "middle-center"
	
	
	recexplo.cal_gui.draw_cal(player_index, container)
end

function recexplo.cal_gui.draw_cal(player_index, gui_root)
	--game.print("cal_gui.draw_cal")
	local cal_gui = global[player_index].cal_gui
	local i = cal_gui.begin_index + 0.5

	--io begin
	if cal_gui[i] then
		--game.print("draw begin io")
		recexplo.cal_gui.draw_io(player_index, gui_root, "input")
	end
	--products/recipes
	while i <= cal_gui.end_index - 0.5 do
		
		if i == math.floor(i) then
			--game.print("    is a recipe, i: " .. i)
			if cal_gui[i] then
				recexplo.cal_gui.draw_recipe_cal(player_index, gui_root, cal_gui[i], i)
			end
		else
			--game.print("    is a product, i: " .. i)
			if cal_gui[i] then
				local product_name = cal_gui[i]
				local product, product_type
				if game.item_prototypes[product_name] then
					product = game.item_prototypes[product_name]
					product_type = "item"
				elseif game.fluid_prototypes[product_name] then
					product = game.fluid_prototypes[product_name]
					product_type = "fluid"
				end
				recexplo.cal_gui.draw_product_button(player_index, gui_root, product, product_type, i)
			end
		end
		i = i + 0.5
	end
	-- last drawn index
	i = i - 0.5
	--io output
	if cal_gui[i] then
		recexplo.cal_gui.draw_io(player_index, gui_root, "output")
	end
end
function recexplo.cal_gui.draw_recipe_cal(player_index, gui_root, cal_recipe, cal_recipe_index)
	--game.print("cal_gui.draw_recipe_cal")
	local frame = gui_root.add{
		type = "frame",
		name = "cal_recipe_frame_" .. cal_recipe.recipe.name,
		style = "recexplo_recipe_frame"
	}
	local table = frame.add{
		type = "table",
		name = "cal_recipe_table" .. cal_recipe.recipe.name,
		column_count = 1
	}
	recexplo.cal_gui.draw_cal_recipe_title(table, cal_recipe, cal_recipe_index)

	table = table.add{
		type = "table",
		name = "cal_recipe_main_layout_table",
		column_count = 3
	}
	recexplo.cal_gui.draw_cal_recipe_made_in_container(table, cal_recipe_index, cal_recipe)
	recexplo.cal_gui.draw_production_stats(table, cal_recipe.stats, cal_recipe_index)
	recexplo.cal_gui.draw_cal_factories(table, cal_recipe.stats)
end
function recexplo.cal_gui.draw_cal_recipe_title(gui_root, cal_recipe, cal_recipe_index)
	local recipe = cal_recipe.recipe
	local table = gui_root.add{
		type = "table",
		name = "title_table",
		column_count = 4
	}
	table.add{
		type = "label",
		name = "title_lebel",
		style = "recexplo_title_lst",
		caption = {"", recipe.localised_name, ":"}
	}
	recexplo.gui.draw_recipe_button(table, recipe)
	table.add{
		type = "sprite-button",
		name = recexplo.prefix_display_recipe .. recipe.name,
		--sprite = "eye-icon",
		sprite = "add-to-history-icon",
		tooltip = {"recexplo-gui.add-to-history"},
		style = "recexplo_sprite_button"
	}
	table.add{
		type = "sprite-button",
		name =  recexplo.prefix_remove_cal .. cal_recipe_index,
		sprite = "remove-icon",
		style = "recexplo_sprite_button"
	}
end
function recexplo.cal_gui.draw_cal_recipe_made_in_container(gui_root, cal_recipe_index, cal_recipe)
	local table = gui_root.add{
		type = "table",
		name = "cal_main_made_in_table",
		column_count = 1
	}
	table.add{
		type = "label",
		name = "cel_made_in_title",
		style = "recexplo_sub_title_lst",
		caption = {"recexplo-gui.select-factory"}
	}
	local table = table.add{
		type = "table",
		name = "cal_made_in_table",
		style = "recexplo_table",
		column_count = 4
	}
	recexplo.cal_gui.draw_cal_recipe_made_in(table, cal_recipe_index, cal_recipe)
end
function recexplo.cal_gui.draw_cal_recipe_made_in(gui_root, cal_recipe_index, cal_recipe)

	local entity_list = cal_recipe.made_in
	for i = 0, entity_list.length - 1 do
		local entity = entity_list[i]
		local container
		if i == entity_list.selected_entity_index then
			gui_root.add{
				type = "frame",
				name = "selection",
				style = "recexplo_selection_frame"
			}.add{
				type = "sprite-button",
				name = recexplo.prefix_cal_made_in .. cal_recipe_index .. "/" .. i,
				style = "slot_button",
				sprite = "entity/" .. entity.name,
				tooltip = entity.localised_name
			}
		else
			gui_root.add{
				type = "sprite-button",
				name = recexplo.prefix_cal_made_in .. cal_recipe_index .. "/" .. i,
				style = "recexplo_not_selected_button",
				sprite = "entity/" .. entity.name,
				tooltip = entity.localised_name
			}
		end
	end
end
function recexplo.cal_gui.draw_production_stats(gui_root, stats, cal_recipe_index)
	local main_table = gui_root.add{
		type = "table",
		name = "production_stats_table",
		style = "recexplo_stats_table",
		column_count = 3,
		draw_vertical_lines = true,
		draw_horizontal_lines = true
	}

	--1,1
	main_table.add{
		type = "label",
		name = "label_factories",
		style = "recexplo_label_stats",
		caption = {"recexplo-gui.factories"}
	}

	--2,1
	main_table.add{
		type = "label",
		name = "label_factories_amoutn",
		style = "recexplo_label_stats",
		caption = "1"
	}

	--3,1
	main_table.add{
		type = "textfield",
		name = recexplo.prefix_cal_factories_amount .. cal_recipe_index,
		text = stats.factories_selected,
		style = "recexplo_textfield_factories_amount"
	}

	--1,2
	main_table.add{
		type = "label",
		name = "consumption",
		style = "recexplo_label_stats",
		caption = {"recexplo-gui.consumption/s"}
	}

	--2,2
	main_table.add{
		type = "label",
		name = "label_standard_consumption_rate",
		style = "recexplo_label_stats",
		caption = round(stats.standard_consumption_rate, 2)
	}

	--3,2
	main_table.add{
		type = "label",
		name = "label_consumption_rate",
		style = "recexplo_label_stats",
		caption = round(stats.consumption_rate, 2)
	}

	--1,3
	main_table.add{
		type = "label",
		name = "production",
		style = "recexplo_label_stats",
		caption = {"recexplo-gui.production/s"}
	}

	--2,3
	main_table.add{
		type = "label",
		name = "label_standard_production_rate",
		style = "recexplo_label_stats",
		caption = round(stats.standard_production_rate, 2)
	}

	--3,3
	main_table.add{
		type = "label",
		name = "label_production_rate",
		style = "recexplo_label_stats",
		caption = round(stats.production_rate, 2)
	}

end
function recexplo.cal_gui.draw_cal_factories(gui_root, stats)
	local table = gui_root.add{
		type = "table",
		name = "layout_table",
		column_count = 2,
		draw_vertical_lines = true,
		draw_horizontal_lines = true
	}
	--1,1
	table.add{
		type = "label",
		name = "table_pos_1_1",
		style = "recexplo_label_factories",
		caption = {"recexplo-gui.full-consumption"}
	}
	--2,1
	table.add{
		type = "label",
		name = "table_pos_2_1",
		style = "recexplo_label_stats",
		caption = round(stats.factories_for_consumption, 2)
	}
	--1,2
	table.add{
		type = "label",
		name = "table_pos_1_2",
		style = "recexplo_label_factories",
		caption ={"recexplo-gui.fulfill-demand"}
	}
	--2,2
	table.add{
		type = "label",
		name = "table_pos_2_2",
		style = "recexplo_label_stats",
		caption = round(stats.factories_for_demand, 2)
	}
end
function recexplo.cal_gui.draw_product_button(player_index, gui_root, product, product_type)
	local sprite_button = gui_root.add{
		type = "sprite-button",
		name = recexplo.prefix_cal_item_button .. product.name,
		style = "slot_button",
		sprite = product_type .. "/" .. product.name,
		tooltip = product.localised_name
	}
end

--io
function recexplo.cal_gui.add_io(player_index, io_type)
	local cal_gui = global[player_index].cal_gui

	local stats, index
	if io_type == "input" then
		index = cal_gui.begin_index
		stats = {
			standard_production_rate = 0,
			production_rate = 0,
			factories_selected = 1,
			factories_for_consumption = 0
		}
	elseif io_type == "output" then
		index = cal_gui.end_index
		stats = {
			standard_consumption_rate = 0,
			consumption_rate = 0,
			factories_selected = 1,
			factories_for_demand = 0,
		}
	end
	
	local made_in_list = {}
	recexplo.cal_gui.setup_io_facilities(made_in_list)

	cal_gui[index] = {
		made_in = made_in_list,
		stats = stats
	}

end

function recexplo.cal_gui.setup_io_facilities(made_in_list)
	made_in_list.selected_entity_index = -1
	made_in_list.selected_manual_rate = 1
	made_in_list.crafting_speed = 0
	recexplo.cal_gui.update_io_facilities(made_in_list, "")

end


function recexplo.cal_gui.update_io(player_index, io_type)
	local cal_gui = global[player_index].cal_gui

	if cal_gui.end_index - cal_gui.begin_index > 1 then

		local index, product_name, other_cal_recipe 
		if io_type == "input" then
			index = cal_gui.begin_index
			product_name = cal_gui[index + 0.5]
			other_cal_recipe = cal_gui[index + 1]
		elseif io_type == "output" then
			index = cal_gui.end_index
			product_name = cal_gui[index - 0.5]
			other_cal_recipe = cal_gui[index - 1]
		end
		local cal_recipe = global[player_index].cal_gui[index]
		
		--game.print("begin_index: " .. cal_gui.begin_index .. ", end_index: " .. cal_gui.end_index)
		--game.print("io_type: " .. io_type .. ", product_name: " .. product_name)
		--game.print(debug.traceback())
		
		--update made in
		if product_name == nil then
			product_name = ""
		end
		recexplo.cal_gui.update_io_facilities(cal_recipe.made_in, product_name)
		
		--calculate stats
		local stats = cal_recipe.stats
		local product_rate = cal_recipe.made_in.crafting_speed
		if io_type == "input" then
			stats.standard_production_rate = product_rate
			stats.production_rate = product_rate * stats.factories_selected
			
			local consumption_rate = other_cal_recipe.stats.consumption_rate
			local standard_production_rate = cal_recipe.stats.standard_production_rate
			stats.factories_for_demand = consumption_rate / standard_production_rate 
		elseif io_type == "output" then
			stats.standard_consumption_rate = product_rate
			stats.consumption_rate = product_rate * stats.factories_selected
			
			local production_rate = other_cal_recipe.stats.production_rate
			local standard_consumption_rate = cal_recipe.stats.standard_consumption_rate
			--game.print("..prodduction_rate: " .. other_cal_recipe.stats.production_rate .. ", prodduction_rate: " .. production_rate)
			--game.print("..standard_consumption_rate: " .. cal_recipe.stats.standard_consumption_rate .. ", standard_consumption_rate: " .. standard_consumption_rate)
			stats.factories_for_consumption = production_rate / standard_consumption_rate
		end
	end
end
function recexplo.cal_gui.update_io_facilities(made_in_list, product_name)
	--delete all old
	if made_in_list.length then
		for i = 0, made_in_list.length - 1 do
			made_in_list[i] = nil
		end
	end

	--add entities
	local i = 0
	if game.item_prototypes[product_name] then
		for _, entity in pairs(game.entity_prototypes) do
			if entity.type == "transport-belt" then
				made_in_list[i] = entity
				i = i + 1
			end
		end
	end
	made_in_list.length = i
	
	if made_in_list.selected_entity_index >= made_in_list.length then
		made_in_list.selected_entity_index = made_in_list.length - 1 
	end

	recexplo.cal_gui.calcualte_io_crafting_speed(made_in_list)


end
function recexplo.cal_gui.calcualte_io_crafting_speed(made_in_list)
	--calcualte io facilities
	if made_in_list.length > 0 then
		if made_in_list.selected_entity_index == -1 then
			made_in_list.crafting_speed = made_in_list.selected_manual_rate
		else
			local selected_entity =  made_in_list[made_in_list.selected_entity_index]
			if selected_entity.type == "transport-belt" then
				game.print(selected_entity.belt_speed)
				made_in_list.crafting_speed = selected_entity.belt_speed * 60 * 8
			end
		end
	end
end
function recexplo.cal_gui.update_manual_io(player_index, io_type, text)
	local cal_gui = global[player_index].cal_gui
	
	local cal_recipe
	if io_type == "input" then
		cal_recipe = cal_gui[cal_gui.begin_index]
	elseif io_type == "output" then
		cal_recipe = cal_gui[cal_gui.end_index]
	end

	local value = tonumber(text)
	if value then
		if cal_recipe.made_in.selected_entity_index == -1 then
			cal_recipe.made_in.selected_manual_rate = value
			--game.print("update_manual_io crafting_speed: " .. cal_recipe.made_in.crafting_speed)
			recexplo.cal_gui.update_stats(player_index)
			--game.print("crafting_speed: " .. cal_recipe.made_in.crafting_speed)
		end
	else
		if text ~= "" and text ~= nil then
			game.players[player_index].print({"recexplo-consol.enter-a-number"})
		end
	end
	--game.print("value: " .. value .. ", io_type: " .. io_type.. ", cal_recipe.made_in.crafting_speed: " .. cal_recipe.made_in.crafting_speed .. ", cal_recipe.made_in.selected_entity_index: " .. cal_recipe.made_in.selected_entity_index)
end

function recexplo.cal_gui.draw_io(player_index, gui_root, io_type)
	local cal_gui = global[player_index].cal_gui

	local frame = {
		type = "frame",
		style = "recexplo_recipe_frame"
	}
	if io_type == "input" then
		frame.name = "input_cal_recipe_frame"
	elseif io_type == "output" then
		frame.name = "output_cal_recipe_frame"
	end
	frame = gui_root.add(frame)

	local table = frame.add{
		type = "table",
		name = "io_cal_recipe_table",
		column_count = 1
	}
	table.add{
		type = "label",
		name = "title_label",
		style = "recexplo_gui_title",
	}
	if io_type == "input" then
		table.title_label.caption = {"recexplo-gui.input"}
	elseif io_type == "output" then
		table.title_label.caption = {"recexplo-gui.output"}
	end
	
	local layout_table = table.add{
		type = "table",
		name = "io_cal_recipe_main_layout_table",
		column_count = 3
	}

	local io_cal_recipe, index
	if io_type == "input" then
		index = cal_gui.begin_index
		io_cal_recipe = cal_gui[index]
	elseif io_type == "output" then
		index = cal_gui.end_index
		io_cal_recipe = cal_gui[index]
	end
	recexplo.cal_gui.draw_cal_recipe_made_in_container(layout_table, index, io_cal_recipe)
	recexplo.cal_gui.draw_manual_io(player_index, layout_table.cal_main_made_in_table, io_cal_recipe, io_type)

	recexplo.cal_gui.draw_production_stats(layout_table, io_cal_recipe.stats, index)
	recexplo.cal_gui.draw_cal_factories(layout_table, io_cal_recipe.stats)
end
function recexplo.cal_gui.draw_manual_io(player_index, gui_root, io_cal_recipe, io_type)
	local table = gui_root.add{
		type = "table",
		name = "manual_io_table",
		column_count = 4
	}
	local radiobutton = {
		type = "radiobutton"
	}
	if io_type == "input" then
		radiobutton.name = "recexplo_manual_input_radiobutton"
	elseif io_type == "output" then
		radiobutton.name = "recexplo_manual_output_radiobutton"
	end
	if io_cal_recipe.made_in.selected_entity_index == -1 then
		radiobutton.state = true
	else
		radiobutton.state = false
	end
	table.add(radiobutton)
	local label = table.add{
		type = "label",
		name = "manual_io_label",
		style = "recexplo_label_stats",
		caption = {"recexplo-gui.manual"}
	}

	local textfield = {
		type = "textfield",
		text = io_cal_recipe.made_in.selected_manual_rate,
		style = "recexplo_textfield_factories_amount"
	}
	if io_type == "input" then
		textfield.name = "recexplo_manual_input_textfield"
	elseif io_type == "output" then
		textfield.name = "recexplo_manual_output_textfield"
	end
	table.add(textfield)
	table.add{
		type = "label",
		name = "/s",
		caption = "/s"
	}
end
