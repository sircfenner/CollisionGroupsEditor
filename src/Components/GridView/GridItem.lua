local Plugin = script.Parent.Parent.Parent

local Constants = require(Plugin.Constants)
local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local Checkbox = StudioComponents.Checkbox
local withTheme = StudioComponents.withTheme

local CELL_SIZE = Constants.GridCellSize
local CHECKBOX_HEIGHT = Constants.CheckboxHeight

local size = Vector2.new(CHECKBOX_HEIGHT, CHECKBOX_HEIGHT)
local offset = (CELL_SIZE - size) * 0.5

local function GridItem(props)
	return withTheme(function(theme)
		local color = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
		if not props.Disabled and props.Highlighted then
			color = theme:GetColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Hover)
		end
		return Roact.createElement("Frame", {
			LayoutOrder = props.LayoutOrder,
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(CELL_SIZE.x, CELL_SIZE.y),
			[Roact.Event.InputBegan] = function(_, input)
				if props.Disabled then
					return
				end
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					props.OnHoverBegan()
				end
			end,
			[Roact.Event.InputEnded] = function(_, input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					props.OnHoverEnded()
				end
			end,
		}, {
			Holder = Roact.createElement("Frame", {
				Position = UDim2.fromOffset(offset.x, offset.y),
				Size = UDim2.fromOffset(size.x, size.y),
				BackgroundTransparency = 1,
			}, {
				Checkbox = Roact.createElement(Checkbox, {
					Value = props.Collidable,
					OnActivated = props.OnActivated,
					Disabled = props.Disabled,
				}),
			}),
		})
	end)
end

return GridItem
