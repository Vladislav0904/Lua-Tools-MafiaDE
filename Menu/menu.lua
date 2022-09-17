local script = ScriptHook.CurrentScript()

function script:CacheMenu(menu_callback)
	local menu_cached = nil
	return function()
		menu_cached = menu_cached or menu_callback()
		return menu_cached
	end
end

local menu = UI.SimpleMenu()
SimpleTrainerMenu = menu

menu:SetTitle("Lua Tools")

-- Items
SimpleTrainerMenuItems = {}
include("raceMenu.lua")

for _,data in ipairs(SimpleTrainerMenuItems) do
	menu:AddButton(unpack(data))
end

-- Key Bind
ScriptHook.RegisterKeyHandler("menu", function()
	menu:Toggle()
end)