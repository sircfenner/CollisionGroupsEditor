local Plugin = script.Parent.Parent

local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local withTheme = StudioComponents.withTheme

local TabButton = Roact.Component:extend("TabButton")

function TabButton:init()
	self:setState({ Hover = false })
	self.onInputBegan = function(_, input)
		if self.props.Disabled then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = true })
		end
	end
	self.onInputEnded = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self:setState({ Hover = false })
		end
	end
end

function TabButton:render()
	local modifier = Enum.StudioStyleGuideModifier.Default
	if self.props.Disabled then
		modifier = Enum.StudioStyleGuideModifier.Disabled
	elseif self.props.Selected then
		modifier = Enum.StudioStyleGuideModifier.Pressed
	elseif self.state.Hover then
		modifier = Enum.StudioStyleGuideModifier.Hover
	end
	return withTheme(function(theme)
		return Roact.createElement("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Button, modifier),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
			LayoutOrder = self.props.LayoutOrder,
			Size = self.props.Size,
			Text = self.props.Text,
			Font = Enum.Font.SourceSans,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, modifier),
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextSize = 14,
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputEnded] = self.onInputEnded,
			[Roact.Event.Activated] = function()
				if not self.props.Disabled then
					self.props.OnActivated()
				end
			end,
		}, {
			Top = Roact.createElement("Frame", {
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border, modifier),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 1),
			}),
			Indicator = self.props.Selected and Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = Color3.fromRGB(0, 162, 255),
				BackgroundTransparency = self.props.Disabled and 0.8 or 0,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 2),
			}),
		})
	end)
end

return TabButton
