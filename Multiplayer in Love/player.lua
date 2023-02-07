Player = {}
players = {}

maxPlayers = 4


function Player:new( num, o)
	o = o or {}
	o.playerNumber = num
	o.name = "Player "..tostring(num)
	setmetatable(o,self)
	self.__index = self
	--if table.getn(players) == maxPlayers then
	--	return nil
	--else
		return o
	--end
end


