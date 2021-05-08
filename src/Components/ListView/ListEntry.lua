local Plugin = script.Parent.Parent.Parent
local Constants = require(Plugin.Constants)

local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local withTheme = StudioComponents.withTheme

local ENTRY_HEIGHT = Constants.ListEntryHeight

local ListEntry = Roact.Component:extend("ListEntry")

function ListEntry:init()
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

function ListEntry:render()
	local color = Enum.StudioStyleGuideColor.FilterButtonDefault
	if self.props.Selected then
		color = Enum.StudioStyleGuideColor.FilterButtonChecked
	elseif self.state.Hover then
		color = Enum.StudioStyleGuideColor.FilterButtonHover
	end
	return withTheme(function(theme)
		return Roact.createElement("TextButton", {
			LayoutOrder = self.props.Group.id,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundColor3 = theme:GetColor(color),
			Font = Enum.Font.SourceSans,
			Text = self.props.Group.name,
			TextSize = 14,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
			Size = UDim2.new(1, 0, 0, ENTRY_HEIGHT),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputEnded] = self.onInputEnded,
			[Roact.Event.Activated] = function()
				if not self.props.Disabled then
					self.props.OnActivated()
				end
			end,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 7),
				PaddingRight = UDim.new(0, 5),
			}),
		})
	end)
end

return ListEntry
