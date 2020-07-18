AddCSLuaFile("shared.lua")

SWEP.Author = "Hoff"
SWEP.Instructions = "Oh yeah, drink it baby."
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

SWEP.ViewModel = "models/hoff/animations/perks/staminup/stam.mdl"
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

SWEP.PrintName = "Stamin-Up"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 60

SWEP.CorrectModelPlacement = Vector(0, 0, -1)
SWEP.SwayScale = 0.01
SWEP.BobScale = 0.01

if SERVER then
    util.AddNetworkString("perkBGBlurStaminup")
    util.AddNetworkString("perkHUDIconStaminup")
end

function SWEP:Equip() end

function SWEP:Deploy()
    self.Owner:DrawViewModel(true)
    self.Weapon:SetNetworkedString("isDrinkingPerk", "true")
    self.Owner:SetNetworkedString("stamIsActive", "false")

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

            if SERVER then
                net.Start("perkBGBlurStaminup")
                net.Send(self.Owner)
                net.Start("perkHUDIconStaminup")
                net.Send(self.Owner)
            end
        end
    end)

    timer.Simple(3.1, function()
        if self.Owner:Alive() then
            self.Weapon:EmitSound("hoff/animations/perks/017bf9c0.wav")
            self.Weapon:SetNetworkedString("isDrinkingPerk", "false")
            self.Owner:SetNetworkedString("stamIsActive", "true")
            self.Owner:SetWalkSpeed(300)
            self.Owner:SetRunSpeed(575)
            if SERVER then
                timer.Simple(0.1, function() self.Weapon:Remove() end)
            end
        end
    end)
end

function SWEP:OnRemove() end

local function RemovePerk(ply)
    ply:SetNetworkedString("stamIsActive", "false")
    ply:SetWalkSpeed(250)
    ply:SetRunSpeed(500)
    timer.Simple(2, function() hook.Remove("HUDPaint", "perkHUDPaintIconStaminup") end)
end

hook.Add("PlayerDeath", "perkPlayerDeathStaminup", function(vic, infl, att)
    RemovePerk(vic)
end)
hook.Add("TTTEndRound", "perkEndRoundStaminup", function()
    for _, v in pairs(player.GetAll()) do
        RemovePerk(v)
    end
end)

function SWEP:PreDrop()
    RemovePerk(self.Owner)
end

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
    SWEP.Icon = "VGUI/ttt/icon_hoff_juggernog"

    SWEP.EquipMenuData = {
        type = "Perk Bottle",
        desc = "Stamin-Up Perk.\nAutomatically drink perk to greatly increase\nwalk speed. One time purchase."
    };

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
        hook.Add("HUDPaint", "perkBlurPaintStaminup", perkBlurHUD)
        timer.Simple(2, function() hook.Remove("HUDPaint", "perkBlurPaintStaminup") end)
    end
    net.Receive("perkBGBlurStaminup", perkBlur)

    -- hud icon from wiki
    local function perkIcon()
        local function perkIconHUD()
            if LocalPlayer():GetNetworkedString("stamIsActive") == "true" then
                surface.SetMaterial(Material("vgui/hoff/perks/marathon_hud.png"))
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(50, (ScrH() / 2) + 150, 38, 38)
            end
        end
        hook.Add("HUDPaint", "perkHUDPaintIconStaminup", perkIconHUD)
    end
    net.Receive("perkHUDIconStaminup", perkIcon)
end
