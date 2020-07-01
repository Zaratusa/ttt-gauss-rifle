AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

resource.AddWorkshop("646754302")

function SWEP:Think()
	local idletime = self:GetNWFloat("NextIdle")

	if (idletime > 0 and CurTime() > idletime) then
		local vm = self:GetOwner():GetViewModel()
		vm:SendViewModelMatchingSequence(vm:LookupSequence("idle"))
		self:UpdateNextIdle()
	end
end
