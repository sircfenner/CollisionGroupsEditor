local Plugin = script.Parent.Parent

local Roact = require(Plugin.Vendor.Roact)
local Constants = require(Plugin.Constants)

local StudioComponents = Plugin.Vendor.StudioComponents
local withTheme = require(StudioComponents.withTheme)

local ScrollFrame = require(StudioComponents.ScrollFrame)
local Label = require(StudioComponents.Label)
local GridItem = require(script.GridItem)

local SIZE_LEFT = 75
local SIZE_TOP = 50
local CELL_SIZE = Constants.GridCellSize

local areGroupsCollidable = require(Plugin.areGroupsCollidable)

local GridView = Roact.Component:extend("GridView")

function GridView:init()
	self.scrollPosition, self.setScrollPosition = Roact.createBinding(Vector2.new(0, 0))
	self:setState({
		HoveredGroupId0 = -1,
		HoveredGroupId1 = -1,
	})
end

function GridView:render()
	local groups = self.props.Groups
	local hoveredId0 = self.state.HoveredGroupId0
	local hoveredId1 = self.state.HoveredGroupId1

	local gridContent = {}
	for i, group0 in ipairs(groups) do
		local items = {}
		for j = i, #groups do
			local group1 = groups[j]
			local collidable = areGroupsCollidable(group0.id, group1.id)
			local highlighted = (group0.id == hoveredId0 and group1.id >= hoveredId1)
				or (group1.id == hoveredId1 and group0.id <= hoveredId0)
			items[j] = Roact.createElement(GridItem, {
				Disabled = self.props.Disabled,
				LayoutOrder = #groups - j,
				Highlighted = highlighted,
				Collidable = collidable,
				OnActivated = function()
					self.props.SetGroupsCollidable(group0.id, group1.id, not collidable)
				end,
				OnHoverBegan = function()
					self:setState({
						HoveredGroupId0 = group0.id,
						HoveredGroupId1 = group1.id,
					})
				end,
				OnHoverEnded = function()
					if hoveredId0 == group0.id and hoveredId1 == group1.id then
						self:setState({
							HoveredGroupId0 = -1,
							HoveredGroupId1 = -1,
						})
					end
				end,
			})
		end
		gridContent[i] = Roact.createElement("Frame", {
			LayoutOrder = i,
			Size = UDim2.fromOffset(CELL_SIZE.x * #groups, CELL_SIZE.y),
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
			}),
			Content = Roact.createFragment(items),
		})
	end

	local headerContent0 = {}
	for i, group in ipairs(groups) do
		local highlighted = group.id == hoveredId1
		headerContent0[i] = Roact.createElement("Frame", {
			LayoutOrder = #groups - i,
			Size = UDim2.new(0, CELL_SIZE.x, 1, 0),
			BackgroundTransparency = 1,
		}, {
			Label = Roact.createElement(Label, {
				AnchorPoint = Vector2.new(1, 1),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -3, 1, -23),
				Rotation = 35,
				Size = UDim2.fromOffset(78, 14),
				Text = group.name,
				Font = highlighted and Enum.Font.SourceSansBold or Enum.Font.SourceSans,
				TextColorStyle = highlighted and Enum.StudioStyleGuideColor.BrightText or Enum.StudioStyleGuideColor.MainText,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Disabled = self.props.Disabled,
			}),
		})
	end

	local headerContent1 = {}
	for i, group in ipairs(groups) do
		local highlighted = group.id == hoveredId0
		headerContent1[i] = Roact.createElement(Label, {
			LayoutOrder = i,
			Size = UDim2.new(1, -5, 0, CELL_SIZE.y),
			Text = group.name,
			Font = highlighted and Enum.Font.SourceSansBold or Enum.Font.SourceSans,
			TextColorStyle = highlighted and Enum.StudioStyleGuideColor.BrightText or Enum.StudioStyleGuideColor.MainText,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Disabled = self.props.Disabled,
		})
	end

	return Roact.createFragment({
		Main = Roact.createElement(ScrollFrame, {
			AnchorPoint = Vector2.new(1, 1),
			Size = UDim2.new(1, -SIZE_LEFT, 1, -SIZE_TOP),
			Position = UDim2.fromScale(1, 1),
			ScrollingDirection = Enum.ScrollingDirection.XY,
			OnScrolled = self.setScrollPosition,
			Disabled = self.props.Disabled,
		}, gridContent),
		Header0 = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(1, -SIZE_LEFT, 0, SIZE_TOP),
			ClipsDescendants = true,
		}, {
			Holder = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, #groups * CELL_SIZE.x, 1, 0),
				Position = self.scrollPosition:map(function(pos)
					return UDim2.fromOffset(-pos.x, 0)
				end),
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
				}),
				Content = Roact.createFragment(headerContent0),
			}),
		}),
		Header0Triangle = withTheme(function(theme)
			return Roact.createElement("ImageLabel", {
				ZIndex = 2,
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.fromOffset(SIZE_LEFT, SIZE_TOP),
				Size = UDim2.fromOffset(78, 55),
				Image = "rbxassetid://6688985828",
				ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			})
		end),
		Header1 = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, SIZE_LEFT, 1, -SIZE_TOP),
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
			ClipsDescendants = true,
		}, {
			Holder = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, #groups * CELL_SIZE.y),
				Position = self.scrollPosition:map(function(pos)
					return UDim2.fromOffset(0, -pos.y)
				end),
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Content = Roact.createFragment(headerContent1),
			}),
		}),
	})
end

return GridView
