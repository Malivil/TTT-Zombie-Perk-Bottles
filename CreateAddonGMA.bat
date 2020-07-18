"C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmad.exe" create -folder %1
echo Removing old file
del TTT-Zombie-Perk-Bottles.gma
echo Renaming file
ren %1.gma TTT-Zombie-Perk-Bottles.gma
pause