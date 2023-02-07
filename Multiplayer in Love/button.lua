Button = {}
typed = false
typeFinished = false

function Button:draw()
	local i = self --easier adaptation from for loop system, I confess
		if i.type == 2 then --sliding
			i:drawSlide()
		elseif i.type == 3 then --text field
			love.graphics.setColor(0.3,0.3,0.3)
			love.graphics.rectangle('fill',i.x,i.y,i.w,i.h)
			funkyBox(i.x,i.y,i.w,i.h)
			love.graphics.setColor(1,1,1)
			if i == typingField then
				love.graphics.printf(i.text..textCursor, self.font or buttonFontBig, i.x+4,i.y+blockH*1/6,i.w-8,'left')
			else
				love.graphics.printf(i.text, self.font or buttonFontBig, i.x+4,i.y+blockH*1/6,i.w-8,'left')
			end
		elseif i.type == 4 then --pop-up
			love.graphics.setColor(0.2,0.2,0.6)
			love.graphics.rectangle('fill',i.x,i.y,i.w,i.h)
			funkyBox(i.x,i.y,i.w,i.h)
			love.graphics.setColor(1,1,1)
			love.graphics.printf(i.text, self.font or buttonFontBig, i.x,i.y+blockH*1/6,i.w,'center')
		elseif i.type == 1 then --highlight
			i:drawHighlight()
		elseif i.type == 5 then --player text field
			love.graphics.setColor(0.4,0.4,0.0)
			love.graphics.rectangle('fill',i.x,i.y,i.w,i.h)
			funkyBox(i.x,i.y,i.w,i.h)
			love.graphics.setColor(1,1,1)
			love.graphics.printf(i.text, self.font or playerFont, i.x+4,i.y+blockH*1/6,i.w-8,'left')
		elseif i.type == 6 then --chat
			love.graphics.setColor(0.3,0.3,0.3)
			love.graphics.rectangle('fill',i.x,i.y,i.w,i.h)
			funkyBox(i.x,i.y,i.w,i.h, 1)
			love.graphics.setColor(1,1,1)
			if i.text ~= "" or i == typingField and love.keyboard.hasTextInput( ) then
				if i == typingField and love.keyboard.hasTextInput( ) then
					love.graphics.printf(i.text..textCursor, self.font or buttonFontSmall, i.x+4,i.y+4,i.w-8,'left')
				else
					love.graphics.printf(i.text, self.font or buttonFontSmall, i.x+4,i.y+4,i.w-8,'left')
				end
			else 
				love.graphics.setColor(1,1,1,0.5)
				love.graphics.printf("Chat: ", self.font or buttonFontSmall, i.x+4,i.y+4,i.w-8,'left')
			end
		end
end

function funkyBox(x,y,w,h, linewidth)
	love.graphics.setLineWidth(linewidth or 2)
	love.graphics.setColor(0.3,0.3,1)
	love.graphics.rectangle('line', x, y, w, h)
	love.graphics.setColor(192/255,192/255,192/255)
	love.graphics.rectangle('line', x+2, y+2, w-4, h-4)
	love.graphics.rectangle('line', x-2, y-2, w+4, h+4)	

end

function Button:new(type,x,y,w,h,text,phase,font,priority,o)
	o = o or {}
	o.x,o.y,o.w,o.h = x,y,w,h
	o.var = 0
	o.text = text or ""
	o.phaseChange = phase
	o.type = type
	o.priority = priority or 0
	o.font = font
	setmetatable(o,self)
	self.__index = self
	return o
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
	love.graphics.printf(self.text, self.font or buttonFontBig, self.x-blockW/2*self.var,self.y+blockH*1/4,self.w,'center')
end

function Button:drawHighlight( ... )
	if self:hover() then
		love.graphics.setColor(0.08,0.08,0.25)
		love.graphics.rectangle('fill',self.x,self.y,self.w,self.h)
	end
	funkyBox(self.x,self.y,self.w,self.h)
	love.graphics.setColor(1,1,1)
	love.graphics.printf(self.text, self.font or buttonFontSmall, self.x,self.y+1,self.w,'center')
	
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
			if phase == 'Multiplayer' then
				sliderPos = {buttons[6].var, buttons[7].var}
			end
			phase = self.phaseChange
			initializeButtons()
		end
		if self.type == 3 or self.type == 6 or self.type == 5 then
			love.keyboard.setTextInput(true)
			cooldown = 1
			--if typed == false then
				typeFinished = false
				typingField = self
				--else typeFinished = true 
			--end
		end
		return true
	elseif love.mouse.isDown(1) and cooldown <= 0 then
		love.keyboard.setTextInput(false)
		typeFinished = true
	end
end










playerNameBox = Button:new()

function playerNameBox:new(x,y,w,h,text,playerPerm,o)
	o = o or {}
	o.x,o.y,o.w,o.h = x,y,w,h
	o.playerPerm = playerPerm
	o.type = 5
	o.text = text or ""
	setmetatable(o,self)
	self.__index = self
	return o
end

function playerNameBox:draw()
	local xhold = self.x
	love.graphics.setColor(0.4,0.4,0.0)
	if self.playerPerm == assignedPlayerNumber then
		self.x = self.x+10
		funkyBox(self.x-4,self.y-4,self.w+8,self.h+8)
		love.graphics.setColor(0.6,0.6,0.0)
	end
	love.graphics.rectangle('fill',self.x,self.y,self.w,self.h)
	funkyBox(self.x,self.y,self.w,self.h)
	love.graphics.setColor(1,1,1)
	if self == typingField then
		love.graphics.printf(self.text..textCursor, self.font or playerFont, self.x+4,self.y+blockH*1/10,self.w-8,'left')
	else
	love.graphics.printf(self.text, self.font or playerFont, self.x+4,self.y+blockH*1/10,self.w-8,'left')
	end
	--love.graphics.printf(players[self.playerPerm].name, playerFont, self.x+4,self.y+blockH*1/4,self.w-8,'left')
	self.x = xhold
end

function playerNameBox:isClicked( ... )
	if self:hover() and love.mouse.isDown(1) then
		if self.playerPerm == assignedPlayerNumber then
			love.keyboard.setTextInput(true)
			cooldown = 1
			if typed == false then
				typeFinished = false
				typingField = self
				else typeFinished = true end
		end
		return true
	elseif love.mouse.isDown(1) and cooldown <= 0 then
		love.keyboard.setTextInput(false)
		typeFinished = true
	end
end








inputField = Button:new()

function inputField:new(type,x,y,w,h,text,font,o)
	o = o or {}
	o.x,o.y,o.w,o.h = x,y,w,h
	o.var = 0
	o.text = text or ""
	o.phaseChange = phase
	o.type = type
	o.priority = priority or 0
	o.font = font
	setmetatable(o,self)
	self.__index = self
	return o
end








function drawChat(x,y,w,h)
	for i=0, h, 4 do
		love.graphics.setColor(0.2,0.2,0.2, 1-i/h)
		love.graphics.rectangle('fill', x, y-i, w, 4)
	end
	for v=1, table.getn(chat) do
		if table.getn(chat)-v > 1 then
			love.graphics.setColor(1,1,1,1-(table.getn(chat)-v)/(h/blockH))
		else
			love.graphics.setColor(1,1,1)
		end
		love.graphics.printf(chat[v], buttonFontSmall, x+0.5*blockW, y-blockH*(table.getn(chat)-v+1), w, 'left')
	end
end

function updateChatMessages()
	if typeFinished == true and typingField.type == 6 and typingField.text ~= "" then
		typeFinished = false
		typed = false
		table.insert(chat, typingField.text)
		sendNewChat = typingField.text
		typingField.text = ""
		love.keyboard.setTextInput(true)
	end
end








function popUp ( ... )
	if sliderPos[1] then
		buttons[6].var = sliderPos[1]
		buttons[7].var = sliderPos[2]
		print(sliderPos[1], sliderPos[2])
		sliderPos = {}
	end

	if joining then
		table.insert(buttons, Button:new(4, blockW*4.5, blockH*4, 7*blockW, blockH*3.5, "Joining..."))
		table.insert(buttons, Button:new(1, blockW*7, blockH*6.5, 2*blockW, blockH*3/4, "Cancel", 'breaker'))
	end
	if kicked == true then
		table.insert(buttons, Button:new(4, blockW*4.5, blockH*3, 7*blockW, blockH*4.5, "Your Host Has Left You"))
		table.insert(buttons, Button:new(1, blockW*7, blockH*6.5, 2*blockW, blockH*3/4, "Rude!", "Rude!"))
	end
	if kicked == 1 then
		table.insert(buttons, Button:new(4, blockW*4, blockH*3, 8*blockW, blockH*4.5, "The Lobby's Full! Outrageous!"))
		table.insert(buttons, Button:new(1, blockW*7, blockH*6.5, 2*blockW, blockH*3/4, "Rude!", "Rude!"))
	end
	if kicked == 2 then
		table.insert(buttons, Button:new(4, blockW*4.5, blockH*4, 7*blockW, blockH*3.5, "No Dice"))
		table.insert(buttons, Button:new(1, blockW*7, blockH*6.5, 2*blockW, blockH*3/4, "Shucks!", 'Rude!'))
	end
	if kicked == 3 then
		table.insert(buttons, Button:new(4, blockW*4.5, blockH*4, 7*blockW, blockH*3.5, "Formated Improperly. Write it as IP:Port", nil, ipFont))
		table.insert(buttons, Button:new(1, blockW*7, blockH*6.5, 2*blockW, blockH*3/4, "Fine", 'Rude!'))
	end
	if kicked == 4 then
		if msg then
			table.insert(buttons, Button:new(4, blockW*4.5, blockH*4, 7*blockW, blockH*3.5, "Failed to start host: "..msg, nil, ipFont))
		else 
			table.insert(buttons, Button:new(4, blockW*4.5, blockH*4, 7*blockW, blockH*3.5, "Failed to start host"))
		end
		table.insert(buttons, Button:new(1, blockW*7, blockH*6.5, 2*blockW, blockH*3/4, "Nani?", 'Rude!'))
		msg = nil
	end
	if awaitingIP == 1 then
		table.insert(buttons, Button:new(4, blockW*11.25, blockH*11, 3.5*blockW, blockH*2, "IP:Port",nil,ipFont))
		table.insert(buttons, Button:new(3, blockW*11.5, blockH*12, 3*blockW, blockH*3/4,nil,nil,ipFontSmall))
	end
	if awaitingIP == 2 then
		table.insert(buttons, Button:new(4, blockW*11.25, blockH*11, 3.5*blockW, blockH*2, "Port",nil,ipFont))
		table.insert(buttons, Button:new(3, blockW*11.5, blockH*12, 3*blockW, blockH*3/4,nil,nil,ipFontSmall))
	end
end







--[[Here's a stupid priority system. Just order the buttons when you initialize them tbh

function drawButtons( ... )
	--I did this whole damn priority system instead of just changing the order of the buttons.
	for v, i in ipairs(buttons) do
		if i.priority == nil or i.priority < 1 then
			if i.type == 1 then
				i:drawHighlight()
			elseif i.type == 2 then
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
			end
		end
	end
	for v, i in ipairs(buttons) do
		if i.priority == 1 then
			if i.type == 1 then
				i:drawHighlight()
			elseif i.type == 2 then
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
			end
		end
	end
	for v, i in ipairs(buttons) do
		if i.priority >= 2 then
			if i.type == 1 then
				i:drawHighlight()
			elseif i.type == 2 then
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
			end
		end
	end
end]]