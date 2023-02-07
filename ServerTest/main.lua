--Server
local socket = require "socket"
local udp = socket.udp()
udp:setoption('broadcast', true)
udp:settimeout(0)
local serverPort = 7777
local clientPort = 27402
local hostname = socket.dns.gethostname()
local myIP = socket.dns.toip(hostname)
udp:setsockname('0.0.0.0', serverPort)
assert(udp:setoption('dontroute', true))
print(udp:getsockname())
print(hostname)

function love.update()

	data, msg_or_ip, port_or_nil = udp:receivefrom()
	--print(data)
	--if data == nil and msg_or_ip == 'timeout' then print(msg_or_ip) end
	if data == 'JoinRequest' then
		udp:sendto(myIP, msg_or_ip, port_or_nil)
		print(data, msg_or_ip, port_or_nil)
	end
	if data == 'connected' then
		print(data, msg_or_ip, port_or_nil)
	end
	socket.sleep(0.01)
end