
palette = { }

local PAL_SIZE = 256

local floor = math.floor

local col_diff

--[[ bestfit_init:
  |  Color matching is done with weighted squares, which are much faster
  |  if we pregenerate a little lookup table...
  ]]
local function bestfit_init()

	col_diff = { }

	for i = 0, 63 do
		local k = i * i;
		local t

		t = k * (59 * 59)
		col_diff[0  +i] = t
		col_diff[0  +128-i] = t

		t = k * (30 * 30)
		col_diff[128+i] = t
		col_diff[128+128-i] = t

		t = k * (11 * 11)
		col_diff[256+i] = t
		col_diff[256+128-i] = t
	end

end

--[[ bestfit_color:
  |  Searches a palette for the color closest to the requested R, G, B value.
  ]]
function palette.bestfit_color(pal, c)

	local r, g, b = floor(c.r / 4), floor(c.g / 4), floor(c.b / 4)

	local i, coldiff, lowest, bestfit

	assert((r >= 0) and (r <= 63))
	assert((g >= 0) and (g <= 63))
	assert((b >= 0) and (b <= 63))

	bestfit = 1
	lowest = math.huge

	-- only the transparent (pink) color can be mapped to index 0
	if (r == 63) and (g == 0) and (b == 63) then
		i = 1
	else
		i = 2
	end

	while i < PAL_SIZE do
		local cc = pal[i]
		if not cc then break end
		local rgb = { r=floor(cc.r / 4), g = floor(cc.g / 4), b = floor(cc.b / 4) }
		coldiff = col_diff[0 + ((rgb.g - g) % 0x80)]
		if coldiff < lowest then
			coldiff = coldiff + col_diff[128 + ((rgb.r - r) % 0x80)]
			if coldiff < lowest then
				coldiff = coldiff + col_diff[256 + ((rgb.b - b) % 0x80)]
				if coldiff < lowest then
					bestfit = i
					if coldiff == 0 then return bestfit end
					lowest = coldiff
				end
			end
		end
		i = i + 1
	end

	return bestfit

end

palette.wool_palette = {
	{ node="default:cloud", r=224, g=224, b=224 },
	{ node="default:desert_sand", r=217, g=169, b=90 },
	{ node="default:desert_stone", r=121, g=77, b=52 },
	{ node="default:gravel", r=86, g=86, b=85 },
	{ node="default:junglewood", r=101, g=72, b=33 },
	{ node="default:obsidian", r=20, g=22, b=25 },
	{ node="default:sandstone", r=203, g=182, b=139 },
	{ node="default:stonebrick", r=98, g=96, b=95 },
	{ node="default:stone", r=97, g=94, b=93 },
	{ node="default:brick", r=124, g=78, b=76 },
	{ node="default:bronzeblock", r=159, g=97, b=37 },
	{ node="default:clay", r=121, g=121, b=121 },
	{ node="default:coalblock", r=11, g=11, b=11 },
	{ node="default:cobble", r=51, g=51, b=51 },
	{ node="default:copperblock", r=152, g=118, b=84 },
	{ node="default:desert_cobble", r=154, g=98, b=80 },
	{ node="default:desert_stonebrick", r=126, g=77, b=59 },
	{ node="default:dirt", r=115, g=78, b=55 },
	{ node="default:goldblock", r=171, g=156, b=40 },
	{ node="default:mese", r=226, g=228, b=2 },
	{ node="default:mossycobble", r=89, g=115, b=64 },
	{ node="default:obsidian_brick", r=19, g=21, b=23 },
	{ node="default:sand", r=219, g=209, b=167 },
	{ node="default:sandstonebrick", r=188, g=173, b=138 },
	{ node="default:snowblock", r=234, g=235, b=255 },
	{ node="default:tinblock", r=150, g=150, b=158 },
	{ node="default:wood", r=141, g=110, b=64 },
	{ node="moreblocks:all_faces_tree", r=176, g=141, b=96 },
	{ node="extrablocks:mossywall", r=168, g=179, b=154 },
	{ node="extrablocks:gold", r=130, g=112, b=19 },
	{ node="extrablocks:lapis_lazuli_block", r=87, g=113, b=213 },
	{ node="extrablocks:space", r=17, g=2, b=64 },
	{ node="extrablocks:onefootstep", r=60, g=60, b=60 },
	{ node="extrablocks:previous_cobble", r=76, g=76, b=76 },
	{ node="extrablocks:dried_dirt", r=197, g=154, b=116 },
	{ node="extrablocks:iringnite_block", r=222, g=222, b=222 },
	{ node="extrablocks:marble_ore", r=219, g=219, b=219 },
	{ node="extrablocks:wall", r=222, g=222, b=222 },
	{ node="extrablocks:special", r=52, g=52, b=52 },
	{ node="extrablocks:goldbrick", r=82, g=72, b=28 },
	{ node="extrablocks:fokni_gnebbrick", r=128, g=132, b=90 },
	{ node="extrablocks:goldblock", r=188, g=167, b=65 },
	{ node="extrablocks:stonebrick", r=112, g=110, b=108 },
	{ node="extrablocks:mossystonebrick", r=101, g=106, b=71 },
	{ node="extrablocks:acid", r=1, g=225, b=0 },
	{ node="extrablocks:coalblock", r=10, g=10, b=10 },
	{ node="extrablocks:marble_tiling", r=204, g=204, b=204 },
	{ node="extrablocks:fokni_gneb", r=130, g=132, b=110 },
	{ node="extrablocks:marble_clean", r=235, g=235, b=235 },
	{ node="ignore", r=255, g=0, b=255 },
	{ node="moreblocks:cactus_brick", r=89, g=154, b=88 },
	{ node="moreblocks:circle_stone_bricks", r=85, g=82, b=81 },
	{ node="moreblocks:iron_stone_bricks", r=124, g=119, b=117 },
	{ node="moreblocks:stone_tile", r=59, g=59, b=59 },
	{ node="moreblocks:trap_stone", r=103, g=103, b=87 },
	{ node="moreblocks:coal_stone", r=91, g=91, b=91 },
	{ node="moreblocks:iron_stone", r=136, g=136, b=136 },
	{ node="moretrees:birch_planks", r=231, g=178, b=90 },
	{ node="moretrees:fir_planks", r=171, g=140, b=108 },
	{ node="moretrees:oak_planks", r=140, g=97, b=41 },
	{ node="moretrees:sequoia_planks", r=174, g=91, b=64 },
	{ node="nether:netherrack", r=78, g=26, b=21 },
	{ node="nether:blood_empty", r=172, g=150, b=142 },
	{ node="nether:dirt", r=101, g=77, b=51 },
	{ node="nether:wood", r=122, g=0, b=0 },
	{ node="nether:blood", r=130, g=0, b=0 },
	{ node="nether:blood_cooked", r=50, g=36, b=36 },
	{ node="nether:wood_empty", r=175, g=161, b=148 },
	{ node="nether:netherrack_black", r=16, g=16, b=18 },
	{ node="nether:white", r=232, g=231, b=188 },
	{ node="nether:forest_wood", r=153, g=141, b=118 },
	{ node="nether:extractor", r=80, g=37, b=30 },
	{ node="nether:netherrack_brick_blue", r=44, g=47, b=54 },
	{ node="nether:netherrack_blue", r=64, g=69, b=80 },
	{ node="nether:fruit_leaves", r=32, g=130, b=0 },
	{ node="nether:netherrack_brick_black", r=22, g=22, b=23 },
	{ node="nether:netherrack_brick", r=72, g=23, b=19 },
	{ node="nether:netherrack_tiled", r=88, g=29, b=26 },
	{ node="nether:wood_cooked", r=95, g=32, b=32 },
	{ node="wool:black", r=30, g=30, b=30 },
	{ node="wool:blue", r=0, g=73, b=145 },
	{ node="wool:brown", r=86, g=43, b=0 },
	{ node="wool:cyan", r=0, g=131, b=139 },
	{ node="wool:dark_green", r=33, g=103, b=0 },
	{ node="wool:dark_grey", r=59, g=59, b=59 },
	{ node="wool:green", r=92, g=216, b=28 },
	{ node="wool:grey", r=131, g=131, b=131 },
	{ node="wool:magenta", r=201, g=3, b=109 },
	{ node="wool:orange", r=213, g=82, b=22 },
	{ node="wool:pink", r=255, g=132, b=132 },
	{ node="wool:red", r=168, g=18, b=18 },
	{ node="wool:violet", r=93, g=3, b=169 },
	{ node="wool:white", r=220, g=220, b=220 },
	{ node="wool:yellow", r=254, g=225, b=16 },
}

bestfit_init()
