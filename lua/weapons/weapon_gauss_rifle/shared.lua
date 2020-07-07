--- Author informations ---
SWEP.Author = "Zaratusa"
SWEP.Contact = "http://steamcommunity.com/profiles/76561198032479768"

--- Default GMod values ---
SWEP.Base = "weapon_base"
SWEP.Category = "Crysis 3"
SWEP.Purpose = "Kill your oponent with explosions."
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Primary.Ammo = "smg1_grenade"
SWEP.Primary.Delay = 2
SWEP.Primary.Recoil = 6
SWEP.Primary.Cone = 0.0025
SWEP.Primary.Damage = 75
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 4
SWEP.Primary.DefaultClip = 16
SWEP.Primary.Sound = Sound("Gauss_Rifle.Single")
SWEP.Primary.SoundLevel = 120

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Delay = 0.5
SWEP.Secondary.Sound = Sound("Default.Zoom")

SWEP.DeploySpeed = 1.4

--- Model settings ---
SWEP.HoldType = "ar2"

SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 64
SWEP.ViewModel = Model("models/weapons/zaratusa/gauss_rifle/v_gauss_rifle.mdl")
SWEP.WorldModel = Model("models/weapons/zaratusa/gauss_rifle/w_gauss_rifle.mdl")

SWEP.IronSightsPos = Vector(-1.55, -22, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Ironsights")
end

function SWEP:Initialize()
	self:SetDeploySpeed(self.DeploySpeed)

	if (self.SetHoldType) then
		self:SetHoldType(self.HoldType or "pistol")
	end

	self:ResetIronSights()

	PrecacheParticleSystem("smoke_trail")
end

function SWEP:PrimaryAttack(worldsnd)
	if (self:CanPrimaryAttack() and self:GetNextPrimaryFire() <= CurTime()) then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

		local owner = self:GetOwner()
		owner:GetViewModel():StopParticles()

		if (not worldsnd) then
			self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)
		elseif SERVER then
			sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
		end

		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self:GetPrimaryCone())
		self:TakePrimaryAmmo(1)

		local tr = owner:GetEyeTrace()

		-- explosion effect
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetNormal(tr.HitNormal)
		effectdata:SetEntity(tr.Entity)
		effectdata:SetAttachment(tr.PhysicsBone)
		util.Effect("Explosion", effectdata)

		-- electrical tracer
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetStart(self:GetOwner():GetShootPos())
		effectdata:SetAttachment(1)
		effectdata:SetEntity(self)
		util.Effect("ToolTracer", effectdata)

		-- explosion damage
		if SERVER then
			util.BlastDamage(self, owner, tr.HitPos, 250, 40)
		end

		self:UpdateNextIdle()

		if (IsValid(owner) and not owner:IsNPC() and owner.ViewPunch) then
			owner:ViewPunch(Angle(math.Rand(-0.2, -0.1) * self.Primary.Recoil, math.Rand(-0.1, 0.1) * self.Primary.Recoil, 0))
		end

		ParticleEffectAttach("smoke_trail", PATTACH_POINT_FOLLOW, owner:GetViewModel(), 1)
	end
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:ResetIronSights()
	self:UpdateNextIdle()
	return true
end

function SWEP:UpdateNextIdle()
	self:SetNWFloat("NextIdle", CurTime() + self:GetOwner():GetViewModel():SequenceDuration())
end

-- Add some zoom to the scope for this gun
function SWEP:SecondaryAttack(worldsnd)
	if (self.IronSightsPos and self:GetNextSecondaryFire() <= CurTime()) then
		self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

		local bIronsights = not self:GetIronsights()
		self:SetIronsights(bIronsights)
		if SERVER then
			self:SetZoom(bIronsights)
		end

		self:EmitSound(self.Secondary.Sound)
	end
end

function SWEP:SetZoom(state)
	if (SERVER and IsValid(self:GetOwner()) and self:GetOwner():IsPlayer()) then
		if (state) then
			self:GetOwner():SetFOV(20, 0.3)
		else
			self:GetOwner():SetFOV(0, 0.2)
		end
	end
end

function SWEP:PreDrop()
	self:ResetIronSights()
	return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
	if (self:Clip1() < self.Primary.ClipSize and self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0) then
		self:DefaultReload(ACT_VM_RELOAD)
		self:ResetIronSights()
	end
end

function SWEP:Holster()
	if (IsValid(self:GetOwner())) then
		local vm = self:GetOwner():GetViewModel()
		if (IsValid(vm)) then
			vm:StopParticles()
		end
	end
	self:ResetIronSights()
	return true
end

function SWEP:ResetIronSights()
	self:SetIronsights(false)
	self:SetZoom(false)
end

function SWEP:GetPrimaryCone()
	local cone = self.Primary.Cone
	-- 10% accuracy bonus when sighting
	return self:GetIronsights() and (cone * 0.85) or cone
end
