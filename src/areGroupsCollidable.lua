local PhysicsService = game:GetService("PhysicsService")

local function areGroupsCollidable(id0, id1)
	local name0 = PhysicsService:GetCollisionGroupName(id0)
	local name1 = PhysicsService:GetCollisionGroupName(id1)
	return PhysicsService:CollisionGroupsAreCollidable(name0, name1)
end

return areGroupsCollidable
