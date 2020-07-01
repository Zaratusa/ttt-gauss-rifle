--[[Author informations]]--
SWEP.Author = "Zaratusa"
SWEP.Contact = "http://steamcommunity.com/profiles/76561198032479768"

-- always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

--[[Default GMod values]]--
SWEP.Primary.Ammo = "thumper" -- use a unused ammo type
SWEP.Primary.Delay = 2
SWEP.Primary.Recoil = 6
SWEP.Primary.Cone = 0.0025
SWEP.Primary.Damage = 75
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 1
SWEP.Primary.ClipMax = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Sound = Sound("Gauss_Rifle.Single")
SWEP.Primary.SoundLevel = 120
SWEP.Secondary.Delay = 0.5
SWEP.Secondary.Sound = Sound("Default.Zoom")

--[[Model settings]]--
SWEP.HoldType = "ar2"
SWEP.ViewModel = Model("models/weapons/zaratusa/gauss_rifle/v_gauss_rifle.mdl")
SWEP.WorldModel = Model("models/weapons/zaratusa/gauss_rifle/w_gauss_rifle.mdl")

SWEP.IronSightsPos = Vector(-1.55, -22, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)

--[[TTT config values]]--

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP1

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2,
-- then this gun can be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "none"

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_TRAITOR }

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = true

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = false

function SWEP:Initialize()
	if (CLIENT and self:Clip1() == -1) then
		self:SetClip1(self.Primary.DefaultClip)
	elseif (SERVER) then
		self.fingerprints = {}
		self:SetIronsights(false)
		-- aditional magazine, seems to be bugged, when using DefaultClip
		timer.Simple(0.1, function() if (IsValid(self:GetOwner())) then self:GetOwner():GiveAmmo(1, "thumper", true) end end)
	end

	self:SetDeploySpeed(self.DeploySpeed)

	if (self.SetHoldType) then
		self:SetHoldType(self.HoldType or "pistol")
	end

	PrecacheParticleSystem("smoke_trail")
end

function SWEP:PrimaryAttack(worldsnd)
	if (self:CanPrimaryAttack() and self:GetNextPrimaryFire() <= CurTime()) then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

		local owner = self:GetOwner()
		owner:GetViewModel():StopParticles()

		if (!worldsnd) then
			self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)
		elseif SERVER then
			sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
		end

		self:ShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetPrimaryCone())
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

		if (IsValid(owner) and !owner:IsNPC() and owner.ViewPunch) then
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

-- add some zoom to the scope for this gun
function SWEP:SecondaryAttack()
	if (self.IronSightsPos and self:GetNextSecondaryFire() <= CurTime()) then
		-- set the delay for left and right click
		self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

		local bIronsights = !self:GetIronsights()
		self:SetIronsights(bIronsights)
		if SERVER then
			self:SetZoom(bIronsights)
		else
			self:EmitSound(self.Secondary.Sound)
		end
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

function SWEP:ResetIronSights()
	self:SetIronsights(false)
	self:SetZoom(false)
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
