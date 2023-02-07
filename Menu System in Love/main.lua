--Make a menu! Set the phase names that you want at the end of the buttons. Draw and update are concise. 
--It's resizable if you re-initialize in update. The whole menu sequence can be made in initialize.
--Obviously, you'll need to go into the weeds to change styling. Should be fairly straight forward.
--Button type 1 is hover highlight, 2 is sliding, 3 is text input field, 4 is pop-up.
--Button:new(type,x,y,w,h,text,phase,o)
--To make buttons with funky attributes, make a subclass of button, and change the appropriate functions.
--You can still put them in the usual buttons table, and it'll draw. Look at the multiplayer menu's playerNameBox for reference.

local mx, my = love.mouse.getPosition()
Button = {}
local typingField = {text = ""}
local utf8 = require("utf8")
local cooldown

function initializeButtons ( ... )
	buttons = {}
	if phase == 'Multiplayer'then
		cooldown = 15
		titleText = "Liam's Incredible Multiplayer Menu"

		table.insert(buttons,Button:new(1, blockW*8.5, blockH*8.15, blockW*2, blockH*3/4, "Host", "Host-LAN"))
		table.insert(buttons,Button:new(1, blockW*8.5, blockH*9.15, blockW*2, blockH*3/4, "Join", "Join-LAN"))

		table.insert(buttons,Button:new(1, blockW*8.5, blockH*11.15, blockW*2, blockH*3/4, "Host", "Host-Non-LAN"))
		table.insert(buttons,Button:new(1, blockW*8.5, blockH*12.15, blockW*2, blockH*3/4, "Join", "Join-Non-LAN"))

		table.insert(buttons,Button:new(1, blockW*1.25, blockH*14, blockW*2, blockH*3/4, "Leave", "Leave"))

		table.insert(buttons,Button:new(3, blockW*2, blockH*2, windowWidth-10*blockW, blockH*2))

		table.insert(buttons,Button:new(2, blockW*5, blockH*8, windowWidth-10*blockW, blockH*2, "LAN"))
		table.insert(buttons,Button:new(2, blockW*5, blockH*11, windowWidth-10*blockW, blockH*2, "Not LAN"))

		table.insert(buttons,Button:new(4, blockW*4.5, blockH*4, 7*blockW, blockH*4.5, "Joining..."))
		table.insert(buttons,Button:new(1, blockW*7, blockH*7.5, 2*blockW, blockH*3/4, "Cancel"))
	elseif phase == 'Host-LAN' then
		titleText = "Hosting LAN"
		buttons[1] = Button:new(1, blockW*1.25, blockH*14, blockW*2, blockH*3/4, "Leave", "Multiplayer")
	elseif phase == 'Host-Non-LAN' then
		titleText = "Hosting Internet"
		buttons[1] = Button:new(1, blockW*1.25, blockH*14, blockW*2, blockH*3/4, "Leave", "Multiplayer")
	elseif phase == 'Leave' then
		love.event.quit()
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

	
	initializeButtons()

end



function love.update (dt)
	mx, my = love.mouse.getPosition()

	if cooldown <= 0 then
		for v, i in ipairs(buttons) do
			i:isClicked()
		end
		else cooldown = cooldown-1
	end

end

function love.draw()
	funkyBox(blockW, blockH, windowWidth-2*blockW, windowHeight-2*blockH)

	love.graphics.setColor(1,1,1)
	love.graphics.printf(titleText, headerFont, blockW*2, blockH*2, windowWidth-4*blockW, 'center')

	drawButtons()
end


function love.resize(w, h) 
	wRatio = w/windowWidth
	hRatio = h/windowHeight
	windowWidth = love.graphics.getWidth()
	windowHeight = love.graphics.getHeight()
	blockW = windowWidth/16
	blockH = windowHeight/16
	
	for v, i in ipairs(buttons) do
		i.x = i.x *wRatio
		i.w = i.w*wRatio
		i.h = i.h*hRatio
		i.y = i.y*hRatio
	end

	headerFont = love.graphics.newFont(windowWidth/12)
	buttonFontBig = love.graphics.newFont(windowWidth/17)
	buttonFontSmall = love.graphics.newFont(windowWidth/42)
	playerFont = love.graphics.newFont(windowWidth/35)
end

function love.textinput(t)
    typingField.text = typingField.text .. t
end

function love.keypressed(key)
    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(typingField.text, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            typingField.text = string.sub(typingField.text, 1, byteoffset - 1)
        end
    end
    if key == "return" then
    	love.keyboard.setTextInput(false)
    end
end


function funkyBox(x,y,w,h)
	love.graphics.setLineWidth(2)
	love.graphics.setColor(0.3,0.3,1)
	love.graphics.rectangle('line', x, y, w, h)
	love.graphics.setColor(192/255,192/255,192/255)
	love.graphics.rectangle('line', x+2, y+2, w-4, h-4)
	love.graphics.rectangle('line', x-2, y-2, w+4, h+4)	

end

function Button:new(type,x,y,w,h,text,phase,o)
	o = o or {}
	o.x,o.y,o.w,o.h = x,y,w,h
	o.var = 0
	o.text = text or ""
	o.phaseChange = phase
	o.type = type
	setmetatable(o,self)
	self.__index = self
	return o
end

function drawButtons( ... )
	for v, i in ipairs(buttons) do
		if i.type == 2 then
			i:drawSlide()
		elseif i.type == 3 then
			love.graphics.setColor(0.3,0.3,0.3)
			love.graphics.rectangle('fill',i.x,i.y,i.w,i.h)
			funkyBox(i.x,i.y,i.w,i.h)
			love.graphics.setColor(1,1,1)
			love.graphics.printf(i.text, buttonFontBig, i.x,i.y+blockH*1/4,i.w,'left')
		elseif i.type == 4 then
			love.graphics.setColor(0.2,0.2,0.6)
			love.graphics.rectangle('fill',i.x,i.y,i.w,i.h)
			funkyBox(i.x,i.y,i.w,i.h)
			love.graphics.setColor(1,1,1)
			love.graphics.printf(i.text, buttonFontBig, i.x,i.y+blockH*1/4,i.w,'center')
		elseif i.type == 1 then
			i:drawHighlight()
		end

	end
end

function Button:drawSlide()
	--local tempx = self.x
	if self:hover() then
		self.var = self.var+1
	else 
		self.var = self.var-1 
	end
	if self.var < 0 then self.var =0 elseif self.var > 7 then self.var = 7 end
	--tempx = tempx - blockW/2*self.var
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle('fill',self.x-blockW/2*self.var,self.y,self.w,self.h)

	funkyBox(self.x- blockW/2*self.var,self.y,self.w,self.h)
	love.graphics.setColor(1,1,1)
	love.graphics.printf(self.text, buttonFontBig, self.x-blockW/2*self.var,self.y+blockH*1/4,self.w,'center')
end

function Button:drawHighlight( ... )
	if self:hover() then
		love.graphics.setColor(0.08,0.08,0.25)
		love.graphics.rectangle('fill',self.x,self.y,self.w,self.h)
	end
	funkyBox(self.x,self.y,self.w,self.h)
	love.graphics.setColor(1,1,1)
	love.graphics.printf(self.text, buttonFontSmall, self.x,self.y+1,self.w,'center')
end

function Button:hover( ... )
	if mx > self.x and mx < self.x+self.w and my > self.y and my < self.y+self.h then
		return true
	else
		return false
	end
end

function Button:isClicked( ... )
	if self:hover() and love.mouse.isDown(1) then
		if self.phaseChange then
			phase = self.phaseChange
			initializeButtons()
		end
		if self.type == 3 then
			love.keyboard.setTextInput(true)
			typingField = self
			cooldown = 1
		end
		return true
	elseif love.mouse.isDown(1) and cooldown <= 0 then
		love.keyboard.setTextInput(false)
	end
end



