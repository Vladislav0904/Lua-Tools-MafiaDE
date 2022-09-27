loader = {}

loader._luas = {
    "Core/coreStats.lua",
    "Core/coreThreads.lua",
    
    "Data/animsData.lua",
    "Data/carTuneData.lua",
    "Data/checkpointsData.lua",
    "Data/colorsData.lua",
    "Data/componentsData.lua",
    "Data/vehiclesData.lua",
    "Data/weaponsData.lua",
    "Data/weatherData.lua",
    "Data/wheelsData.lua",
    "Data/raceData.lua",

    "Menu/mainMenu.lua",
    "Menu/raceMenu.lua",
    "Menu/debugMenu.lua",

    "Scripts/race.lua",

    "Utils/playerUtils.lua",
    "Utils/vehicleUtils.lua"
}

function loader.ImportLua(luas)
    for _,lua in ipairs(luas) do
        if game then
            include(lua)
        else
            require(lua)
        end
    end
end  