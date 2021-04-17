local PhysicsService = game:GetService("PhysicsService")

local function setGroupsCollidable(id0, id1, collidable)
	local name0 = PhysicsService:GetCollisionGroupName(id0)
	local name1 = PhysicsService:GetCollisionGroupName(id1)
	PhysicsService:CollisionGroupSetCollidable(name0, name1, collidable)
end

return setGroupsCollidable
