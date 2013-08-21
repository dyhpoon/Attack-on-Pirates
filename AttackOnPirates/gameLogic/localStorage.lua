module(..., package.seeall)

local json = require "json"
local toast = require 'gameLogic.toast'

local filename = "gamedata.json"

local function save(t)
	local path = system.pathForFile(filename, system.DocumentsDirectory)
	local file = io.open(path, "w")
	if file then
		local contents = json.encode(t)
		file:write(contents)
		io.close(file)
		return true
	else
		return false
	end
end

local function createNewGameSave()
	print("created a new file")
	local gameSettings = {
		["phoneID"] = system.getInfo("deviceID"),
		["charLevel"] = 1,
		["charExp"] = 0,
		["coins"] = 100,
		["diamonds"] = 10,
		["keys"] = 0,
		["timestamp"] = os.time(),
		["currentEnergy"] = 5,
		["dailyRewardRecord"] = {},
		["survivalRecord"] = 0,
		["storyLevel"] = 0,
		["expBonus"] = 0,
		["redPot1"] = 10,
		["redPot2"] = 5,
		["redPot3"] = 3,
		["redPot4"] = 0,
		["bluePot"] = 10,
		["energyBottle"] = 1,
		["highScore"] = {},
		["survivalHighScore"] = 0,
	}
	save(gameSettings)
end

local function load()
	local path = system.pathForFile(filename, system.DocumentsDirectory)
	local contents = ""
	local myTable = {}
	local file = io.open(path, "r")

	if not file then
		createNewGameSave()
		file = io.open(path, "r")
	end

	local contents = file:read("*a")
	myTable = json.decode(contents)
	io.close(file)
	return myTable
		
end

local function checkSave()
	local myTable = load()

	if myTable["phoneID"] == system.getInfo("deviceID") then
		return true
	else
		return false
	end
end

function get(key)
	local myTable = load()

	if pcall(checkSave) then
		return myTable[key]
	else
		print("data corrupted")
		createNewGameSave()
		toast.new("ERROR: Game data is corrupted, reinitializing...", 10000)
		return get(key)
	end
	
end

function saveWithKey(key,value)
	local myTable = load()
	if pcall(checkSave) then
		myTable[key] = value
		save(myTable)
	else
		createNewGameSave()
		saveWithKey(key,value)
	end
end
