--[[ Old mailbox.lua from kilbith's excellent X-Decor mod
     https://github.com/minetest-mods/xdecor
     GPL3 ]]

local mailbox = {}
screwdriver = screwdriver or {}

minetest.register_craft({
	output = "mailbox:mailbox",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"dye:red", "default:paper", "dye:red"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
	}
})

minetest.register_node("mailbox:mailbox", {
	description = "Mailbox",
	tiles = {
		"xdecor_mailbox_top.png", "xdecor_mailbox_bottom.png",
		"xdecor_mailbox_side.png", "xdecor_mailbox_side.png",
		"xdecor_mailbox.png", "xdecor_mailbox.png",
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 1},
	on_rotate = screwdriver.rotate_simple,
	sounds = default.node_sound_defaults(),
	paramtype2 = "facedir",
	after_place_node = function(pos, placer, _)
		local meta = minetest.get_meta(pos)
		local player_name = placer:get_player_name()

		meta:set_string("owner", player_name)
		meta:set_string("infotext", player_name.."'s Mailbox")

		local inv = meta:get_inventory()
		inv:set_size("mailbox", 8*4)
		inv:set_size("drop", 1)
	end,
	on_rightclick = function(pos, _, clicker, _)
		local meta = minetest.get_meta(pos)
		local player = clicker:get_player_name()
		local owner = meta:get_string("owner")

		if player == owner then
			minetest.show_formspec(player, "", mailbox.get_formspec(pos, owner, 1))
		else
			minetest.show_formspec(player, "", mailbox.get_formspec(pos, owner, 0))
		end
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local player_name = player:get_player_name()
		local inv = meta:get_inventory()

		return inv:is_empty("mailbox") and player and player_name == owner
	end,
	on_metadata_inventory_put = function(pos, listname, _, stack, _)
		local inv = minetest.get_meta(pos):get_inventory()
		if listname == "drop" and inv:room_for_item("mailbox", stack) then
			inv:remove_item("drop", stack)
			inv:add_item("mailbox", stack)
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, _, stack, _)
		if listname == "drop" then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if inv:room_for_item("mailbox", stack) then return -1 end
		end
		return 0
	end
})

function mailbox.get_formspec(pos, owner, fs_type)
	local xbg = default.gui_bg..default.gui_bg_img..default.gui_slots
	local spos = pos.x..","..pos.y..","..pos.z

	if fs_type == 1 then
		return "size[8,9]"..xbg..default.get_hotbar_bg(0,5.25)..
			"label[0,0;You received...]" ..
			"list[nodemeta:"..spos..";mailbox;0,0.75;8,4;]" ..
			"list[current_player;main;0,5.25;8,4;]" ..
			"listring[]"
	else
		return "size[8,5]"..xbg..default.get_hotbar_bg(0,1.25)..
			"label[0.5,0;Send your goods\nto "..owner.." :]" ..
			"list[nodemeta:"..spos..";drop;3.5,0;1,1;]" ..
			"list[current_player;main;0,1.25;8,4;]" ..
			"listring[]"
	end
end
