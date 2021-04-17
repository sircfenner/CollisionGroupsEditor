local Plugin = script.Parent.Parent

local Vendor = Plugin.Vendor
local Roact = require(Vendor.Roact)
local Constants = require(Plugin.Constants)

local MainPlugin = Roact.Component:extend("MainPlugin")

local Widget = require(Vendor.StudioComponents.Widget)
local App = require(Plugin.Components.App)

function MainPlugin:init()
	self:setEnabled(false)
end

function MainPlugin:setEnabled(enabled)
	self:setState({ Enabled = enabled })
	self.props.Button:SetActive(enabled)
end

function MainPlugin:didMount()
	self.buttonClicked = self.props.Button.Click:Connect(function()
		self:setEnabled(not self.state.Enabled)
	end)
end

function MainPlugin:willUnmount()
	self.buttonClicked:Disconnect()
end

function MainPlugin:render()
	return self.state.Enabled and Roact.createElement(Widget, {
		Id = Constants.MainWidgetId,
		Name = Constants.MainWidgetId,
		Title = "Collision Groups",
		InitialDockState = Enum.InitialDockState.Float,
		MinimumWindowSize = Vector2.new(220, 175),
		OnClosed = function()
			self:setEnabled(false)
		end,
	}, {
		App = Roact.createElement(App),
	})
end

return MainPlugin
