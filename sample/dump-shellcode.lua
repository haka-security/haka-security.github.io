local tcp_connection = require('protocol/tcp_connection')

local rem = require('regexp/pcre')
local re = rem.re:compile('%x90{100,}')

local asm = require('misc/asm')
local dasm = asm.new_disassembler('x86', '32')
dasm:setsyntax('att')

haka.rule {
	hook = tcp_connection.events.receive_data,
	options = {
		streamed = true,
	},
	eval = function (flow, iter, direction)
		if flow.dstport ~= 445 then return end
		if re:match(iter, false) then
			-- raise an alert
			haka.alert{
				description = "nop sled detected",
				targets = { haka.alert.service(flow.dstport, "smb") }
			}
			-- dump 30 instructions following nop sled
			dasm:dump_instructions(iter, 30)
		end
	end
}
