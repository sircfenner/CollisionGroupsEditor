local Plugin = script.Parent.Parent

local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local ScrollFrame = StudioComponents.ScrollFrame
local ListEntry = require(script.ListEntry)
local ListActionEntry = require(script.ListActionEntry)

local areGroupsCollidable = require(Plugin.areGroupsCollidable)

local function ListView(props)
	local childrenLeft = {}
	local childrenRight = {}
	for _, group in ipairs(props.Groups) do
		local collides = areGroupsCollidable(props.SelectedGroupId, group.id)
		table.insert(
			childrenLeft,
			Roact.createElement(ListEntry, {
				Group = group,
				Selected = group.id == props.SelectedGroupId,
				OnActivated = function()
					props.SetSelectedGroupId(group.id)
				end,
				Disabled = props.Disabled,
			})
		)
		table.insert(
			childrenRight,
			Roact.createElement(ListActionEntry, {
				Group = group,
				Collides = collides,
				OnActivated = function()
					props.SetGroupsCollidable(props.SelectedGroupId, group.id, not collides)
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
