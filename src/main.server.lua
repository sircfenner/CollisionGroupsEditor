local Plugin = script.Parent

local Vendor = Plugin.Vendor
local Roact = require(Vendor.Roact)

local Components = Plugin.Components
local MainPlugin = require(Components.MainPlugin)

local toolbar = plugin:CreateToolbar("Collision Groups")
local button = toolbar:CreateButton(
	"CollisionGroupsToggleWidget",
	"Collision Groups",
	"rbxasset://textures/CollisionGroupsEditor/ToolbarIcon.png",
	"Toggle Widget"
)
button.ClickableWhenViewportHidden = true

local main = Roact.createElement(MainPlugin, {
	Button = button,
})

local handle = Roact.mount(main, nil)

plugin.Unloading:Connect(function()
	Roact.unmount(handle)
end)
