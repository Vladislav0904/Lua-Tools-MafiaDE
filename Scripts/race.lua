raceScr = {}


function raceScr.showStats()
	local checkpoint_first = tostring(getRaceData("checkpointTime", "first"))
	local checkpoint_second = tostring(getRaceData("checkpointTime", "second"))
	local checkpoint_third = tostring(getRaceData("checkpointTime", "third"))
	local checkpoint_fourth = tostring(getRaceData("checkpointTime", "fourth"))
	local checkpoint_finish = tostring(getRaceData("checkpointTime", "finish"))

	local speed_40 = tostring(getRaceData("speedTime", "s_40"))
	local speed_60 = tostring(getRaceData("speedTime", "s_60"))
	local speed_80 = tostring(getRaceData("speedTime", "s_80"))
	local speed_100 = tostring(getRaceData("speedTime", "s_100"))
	local speed_120 = tostring(getRaceData("speedTime", "s_120"))
	local speed_140 = tostring(getRaceData("speedTime", "s_140"))

	raceResults = "First Checkpoint: "..checkpoint_first.."\nSecond Checkpoint: "..checkpoint_second.."\nThird Checkpoint: "..checkpoint_third.."\nFourth Checkpoint: "..checkpoint_fourth.."\nFinish: "..checkpoint_finish.."\n0-40: "..speed_40.." | 0-60: "..speed_60.." | 0-80: "..speed_80.."\n0-100: "..speed_100.." | 0-120: "..speed_120.." | 0-140: "..speed_140

	raceMenu.hide()
	coreThreads.list.showStatsThread = StartThread(function()
		Sleep(500)
		game.hud:SendMessageMovie("HUD", "OnShowFreerideBanner", "Race Stats:", raceResults)
		coreThreads.list.showStatsThread = DestroyThread()
	end)

	return raceResults
end

local function createTimer()
	game.hud:RacingStart(0, 0)
	game.hud:RacingShowHud(true)
end

local function destroyTimer()
	game.hud:RacingStop()
	game.hud:RacingClear()
end

local function setPlayerCamera(dir)
	LookAtVector = getp():GetPos()
	if dir == "enter" then
		LookAtVector.x = -2300 -- BREH -_-
		LookAtVector.y = 0
		LookAtVector.z = 0

		game.cameramanager:GetPlayerCamera():ScriptPointAtVec(LookAtVector, 0, 1, 0)

	elseif dir == "exit" then
		LookAtVector.x = 7000 -- BREH -_-
		LookAtVector.y = 0
		LookAtVector.z = 0

		game.cameramanager:GetPlayerCamera():ScriptPointAtVec(LookAtVector, 0, 1, 0)
	end
end

local function createCheckpoint(pos)
	checkpointEntity = game.entitywrapper:GetEntityByName("sm_ef_110_checkpoint_00")
	checkpointObjectiveEntity = game.game:CreateCleanEntity(Math:newVector(0.0, 0.0, 0.0), 0, false, false, true)

    checkpointEntity:Deactivate()
    checkpointEntity:SetPos(pos) 
    checkpointObjectiveEntity:SetPos(pos)
    game.hud:AddEntityIndicator(checkpointObjectiveEntity, "objective_primary", Math:newVector(0,0,-1))
    checkpointEntity:Activate()
end

local function removeCheckpont()
	game.hud:RemoveEntityIndicator(checkpointObjectiveEntity)
end

local function teleportCar(pos)
	if pos == "enter" then
		getp():GetOwner():SetPos(getRaceData("carPos", "carRacePos"))
		getp():GetOwner():SetDir(getRaceData("carPos", "carRaceDir"))
		setPlayerCamera("enter")
	elseif pos == "exit" then
		getp():GetOwner():SetPos(getRaceData("carPos", "carExitPos"))
		getp():GetOwner():SetDir(getRaceData("carPos", "carExitDir"))
		setPlayerCamera("exit")
	end
end

local function exitRace()
	coreThreads.list.exitRaceThread = StartThread(function()
		local veh = getp():GetOwner()

		veh:SetSpeed(0)
		game.hud:FaderFadeOut(5)
		teleportCar("exit")
		Sleep(5000)
		game.hud:FaderFadeIn(350)
		coreThreads.list.exitRaceThread = DestroyThread()
	end)
end

local function checkpointsRace()
	coreThreads.list.checkpointsRaceThread = StartThread(function()
		local firstFlag = 0
		local secondFlag = 0
		local thirdFlag = 0
		local fourthFlag = 0
		local finishFlag = 0

		createCheckpoint(getRaceData("checkpointPos", "firstCheckPoint"))

		while true do
			local veh = getp():GetOwner()
			local first = getRaceData("checkpointPos", "firstCheckPoint"):DistanceToPoint(veh:GetPos())
			local second = getRaceData("checkpointPos", "secondCheckPoint"):DistanceToPoint(veh:GetPos())
			local third = getRaceData("checkpointPos", "thirdCheckPoint"):DistanceToPoint(veh:GetPos())
			local fourth = getRaceData("checkpointPos","fourthCheckPoint"):DistanceToPoint(veh:GetPos())
			local finish = getRaceData("checkpointPos","finishCheckPoint"):DistanceToPoint(veh:GetPos())

			if first <= 5 and firstFlag == 0 then
				setRaceData("checkpointTime", "first", string.format("%.2f", game.hud:RacingGetTime()))
				removeCheckpont()
				createCheckpoint(getRaceData("checkpointPos", "secondCheckPoint"))
				firstFlag = 1
			end
			if second <= 5 and secondFlag == 0 then
				setRaceData("checkpointTime", "second", string.format("%.2f", game.hud:RacingGetTime()))
				removeCheckpont()
				createCheckpoint(getRaceData("checkpointPos", "thirdCheckPoint"))
				secondFlag = 1
			end
			if third <= 5 and thirdFlag == 0 then
				setRaceData("checkpointTime", "third", string.format("%.2f", game.hud:RacingGetTime()))
				removeCheckpont()
				createCheckpoint(getRaceData("checkpointPos", "fourthCheckPoint"))
				thirdFlag = 1
			end
			if fourth <= 5 and fourthFlag == 0 then
				setRaceData("checkpointTime", "fourth", string.format("%.2f", game.hud:RacingGetTime()))
				removeCheckpont()
				createCheckpoint(getRaceData("checkpointPos", "finishCheckPoint"))
				fourthFlag = 1
			end
			if finish <= 5 and finishFlag == 0 then
				exitRace()
				setRaceData("checkpointTime", "finish", string.format("%.2f", game.hud:RacingGetTime()))
				destroyTimer()
				removeCheckpont()
				finishFlag = 1
				coreThreads.list.speedRaceThread = DestroyThread()
				coreThreads.list.checkpointsRaceThread = DestroyThread()
			end
			Sleep(1)
		end
	end)
end

local function speedRace()
	coreThreads.list.speedRaceThread = StartThread(function()
		local s_40f = 0
		local s_60f = 0
		local s_80f = 0
		local s_100f = 0
		local s_120f = 0
		local s_140f = 0

		while true do
			local veh = getp():GetOwner()
			local speed = veh:GetSpeedFloat() / 1.6093

			if speed >= 40 and s_40f == 0 then
				setRaceData("speedTime", "s_40", string.format("%.2f", game.hud:RacingGetTime()))
				s_40f = 1
			end
			if speed >= 60 and s_60f == 0 then
				setRaceData("speedTime", "s_60", string.format("%.2f", game.hud:RacingGetTime()))
				s_60f = 1
			end
			if speed >= 80 and s_80f == 0 then
				setRaceData("speedTime", "s_80", string.format("%.2f", game.hud:RacingGetTime()))
				s_80f = 1
			end
			if speed >= 100 and s_100f == 0 then
				setRaceData("speedTime", "s_100", string.format("%.2f", game.hud:RacingGetTime()))
				s_100f = 1
			end
			if speed >= 120 and s_120f == 0 then
				setRaceData("speedTime", "s_120", string.format("%.2f", game.hud:RacingGetTime()))
				s_120f = 1
			end
			if speed >= 140 and s_140f == 0 then
				setRaceData("speedTime", "s_140", string.format("%.2f", game.hud:RacingGetTime()))
				s_140f = 1
			end
			Sleep(1)
		end
	end)
end

function raceScr.enterRace()
	coreThreads.list.enterRaceThread = StartThread(function()
		local veh = getp():GetOwner()
		
		Sleep(200)
		destroyTimer()
		removeCheckpont()
		game.hud:FaderFadeOut(350)
		Sleep(1000)
		veh:SetSpeed(0)
		getp():SetControlStyle(enums.ControlStyle.LOCKED)
		veh:Lock()
		teleportCar("enter")
		Sleep(5000)
		veh:Repair()
		veh:Unlock()
		game.hud:FaderFadeIn(350)
		getp():SetControlStyle(enums.ControlStyle.FREE)
		veh:SetPreLaunchMode(true)
		Wait(game.hud:StartCountDown(5))
		veh:SetPreLaunchMode(false)
		createTimer()
		checkpointsRace()
		speedRace()
		coreThreads.list.enterRaceThread = DestroyThread()
	end)
end