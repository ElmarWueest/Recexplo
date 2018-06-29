

function recexplo.history.add_current_state(player_index)
	local max_length = game.players[player_index].mod_settings["recexplo-max-history-length"].value
	local history = global[player_index].history
    --game.print("add_current_state")
    --game.print("debug start")
    --recexplo.history.debug(player_index)

	if history.length == history.pos then
        --pos is on the end
        --game.print("pos is on the end")
		if history.length == max_length then
            --hidden limit and shift
            --game.print("hidden limit and shift")
			for i = 1, (max_length - 1), 1 do
				history[i] = history[i+1]
			end
			recexplo.history.save_state(player_index, history.pos)
		else 
            -- grow in size
            --game.print("grow in size")
			history.length = history.length + 1
			history.pos = history.pos + 1
			recexplo.history.save_state(player_index, history.pos)
		end
	else
        --pos is not on the end
        --game.print("pos is not on the end")
		if history.insert_mode then
			if history.max_length == max_length then
                --shift back
                --game.print("shift back")
				for i = 1, history.pos -1, 1 do 
					history[i] = history[i+1]
				end
				recexplo.history.save_state(player_index, history.pos)
			else 
                --shift forward
                --game.print("shift forward")
				for i = history.length +1, history.pos +1, -1 do
					history[i] = history[i-1]
				end
				history.pos = history.pos +1
				history.length = history.length +1
				recexplo.history.save_state(player_index, history.pos)
			end
		else 
            --overwrith
            --game.print("overwrith")
			history.pos = history.pos + 1
			recexplo.history.save_state(player_index, history.pos)
		end
    end
    
    --game.print("debug end")
	--recexplo.history.debug(player_index)
end
function recexplo.history.save_state(player_index, pos)
    global[player_index].history[pos] = {}

    if global[player_index].selctet_product_signal then
        global[player_index].history[pos].signal = {}
	    global[player_index].history[pos].signal.name = global[player_index].selctet_product_signal.name
        global[player_index].history[pos].signal.type = global[player_index].selctet_product_signal.type
    end
	global[player_index].history[pos].display_mode = global[player_index].display_mode
end

function recexplo.history.delete_pos(player_index, delete_pos)
	local history = global[player_index].history	
	if history.length == delete_pos then
		--pos is on the end
		history[delete_pos] = nil
		history.length = history.length -1
		if history.pos == delete_pos then
			history.pos = history.pos -1
		end
	else
		--pos is not on the end
		for i = delete_pos, history.length -1, 1 do
			history[i] = history[i+1]
		end

		if history.pos > delete_pos then
			history.pos = history.pos -1
		end
		history[history.length] = nil
		history.length = history.length -1
    end

end
function recexplo.history.delete(player_index)
	local history = global[player_index].history	
	for i = 1, history.length, 1 do
		history[i] = nil
	end
	history.length = 0
    history.pos = 0

end

function recexplo.history.load_selected(player_index)
    local pos = global[player_index].history.pos
    recexplo.history.load(player_index, pos)
end
function recexplo.history.load(player_index, pos)
    --game.print("recexplo.history.load/pos: ".. tostring(pos))
    local history = global[player_index].history
    if pos > 0 then
	    global[player_index].selctet_product_signal.name = history[pos].signal.name
	    global[player_index].selctet_product_signal.type = history[pos].signal.type
        global[player_index].display_mode = history[pos].display_mode
    else
        global[player_index].selctet_product_signal.name = nil
	    global[player_index].selctet_product_signal.type = nil
    	global[player_index].selctet_product_signal = nil
        global[player_index].display_mode = "recipe"
    end
end


function recexplo.history.go_forward(player_index)
	local history = global[player_index].history
	if history.pos < history.length then
		history.pos = history.pos + 1
		local pos = history.pos
		recexplo.history.load_selected(player_index)

		--game.print("history_go_forward")
		--recexplo.history.debug(player_index)
	end
end
function recexplo.history.go_backward(player_index)
	local history = global[player_index].history
	if history.pos > 1 then
		history.pos = history.pos - 1
		recexplo.history.load_selected(player_index)

		--game.print("history_go_backward")
		--recexplo.history.debug(player_index)
	end
end

function recexplo.history.debug(player_index)
	local history = global[player_index].history
	game.print("length: " .. history.length)
    game.print("pos: " .. history.pos)

    --signal.name
	local i = 1
	local text = ""
	::start::
	if history[i] then
		text = text .. "/ " .. tostring(i).. " " .. history[i].signal.name
		i = i + 1
		goto start
	end
    game.print("history stack: " .. text)
    
    --display_mode
	local i = 1
	local text = ""
	::start2::
	if history[i] then
		text = text .. "/ " .. tostring(i).. " " .. history[i].display_mode
		i = i + 1
		goto start2
	end
	game.print("display_mode stack: " .. text)
end

