--[[

Mod: HUDweaponCharge
Author: Nitro

--]]

local I = require("openmw.interfaces")
local modInfo = require("Scripts.HUDweaponCharge.modInfo")
local util = require('openmw.util')
local ChargeColor   = util.color.rgba(0.50, 0.60, 0.90, 1.00)

-- Settings Descriptions
local pageDescription = "By Nitro\nv" .. modInfo.version .. "\n\nShows weapon charge on HUD"
local modEnableDescription = "This enables the mod or disables it."

local function setting(key, renderer, argument, name, description, default)
	return {
		key = key,
		renderer = renderer,
		argument = argument,
		name = name,
		description = description,
		default = default,
	}
end

I.Settings.registerPage {
	key = modInfo.name,
	l10n = modInfo.name,
	name = "HUDweaponCharge",
	description = pageDescription
}

I.Settings.registerGroup {
	key = "SettingsPlayer" .. modInfo.name,
	page = modInfo.name,
	order = 0,
	l10n = modInfo.name,
	name = "General",
	permanentStorage = false,
	settings = {
		setting("modEnable", "checkbox", {}, "Enable Mod", modEnableDescription, true),
		setting("colorSetting", "color2", {}, "colorPicker", "color picker widget", util.color.hex(ChargeColor:asHex())),
		setting("betterBarSetting", "checkbox", {}, "Better Bar Compatibility", "Enable if using BetterBars mod", false),
	}
}


print("[" .. modInfo.name .. "] Initialized v" .. modInfo.version)
