
data:extend({
	--fonts
	{
		type = "font",
		name = "recexplo_s",
		from = "default",
		size = 12
	},
	{
		type = "font",
		name = "recexplo_m",
		from = "default",
		size = 14
	},
	{
		type = "font",
		name = "recexplo_l",
		from = "default",
		size = 17
	},
	{
		type = "font",
		name = "recexplo_sb",
		from = "default-semibold",
		size = 12
	},
	{
		type = "font",
		name = "recexplo_mb",
		from = "default-semibold",
		size = 14
	},
	{
		type = "font",
		name = "recexplo_lb",
		from = "default-semibold",
		size = 22
	},

	--sprite
	{
		type = "sprite",
		name = "clock",
		filename = "__core__/graphics/clock-icon.png",
		priority = "extra-high-no-scale",
		width = 32,
		height = 32,
		scale = 1,
	},
	{
		type = "sprite",
		name = "remove-icon",
		filename = "__core__/graphics/icons/mip/trash.png",
		priority = "extra-high-no-scale",
		size = 32,
		flags = {"gui-icon"},
		mipmap_count = 2,
		scale = 0.5
	},
	{
		type = "sprite",
		name = "add-to-history-icon",
		filename = "__RecExplo__/graphics/history-clock-button.png",
		priority = "extra-high-no-scale",
		width = 64,
		height = 64,
		scale = 1,
	},
	{
		type = "sprite",
		name = "recipe-book",
		filename = "__RecExplo__/graphics/recipe-book.png",
		priority = "extra-high-no-scale",
		width = 64,
		height = 64,
		scale = 1,
	},
	{
		type = "sprite",
		name = "recipe-calculator",
		filename = "__RecExplo__/graphics/recipe-calculator.png",
		priority = "extra-high-no-scale",
		width = 64,
		height = 64,
		scale = 1,
	}
})


--flow_style
data.raw["gui-style"].default["recexplo_flow"] ={
	type = "horizontal_flow_style"
}


--frame_style
data.raw["gui-style"].default["recexplo_selection_frame"] ={
	type = "frame_style",
	parent = "frame",

	top_padding = 1,
	left_padding = 1,
	right_padding = 2,
	bottom_padding = 2,

	graphical_set = {
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 8}
	}
}
data.raw["gui-style"].default["recexplo_frame"] ={
	type = "frame_style",
	parent = "frame",
	top_padding = 2,
	bottom_padding = 2,
	left_padding = 4,
	right_padding = 4
}
data.raw["gui-style"].default["recexplo_recipe_frame"] ={
	type = "frame_style",
	parent = "frame",
	vertically_stretchable = "on",

	horizontally_squashable = "on",
	padding = 2,
	--width = 208
}



--label_style
data.raw["gui-style"].default["recexplo_gui_title"] = {
	type = "label_style",
	font = "recexplo_lb",
	font_color = {r=1, g=1, b=1}
}
data.raw["gui-style"].default["recexplo_object_naming_lst"] = {
	type = "label_style",
	font = "recexplo_s",
	font_color = {r=1, g=1, b=1},
	single_line = false
}
data.raw["gui-style"].default["recexplo_sub_title_lst"] = {
	type = "label_style",
	font = "recexplo_sb",
	font_color = {r=1, g=1, b=1},
}
data.raw["gui-style"].default["recexplo_title_lst"] = {
	type = "label_style",
	font = "recexplo_mb",
	font_color = {r=1, g=1, b=1},
	single_line = false,
	top_padding = 3,
	maximal_width = 108
}
data.raw["gui-style"].default["recexplo_label_stats"] = {
	type = "label_style",
	font = "recexplo_s",
	padding = 2,
	font_color = {r=1, g=1, b=1},
	minimal_width = 30
}
data.raw["gui-style"].default["recexplo_label_factories"] = {
	type = "label_style",
	font = "recexplo_s",
	padding = 2,
	font_color = {r=1, g=1, b=1},
	maximal_width = 130,
	single_line = false
}

--textfield_style
data.raw["gui-style"].default["recexplo_textfield_factories_amount"] = {
	type = "textbox_style",
	font = "recexplo_s",
	width = 40,
	vertical_align = "center",
	horizontal_align = "left",
	horizontally_stretchable = "on"

}

--button_style
data.raw["gui-style"].default["recexplo_button_midium_font"] = {
	type = "button_style",
	parent = "button",
	font = "recexplo_m",

	minimal_width = 57,

	
	right_padding = 4,
	left_padding = 4,
}
--[[data.raw["gui-style"].default["recexplo_made_in_button_unselected"] = {
	type = "button_style",
	parent = "slot_button",
	font = "recexplo_m",
	left_padding = 3
}]]
data.raw["gui-style"].default["recexplo_sprite_button"] = {
	type = "button_style",
	parent = "button",
	width = 40,
	height = 40,
	padding = 0
}
data.raw["gui-style"].default["recexplo_back_button"] = {
	type = "button_style",
	parent = "back_button",
	minimal_width = 30
}
data.raw["gui-style"].default["recexplo_forward_button"] = {
	type = "button_style",
	parent = "forward_button",
	minimal_width = 30
}
data.raw["gui-style"].default["recexplo_forward_button"] = {
	type = "button_style",
	parent = "forward_button",
	minimal_width = 30
}
data.raw["gui-style"].default["recexplo_not_selected_button"] = {
	type = "button_style",
	parent = "slot_button",

	top_margin = 2,
	left_margin = 2,
	right_margin = 3,
	bottom_margin = 3
}
data.raw["gui-style"].default["recexplo_red_not_selected_button"] = {
	type = "button_style",
	parent = "red_slot_button",

	top_margin = 2,
	right_margin = 2,
	bottom_margin = 3,
	left_margin = 3
}


--tech slot buttons
data.raw["gui-style"].default["recexplo_unavailable_technology_slot"] = 
{
  type = "button_style",
  parent = "red_slot_button",
  height = 68,
  width = 68,
}
data.raw["gui-style"].default["recexplo_researched_technology_slot"] = 
{
  type = "button_style",
  parent = "green_slot",
  height = 68,
  width = 68,
}
data.raw["gui-style"].default["recexplo_available_technology_slot"] = 
{
  type = "button_style",
  parent = "slot_button",

  clicked_graphical_set = {
    border = 1,
    filename = "__core__/graphics/gui.png",
    position = {
      185,
      72
    },
    scale = 1,
    size = 36
  },
  default_graphical_set = {
    border = 1,
    filename = "__core__/graphics/gui.png",
    position = {
      111,
      72
    },
    scale = 1,
    size = 36
  },
  hovered_graphical_set = {
    border = 1,
    filename = "__core__/graphics/gui.png",
    position = {
      148,
      72
    },
    scale = 1,
    size = 36
  },
  
  height = 68,
  width = 68,
}



--scroll_pane_style
--explo_gui
for i=300, 1200, 100 do
	--local name = "recexplo_recipes_scroll_plane_" .. i
	data.raw["gui-style"].default["recexplo_recipes_scroll_plane_" .. i] = {
		type = "scroll_pane_style",
		maximal_height = i,
		extra_padding_when_activated = 3
	}
end
--cal_gui
for i=410, 1310, 100 do
	--local name = "recexplo_recipes_scroll_plane_" .. i
	data.raw["gui-style"].default["recexplo_recipes_scroll_plane_" .. i] = {
		type = "scroll_pane_style",
		maximal_height = i
	}
end

--tabel_style
--[[data.raw["gui-style"].default["recexplo_selectable_table"] = {
	type = "table_style",
	parent = "table",

	horizontal_align = "center",
	vertical_align = "center",

	padding = 2
}]]
data.raw["gui-style"].default["recexplo_stats_table"] = {
	type = "table_style",
	parent = "table",

	horizontal_spacing = 3,
	cell_spacing = 3
}
data.raw["gui-style"].default["recexplo_table"] = {
	type = "table_style",
	parent = "table",

	horizontal_spacing = 0,
	vertical_spacing = 0
}
data.raw["gui-style"].default["recexplo_recipe_table"] = {
	type = "table_style",
	parent = "table",

	horizontal_spacing = 3,
	vertical_spacing = 3
}

