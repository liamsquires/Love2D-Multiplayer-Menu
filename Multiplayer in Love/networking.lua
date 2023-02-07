local socket = require "socket"
udp = socket.udp()
udp:settimeout(0)

local serverPort = 7777
local clientPort = 0
local hostname = socket.dns.gethostname()
local myIP = socket.dns.toip(hostname)

connected = false
hosting = false
joining = false
local updaterate = 0.5


function startClient()
	udp:close()
	udp:setsockname(myIP, clientPort)
	assert(udp:setoption('broadcast', true))
	print(udp:getsockname())
	print(hostname)

	local v=0

	udp:sendto('JoinRequest',joinIP or '255.255.255.255',joinPort or serverPort)
	print(joinIP or '255.255.255.255',joinPort or serverPort)

	joining = true
	hosting = false
	assert(udp:setoption('broadcast', false))
	joinIP = nil
	joinPort = nil
	awaitingIP = false

	function joinAttempt(dt)
		v=v+dt
		if v > updaterate*8 then
			joining = false
			kicked = 2
			udp:close()
			popUp()
		end
		data, msg_or_ip, port_or_nil = udp:receivefrom()
		if data then
			cmd = string.sub(data, string.find(data, "^(%S*)"))
				if cmd == 'connected' then
					assignedPlayerNumber = string.sub(data, 11, 12) --could have up to 99 players with this lmao
					assignedPlayerNumber= tonumber(assignedPlayerNumber)
					--do I need to close the socket?
					udp:close() --doing it
					print(data,msg_or_ip,port_or_nil, assignedPlayerNumber)
					assert(udp:setpeername(msg_or_ip,port_or_nil))
					udp:send('connected')
					connected = true
					joining = false
					phase = 'Lobby'
					sliderPos = {}
					initializeButtons()

					for i=2, assignedPlayerNumber do --make players for everyone else
						table.insert(players, Player:new(table.getn(players)+1))
						table.insert(buttons, playerNameBox:new(blockW*2, blockH*(3+2* players[table.getn(players)].playerNumber), 5*blockW, blockH*1.5, players[table.getn(players)].name,i))
					end

					local c,b,n = 0,nil,nil
					for i,v in ipairs(players) do --arguably my greatest achievement
						b, n = string.find(data, "%s@(.-)%s@", c)
						if b and n then
							v.name = string.sub(data, b+2, n-2)
							buttons[table.getn(buttons)-table.getn(players)+i].text = v.name
							c=n-2
							else break
						end
					end
				elseif cmd == 'connectionRefused' then
					joining = false
					phase = 'Multiplayer'
					kicked = 1
					initializeButtons()
				end

			end
		
		if love.keyboard.isDown('escape') or phase == 'breaker' then
			joining = false
			print('Cancelled')
			phase = 'Multiplayer'
			if buttons[6] and buttons[7] then sliderPos = {buttons[6].var, buttons[7].var} end
			initializeButtons()
			udp:close()
		end
	end

	function connectedToLobby(dt)
		--Because the server sends direct messges, the joiner doesn't need update requests. 
		--This may change for gameplay, so I'll leave this here.
		--[[v=v+dt
		if v > updaterate then
			--if host leaves, reset variables and go back to menu, disconnect setpeer, make button (Host has left)
			--udp:send('update 0')
			v = 0
		end]]
		repeat
			data, msg_or_ip, port_or_nil = udp:receive()
			if data then
				cmd = string.sub(data, string.find(data, "^(%S*)"))
				print(cmd)
				if cmd == "leaving" then
					cmd, info = data:match("^(%S*) (%S*)")
					if tonumber(info) < assignedPlayerNumber then
						assignedPlayerNumber = assignedPlayerNumber-1
					end
					playerIsLeaving()
				elseif cmd == "shuttingDown" then
					print("shuttingDown")
					connected =false
					kicked = true
					udp:setpeername('*')
					phase = 'Multiplayer'
					initializeButtons()
				elseif cmd == "newPlayer" then
					table.insert(players, Player:new(table.getn(players)+1))
					table.insert(buttons, playerNameBox:new(blockW*2, blockH*(3+2* players[table.getn(players)].playerNumber), 5*blockW, blockH*1.5, players[table.getn(players)].name, table.getn(players)))
				elseif cmd == 'nameChange' then
					cmd, info, numP = data:match("^(%S*) (.*) (%S*)$")
					print(cmd, info, numP)
					players[tonumber(numP)].name = info
					buttons[table.getn(buttons)-table.getn(players)+tonumber(numP)].text = players[tonumber(numP)].name
				elseif cmd == 'newChat' then
					cmd, info = data:match("^(%S*) (.*)")
					table.insert(chat,info)
				end
			end
		until not data

		if phase == 'Leave-Lobby' then --add this to the love event where the program is quit
				datagram = 'leaving '..assignedPlayerNumber
				udp:send(datagram)
				connected =false
				udp:setpeername('*')
				udp:close()
				phase = 'Multiplayer'
				initializeButtons()
			end
		if typed == true and typeFinished == true and typingField.playerPerm then --playerPerm is unique to player names
			players[assignedPlayerNumber].name = typingField.text
			typeFinished = false
			typed = false
			udp:send('nameChange '..players[assignedPlayerNumber].name..' '..assignedPlayerNumber)
			typingField = dudTypingField
		end
		if sendNewChat then
			udp:send('newChat '..players[assignedPlayerNumber].name..': '..sendNewChat)
			sendNewChat = nil
		end
	end
	
end

function startHost( ... )
	udp:close()
	_, msg = udp:setsockname('0.0.0.0', hostPort or serverPort)
		
	print(udp:getsockname())
	print(hostname)

	hosting = true
	joining = false
	awaitingIP = false
	hostPort = nil
	assignedPlayerNumber = 1

	if msg then 
		kicked = 4
		phase = 'Leave-Lobby'
	else
		phase = 'Lobby'
		sliderPos = {}
		initializeButtons()
	end
	

	local v = 0

		function runningLobby(dt)
				data, msg_or_ip, port_or_nil = udp:receivefrom()
				if data then
					cmd = string.sub(data, string.find(data, "^(%S*)"))
					print(cmd)
					if data == 'JoinRequest' then
						if table.getn(players) < maxPlayers then
							--send datagram
							local datagram = string.format("%s %d", 'connected', table.getn(players)+1)
							for i,v in ipairs(players) do
								datagram = datagram.." @"..v.name
							end
							datagram = datagram.." @"
							udp:sendto(datagram, msg_or_ip, port_or_nil)
							--Send player names. How?
							print(datagram)
							print(data, msg_or_ip, port_or_nil)
						else
							udp:sendto('connectionRefused', msg_or_ip, port_or_nil)
						end
					elseif data == 'connected' then
						print(data, msg_or_ip, port_or_nil)
						--add player
						sendToPlayers('newPlayer')
						table.insert(players, Player:new(table.getn(players)+1))
						table.insert(buttons, playerNameBox:new(blockW*2, blockH*(3+2* players[table.getn(players)].playerNumber), 5*blockW, blockH*1.5, players[table.getn(players)].name, table.getn(players)))
						players[table.getn(players)].ip, players[table.getn(players)].port = msg_or_ip, port_or_nil
						
					elseif cmd == 'leaving' then
						cmd, info = data:match("^(%S*) (%S*)")
						--move down if higher. Change name if it's still "Player _"
						playerIsLeaving()
						sendToPlayers(data)
					elseif cmd == 'update' then
					elseif cmd == 'nameChange' then
						cmd, info, numP = data:match("^(%S*) (.*) (%S*)$")
						if info and numP then
							players[tonumber(numP)].name = info
							buttons[table.getn(buttons)-table.getn(players)+tonumber(numP)].text = players[tonumber(numP)].name
							sendToPlayers(data, tonumber(numP))
						end
					elseif cmd == 'newChat' then
						cmd, info = data:match("^(%S*) (.*)")
						table.insert(chat,info)
						sendToPlayers(data, msg_or_ip..port_or_nil)
					end
				end
			--if leaving send to peers over one update cycle (temp button 'Closing'), hosting = false, phase = 'Multiplayer', initialize
			if phase == 'Leave-Lobby' then --add this to the love event where the program is quit
				datagram = 'shuttingDown'
				sendToPlayers(datagram)
				phase = 'Multiplayer'
				hosting =false
				udp:close()
				initializeButtons()
			end
			if typed == true and typeFinished == true and typingField.playerPerm then
				players[assignedPlayerNumber].name = typingField.text
				typeFinished = false
				typed = false
				sendToPlayers('nameChange '..players[assignedPlayerNumber].name..' '..assignedPlayerNumber)
				typingField = dudTypingField
			end
			if sendNewChat then
				sendToPlayers('newChat '..players[assignedPlayerNumber].name..': '..sendNewChat)
				sendNewChat = nil
			end
		end

		function sendToPlayers(datagram, exception)
			for i,v in ipairs(players) do
				if i~=1 and i~=exception and v.ip..v.port~=exception then
					udp:sendto(datagram, v.ip, v.port)
				end
			end
		end
end

function playerIsLeaving() --Code I am keeping in a function at the bottom because I never want to look at it again.
	table.remove(buttons, table.getn(buttons)-table.getn(players)+info)
	for i=table.getn(buttons)-table.getn(players)+info+1, table.getn(buttons) do --i=button just higher than the one that left. Go to all buttons higher.
		buttons[i].y = buttons[i].y-blockH*2
		if tonumber(info) < buttons[i].playerPerm then
		buttons[i].playerPerm = buttons[i].playerPerm-1
		end
	end 
	table.remove(players, info)
	for i, v in ipairs(players) do
		if tonumber(info) < v.playerNumber then
			v.playerNumber = v.playerNumber-1
			if string.find(v.name, "Player %d") then
				v.name = string.gsub(v.name, "Player %d", "Player "..tonumber(string.sub(v.name,8,8))-1) 
			end
			buttons[table.getn(buttons)-table.getn(players)+v.playerNumber].text = v.name
		end
	end
end
