AddCSLuaFile("shared.lua")

SWEP.Author = "Hoff"
SWEP.Instructions = "Reach for Juggernog tonight!"
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

SWEP.ViewModel = "models/hoff/animations/perks/juggernog/jug.mdl"
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

SWEP.PrintName = "Juggernog"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 60

SWEP.CorrectModelPlacement = Vector(0, 0, -1)
SWEP.SwayScale = 0.01
SWEP.BobScale = 0.01

if SERVER then
    util.AddNetworkString("perkBGBlurJug")
end

function SWEP:Equip() end

function SWEP:Deploy()
    self.Weapon:SetNWString("isDrinkingPerk", "true")

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
            self.Owner:SetNWString("shouldBlurPerkScreen", "true")
            timer.Simple(0.5, function()
                self.Owner:SetNWString("shouldBlurPerkScreen", "false")
            end)

            if SERVER then
                net.Start("perkBGBlurJug")
                net.Send(self.Owner)
            end
        end
    end)

    timer.Simple(3.1, function()
        if self.Owner:Alive() then
            self.Weapon:EmitSound("hoff/animations/perks/017bf9c0.wav")
            self.Weapon:SetNWString("isDrinkingPerk", "false")
            self.Owner:SetHealth(100)
            if SERVER then
                timer.Simple(0.1, function() self.Weapon:Remove() end)
            end
        end
    end)
end

function SWEP:Holster()
    if self.Weapon:GetNWString("isDrinkingPerk", "false") == "true" then
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
        desc = "Juggernog Perk.\nDrink perk to give 100 health.\nOne time purchase."
    };

    local function perkBlur()
        local matBlurScreen = Material("pp/blurscreen")
        local function perkBlurHUD()
            if LocalPlayer():GetNWString("shouldBlurPerkScreen", "false") == "true" then
                surface.SetMaterial(matBlurScreen)
                surface.SetDrawColor(255, 255, 255, 255)

                matBlurScreen:SetFloat("$blur", 6)
                render.UpdateScreenEffectTexture()

                surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

                surface.SetDrawColor(0, 0, 0, 60)
                surface.DrawRect(0, 0, ScrW(), ScrH())
            end
        end
        hook.Add("HUDPaint", "perkBlurPaintJug", perkBlurHUD)
        timer.Simple(2, function() hook.Remove("HUDPaint", "perkBlurPaintJug") end)
    end
    net.Receive("perkBGBlurJug", perkBlur)
end
