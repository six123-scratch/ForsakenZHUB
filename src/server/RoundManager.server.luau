local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local RoundEvent = ReplicatedStorage.Events:WaitForChild("RoundStatus")
local LMSTheme = SoundService:WaitForChild("LMSTheme")

local INTERMISSION_TIME = 20
local ROUND_TIME = 180

local function getAliveSurvivors(survivors)
	local alive = {}
	for _, p in pairs(survivors) do
		if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
			table.insert(alive, p)
		end
	end
	return alive
end

while true do
	LMSTheme:Stop()
	for i = INTERMISSION_TIME, 1, -1 do
		RoundEvent:FireAllClients("Intermission", "Game mulai dalam: " .. i)
		task.wait(1)
	end

	local allPlayers = Players:GetPlayers()
	if #allPlayers < 2 then
		RoundEvent:FireAllClients("Info", "Butuh minimal 2 pemain untuk memulai!")
		task.wait(3)
		continue
	end

	local killerIndex = math.random(1, #allPlayers)
	local killer = allPlayers[killerIndex]
	local survivors = {}

	for i, p in pairs(allPlayers) do
		if p ~= killer then
			table.insert(survivors, p)
		end
	end

	local mapNames = {"PizzaPlace", "HorrorHotel"}
	local chosenMapName = mapNames[math.random(1, #mapNames)]
	local mapFolder = workspace.Maps:FindFirstChild(chosenMapName)

	if killer.Character and killer.Character:FindFirstChild("HumanoidRootPart") then
		killer.Character.HumanoidRootPart.CFrame = mapFolder.KillerSpawn.CFrame + Vector3.new(0, 3, 0)
		killer.Character:SetAttribute("Role", "Killer")
	end

	local spawnParts = mapFolder.SurvivorSpawns:GetChildren()
	for i, s in pairs(survivors) do
		if s.Character and s.Character:FindFirstChild("HumanoidRootPart") then
			local sp = spawnParts[((i - 1) % #spawnParts) + 1]
			s.Character.HumanoidRootPart.CFrame = sp.CFrame + Vector3.new(0, 3, 0)
			s.Character:SetAttribute("Role", "Survivor")
		end
	end

	RoundEvent:FireAllClients("GameStarted", {
		Killer = killer.Name,
		Map = chosenMapName
	})

	local lmsTriggered = false
	local roundTimer = ROUND_TIME

	while roundTimer > 0 do
		task.wait(1)
		roundTimer = roundTimer - 1

		local aliveSurvivors = getAliveSurvivors(survivors)

		if #aliveSurvivors == 0 then
			RoundEvent:FireAllClients("GameOver", "Killer (c00lkidd) Menang!")
			break
		end

		if #aliveSurvivors == 1 and not lmsTriggered and #survivors > 1 then
			lmsTriggered = true
			local lastSurvivor = aliveSurvivors[1]
			LMSTheme:Play()
			RoundEvent:FireAllClients("LMS", lastSurvivor.Name .. " adalah LAST MAN STANDING!")
		end

		if not killer.Character or not killer.Character:FindFirstChild("Humanoid") or killer.Character.Humanoid.Health <= 0 then
			RoundEvent:FireAllClients("GameOver", "Survivors Menang!")
			break
		end
	end

	if roundTimer <= 0 then
		RoundEvent:FireAllClients("GameOver", "Waktu habis! Survivors Selamat!")
	end

	LMSTheme:Stop()
	task.wait(5)
	for _, p in pairs(Players:GetPlayers()) do
		p:LoadCharacter()
	end
end
