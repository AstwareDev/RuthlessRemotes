local RuthlessRemotes = {}

RuthlessRemotes.OnDataReceivedCallback = nil

local Players = game:GetService("Players")

if not getgenv().RuthlessInfo then
    getgenv().RuthlessInfo = {
        CurrentData = {},
    }
end

-- Encoding and Decoding

local indexTable = {
    ["A"] = "1", ["B"] = "2", ["C"] = "3", ["D"] = "4", ["E"] = "5",
    ["F"] = "6", ["G"] = "7", ["H"] = "8", ["I"] = "9", ["J"] = "10",
    ["K"] = "11", ["L"] = "12", ["M"] = "13", ["N"] = "14", ["O"] = "15",
    ["P"] = "16", ["Q"] = "17", ["R"] = "18", ["S"] = "19", ["T"] = "20",
    ["U"] = "21", ["V"] = "22", ["W"] = "23", ["X"] = "24", ["Y"] = "25",
    ["Z"] = "26", ["a"] = "27", ["b"] = "28", ["c"] = "29", ["d"] = "30",
    ["e"] = "31", ["f"] = "32", ["g"] = "33", ["h"] = "34", ["i"] = "35",
    ["j"] = "36", ["k"] = "37", ["l"] = "38", ["m"] = "39", ["n"] = "40",
    ["o"] = "41", ["p"] = "42", ["q"] = "43", ["r"] = "44", ["s"] = "45",
    ["t"] = "46", ["u"] = "47", ["v"] = "48", ["w"] = "49", ["x"] = "50",
    ["y"] = "51", ["z"] = "52", ["0"] = "53", ["1"] = "54", ["2"] = "55",
    ["3"] = "56", ["4"] = "57", ["5"] = "58", ["6"] = "59", ["7"] = "60",
    ["8"] = "61", ["9"] = "62", ["!"] = "63", ["@"] = "64", ["#"] = "65",
    ["$"] = "66", ["%"] = "67", ["^"] = "68", ["&"] = "69", ["*"] = "70",
    ["("] = "71", [")"] = "72", ["-"] = "73", ["_"] = "74", ["="] = "75",
    ["+"] = "76", ["["] = "77", ["]"] = "78", ["{"] = "79", ["}"] = "80",
    [";"] = "81", [":"] = "82", ["'"] = "83", ['"'] = "84", [","] = "85",
    ["."] = "86", ["/"] = "87", ["?"] = "88", ["<"] = "89", [">"] = "90",
    ["|"] = "91", ["\\"] = "92", [" "] = "93"
}

local reverseTable = {}
for char, code in pairs(indexTable) do
	reverseTable[code] = char
end

local function encodeString(input)
	local encoded = {}
	for i = 1, #input do
		local char = input:sub(i, i)
		table.insert(encoded, indexTable[char] or "0000")
	end
	return table.concat(encoded, "999")
end

local function decodeString(input)
	local decoded = {}
	for _, code in ipairs(string.split(input, "999")) do
		table.insert(decoded, reverseTable[code] or "?")
	end
	return table.concat(decoded)
end

local function encodeTable(tbl)
	local encoded = {}
	for index, value in pairs(tbl) do
		local encodedIndex = "444" .. encodeString(tostring(index)) .. "444"
		local encodedValue = "888" .. encodeString(tostring(value)) .. "888"
		table.insert(encoded, encodedIndex .. encodedValue)
	end
	return table.concat(encoded, "999")
end

local function decodeTable(input)
	local decoded = {}
	for encodedIndex, encodedValue in input:gmatch("444(.-)444888(.-)888") do
		local index = decodeString(encodedIndex)
		local value = decodeString(encodedValue)
		decoded[tonumber(index) or index] = value
	end
	return decoded
end

-- Creating Library commands

local function CheckForData(player, character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.AnimationPlayed:Connect(function(track)
            local animId = track.Animation.AnimationId:gsub("rbxassetid://", "")
            if not animId:match("https://www.roblox") then
                local decodedData = decodeTable(animId)
                getgenv().RuthlessInfo.CurrentData[player.Name] = decodedData
                if RuthlessRemotes.OnDataReceivedCallback then
                    RuthlessRemotes.OnDataReceivedCallback(player, decodedData)
                end
            end
        end)
    end
end

function RuthlessRemotes.FireData(Data)
    local function SendData()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. encodeTable(Data)
        game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid"):LoadAnimation(anim):Play()
    end
    local success, result = pcall(SendData)
    if success then
        result = "Data was sent successfully\nData: " .. encodeTable(Data)
        print(result)
    end
end

function RuthlessRemotes.GetData()
    return getgenv().RuthlessInfo.CurrentData
end

function RuthlessRemotes.Start()
    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(function(character) CheckForData(player, character) end)
        if player.Character then CheckForData(player, player.Character) end
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, player in Players:GetPlayers() do 
        onPlayerAdded(player) 
    end
end

return RuthlessRemotes
