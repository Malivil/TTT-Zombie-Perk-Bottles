@echo off
set /p changes="Enter Changes: "
"C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmpublish.exe"  update -addon "TTT-Zombie-Perk-Bottles.gma" -id "2170163632" -changes "%changes%"
pause