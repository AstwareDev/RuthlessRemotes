local indexTable = {
	["A"] = "1023", ["B"] = "4067", ["C"] = "8392", ["D"] = "9173", ["E"] = "2840",
	["F"] = "6701", ["G"] = "9324", ["H"] = "8076", ["I"] = "3642", ["J"] = "9012",
	["K"] = "6738", ["L"] = "2401", ["M"] = "8042", ["N"] = "1637", ["O"] = "7204",
	["P"] = "9083", ["Q"] = "4370", ["R"] = "2648", ["S"] = "3702", ["T"] = "4091",
	["U"] = "8034", ["V"] = "2067", ["W"] = "9473", ["X"] = "6124", ["Y"] = "8340",
	["Z"] = "7093", ["a"] = "3412", ["b"] = "9084", ["c"] = "2736", ["d"] = "7041",
	["e"] = "6328", ["f"] = "4072", ["g"] = "9360", ["h"] = "2184", ["i"] = "7043",
	["j"] = "9812", ["k"] = "3647", ["l"] = "2403", ["m"] = "8720", ["n"] = "4612",
	["o"] = "7930", ["p"] = "6042", ["q"] = "8317", ["r"] = "2904", ["s"] = "8740",
	["t"] = "3026", ["u"] = "6704", ["v"] = "9132", ["w"] = "4620", ["x"] = "8024",
	["y"] = "3740", ["z"] = "6920", ["0"] = "2468", ["1"] = "1937", ["2"] = "8023",
	["3"] = "7604", ["4"] = "3092", ["5"] = "9183", ["6"] = "4703", ["7"] = "9204",
	["8"] = "3170", ["9"] = "8642", ["!"] = "3074", ["@"] = "6192", ["#"] = "7408",
	["$"] = "2307", ["%"] = "8940", ["^"] = "6720", ["&"] = "1304", ["*"] = "9072",
	["("] = "3824", [")"] = "6048", ["-"] = "9412", ["_"] = "7083", ["="] = "4632",
	["+"] = "8027", ["["] = "7013", ["]"] = "6240", ["{"] = "7392", ["}"] = "8704",
	[";"] = "2340", [":"] = "9043", ["'"] = "6812", ['"'] = "2930", [","] = "7402",
	["."] = "9184", ["/"] = "3640", ["?"] = "2740", ["<"] = "3902", [">"] = "7406",
	["|"] = "6023", ["\\"] = "8072", [" "] = "1111"
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

local Players = game:GetService("Players")

if not getgenv().RuthlessInfo then
    getgenv().RuthlessInfo = {
        CurrentData = {},
    }
end

local RuthlessRemotes = {}

RuthlessRemotes.OnDataReceivedCallback = nil

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
    for _, player in Players:GetPlayers() do onPlayerAdded(player) end
end

return RuthlessRemotes
