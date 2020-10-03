include('shared.lua')

LANG.AddToLanguage("english", "gauss_name", "M2014 Gauss")
LANG.AddToLanguage("english", "gauss_desc", "Fires heavy explosives.")

LANG.AddToLanguage("Русский", "gauss_name", "M2014 Gauss")
LANG.AddToLanguage("Русский", "gauss_desc", "Стреляет тяжёлой взрывчаткой.")

SWEP.PrintName = "gauss_name"
SWEP.Slot = 6
SWEP.Icon = "vgui/ttt/icon_gauss_rifle"

-- client side model settings
SWEP.UseHands = true -- should the hands be displayed
SWEP.ViewModelFlip = false -- should the weapon be hold with the left or the right hand
SWEP.ViewModelFOV = 64

-- equipment menu information is only needed on the client
SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = "gauss_desc"
}

hook.Add("TTT2ScoreboardAddPlayerRow", "ZaratusasTTTMod", function(ply)
	local ID64 = ply:SteamID64()

	if (ID64 == "76561198032479768") then
		AddTTT2AddonDev(ID64)
	end
end)

-- draw the scope on the HUD
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
