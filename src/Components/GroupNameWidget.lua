local Plugin = script.Parent.Parent
local Constants = require(Plugin.Constants)

local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local Widget = StudioComponents.Widget
local Label = StudioComponents.Label
local TextInput = StudioComponents.TextInput
local Button = StudioComponents.Button
local MainButton = StudioComponents.MainButton

local PhysicsService = game:GetService("PhysicsService")
local GroupNameWidget = Roact.Component:extend("GroupNameWidget")

function GroupNameWidget:init()
	self:setState({ LastText = "" })
end

function GroupNameWidget:render()
	local lastText = self.state.LastText
	local groups = PhysicsService:GetCollisionGroups()

	local valid = true
	local message = nil
	if #lastText == 0 then
		valid = false
	elseif string.find(lastText, "[\\%^]") then
		valid = false
		message = "Cannot have \\ or ^"
	else
		for _, group in ipairs(groups) do
			if group.name == lastText then
				valid = false
				message = "Name already used"
				break
			end
		end
	end

	return Roact.createElement(Widget, {
		Id = Constants.ModalWidgetId,
		Name = Constants.ModalWidgetId,
		Title = self.props.Title,
		InitialDockState = Enum.InitialDockState.Float,
		MinimumWindowSize = Vector2.new(185, 85),
		OnClosed = self.props.OnClosed,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 7),
			PaddingRight = UDim.new(0, 7),
			PaddingTop = UDim.new(0, 7),
			PaddingBottom = UDim.new(0, 4),
		}),
		Label = Roact.createElement(Label, {
			Size = UDim2.fromOffset(31, 20),
			Text = "Name",
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}),
		InputHolder = Roact.createElement("Frame", {
			Position = UDim2.fromOffset(38, 0),
			Size = UDim2.new(1, -38, 0, 20),
			BackgroundTransparency = 1,
		}, {
			Input = Roact.createElement(TextInput, {
				ClearTextOnFocus = false,
				PlaceholderText = "Enter name",
				Text = self.state.LastText,
				OnChanged = function(text)
					self:setState({ LastText = text })
				end,
				OnFocusLost = function(enterPressed)
					if enterPressed and valid then
						self.props.OnSubmitted(lastText)
					end
				end,
			}),
		}),
		Message = message and Roact.createElement(Label, {
			Position = UDim2.fromOffset(38, 21),
			Size = UDim2.new(1, -38, 0, 20),
			Text = message,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColorStyle = Enum.StudioStyleGuideColor.ErrorText,
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
			CreateButton = Roact.createElement(MainButton, {
				LayoutOrder = 2,
				Size = UDim2.new(0, 65, 1, 0),
				Text = self.props.Action,
				Disabled = not valid,
				OnActivated = function()
					self.props.OnSubmitted(lastText)
				end,
			}),
			CancelButton = Roact.createElement(Button, {
				LayoutOrder = 1,
				Size = UDim2.new(0, 65, 1, 0),
				Text = "Cancel",
				OnActivated = self.props.OnClosed,
			}),
		}),
	})
end

return GroupNameWidget
