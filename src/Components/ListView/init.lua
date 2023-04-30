local PhysicsService = game:GetService("PhysicsService")

local Plugin = script.Parent.Parent

local Roact = require(Plugin.Packages.Roact)
local StudioComponents = require(Plugin.Packages.StudioComponents)

local ScrollFrame = StudioComponents.ScrollFrame
local ListEntry = require(script.ListEntry)
local ListActionEntry = require(script.ListActionEntry)

local function ListView(props)
	local childrenLeft = {}
	local childrenRight = {}
	for i, group in ipairs(props.Groups) do
		local collides = PhysicsService:CollisionGroupsAreCollidable(props.SelectedGroupName, group.name)
		table.insert(
			childrenLeft,
			Roact.createElement(ListEntry, {
				Order = i,
				Group = group,
				Selected = group.name == props.SelectedGroupName,
				OnActivated = function()
					props.SetSelectedGroupName(group.name)
				end,
				Disabled = props.Disabled,
			})
		)
		table.insert(
			childrenRight,
			Roact.createElement(ListActionEntry, {
				Order = i,
				Group = group,
				Collides = collides,
				OnActivated = function()
					props.SetGroupsCollidable(props.SelectedGroupName, group.name, not collides)
				end,
				Disabled = props.Disabled,
			})
		)
	end
	return Roact.createFragment({
		Left = Roact.createElement(ScrollFrame, {
			Size = UDim2.new(0.5, 1, 1, 0),
			Disabled = props.Disabled,
		}, childrenLeft),
		Right = Roact.createElement(ScrollFrame, {
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.5, 1),
			Disabled = props.Disabled,
		}, childrenRight),
	})
end

return ListView
