local Plugin = script.Parent.Parent
local Constants = require(Plugin.Constants)

local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local Widget = StudioComponents.Widget
local Label = StudioComponents.Label
local Button = StudioComponents.Button
local MainButton = StudioComponents.MainButton

local function DeleteGroupWidget(props)
	return Roact.createElement(Widget, {
		Id = Constants.ModalWidgetId,
		Name = Constants.ModalWidgetId,
		Title = props.Title,
		InitialDockState = Enum.InitialDockState.Float,
		MinimumWindowSize = Vector2.new(185, 75),
		OnClosed = props.OnClosed,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 7),
			PaddingRight = UDim.new(0, 7),
			PaddingTop = UDim.new(0, 7),
			PaddingBottom = UDim.new(0, 4),
		}),
		Label = Roact.createElement(Label, {
			Size = UDim2.new(1, 0, 0, 28),
			Text = string.format("Are you sure you want to delete the group '%s'?", props.GroupName),
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}),
		Buttons = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0, 4),
			}),
			DeleteButton = Roact.createElement(MainButton, {
				LayoutOrder = 2,
				Size = UDim2.new(0, 65, 1, 0),
				Text = "Delete",
				OnActivated = function()
					props.OnActivated()
				end,
			}),
			CancelButton = Roact.createElement(Button, {
				LayoutOrder = 1,
				Size = UDim2.new(0, 65, 1, 0),
				Text = "Cancel",
				OnActivated = props.OnClosed,
			}),
		}),
	})
end

return DeleteGroupWidget
