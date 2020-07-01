include('shared.lua')

SWEP.PrintName = "M2014 Gauss"
SWEP.Slot = 4

-- Draw the scope on the HUD
local scope = surface.GetTextureID("sprites/scope")
function SWEP:DrawHUD()
	if self:GetIronsights() then
		surface.SetDrawColor(0, 0, 0, 255)

		local x = ScrW() / 2.0
		local y = ScrH() / 2.0
		local scope_size = ScrH()

		-- crosshair
		local gap = 80
		local length = scope_size
		surface.DrawLine(x - length, y, x - gap, y)
		surface.DrawLine(x + length, y, x + gap, y)
		surface.DrawLine(x, y - length, x, y - gap)
		surface.DrawLine(x, y + length, x, y + gap)

		gap = 0
		length = 50
		surface.DrawLine(x - length, y, x - gap, y)
		surface.DrawLine(x + length, y, x + gap, y)
		surface.DrawLine(x, y - length, x, y - gap)
		surface.DrawLine(x, y + length, x, y + gap)

		-- cover edges
		local sh = scope_size / 2
		local w = (x - sh) + 2
		surface.DrawRect(0, 0, w, scope_size)
		surface.DrawRect(x + sh - 2, 0, w, scope_size)
		surface.SetDrawColor(255, 0, 0, 255)
		surface.DrawLine(x, y, x + 1, y + 1)

		-- scope
		surface.SetTexture(scope)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
	else
		return self.BaseClass.DrawHUD(self)
	end
end

function SWEP:AdjustMouseSensitivity()
	return (self:GetIronsights() and 0.2) or nil
end

function SWEP:DoDrawCrosshair(x, y)
	return self:GetIronsights()
end

local LOWER_POS = Vector(0, 0, -2)
local IRONSIGHT_TIME = 0.25
function SWEP:GetViewModelPosition(pos, ang)
	if (!self.IronSightsPos) then return pos, ang end

	local bIron = self:GetIronsights()
	if (bIron != self.bLastIron) then
		self.bLastIron = bIron
		self.fIronTime = CurTime()

		if bIron then
			self.SwayScale = 0.3
			self.BobScale = 0.1
		else
			self.SwayScale = 1.0
			self.BobScale = 1.0
		end
	end

	local fIronTime = self.fIronTime or 0
	if (!bIron and fIronTime < CurTime() - IRONSIGHT_TIME) then
		return pos, ang
	end

	local mul = 1.0

	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)

		if (!bIron) then
			mul = 1 - mul
		end
	end

	local offset = self.IronSightsPos + LOWER_POS

	if (self.IronSightsAng) then
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(),    self.IronSightsAng.x * mul )
		ang:RotateAroundAxis( ang:Up(),       self.IronSightsAng.y * mul )
		ang:RotateAroundAxis( ang:Forward(),  self.IronSightsAng.z * mul )
	end

	pos = pos + offset.x * ang:Right() * mul
	pos = pos + offset.y * ang:Forward() * mul
	pos = pos + offset.z * ang:Up() * mul

	return pos, ang
end
