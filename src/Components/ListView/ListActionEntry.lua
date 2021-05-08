local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Vendor.Roact)
local Constants = require(Plugin.Constants)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local Label = StudioComponents.Label
local Checkbox = StudioComponents.Checkbox

local ENTRY_HEIGHT = Constants.ListEntryHeight
local CHECKBOX_HEIGHT = Constants.CheckboxHeight

local function ListActionEntry(props)
	return Roact.createElement("Frame", {
		LayoutOrder = props.Group.id,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, ENTRY_HEIGHT),
	}, {
		Label = Roact.createElement(Label, {
			Size = UDim2.new(1, -24, 1, 0),
			Text = props.Group.name,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 7),
				PaddingRight = UDim.new(0, 5),
			}),
		}),
		CheckboxFrame = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -(ENTRY_HEIGHT - CHECKBOX_HEIGHT), 0.5, 0),
			Size = UDim2.fromOffset(CHECKBOX_HEIGHT, CHECKBOX_HEIGHT),
			BackgroundTransparency = 1,
		}, {
			Checkbox = Roact.createElement(Checkbox, {
				Value = props.Collides,
				OnActivated = props.OnActivated,
				Disabled = props.Disabled,
			}),
		}),
	})
end

return ListActionEntry
