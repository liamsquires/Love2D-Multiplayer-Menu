--Client
local socket = require "socket"
local udp = socket.udp()

udp:settimeout(0)
local serverPort = 7777
local clientPort = 0
local hostname = socket.dns.gethostname()
local myIP = socket.dns.toip(hostname)
local connected = false
--udp:setsockname(myIP, clientPort)
--udp:close()
udp:setsockname('0.0.0.0', clientPort)
assert(udp:setoption('broadcast', true))
assert(udp:setoption('dontroute', true))
print(udp:getsockname())
print(hostname)
v=0

assert(udp:sendto('JoinRequest', '70.73.228.13' ,serverPort))
function love.update()
if connected == false then
	v=v+1
	if v > 10 then

	data, msg_or_ip, port_or_nil = udp:receivefrom()
	--print(data)
	--if data == nil and msg_or_ip == 'timeout' then print(msg_or_ip) end
		if data ~= nil and data ~= 'JoinRequest' then
			--do I need to close the socket?
			print(data,port_or_nil)
			assert(udp:setpeername(data,port_or_nil))
			udp:send('connected')
			connected = true
		end
		v=0
	end
end
end
assert(udp:setoption('broadcast', false))