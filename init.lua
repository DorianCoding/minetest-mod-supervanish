--[[
Author - DorianCoding 2023 (https://github.com/DorianCoding)

The following code is a derivative work of the code from https://github.com/zmv7/minetest-mod-vanish by zmv7
which is licensed GPLv3. This code therefore is also licensed under the terms 
of the GNU Public License, version 3.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
]] local s = core.get_mod_storage()
vanish = {}
vanish.vanished = {}
vanish.supervanished = {}
vanish.protect = function(playername)
    minetest.register_on_player_hpchange(function(player, hp_change, reason)
        local tabl = s:to_table().fields
        for nick, val in pairs(tabl) do
            if val ~= "" and player:get_player_name() == nick and player:get_player_name() == playername:get_player_name() and hp_change < 0 then
                minetest.chat_send_player(player:get_player_name(), "You are protected in vanished mode.")
                return 0, true -- Avoid other functions to change it
            end
        end
        return hp_change -- Do not alter anything
    end, true)
end
vanish.on = function(player)
    local name = player:get_player_name();
    vanish.vanished[name] = true
    player:set_properties({
        visual = "sprinte",
        visual_size = {
            x = 0,
            y = 0,
            z = 0
        },
        physical = false,
        collide_with_objects = false,
        -- collisionbox = {-0.01, 0, -0.01, 0.01, 0, 0.01},
        show_on_minimap = false,
        pointable = false,
        is_visible = false,
        shaded = false
    })
    player:set_nametag_attributes({ color = { a = 0 }, text = " " })
end
vanish.superon = function(player)
    vanish.supervanished[player:get_player_name()] = true
    player:set_properties({
        visual = "sprinte",
        visual_size = {
            x = 0,
            y = 0,
            z = 0
        },
        physical = false,
        collide_with_objects = false,
        -- collisionbox = {-0.01, 0, -0.01, 0.01, 0, 0.01},
        show_on_minimap = false,
        pointable = false,
        is_visible = false,
        shaded = false
    })
    player:set_nametag_attributes({
        color = {
            a = 0
        },
        text = " "
    })
end
vanish.off = function(player)
    local name = player:get_player_name()
    vanish.vanished[name] = nil
    player:set_properties({
        visual = "mesh",
        visual_size = {
            x = 1,
            y = 1,
            z = 1
        },
        physical = true,
        collide_with_objects = true,
        -- collisionbox = {-0.01, 0, -0.01, 0.01, 0, 0.01},
        show_on_minimap = true,
        pointable = true,
        is_visible = true,
        shaded = true
    })
    if core.get_modpath("nick_prefix") then
        nick_prefix.update_ntag(name)
    else
        player:set_nametag_attributes({
            color = {
                a = 255,
                r = 255,
                g = 255,
                b = 255
            },
            text = name
        })
    end
end
vanish.remove = function(player, force)
	if not s:get_string(name) then
		return false
	end
	if force == True or s:get_string(name) ~= "2" then --Not in supervanish or force
		s:set_string(player, "")
		vanish.vanished[player] = nil
		vanish.supervanished[player] = nil --Does not mind as if no privilege, it was not in the list
		return true
	end
	return false
end
vanish.superoff = function(player)
	local name = player:get_player_name()
    vanish.supervanished[name] = nil
    player:set_properties({
        visual = "mesh",
        visual_size = {
            x = 1,
            y = 1,
            z = 1
        },
        physical = true,
        collide_with_objects = true,
        -- collisionbox = {-0.01, 0, -0.01, 0.01, 0, 0.01},
        show_on_minimap = true,
        pointable = true,
        is_visible = true,
        shaded = true
    })
    if core.get_modpath("nick_prefix") then
        nick_prefix.update_ntag(name)
    else
        player:set_nametag_attributes({
            color = {
                a = 255,
                r = 255,
                g = 255,
                b = 255
            },
            text = name
        })
    end
end
core.register_privilege("vanish", {
    description = "Allows to make players invisible",
    give_to_singleplayer = true
})
core.register_privilege("supervanish", {
    description = "Allows to make players superinvisible",
    give_to_singleplayer = true
})
core.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if not name then
        return
    end
    local isinvis = s:get_string(name)
    if isinvis == "1" then
        core.after(0.1, function()
            vanish.on(player)
        end)
    elseif isinvis == "2" then
        core.after(0.1, function()
            vanish.superon(player)
        end)
    end
    vanish.protect(player)
end)
core.register_chatcommand("vanish", {
    description = "Toggle invisibility of player",
    privs = {
        vanish = true
    },
    params = "<name>",
    func = function(name, param)
        if param == "" then
            param = name
        end
        local player = core.get_player_by_name(param)
		if not player then
			local result = vanish.remove(player,false)
			if result then
				return false, "-!- " .. param .. " is not online but vanish dropped"
			else
				return false, "-!- " .. param .. " is not vanished"
			end
		end
        local isinvis = s:get_string(param)
        if isinvis == "1" then
            s:set_string(param, "")
            vanish.off(player)
            return true, "-!- " .. param .. " unvanished"
        elseif isinvis == "2" then
            return false, "-!- " .. param .. " is not online but vanish dropped"
        else
            s:set_string(param, "1")
            vanish.on(player)
            return true, "-!- " .. param .. " vanished"
        end
    end
})
core.register_chatcommand("supervanish", {
    description = "Toggle superinvisibility of player",
    privs = {
        supervanish = true
    },
    params = "<name>",
    func = function(name, param)
        if param == "" then
            param = name
        end
        local player = core.get_player_by_name(param)
		if not player then
			local result = vanish.remove(player,true)
			if result then
				return false, "-!- " .. param .. " is not online but vanish and supervanish dropped"
			else
				return false, "-!- " .. param .. " is not vanished"
			end
		end
        local isinvis = s:get_string(param)
        if isinvis == "2" then
            s:set_string(param, "")
            vanish.superoff(player)
            return true, "-!- " .. param .. " super-unvanished"
        elseif isinvis == "1" then
            return false, "-!- " .. param .. " is already on vanish mode"
        else
            if not player then
                return false, "-!- " .. param .. " is not online"
            end
            s:set_string(param, "2")
            vanish.superon(player)
            return true, "-!- " .. param .. " super-vanished"
        end
    end
})

core.register_chatcommand("vanished", {
    description = "Show list of vanished players or check if a player vanished",
    privs = {
        vanish = true
    },
    params = "<name>",
    func = function(name, param)
        local out = {}
        local tabl = s:to_table().fields
        if param ~= "" then
            if tabl[param] ~= nil then
                if tabl[param] == "1" then
                    return true, "The player " .. param .. " is vanished"
                end
            end
            return true, "The player " .. param .. " is not vanished or offline"
        end
        local count = 0
        for nick, val in pairs(tabl) do
            if val ~= "2" then
                count = count + 1
                table.insert(out, nick)
            end -- Do not take supervanish on the list
        end
        if count == 0 then
            return true, "Noone is vanished"
        end
        table.sort(out)
        return true, "Vanished players: " .. table.concat(out, ", ")
    end
})
