module(..., package.seeall)

local json = require "json"
local toast = require 'gameLogic.toast'
local crypto = require "crypto"
local openssl = require "plugin.openssl"
local mime = require "mime"
local cipher = openssl.get_cipher ( "aes-256-cbc" )

local deviceID = system.getInfo("deviceID")
local filename = "pirateMatchThree.json"
local myPassword = "HiMyName1sD4rren~"

local function createPassword()
	local hash = crypto.digest(crypto.sha512, deviceID)
	local passwordHash = crypto.digest(crypto.sha512, myPassword)
	local finalPassword = crypto.digest(crypto.sha512, hash .. passwordHash)
	return finalPassword
end

local function save(t)
	local path = system.pathForFile(filename, system.DocumentsDirectory)
	local file = io.open(path, "w")
	if file then
		local contents = json.encode(t)
		local finalPassword = createPassword()
		local encryptedContents = mime.b64(cipher:encrypt(contents, finalPassword))
		--file:write(contents)
		file:write(encryptedContents)
		io.close(file)
		return true
	else
		return false
	end
end

--local phoneID = system.getInfo("deviceID")

local function createNewGameSave()

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
		["storyLevel"] = -1,
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
	local finalPassword = createPassword()
	local decryptedContents = cipher:decrypt(mime.unb64(contents), finalPassword)
	myTable = json.decode(decryptedContents)
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
