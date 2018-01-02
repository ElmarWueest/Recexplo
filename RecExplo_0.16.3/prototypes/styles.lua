--fonts
data:extend({
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
    type = "font",
    name = "recexplo_s",
    from = "default",
    size = 12
  },
  {
    type = "font",
    name = "recexplo_m",
    from = "default",
    size = 15
  },
  {
    type = "font",
    name = "recexplo_l",
    from = "default",
    size = 18
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
    size = 15
  },
  {
    type = "font",
    name = "recexplo_lb",
    from = "default-semibold",
    size = 18
  }
})


--flow_style
data.raw["gui-style"].default["recexplo_flow"] ={
  type = "flow_style",
  parent = "flow",
  horizontal_spacing = 0,
  vertical_spacing = 0,
}


--frame_style
data.raw["gui-style"].default["recexplo_selection_frame"] ={
  type = "frame_style",
  parent = "frame",
  top_padding  = 1,
  right_padding = 2,
  bottom_padding = 2,
  left_padding = 1,
  graphical_set = {
    type = "composition",
    filename = "__core__/graphics/gui.png",
    priority = "extra-high-no-scale",
    corner_size = {3, 3},
    position = {0, 8}
  }
}


--scroll_pane_style
data.raw["gui-style"].default["recexplo_recipes_scroll_plane_300"] = {
  type = "scroll_pane_style",
	maximal_height = 300
}
data.raw["gui-style"].default["recexplo_recipes_scroll_plane_400"] = {
  type = "scroll_pane_style",
	maximal_height = 400
}
data.raw["gui-style"].default["recexplo_recipes_scroll_plane_500"] = {
  type = "scroll_pane_style",
	maximal_height = 500
}
data.raw["gui-style"].default["recexplo_recipes_scroll_plane_600"] = {
  type = "scroll_pane_style",
	maximal_height = 600	
}
data.raw["gui-style"].default["recexplo_recipes_scroll_plane_700"] = {
  type = "scroll_pane_style",
	maximal_height = 700
}
data.raw["gui-style"].default["recexplo_recipes_scroll_plane_800"] = {
  type = "scroll_pane_style",
	maximal_height = 800
}
data.raw["gui-style"].default["recexplo_recipes_scroll_plane_900"] = {
	type = "scroll_pane_style",
	maximal_height = 900
}
data.raw["gui-style"].default["recexplo_recipes_scroll_plane_1000"] = {
	type = "scroll_pane_style",
	maximal_height = 1000
}
data.raw["gui-style"].default["recexplo_recipes_scroll_plane_1100"] = {
	type = "scroll_pane_style",
	maximal_height = 1100
}
data.raw["gui-style"].default["recexplo_recipes_scroll_plane_1200"] = {
	type = "scroll_pane_style",
	maximal_height = 1200
}

--label_style
data.raw["gui-style"].default["recexplo_object_naming_lst"] = {
	type = "label_style",
	font = "recexplo_s",
  font_color = {r=1, g=1, b=1},
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
	maximal_width = 200
}
