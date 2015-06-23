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

			-- shellcode info extracted from previous dump
			local key = 0x99
			local decipher_routine_size = 0x17
			local shellcode_size = 0x17d

			-- fill shellcode buffer from stream
			local code = haka.vbuffer_allocate(0)
			local size = 0

			local sub
			for sub in iter:foreach_available() do
				code:append(haka.vbuffer_from(sub:asstring()))
				size  = size + #sub
				if size >= shellcode_size then break end
			end

			-- remove superfluous data
			code:sub(decipher_routine_size + shellcode_size):erase()

			-- decipher shellcode
			local byte
			for i = decipher_routine_size, #code-1 do
				byte = bit32.bxor(code:sub(i):asbits(0, 8), key)
				code:sub(i):setbits(0, 8, byte)
			end

			-- dump shellcode
			local start = code:pos(decipher_routine_size)
			dasm:dump_instructions(start)
		end
	end
}
