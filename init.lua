-- Superblock v1.0
-- (c)2019 Nigel Garnett.

local function push_pull(pos,pt,dir)
    local ptpos = minetest.get_pointed_thing_position(pt, true)
    local add = { x=0, y=0, z=0 }
    if pos.y > ptpos.y then add.y = dir end
    if pos.y < ptpos.y then add.y = -dir end
    if pos.x > ptpos.x then add.x = dir end
    if pos.x < ptpos.x then add.x = -dir end
    if pos.z > ptpos.z then add.z = dir end
    if pos.z < ptpos.z then add.z = -dir end
    return add
end


local function move_block(pos,dir,clicker)
    local node = minetest.get_node(pos)
    local item = clicker:get_wielded_item():get_name()
    if item == "" or item == "superblock:block" then
        local newpos = { x=pos.x+dir.x, y=pos.y+dir.y, z=pos.z+dir.z }
        local moveto_node = minetest.get_node(newpos)
        if moveto_node.name == "air" then
            minetest.set_node(newpos,{name=node.name})
            minetest.set_node(pos,{name="air"})
--             local clicker_pos = vector.round(clicker:get_pos())
--             if math.abs(clicker_pos.x-pos.x)<2 and
--                     math.abs(clicker_pos.z-pos.z)<2 and
--                     clicker_pos.y==pos.y+1 then
--                 clicker:setpos({x=clicker_pos.x+dir.x,
--                                 y=clicker_pos.y+dir.y+0.1,
--                                 z=clicker_pos.z+dir.z })
--             end
        else
            minetest.sound_play("system-fault",{pos = newpos, gain = 10})
        end
    else
        minetest.dig_node(pos)
    end
end


-- local function control_block(player)
--     local player_pos = vector.round(player:get_pos())
--     local try_pos = { x=player_pos.x, y=player_pos.y-1, z=player_pos.z }
--     local node_name = minetest.get_node(try_pos).name
--     if node_name == "superblock:block" then
--         local facing = minetest.dir_to_facedir(player:get_look_dir())
--         local add = { x=0, y=0, z=0 }
--         if facing == 0 then add.z = 1 end
--         if facing == 1 then add.x = 1 end
--         if facing == 2 then add.z = -1 end
--         if facing == 3 then add.x = -1 end
--         move_block(try_pos,add,player)
--     end
-- end


minetest.register_node("superblock:block", {
    description = "Superblock",
    drawtype = "mesh",
    mesh = "mymeshnodes_sphere.obj",
    tiles = {"superblock_plain_ball.png^[colorize:#ff00ff:100"},
    is_ground_content = false,
    stack_max = 1,
    light_source = core.LIGHT_MAX,
    groups = {cracky = 3, snappy = 3, crumbly = 3},
    on_blast = function() end,
    on_punch = function(pos, node, puncher, pointed_thing)
        if puncher:get_player_control().sneak then
            local inv = puncher:get_inventory()
            if not (creative and creative.is_enabled_for
                    and creative.is_enabled_for(puncher:get_player_name()))
                    or not inv:contains_item("main", "superblock:block") then
                local leftover = inv:add_item("main", "superblock:block")
                -- If no room in inventory add a replacement cart to the world
                if not leftover:is_empty() then
                    minetest.add_item(self.object:get_pos(), leftover)
                end
            end
            minetest.set_node(pos,{name="air"})
        else
            move_block(pos, push_pull(pos,pointed_thing,1), puncher)
        end
        return true
    end,
    on_dig = function() end,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        --print(node.name)
        move_block(pos, push_pull(pos,pointed_thing,-1), clicker)
        return false
    end,
--     on_use = function(itemstack, player, pointed_thing)
--         --control_block(player)
--     end,
--     can_dig = function(pos,player)
--         return true
--     end,
})
