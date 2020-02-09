
function recexplo.find_all_made_in_entity(player_index, recipe)
	local entity_list = {}
	local i = 0
	local show_hidden = game.players[player_index].mod_settings["recexplo-show-hidden"].value
	for _, entity in pairs(game.entity_prototypes) do
		if entity.crafting_categories ~= nil and(not(entity.flags["hidden"])or(show_hidden))then
			for entity_crafting_categories, v in next, entity.crafting_categories do
				--game.print("entity_crafting_categories: " .. entity_crafting_categories)
				if entity_crafting_categories == recipe.category then
					entity_list[i] = entity
					i = i + 1
				end
			end
		end
	end
	entity_list.length = i - 1
	return entity_list
end

function round(num, numDecimalPlaces)
	local num = tonumber(num)
	if num then
		local mult = 10^(numDecimalPlaces or 0)
		return math.floor(num * mult + 0.5) / mult
	else
		return "-"
	end
end


function technology_state(technology)
	--find style
	if technology.researched then
		return "researched"
	else
		for _, prerequisite in pairs(technology.prerequisites) do
			if prerequisite and not prerequisite.researched then
				return "unavailable"
			end
		end
		return "available"
	end
end
