AddCSLuaFile("shared.lua")

SWEP.Author = "Hoff"
SWEP.Instructions = "Damn straight."
SWEP.Category = "CoD Zombies"
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP2
SWEP.AmmoEnt = ""
SWEP.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE}
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true
SWEP.AllowDrop = false
SWEP.IsSilent = false
SWEP.NoSights = false
SWEP.AutoSpawnable = false
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/hoff/animations/perks/phdflopper/phd.mdl"
SWEP.WorldModel = ""

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.PrintName = "PHD Flopper"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 60

SWEP.CorrectModelPlacement = Vector(0, 0, -1)
SWEP.SwayScale = 0.01
SWEP.BobScale = 0.01

function SWEP:Equip(ply)
    local oldWep = self.Owner:GetActiveWeapon()
    ply:SetActiveWeapon("zombies_perk_phd")
    timer.Simple(3.8, function() ply:SetActiveWeapon(oldWep) end)
end

function SWEP:Deploy()
    if self.Owner:GetNetworkedString("phdIsActive") == "true" then
        self.Owner:DrawViewModel(false)
        return false
    end

    self.Owner:DrawViewModel(true)
    self.Weapon:SetNetworkedString("isDrinkingPerk", "true")
    self.Owner:SetNetworkedString("phdIsActive", "false")
    self.Owner.ShouldRemoveFallDamage = false

    timer.Simple(0.5, function()
        if self.Owner:Alive() then
            self.Weapon:EmitSound("hoff/animations/perks/017f11fa.wav")
            self.Owner:ViewPunch(Angle(-1, 1, 0))
        end
    end)

    timer.Simple(1.3, function()
        if self.Owner:Alive() then
            self.Weapon:EmitSound("hoff/animations/perks/0180acfa.wav")
            self.Owner:ViewPunch(Angle(-2.5, 0, 0))
        end
    end)

    timer.Simple(2.3, function()
        if self.Owner:Alive() then
            self.Weapon:EmitSound("hoff/animations/perks/017c99be.wav")
            self.Owner:SetNetworkedString("shouldBlurPerkScreen", "true")
            timer.Simple(0.5, function()
                self.Owner:SetNetworkedString("shouldBlurPerkScreen", "false")
            end)
            umsg.Start("perkBGBlur", self.Owner)
            umsg.End()
            umsg.Start("perkHUDIcon", self.Owner)
            umsg.End()
        end
    end)

    timer.Simple(3.1, function()
        if self.Owner:Alive() then
            self.Weapon:EmitSound("hoff/animations/perks/017bf9c0.wav")
            self.Weapon:SetNetworkedString("isDrinkingPerk", "false")
            self.Owner:SetNetworkedString("phdIsActive", "true")
            self.Owner.ShouldRemoveFallDamage = true
        end
    end)

end

function SWEP:OnRemove()
    self.Owner:SetNetworkedString("phdIsActive", "false")
    self.Owner.ShouldRemoveFallDamage = false
    timer.Simple(2, function() hook.Remove("HUDPaint", "perkHUDPaintIcon") end)
end

function SWEP:PreDrop()
    self.Owner:SetNetworkedString("phdIsActive", "false")
    self.Owner.ShouldRemoveFallDamage = false
    timer.Simple(2, function() hook.Remove("HUDPaint", "perkHUDPaintIcon") end)
end

local function RemoveFallDamage(target, dmginfo)
    if target:IsPlayer() and target.ShouldRemoveFallDamage then
        if dmginfo:IsFallDamage() then
            local explode = ents.Create("env_explosion")
            explode:SetPos(target:GetPos())
            explode:SetOwner(target)
            explode:Spawn()
            explode:SetKeyValue("iMagnitude", "100")
            explode:Fire("Explode", 0, 0)
            explode:EmitSound("weapon_AWP.Single", 400, 400)
        end
        if dmginfo:IsFallDamage() or dmginfo:IsExplosionDamage() then
            dmginfo:SetDamage(0)
        end
    end
end

hook.Add("EntityTakeDamage", "RemoveFallDamage", RemoveFallDamage)

local function perkBlur()
    local matBlurScreen = Material("pp/blurscreen")
    local function perkBlurHUD()
        if LocalPlayer():GetNetworkedString("shouldBlurPerkScreen") == "true" then
            surface.SetMaterial(matBlurScreen)
            surface.SetDrawColor(255, 255, 255, 255)

            matBlurScreen:SetFloat("$blur", 6)
            render.UpdateScreenEffectTexture()

            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

            surface.SetDrawColor(0, 0, 0, 60)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        end
    end
    hook.Add("HUDPaint", "perkBlurPaint", perkBlurHUD)
    timer.Simple(2, function() hook.Remove("HUDPaint", "perkBlurPaint") end)
end
usermessage.Hook("perkBGBlur", perkBlur)

-- hud icon from wiki
local function perkIcon()
    local function perkIconHUD()
        if LocalPlayer():GetNetworkedString("phdIsActive") == "true" then
            surface.SetMaterial(Material("vgui/hoff/perks/phd_hud.png"))
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(50, (ScrH() / 2) + 100, 38, 38)
        end
    end
    hook.Add("HUDPaint", "perkHUDPaintIcon", perkIconHUD)
end
usermessage.Hook("perkHUDIcon", perkIcon)

function SWEP:Holster()
    if self.Weapon:GetNetworkedString("isDrinkingPerk") == "true" then
        return false
    else
        return true
    end
end

function SWEP:PrimaryAttack() end

function SWEP:GetViewModelPosition(pos, ang)
    local right = ang:Right()
    local up = ang:Up()
    local forward = ang:Forward()
    local mul = 1.0
    local offset = self.CorrectModelPlacement

    pos = pos + offset.x * right * mul
    pos = pos + offset.y * forward * mul
    pos = pos + offset.z * up * mul

    return pos, ang
end

function SWEP:SecondaryAttack() end

function SWEP:ShouldDropOnDie() return false end

if CLIENT then
    SWEP.Icon = "VGUI/ttt/icon_hoff_phd"

    SWEP.EquipMenuData = {
        type = "Perk Bottle",
        desc = "PHD Flopper Perk.\nAutomatically drink perk to become immune to fall damage,\nexplosion damage, and create an explosion\nwhere you land. One time purchase."
    };
end
