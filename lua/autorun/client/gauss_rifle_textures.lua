CreateConVar("gauss_rifle_body", 1, {FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE}, "Which color should the gauss rifle body have?")
CreateConVar("gauss_rifle_scope", 1, {FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE}, "Which color should the gauss rifle scope have?")

local BodyColors = {"blue", "green", "orange", "purple"}
local ScopeColors = {"blue", "green", "orange", "purple", "grey", "white"}

local function changeBodyTextures(color)
	Material("models/weapons/v_models/zaratusa.gauss.rifle/gauss_a_d"):SetTexture("$basetexture", "models/weapons/v_models/zaratusa.gauss.rifle/gauss_a_d_" .. color)
	Material("models/weapons/v_models/zaratusa.gauss.rifle/gauss_b_d"):SetTexture("$basetexture", "models/weapons/v_models/zaratusa.gauss.rifle/gauss_b_d_" .. color)
	Material("models/weapons/w_models/zaratusa.gauss.rifle/gauss_a"):SetTexture("$basetexture", "models/weapons/v_models/zaratusa.gauss.rifle/gauss_a_d_" .. color)
	Material("models/weapons/w_models/zaratusa.gauss.rifle/gauss_b"):SetTexture("$basetexture", "models/weapons/v_models/zaratusa.gauss.rifle/gauss_b_d_" .. color)
end

local function changeScopeTextures(color)
	Material("models/weapons/v_models/zaratusa.gauss.rifle/scope_d"):SetTexture("$basetexture", "models/weapons/v_models/zaratusa.gauss.rifle/scope_d_" .. color)
	Material("models/weapons/w_models/zaratusa.gauss.rifle/scope"):SetTexture("$basetexture", "models/weapons/v_models/zaratusa.gauss.rifle/scope_d_" .. color)
end

local function getIncreasedValue(conVar, maxValue)
	local value = conVar:GetInt() + 1
	if (value > maxValue) then
		value = 1
	end
	conVar:SetInt(value)
	return value
end

-- console commands
concommand.Add("gr_changebody", function()
	changeBodyTextures(BodyColors[getIncreasedValue(GetConVar("gauss_rifle_body"), 4)])
end)

concommand.Add("gr_changescope", function()
	changeScopeTextures(ScopeColors[getIncreasedValue(GetConVar("gauss_rifle_scope"), 6)])
end)

-- somehow just loads like this on startup
concommand.Add("gr_loadsettings", function()
	changeBodyTextures(BodyColors[GetConVar("gauss_rifle_body"):GetInt()])
	changeScopeTextures(ScopeColors[GetConVar("gauss_rifle_scope"):GetInt()])
end)

RunConsoleCommand("gr_loadsettings")
