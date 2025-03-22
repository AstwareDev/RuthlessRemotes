local Players = game:GetService("Players")

if not getgenv().RuthlessInfo then
    getgenv().RuthlessInfo = {
        CurrentData = {},
    }
end

local function encodeString(input)
    local encoded = {}
    for i = 1, #input do
        encoded[#encoded + 1] = tostring(string.byte(input:sub(i, i))) or "0000"
    end
    return table.concat(encoded, "999")
end

local function decodeString(input)
    local decoded = {}
    for _, code in ipairs(string.split(input, "999")) do
        decoded[#decoded + 1] = string.char(tonumber(code) or 63)
    end
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
    local function SendData()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. encodeTable(Data)
        game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid"):LoadAnimation(anim):Play()
    end
    local success, result = pcall(SendData)
    if success then
        result = "Data was sent successfully\nData: " .. encodeTable(Data)
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
    for _, player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end
end

return RuthlessRemotes
