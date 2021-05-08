local Plugin = script.Parent

local Roact = require(Plugin.Vendor.Roact)
local MainPlugin = require(Plugin.Components.MainPlugin)

local toolbar = plugin:CreateToolbar("Collision Groups")
local button = toolbar:CreateButton(
	"thirdPartyCollisionGroupsToggleWidget",
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
