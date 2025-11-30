-- chargeBar.lua
local ui      = require("openmw.ui")
local self    = require("openmw.self")
local types   = require("openmw.types")
local util    = require("openmw.util")
local core    = require("openmw.core")
local I       = require("openmw.interfaces")
local modInfo = require("Scripts.HUDweaponCharge.modInfo")
local storage = require("openmw.storage")
local async   = require('openmw.async')

-- Load user settings
local userInterfaceSettings = storage.playerSection("SettingsPlayer" .. modInfo.name)
local colorSetting = userInterfaceSettings:get("colorSetting")



-- Local variables & Defaults
local v2 = util.vector2
local Actor = types.Actor
local Item = types.Item
local SLOT_CARRIED_RIGHT = Actor.EQUIPMENT_SLOT.CarriedRight
local fns = {}
local iconSize = 30
local displayAreaY = ui.layers[1].size.y
local defaults = {xPos = 82, yPos = displayAreaY-12}
local DataBarHeight = 7
local UPDATE_INTERVAL = 1        -- update every 1 seconds

-- Getter for current right slot
fns.getCurrentWeapon = function() return Actor.equipment(self)[SLOT_CARRIED_RIGHT] end
-- Small Progress Bar Creator
fns.createSmallProgressBar = function(width, height, color, percent, opacity)
    local p = percent and math.max(0, math.min(1, percent)) or 1
    return {
        template = I.MWUI.templates.boxSolid,
        type     = ui.TYPE.Container,
        props    = { inheritAlpha = false, color = util.color.rgba(0, 0, 0, 0), alpha = opacity or 1.0 },
        content  = ui.content({
            {
                type  = ui.TYPE.Image,
                props = {
                    inheritAlpha = false,
                    alpha  = 0,
                    color  = util.color.rgb(color.r, color.g, color.b),
                    size   = util.vector2(width - 4, height - 4),
                    resource = ui.texture{
                        path   = 'textures/menu_bar_gray.dds',
                        size   = util.vector2(1, 8),
                        offset = util.vector2(0, 0)
                    }
                },
                content = ui.content({
                    {
                        type  = ui.TYPE.Image,
                        props = {
                            inheritAlpha = false,
                            alpha  = opacity or 1.0,
                            color  = util.color.rgb(color.r, color.g, color.b),
                            size   = util.vector2((width - 4) * p, height - 4),
                            resource = ui.texture{
                                path   = 'textures/menu_bar_gray.dds',
                                size   = util.vector2(1, 8),
                                offset = util.vector2(0, 0)
                            }
                        }
                    }
                })
            }
        })
    }
end

-- Subscribe to color setting
userInterfaceSettings:subscribe(async:callback(function(section, key)
    if key then
        if key == "colorSetting" then
            colorSetting = userInterfaceSettings:get(key)
            fns.updateChargeBar()
        end
    else
        --do nothing..
    end
end))
--------------------------------------------------------------------
-- ROOT UI ELEMENT (center screen)
--------------------------------------------------------------------
local barRoot = ui.create {
    layer = "HUD",
    name  = "ChargeBarHUD",
    props = {
        anchor = v2(0, 0),
        --relativePosition = v2(0.0647, 0.984),
        position = v2(defaults.xPos, defaults.yPos),      -- adjust horizontal centering if needed
        size = v2(iconSize*1.2, DataBarHeight),
    },
    content = ui.content {},
}
-- UPDATE TIMER
local accumulator = 0

-- UPDATE FUNCTION
fns.updateChargeBar = function()
    local weapon = fns.getCurrentWeapon()

    local rec, itemData = nil, nil
    if weapon then
        rec      = weapon.type.records[weapon.recordId]
        itemData = Item.itemData(weapon)
    end

    if not weapon then
        barRoot.layout.content = ui.content({})
        barRoot:update()
        return
    end
    if not rec or not rec.enchant then
        barRoot.layout.content = ui.content({})
        barRoot:update()
        return
    end
    local ench = core.magic.enchantments.records[rec.enchant]
    if not ench then return end
    local pct = (itemData and math.floor(itemData.enchantmentCharge) or 0) / ench.charge
    local bar = fns.createSmallProgressBar(iconSize*1.2, DataBarHeight, colorSetting, pct, 1.0)
    barRoot.layout.content = ui.content{bar}
    barRoot:update()
end

return {
    engineHandlers = {
        onUpdate = function(dt)
            accumulator = accumulator + dt
            if accumulator >= UPDATE_INTERVAL then
                accumulator = 0
                fns.updateChargeBar()
            end
        end,
        onLoad = function(data)
            fns.updateChargeBar()
        end,
    }
}
