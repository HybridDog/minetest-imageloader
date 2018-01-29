
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
	{ node="ignore", r=255, g=0, b=255 },
	{ node="wool:white", r=221, g=221, b=221},
	{ node="wool:grey", r=134, g=134, b=134},
	{ node="wool:dark_grey", r=61, g=61, b=61},
	{ node="wool:black", r=31, g=31, b=31},
	{ node="wool:red", r=171, g=18, b=18},
	{ node="wool:green", r=94, g=218, b=28},
	{ node="wool:dark_green", r=34, g=104, b=0},
	{ node="wool:blue", r=0, g=74, b=146},
	{ node="wool:violet", r=93, g=6, b=170},
	{ node="wool:magenta", r=202, g=3, b=113},
	{ node="wool:orange", r=214, g=84, b=22},
	{ node="wool:yellow", r=254, g=227, b=16},
	{ node="wool:pink", r=255, g=134, b=134},
	{ node="wool:brown", r=89, g=45, b=0},
	{ node="wool:cyan", r=0, g=133, b=141},

	{node="default:acacia_tree", r=196, g=121, b=100},
	{node="default:acacia_wood", r=151, g=62, b=40},
	{node="default:aspen_tree", r=218, g=198, b=169},
	{node="default:aspen_wood", r=210, g=199, b=171},
	{node="default:brick", r=124, g=104, b=100},
	{node="default:bronzeblock", r=187, g=111, b=15},
	{node="default:cactus", r=74, g=120, b=58},
	{node="default:chest", r=151, g=117, b=71},
	{node="default:clay", r=183, g=183, b=183},
	{node="default:coalblock", r=59, g=59, b=59},
	{node="default:cobble", r=90, g=87, b=85},
	{node="default:copperblock", r=193, g=127, b=65},
	{node="default:desert_cobble", r=111, g=68, b=51},
	{node="default:desert_sandstone_block", r=193, g=152, b=95},
	{node="default:desert_sandstone_brick", r=192, g=152, b=96},
	{node="default:desert_sandstone", r=195, g=153, b=93},
	{node="default:desert_stone_block", r=132, g=80, b=62},
	{node="default:desert_stonebrick", r=132, g=81, b=62},
	{node="default:diamondblock", r=141, g=219, b=224},
	{node="default:furnace", r=102, g=99, b=96},
	{node="default:goldblock", r=232, g=204, b=36},
	{node="default:gravel", r=133, g=133, b=133},
	{node="default:jungletree", r=125, g=101, b=66},
	{node="default:junglewood", r=57, g=40, b=14},
	{node="default:meselamp", r=214, g=216, b=144},
	{node="default:mese", r=223, g=223, b=0},
	{node="default:mossycobble", r=88, g=92, b=74},
	{node="default:obsidian_block", r=24, g=26, b=32},
	{node="default:obsidianbrick", r=24, g=26, b=31},
	{node="default:obsidian", r=21, g=25, b=30},
	{node="default:pine_tree", r=193, g=167, b=133},
	{node="default:pine_wood", r=222, g=185, b=131},
	{node="default:sand", r=214, g=207, b=159},
	{node="default:sandstone_block", r=196, g=191, b=142},
	{node="default:sandstonebrick", r=195, g=190, b=142},
	{node="default:sandstone", r=198, g=193, b=144},
	{node="default:sand_with_kelp", r=214, g=207, b=159},
	{node="default:silver_sand", r=194, g=192, b=180},
	{node="default:silver_sandstone_block", r=193, g=191, b=181},
	{node="default:silver_sandstone_brick", r=192, g=190, b=180},
	{node="default:silver_sandstone", r=195, g=193, b=182},
	{node="default:snowblock", r=225, g=226, b=238},
	{node="default:steelblock", r=195, g=196, b=195},
	{node="default:stone_block", r=101, g=98, b=97},
	{node="default:stonebrick", r=103, g=100, b=99},
	{node="default:stone", r=98, g=95, b=94},
	{node="default:tinblock", r=150, g=150, b=151},
	{node="default:tree", r=182, g=148, b=102},
	{node="default:wood", r=132, g=103, b=58},
}

bestfit_init()
