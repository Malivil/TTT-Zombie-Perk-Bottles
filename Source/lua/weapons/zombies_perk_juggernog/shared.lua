AddCSLuaFile("shared.lua")

SWEP.Author = "Hoff"
SWEP.Instructions = "Reach for Juggernog tonight!"
SWEP.Category = "CoD Zombies"
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
SWEP.ViewModelFOV = 60

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.PrintName = "Juggernog"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.CorrectModelPlacement = Vector(0, 0, -1)
SWEP.SwayScale = 0.01
SWEP.BobScale = 0.01

function SWEP:Equip(ply)
    local oldWep = self.Owner:GetActiveWeapon()
    ply:SetActiveWeapon("zombies_perk_juggernog")
    timer.Simple(3.8, function() ply:SetActiveWeapon(oldWep) end)
end

function SWEP:Deploy()
    self.Weapon:SetNetworkedString("isDrinkingPerk", "true")

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
        end
    end)

    timer.Simple(3.1, function()
        if self.Owner:Alive() then
            self.Weapon:EmitSound("hoff/animations/perks/017bf9c0.wav")
            self.Weapon:SetNetworkedString("isDrinkingPerk", "false")
            local plyHealth = self.Owner:Health()
            self.Owner:SetHealth(100)
            timer.Simple(0.1, function() self.Weapon:Remove() end)
        end
    end)

end

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
