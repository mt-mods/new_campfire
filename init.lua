-- VARIABLES
new_campfire = {}

-- Load support for intllib. and config
    local MP = minetest.get_modpath(minetest.get_current_modname())
    local S, NS = dofile(MP.."/intllib.lua")
    dofile(MP.."/config.lua")

-- FUNCTIONS
local function fire_particles_on(pos) -- 3 layers of fire
    local meta = minetest.get_meta(pos)
    local id = minetest.add_particlespawner({ -- 1 layer big particles fire
          amount = 26,
		  time = 3.3,
		  minpos = {x = pos.x - 0.2, y = pos.y - 0.4, z = pos.z - 0.2},
		  maxpos = {x = pos.x + 0.2, y = pos.y - 0.1, z = pos.z + 0.2},
		  minvel = {x= 0, y= 0, z= 0},
		  maxvel = {x= 0, y= 0.1, z= 0},
		  minacc = {x= 0, y= 0, z= 0},
		  maxacc = {x= 0, y= 0.5, z= 0},
		  minexptime = 0.3,
		  maxexptime = 0.6,
		  minsize = 2,
		  maxsize = 5,
		  collisiondetection = false,
		  vertical = true,
		  texture = "new_campfire_anim_fire.png",
          animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 0.7,},
	--	      playername = "singleplayer"
	})
    meta:set_int("layer_1", id)

    local id = minetest.add_particlespawner({ -- 2 layer smol particles fire
		  amount = 3,
		  time = 3.3,
		  minpos = {x = pos.x - 0.1, y = pos.y, z = pos.z - 0.1},
		  maxpos = {x = pos.x + 0.1, y = pos.y + 0.4, z = pos.z + 0.1},
		  minvel = {x= 0, y= 0, z= 0},
		  maxvel = {x= 0, y= 0.1, z= 0},
 		  minacc = {x= 0, y= 0, z= 0},
		  maxacc = {x= 0, y= 1, z= 0},
		  minexptime = 0.3,
		  maxexptime = 0.5,
		  minsize = 0.5,
		  maxsize = 0.7,
		  collisiondetection = false,
		  vertical = true,
		  texture = "new_campfire_anim_fire.png",
          animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 0.6,},
	     -- playername = "singleplayer" -- показывать только определенному игроку.
	})
    meta:set_int("layer_2", id)

    local id = minetest.add_particlespawner({ --3 layer smoke
		  amount = 6,
		  time = 3.3,
		  minpos = {x = pos.x - 0.1, y = pos.y - 0.2, z = pos.z - 0.1},
		  maxpos = {x = pos.x + 0.2, y = pos.y + 0.4, z = pos.z + 0.2},
		  minvel = {x= 0, y= 0, z= 0},
		  maxvel = {x= 0, y= 0.1, z= 0},
		  minacc = {x= 0, y= 0, z= 0},
		  maxacc = {x= 0, y= 1, z= 0},
		  minexptime = 0.6,
		  maxexptime = 0.6,
		  minsize = 1,
		  maxsize = 4,
		  collisiondetection = true,
		  vertical = true,
		  texture = "new_campfire_anim_smoke.png",
          animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 0.7,},
		-- playername = "singleplayer"
	})
--    print (dump(id))
    meta:set_int("layer_3", id)
end

local function fire_particles_off(pos)
  local meta = minetest.get_meta(pos)
  local id_1 = meta:get_int("layer_1");
  local id_2 = meta:get_int("layer_2");
  local id_3 = meta:get_int("layer_3");
  minetest.delete_particlespawner(id_1)
  minetest.delete_particlespawner(id_2)
  minetest.delete_particlespawner(id_3)
end

local function indicator(maxVal, curVal)
    local percent_val = math.floor(curVal / maxVal * 100)
    local progress = ""
    local v = percent_val / 10
    for k=1,10 do
        if v > 0 then
            progress = progress.."▓"
        else
            progress = progress.."▒"
        end
        v = v - 1
    end
--    print(progress.." "..percent_val.."%")
    return "\n"..progress.." "..percent_val.."%"
end

-- NODES

minetest.register_node('new_campfire:campfire', {
	description = S("Campfire"),
	drawtype = 'mesh',
	mesh = 'contained_campfire.obj',
	tiles = {{name='[combine:16x16:0,0=default_cobble.png:0,8=default_wood.png'}},
    inventory_image = "campfire.png",
    wield_image = "[combine:16x16:0,0=fire_basic_flame.png:0,12=default_cobble.png",
	walkable = false,
	buildable_to = false,
	sunlight_propagates = true,
	groups = {dig_immediate=3, flammable=0},
	paramtype = 'light',
	selection_box = {
		type = 'fixed',
		fixed = { -0.48, -0.5, -0.48, 0.48, -0.4, 0.48 },
		},
	sounds = default.node_sound_stone_defaults(),

	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string('infotext', S("Campfire"));
	end,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	  if itemstack:get_name() == "fire:flint_and_steel" then
		 minetest.sound_play("fire_flint_and_steel",{pos = pos, gain = 0.5, max_hear_distance = 8})
		 minetest.set_node(pos, {name = 'new_campfire:campfire_active'})
         local id = minetest.add_particle({
	           pos = {x = pos.x, y = pos.y, z = pos.z},
	           velocity = {x=0, y=0.1, z=0},
	           acceleration = {x=0, y=0, z=0},
	           expirationtime = 2,
	           size = 4,
               collisiondetection = true,
               vertical = true,
               texture = "new_campfire_anim_smoke.png",
               animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 2.5,},
--             playername = "singleplayer"
        })
	  end
	end,
})

minetest.register_node('new_campfire:campfire_active', {
	description = S("Active campfire"),
	drawtype = 'mesh',
	mesh = 'contained_campfire.obj',
	tiles = {{name='[combine:16x16:0,0=new_campfire_cobble.png:0,8=nnew_campfire_wood.png'}},
    inventory_image = "campfire.png",
    wield_image = "[combine:16x16:0,0=fire_basic_flame.png:0,12=default_cobble.png",
	walkable = false,
	buildable_to = false,
	sunlight_propagates = true,
	groups = {dig_immediate=3, flammable=0, not_in_creative_inventory=1},
--	paramtype = 'light',
	paramtype = 'none',
    light_source = 13,
    damage_per_second = 3,
    drop = "new_campfire:campfire",
    sounds = default.node_sound_stone_defaults(),
	selection_box = {
		type = 'fixed',
		fixed = { -0.48, -0.5, -0.48, 0.48, -0.4, 0.48 },
		},

    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
      if itemstack:get_name() == "default:stick" then
          local meta = minetest.get_meta(pos)
          local it_val = meta:get_int("it_val") + (new_campfire_stick_time);
          meta:set_int('it_val', it_val);
          local id = minetest.add_particle({
 	           pos = {x = pos.x, y = pos.y+0.5, z = pos.z},
 	           velocity = {x=0, y=-1, z=0},
 	           acceleration = {x=0, y=0, z=0},
 	           expirationtime = 1,
 	           size = 4,
                collisiondetection = true,
                vertical = true,
                texture = "default_stick.png",
         })
         if not minetest.setting_getbool("creative_mode") then
            itemstack:take_item()
			return itemstack
         end
      end
	end,

    on_construct = function(pos)
  		local meta = minetest.env:get_meta(pos)
        if new_campfire_limit == 1 and new_campfire_ttl > 0 then
            meta:set_int('it_val', new_campfire_ttl);
            meta:set_string('infotext', S("Active campfire")..indicator(1, 1));
        else
            meta:set_string('infotext', S("Active campfire"));
        end
        minetest.get_node_timer(pos):start(2)
  	end,

    on_destruct = function(pos, oldnode, oldmetadata, digger)
        fire_particles_off(pos)
        local meta = minetest.get_meta(pos)
        local handle = meta:get_int("handle")
        minetest.sound_stop(handle)
  	end,

    on_timer = function(pos) -- Every 6 seconds play sound fire_small
        local meta = minetest.get_meta(pos)
        local handle = minetest.sound_play("fire_small",{pos=pos, max_hear_distance = 18, loop=false, gain=0.1})
        meta:set_int("handle", handle)
        minetest.get_node_timer(pos):start(6)
    end,
})

-- ABM
minetest.register_abm({
	nodenames = {"new_campfire:campfire_active"},
--  neighbors = {"group:puts_out_fire"},
	interval = 3.0, -- Run every 3 seconds
	chance = 1, -- Select every 1 in 1 nodes
    catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
    local fpos, num = minetest.find_nodes_in_area(
      {x=pos.x-1, y=pos.y, z=pos.z-1},
      {x=pos.x+1, y=pos.y+1, z=pos.z+1},
      {"group:water"}
    )
    if #fpos > 0 then
      minetest.set_node(pos, {name = 'new_campfire:campfire'})
      minetest.sound_play("fire_extinguish_flame",{pos = pos, max_hear_distance = 16, gain = 0.15})
    else
      if new_campfire_limit == 1 and new_campfire_ttl > 0 then
          local meta = minetest.get_meta(pos)
          local it_val = meta:get_int("it_val") - 3;
          if it_val <= 0 then
              minetest.remove_node(pos)
              return
          end
          meta:set_int('it_val', it_val);
          meta:set_string('infotext', S("Active campfire")..indicator(new_campfire_ttl, it_val));
      end
      fire_particles_on(pos)
    end
  end
})

-- CRAFTS
minetest.register_craft({
	output = "new_campfire:campfire",
	recipe = {
        {'', 'default:stick', ''},
        {'group:stone','default:stick', 'group:stone'},
        {'', 'group:stone', ''},
    }
})
