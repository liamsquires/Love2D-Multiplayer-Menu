require "networking"
require "player"
require "button"
utf8 = require("utf8")

mx, my = love.mouse.getPosition()

dudTypingField = {text = ""}
typingField = {text = ""}

local textCursorCount = 0
textCursor = "|"

chat = {}
local chatOnPage = false

cooldown = 0
assignedPlayerNumber = 0
kicked = false
awaitingIP = false

sliderPos = {}



function initializeButtons ( ... )
	buttons = {}
	chat = {}
	chatOnPage = false
	typed = false
	typeFinished = false
	cooldown = 15
	love.keyboard.setTextInput(false)

	if phase == 'Multiplayer' then
		titleText = "Liam's Incredible Multiplayer Menu"
		table.insert(buttons, Button:new(1, blockW*8.5, blockH*8.15, blockW*2, blockH*3/4, "Host", "Host-LAN"))
		table.insert(buttons, Button:new(1, blockW*8.5, blockH*9.15, blockW*2, blockH*3/4, "Join", "Join-LAN"))

		table.insert(buttons, Button:new(1, blockW*8.5, blockH*11.15, blockW*2, blockH*3/4, "Host", "Host-Non-LAN"))
		table.insert(buttons, Button:new(1, blockW*8.5, blockH*12.15, blockW*2, blockH*3/4, "Join", "Join-Non-LAN"))

		table.insert(buttons, Button:new(1, blockW*1.25, blockH*14, blockW*2, blockH*3/4, "Leave", "Leave"))

		table.insert(buttons, Button:new(2, blockW*5, blockH*8, windowWidth-10*blockW, blockH*2, "LAN"))
		table.insert(buttons, Button:new(2, blockW*5, blockH*11, windowWidth-10*blockW, blockH*2, "Internet"))

		popUp()

		--if joining then buttons[6].var = 7 end
		--buttons[2] = Button:new(3, blockW*2, blockH*2, windowWidth-10*blockW, blockH*2)
		--buttons[9] = Button:new(3, blockW*6, blockH*2, windowWidth-10*blockW, blockH*2)
		--buttons[10] = Button:new(3, blockW*2, blockH*6, windowWidth-10*blockW, blockH*2)

	elseif phase == 'Host-LAN' then
		startHost()

	elseif phase == 'Join-LAN' then
		startClient()
		phase = 'Multiplayer'
		initializeButtons()

	elseif phase == 'Join-Non-LAN' then
		awaitingIP = 1
		phase = 'Multiplayer'
		initializeButtons()

	elseif phase == 'Host-Non-LAN' then
		awaitingIP = 2
		phase = 'Multiplayer'
		initializeButtons()

	elseif phase == 'Lobby' then
		titleText = "LAN Lobby"
		buttons[1] = Button:new(1, blockW*1.25, blockH*14, blockW*2, blockH*3/4, "Leave", "Leave-Lobby")

		if hosting then
			table.insert(buttons, Button:new(1, blockW*12.75, blockH*14, blockW*2, blockH*3/4, "Start"))
		end

		table.insert(buttons, Button:new(6, blockW*8, blockH*13, 6*blockW, blockH*0.75))
		chatOnPage = true

		players = {}
		table.insert(players, Player:new(table.getn(players)+1))
		table.insert(buttons, playerNameBox:new(blockW*2, blockH*5, 5*blockW, blockH*1.5, players[1].name, 1))

	elseif phase == 'Leave' then
		love.event.quit()

	elseif phase == 'Rude!' then
		kicked = false
		phase = 'Multiplayer'
		initializeButtons()
	end
end

function love.load()
	phase = 'Multiplayer'
	local titleText

	windowWidth = love.graphics.getWidth()
	windowHeight = love.graphics.getHeight()

	--the intention of this is for resizability and uniform-ness. Everything will be based off set block sizes.
	blockW = windowWidth/16
	blockH = windowHeight/16

	--Font size is based off windowWidth. Not perfect but good enough.
	headerFont = love.graphics.newFont(windowWidth/12)
	buttonFontBig = love.graphics.newFont(windowWidth/17)
	buttonFontSmall = love.graphics.newFont(windowWidth/42)
	playerFont = love.graphics.newFont(windowWidth/22)
	ipFont = love.graphics.newFont(windowWidth/30)
	ipFontSmall = love.graphics.newFont(windowWidth/50)

	
	initializeButtons()
end

function love.update (dt)

	updateChatMessages()

	if awaitingIP and typeFinished and typingField.type == 3 and typingField.text ~= "" then
		typeFinished = false
		typed = false
		typingField.text = string.gsub(typingField.text, " ", "")
		--joinIP = '70.73.228.13'
		--joinPort = 7777
		if awaitingIP == 1 then
			if string.find(typingField.text, ':') then
					joinIP = string.sub(typingField.text, 1, string.find(typingField.text, ':')-1)
					joinPort = tonumber(string.sub(typingField.text, string.find(typingField.text, ':')+1, -1))
					print(joinIP, joinPort)
					startClient()
			else kicked =3 end
		end
		if awaitingIP == 2 then
			joinPort = tonumber(typingField.text)
			print(joinPort)
			startHost()
		end
		popUp()
		typingField = dudTypingField
	end

	updateTextCursor(dt)

	mx, my = love.mouse.getPosition()
	if cooldown <= 0 then
		for v, i in ipairs(buttons) do
			i:isClicked()
		end
		else cooldown = cooldown-1
	end

	if hosting then runningLobby(dt) end
	if joining then joinAttempt(dt) end
	if connected then connectedToLobby(dt) end

end

function love.draw()

	funkyBox(blockW, blockH, windowWidth-2*blockW, windowHeight-2*blockH)

	love.graphics.setColor(1,1,1)
	love.graphics.printf(titleText, headerFont, blockW*2, blockH*2, windowWidth-4*blockW, 'center')

	if chatOnPage then
		drawChat(blockW*8, blockH*13, 6*blockW, blockH*8)
	end

	for v, i in ipairs(buttons) do
		i:draw()
	end

end

function love.resize(w, h) 
	wRatio = w/windowWidth
	hRatio = h/windowHeight
	windowWidth = love.graphics.getWidth()
	windowHeight = love.graphics.getHeight()
	blockW = windowWidth/16
	blockH = windowHeight/16
	
	for v, i in ipairs(buttons) do
		i.x = i.x*wRatio
		i.w = i.w*wRatio
		i.h = i.h*hRatio
		i.y = i.y*hRatio
		if i.font == ipFont then
			i.font = love.graphics.newFont(windowWidth/30)
		elseif i.font == ipFontSmall then
			i.font = love.graphics.newFont(windowWidth/50)
		end
	end

	headerFont = love.graphics.newFont(windowWidth/12)
	buttonFontBig = love.graphics.newFont(windowWidth/17)
	buttonFontSmall = love.graphics.newFont(windowWidth/42)
	playerFont = love.graphics.newFont(windowWidth/22)
	ipFont = love.graphics.newFont(windowWidth/30)
	ipFontSmall = love.graphics.newFont(windowWidth/50)
end

function love.textinput(t)
    typingField.text = typingField.text .. t
    typed = true
    
--This prevents things from having an " @" because it messes with something unrelated lmao
    if string.find(typingField.text, "%s@$") then 
    	print(t)
    	 local byteoffset = utf8.offset(typingField.text, -1)
    	typingField.text = string.sub(typingField.text, 1, byteoffset-1)
    end

    if typingField.type == 5 and string.len(typingField.text) > 11 then --this is hacky, if you're gonna put limits, change this system
    	typingField.text = string.sub(typingField.text, 1,-2)
    end
    --if typingField.type == 3 and string.len(typingField.text) > 16 then --this is hacky, if you're gonna put limits, change this system
    --	typingField.text = string.sub(typingField.text, 1,-2)
    --end
    if typingField.type == 6 and string.len(typingField.text) > 20 then --this is hacky, if you're gonna put limits, change this system
    	typingField.text = string.sub(typingField.text, 1,-2)
    end
end

function love.keypressed(key)
    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(typingField.text, -1)

        if byteoffset then
        	typed = true
    		typeFinished = false
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            typingField.text = string.sub(typingField.text, 1, byteoffset - 1)
        end
    end
    
    if key == "return" then
    	love.keyboard.setTextInput(false)
    	typeFinished = true
    end

    if key == "escape" then
    	love.keyboard.setTextInput(false)
	    typingField = dudTypingField
	end
end

function love.quit ( ... )
	if connected then
		datagram = 'leaving '..assignedPlayerNumber
		udp:send(datagram)
	elseif hosting then
		datagram = 'shuttingDown 1'
		sendToPlayers(datagram)
	end
end



function updateTextCursor(dt) 
	textCursorCount = textCursorCount+dt
	if textCursorCount > 0.65 then
		if textCursor == "" then
			textCursor = "|"
		else
			textCursor = ""
		end
		textCursorCount = 0
	end
end