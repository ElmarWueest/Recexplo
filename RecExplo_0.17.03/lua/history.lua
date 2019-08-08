

function recexplo.history.add_state(history, player_index, data)
	--copy_funktion = funktion(source, destination)
	local max_length = game.players[player_index].mod_settings["recexplo-max-history-length"].value
    --game.print("debug start",{r=1})
    --recexplo.history.debug(player_index)

	if history.list.length == history.pos then
        --pos is on the end
        --game.print("pos is on the end",{g=1})
		if history.list.length == max_length then
            --hidden limit and shift
            --game.print("hidden limit and shift",{g=1})
			for i = 1, (max_length - 1), 1 do
				history.list[i] = history.list[i+1]
			end
			history.list[history.pos] = data
		else 
            -- grow in size
            --game.print("grow in size",{g=1})
			history.list.length = history.list.length + 1
			history.pos = history.pos + 1
			history.list[history.pos] = data
		end
	else
        --pos is not on the end
        --game.print("pos is not on the end",{g=1})
		if history.max_length == max_length then
            --shift back
            --game.print("shift back",{g=1})
			for i = 1, history.pos -1, 1 do 
				history.list[i] = history.list[i+1]
			end
			history.list[history.pos] = data
		else 
            --shift forward
            --game.print("shift forward",{g=1})
			for i = history.list.length +1, history.pos +1, -1 do
				history.list[i] = history.list[i-1]
			end
			history.pos = history.pos +1
			history.list.length = history.list.length +1
			history.list[history.pos] = data
		end
    end
    
    --game.print("debug end",{r=1})
	--recexplo.history.debug(player_index)
end
function recexplo.history.save_state(history, data)
    history.list[history.pos] = data
end

function recexplo.history.delete_active_pos(history)
	if history.pos ~= -1 then
		recexplo.history.delete_pos(history, history.pos)
	end
end
function recexplo.history.delete_pos(history, delete_pos)
	--game.print("pos")
	--game.print("debug start",{r=1})
	--recexplo.history.debug(player_index)
	
	if history.list.length == delete_pos then
		--pos is on the end
		history.list[delete_pos] = nil
		history.list.length = history.list.length -1
		if history.pos == delete_pos then
			history.pos = history.pos -1
		end
	else
		--pos is not on the end
		for i = delete_pos, history.list.length -1, 1 do
			history.list[i] = history.list[i+1]
		end

		if history.pos > delete_pos then
			history.pos = history.pos -1
		end
		history.list[history.list.length] = nil
		history.list.length = history.list.length -1
    end

	--game.print("debug end",{r=1})
	--recexplo.history.debug(player_index)
end
function recexplo.history.delete(history)
	for i = 1, history.list.length, 1 do
		history.list[i] = nil
	end
	history.list.length = 0
    history.pos = 0
end


function recexplo.history.go_forward(history)
	local pos = history.pos
	if pos < history.list.length then
		temp = history.list[pos + 1]
		history.list[pos + 1] = history.list[pos]
		history.list[pos] = temp
		history.pos = pos + 1
	end
end
function recexplo.history.go_backward(history)
	local pos = history.pos
	if pos > 1 then
		temp = history.list[pos - 1]
		history.list[pos - 1] = history.list[pos]
		history.list[pos] = temp
		history.pos = pos - 1
	end
end

function recexplo.history.active_recipe_history(player_index)
	--game.print("active_recipe_history")
	--recexplo.history.debug(global[player_index].global_history)
	--recexplo.history.debug(global[player_index].local_history)

	if global[player_index].global_history.pos ~= -1 then
		return global[player_index].global_history
	elseif global[player_index].local_history.pos ~= -1 then
		return global[player_index].local_history
	else
		return nil
	end
end
function recexplo.history.explo_gui_pack_data(player_index)
	local data = {}

	if global[player_index].selctet_product_signal then
		data.signal = {}
		data.signal.type = global[player_index].selctet_product_signal.type
		data.signal.name = global[player_index].selctet_product_signal.name
	end
	data.display_mode = global[player_index].display_mode

	return data
end
function recexplo.history.explo_gui_unpack_data(player_index, data)
	if data and data.signal then
		global[player_index].selctet_product_signal = {}
		global[player_index].selctet_product_signal.type = data.signal.type
		global[player_index].selctet_product_signal.name = data.signal.name
	else
		global[player_index].selctet_product_signal = nil
	end
	
	if data and data.display_mode then
		global[player_index].display_mode = data.display_mode
	else
		global[player_index].display_mode = "recipe"
	end
end

function recexplo.history.debug(history)
	local color = {r=math.random(0,255);g=math.random(0,255);b=math.random(0,255)}
	if history then
		game.print("history:", color)
		game.print("length: " .. history.list.length, color)
		if history.pos ~= nil then
    		game.print("pos: " .. history.pos, color)
		else
			game.print("pos: nil", color)
		end
    	--signal.name
		local i = 1
		local text = ""
		::start::
		if history.list[i] then
			text = text .. "/ " .. tostring(i).. " " .. history.list[i].signal.name
			i = i + 1
			goto start
		end
    	game.print("history stack: " .. text, color)
	
    	--display_mode
		local i = 1
		local text = ""
		::start2::
		if history.list[i] then
			text = text .. "/ " .. tostring(i).. " " .. history.list[i].display_mode
			i = i + 1
			goto start2
		end
		game.print("display_mode stack: " .. text, color)
	else
		game.print("history: nil", color)
	end
end

