local creeper_siege_enabled = minetest.settings:get_bool("mcl_raids_creeper_siege", false)

local function check_spawn_pos(pos)
	-- return mcl_util.get_natural_light(pos) < 7
	return true
end

local function spawn_creepers(self)
	minetest.sound_play("peepeepoopoocheck", { pos = self.pos, max_hear_distance=512, gain=1 }, true)
	local nn = minetest.find_nodes_in_area_under_air(vector.offset(self.pos,-16,-16,-16),vector.offset(self.pos,16,16,16),{"group:solid"})
	table.shuffle(nn)
	for i=1,20 do
		local p = vector.offset(nn[i%#nn],0,1,0)
		if check_spawn_pos(p) then
			local m = mcl_mobs.spawn(p,"mobs_mc:creeper")
			if m then
				local l = m:get_luaentity()
				l:gopath(self.pos)
				table.insert(self.mobs, m)
				self.health_max = self.health_max + l.health
			else
				minetest.log("Failed to spawn creeper at location: " .. minetest.pos_to_string(p))
			end
		end
	end
end

mcl_events.register_event("creeper_siege",{
	readable_name = "Creeper Siege",
	max_stage = 1,
	health = 1,
	health_max = 1,
	exclusive_to_area = 128,
	enable_bossbar = false,
	cond_start  = function(self)
		--minetest.log("Cond start zs")
		local r = {}

		if not creeper_siege_enabled then
			minetest.log("action", "creeper siege disabled")
			return r
		else
			minetest.log("action", "creeper siege start check")
		end

		local t = minetest.get_timeofday()
		local pr = PseudoRandom(minetest.get_day_count())
		local rnd = pr:next(1,2)
		local random = math.random(1, 10)

		if t > 0.04 then
			minetest.log("Well, it's siege time")
			for _,p in pairs(minetest.get_connected_players()) do
				minetest.log("action", "Creeper siege is starting")
				table.insert(r,{ player = p:get_player_name(), pos = village})
			end
		else
			minetest.log("Not night for a siege, or not success")
		end
		if #r > 0 then return r end
	end,
	on_start = function(self)
		self.mobs = {}
		self.health_max = 1
		self.health = 0
	end,
	cond_progress = function(self)
		local m = {}
		local h = 0
		for k,o in pairs(self.mobs) do
			if o and o:get_pos() then
				local l = o:get_luaentity()
				h = h + l.health
				table.insert(m,o)
			end
		end
		self.mobs = m
		self.health = h
		self.percent = math.max(0,(self.health / self.health_max ) * 100)
		if #m < 1 then
			return true end
	end,
	on_stage_begin = spawn_creepers,
	cond_complete = function(self)
		local m = {}
		for k,o in pairs(self.mobs) do
			if o and o:get_pos() then
				local l = o:get_luaentity()
				table.insert(m,o)
			end
		end
		return self.stage >= self.max_stage and #m < 1
	end,
	on_complete = function(self)
		--minetest.log("SIEGE complete")
		--awards.unlock(self.player,"mcl:hero_of_the_village")
	end,
})
