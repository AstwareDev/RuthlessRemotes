local NotificationSystem = loadstring(game:HttpGet('https://raw.githubusercontent.com/ScripterTSBG/custom-libraries/refs/heads/main/NotificationSystem.lua'))()
local indexTable = {}
local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()-_=+[]{};:'\",./?<>| "
local codes = {"1023","4067","8392","9173","2840","6701","9324","8076","3642","9012","6738","2401","8042","1637","7204","9083","4370","2648","3702","4091","8034","2067","9473","6124","8340","7093","3412","9084","2736","7041","6328","4072","9360","2184","7043","9812","3647","2403","8720","4612","7930","6042","8317","2904","8740","3026","6704","9132","4620","8024","3740","6920","2468","1937","8023","7604","3092","9183","4703","9204","3170","8642","3074","6192","7408","2307","8940","6720","1304","9072","3824","6048","9412","7083","4632","8027","7013","6240","7392","8704","2340","9043","6812","2930","7402","9184","3640","2740","3902","7406","6023","8072","1111"}
for i = 1, #chars do indexTable[chars:sub(i, i)] = codes[i] end

local Players, reverseTable = game:GetService("Players"), {}

if not getgenv().RuthlessInfo then
    getgenv().RuthlessInfo = {
        CurrentData = {},
        Debug = false,
    }
end

for char, code in pairs(indexTable) do reverseTable[code] = char end

local function encodeString(input)
    local encoded = {}
    for i = 1, #input do encoded[#encoded + 1] = indexTable[input:sub(i, i)] or "0000" end
    return table.concat(encoded, "999")
end

local function decodeString(input)
    local decoded = {}
    for _, code in ipairs(string.split(input, "999")) do decoded[#decoded + 1] = reverseTable[code] or "?" end
    return table.concat(decoded)
end

local function encodeTable(tbl)
    local encoded = {}
    for index, value in pairs(tbl) do
        encoded[#encoded + 1] = "444" .. encodeString(tostring(index)) .. "444888" .. encodeString(tostring(value)) .. "888"
    end
    return table.concat(encoded, "999")
end

local function decodeTable(input)
    local decoded = {}
    for encodedIndex, encodedValue in input:gmatch("444(.-)444888(.-)888") do
        decoded[tonumber(decodeString(encodedIndex)) or decodeString(encodedIndex)] = decodeString(encodedValue)
    end
    return decoded
end

local function CheckForData(player, character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.AnimationPlayed:Connect(function(track)
            local animId = track.Animation.AnimationId:gsub("rbxassetid://", "")
            if not animId:match("http") then
                local decodedData = decodeTable(animId)
                getgenv().RuthlessInfo.CurrentData[player.Name] = decodedData
                if RuthlessRemotes.OnDataReceived then
                    RuthlessRemotes.OnDataReceived(player, decodedData)
                end
            end
        end)
    end
end

local RuthlessRemotes = {}

RuthlessRemotes.OnDataReceived = nil

function RuthlessRemotes.FireData(Data)
    local function Debug_Func1()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. encodeTable(Data)
        game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid"):LoadAnimation(anim):Play()
    end
    local success, result = pcall(Debug_Func1)
    if success then
        result = "Data was sent successfully\nData: " .. encodeTable(Data)
    end
    if getgenv().RuthlessInfo.Debug then
        NotificationSystem.createNotification("Success" and success or "Error", result)
    end
end

function RuthlessRemotes.GetData()
    return getgenv().RuthlessInfo.CurrentData
end

function RuthlessRemotes.Debug(Activated)
    getgenv().RuthlessInfo.Debug = Activated
end

function RuthlessRemotes.Start()
    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(function(character) CheckForData(player, character) end)
        if player.Character then CheckForData(player, player.Character) end
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end
end

return RuthlessRemotes
