function recexplo.gui.open_tech(player, tech)
    if player.force.technologies[tech.name] then
        --game.print("start open tech")
        recexplo.player_had_opened_tech = player
        recexplo.had_opened_tech = 2
        if player and player.force.current_research then
            recexplo.was_researched = true
            recexplo.current_researching_technology = player.force.current_research.name
            recexplo.current_researching_progress = player.force.research_progress
        end 
        local list = {}
        recexplo.gui.unlock_tech(player, tech, list)

        player.force.current_research = tech.name
        player.opened = defines.gui_type.research

        recexplo.gui.lock_tech(player, list)

    end
end

function recexplo.gui.unlock_tech(player, tech, list)
    --game.print("unlock_tech: ".. tech.name )
    for key, v in pairs(tech.prerequisites) do
        local technology = player.force.technologies[key]
        if not technology.researched then
            recexplo.gui.unlock_tech(player, technology , list)   
        end
    end
    table.insert(list, tech)
    tech.researched = true
end

function recexplo.gui.lock_tech(player, list)
    for _, technology in pairs(list) do
        technology.researched = false
    end
end

function recexplo.gui.pasting_old_technology(player_index)
  	--game.print("had opened tech")
	local player = recexplo.player_had_opened_tech
	if	recexplo.was_researched then
		player.force.current_research = recexplo.current_researching_technology
		player.force.research_progress = recexplo.current_researching_progress
	else 
		player.force.current_research = nil
	end
	recexplo.had_opened_tech = 0		
end
