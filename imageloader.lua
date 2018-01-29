
imageloader = { }

local types = { }

local bmp_meta = {
	__index = bmp_methods,
}

--[[
typedef = {
	description = "FOO File",
	check = func(filename), --> bool
	load = func(filename), --> table or (nil, errormsg)
}
]]

function imageloader.register_type(def)
	types[#types + 1] = def
end

local function find_loader(filename)
	for _,def in ipairs(types) do
		local r = def.check(filename)
		if r then
			return def
		end
	end
	return nil, "imageloader: unknown file type"
end

function imageloader.load(filename)
	local def, e = find_loader(filename)
	if not def then return nil, e end
	local r, e = def.load(filename)
	if r then
		r = setmetatable(r, bmp_meta)
	end
	return r, e
end

function imageloader.type(filename)
	local def, e = find_loader(filename)
	if not def then return nil, e end
	return def.description
end

local dither = true
if dither then
	function imageloader.to_schematic(bmp, pal)
		local data = { }
		local datai = 1
		local rgb_off = {0,0,0}
		for z = 1, bmp.h do
			for x = 1, bmp.w do
				local c = bmp.pixels[z][bmp.w + 1 - x]
				local transparent = c.r == 255 and c.g == 0 and c.b == 255
				local nodeinfo
				if not transparent then
					local actual_lincol = {
						(c.r / 255) ^ 2.2 + rgb_off[1],
						(c.g / 255) ^ 2.2 + rgb_off[2],
						(c.b / 255) ^ 2.2 + rgb_off[3],
					}
					for i = 1,3 do
						actual_lincol[i] = math.max(0.0,
							math.min(1.0, actual_lincol[i]))
					end
					c = {
						r = actual_lincol[1] ^ (1/2.2) * 255,
						g = actual_lincol[2] ^ (1/2.2) * 255,
						b = actual_lincol[3] ^ (1/2.2) * 255,
					}
					c.r = math.max(0, math.min(255, math.floor(c.r + 0.5)))
					c.g = math.max(0, math.min(255, math.floor(c.g + 0.5)))
					c.b = math.max(0, math.min(255, math.floor(c.b + 0.5)))

					nodeinfo = pal[palette.bestfit_color(pal, c)]

					local used_lincol = {
						(nodeinfo.r / 255) ^ 2.2,
						(nodeinfo.g / 255) ^ 2.2,
						(nodeinfo.b / 255) ^ 2.2,
					}
					for i = 1,3 do
						rgb_off[i] = actual_lincol[i] - used_lincol[i]
					end
				else
					nodeinfo = pal[1]
				end

				data[datai] = {name = nodeinfo.node}
				datai = datai + 1
			end
		end
		return {
			size = { x=bmp.w, y=1, z=bmp.h },
			data = data,
		}
	end
else
	function imageloader.to_schematic(bmp, pal)
		local data = { }
		local datai = 1
		for z = 1, bmp.h do
			for x = 1, bmp.w do
				local c = bmp.pixels[z][bmp.w + 1 - x]
				local i = palette.bestfit_color(pal, c)
				if (i == 1) and ((c.r ~= 255) or (c.g ~= 0)
				or (c.r ~= 255)) then
					print("WARNING: wrong color taken as transparency:"
						..(("at (%d,%d): [R=%d,G=%d,B=%d]"):format(x, z, c.r,
						c.g, c.b))
					)
				end
				local node = pal[i].node
				data[datai] = { name=node }
				datai = datai + 1
			end
		end
		return {
			size = { x=bmp.w, y=1, z=bmp.h },
			data = data,
		}
	end
end

minetest.register_chatcommand("loadimage", {
	description = "Load an image file into the world at current position",
	params = "<filename>",
	func = function(name, param)
		param = param:trim()
		if param == "" then
			minetest.chat_send_player(name, "[imageloader] Usage: /loadimage <filename>")
			return
		end
		minetest.chat_send_player(name, "[imageloader] Loading image...")
		local bmp, e = imageloader.load(minetest.get_modpath("imageloader").."/images/"..param)
		if not bmp then
			minetest.chat_send_player(name, "[imageloader] Failed to load image: "..(e or "unknown error"))
			return
		end
		print(("Image loaded: size: %dx%d"):format(bmp.w, bmp.h))
		minetest.chat_send_player(name, "[imageloader] Creating schematic...")
		local schem = imageloader.to_schematic(bmp, palette.wool_palette)
		print(("Schematic created: size: %dx%dx%d"):format(schem.size.x, schem.size.y, schem.size.z))
		minetest.chat_send_player(name, "[imageloader] Placing schematic...")
		local pos = minetest.get_player_by_name(name):getpos()
		minetest.place_schematic(pos, schem, 0)
		minetest.chat_send_player(name, "[imageloader] DONE!")
	end,
})
