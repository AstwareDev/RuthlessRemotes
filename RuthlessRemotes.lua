local Library = {}

Library.DataReceivedSignal = function(player, data)
    warn("You haven't configured DataReceviedSignal.")
end
Library.AttributeReceivedSignal = function(player, att)
    player:SetAttribute(att.Name, att.Data)
    warn("You haven't configured AttributeReceivedSignal.")
end

local Players = game:GetService("Players")

if not getgenv().RuthlessInfo then
    getgenv().RuthlessInfo = {CurrentData = {}, Debug = false}
end

-- Encoding and Decoding
local indexTable = { ["A"] = "1023", ["B"] = "4067", ["C"] = "8392", ["D"] = "9173", ["E"] = "2840", ["F"] = "6701", ["G"] = "9324", ["H"] = "8076", ["I"] = "3642", ["J"] = "9012", ["K"] = "6738", ["L"] = "2401", ["M"] = "8042", ["N"] = "1637", ["O"] = "7204", ["P"] = "9083", ["Q"] = "4370", ["R"] = "2648", ["S"] = "3702", ["T"] = "4091", ["U"] = "8034", ["V"] = "2067", ["W"] = "9473", ["X"] = "6124", ["Y"] = "8340", ["Z"] = "7093", ["a"] = "3412", ["b"] = "9084", ["c"] = "2736", ["d"] = "7041", ["e"] = "6328", ["f"] = "4072", ["g"] = "9360", ["h"] = "2184", ["i"] = "7043", ["j"] = "9812", ["k"] = "3647", ["l"] = "2403", ["m"] = "8720", ["n"] = "4612", ["o"] = "7930", ["p"] = "6042", ["q"] = "8317", ["r"] = "2904", ["s"] = "8740", ["t"] = "3026", ["u"] = "6704", ["v"] = "9132", ["w"] = "4620", ["x"] = "8024", ["y"] = "3740", ["z"] = "6920", ["0"] = "2468", ["1"] = "1937", ["2"] = "8023", ["3"] = "7604", ["4"] = "3092", ["5"] = "9183", ["6"] = "4703", ["7"] = "9204", ["8"] = "3170", ["9"] = "8642", ["!"] = "3074", ["@"] = "6192", ["#"] = "7408", ["$"] = "2307", ["%"] = "8940", ["^"] = "6720", ["&"] = "1304", ["*"] = "9072", ["("] = "3824", [")"] = "6048", ["-"] = "9412", ["_"] = "7083", ["="] = "4632", ["+"] = "8027", ["["] = "7013", ["]"] = "6240", ["{"] = "7392", ["}"] = "8704", [";"] = "2340", [":"] = "9043", ["'"] = "6812", ['"'] = "2930", [","] = "7402", ["."] = "9184", ["/"] = "3640", ["?"] = "2740", ["<"] = "3902", [">"] = "7406", ["|"] = "6023", ["\\"] = "8072", [" "] = "1111" }

local reverseTable = {}
for char, code in pairs(indexTable) do reverseTable[code] = char end

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

local function encodeAttribute(AttributeName, AttributeData)
    local encoded = {}
    local encodedName = "333" .. encodeString(tostring(AttributeName)) .. "333"
    local encodedData = "666" .. encodeString(tostring(AttributeData)) .. "666"
    table.insert(encoded, encodedName .. encodedData)
    return table.concat(encoded, "999")
end

local function decodeAttribute(input, plr)
    local decoded = {}
    for encodedName, encodedData in input:gmatch("333(.-)333666(.-)666") do
        local AttributeName = decodeString(encodedName)
        local AttributeData = decodeString(encodedData)
        decoded.Name = AttributeName
        decoded.Data = AttributeData
        decoded.Parent = plr
    end
    return decoded
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

local function CheckForData(player, character)
    local DataType = ""
    local prefixMap = {["333"] = "Attribute", ["444"] = "Table"}
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.AnimationPlayed:Connect(function(track)
            local animId = track.Animation.AnimationId:gsub("rbxassetid://", "")
            if not animId:match("https://www.roblox") then
                DataType = prefixMap[animId:sub(1, 3)]
                if DataType == "Table" then
                    print("Table")
                    local decodedData = decodeTable(animId)
                    getgenv().RuthlessInfo.CurrentData[player.Name] =
                        decodedData
                    if Library.DataReceivedSignal then
                        Library.DataReceivedSignal(player, decodedData)
                    end
                elseif DataType == "Attribute" then
                    print("Attribute")
                    local decodedData = decodeAttribute(animId, player)
                    if Library.AttributeReceivedSignal then
                        Library.AttributeReceivedSignal(player, decodedData)
                    end
                end
            end
        end)
    end
end

-- Creating Library commands
function Library.Debug(bool)
    print("Debugging Mode: " .. tostring(bool))
    getgenv().RuthlessInfo.Debug = bool
end

function Library.LoadRequestBody(url, shouldPrint)
    local reqBody = request({Url = url, Method = 'GET'}).Body
    if shouldPrint or getgenv().RuthlessInfo.Debug then print(reqBody) end
    return loadstring(reqBody)
end

function Library.Download(fileName, link)
    local function wf(st, a)
        if not isfile(st) then
            local y = a
            if a:find('https://www.mediafire') or a:find('https://cdn.discordapp.com/attachments/') then
                local request = request or syn.request
                local response = request({Url = a, Method = "GET"})

                local url = response.Body
                if not string.find(a, 'https://cdn.discordapp.com/attachments') then
                    local split = string.split(url, "https://download")[2]
                    for i = 1, string.len(split) do
                        local yes = string.sub(split, i, i)
                        if string.find(yes, '"') then
                            y = "https://download" ..
                                    string.sub(split, 1, i - 1)
                            break
                        end
                    end
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "MediaFire Download",
                        Text = "Downloading " .. fileName,
                        Duration = 5
                    })
                    writefile(st, game:HttpGet(y))
                else
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Discord Download",
                        Text = "Downloading " .. fileName,
                        Duration = 5
                    })
                    writefile(st, response.Body)
                end
            else
                error('Invalid link, Mediafire or discord attachment links only')
            end
        end
        return (getsynasset or getcustomasset)(st)
    end
    repeat task.wait() until wf(fileName, link)
end

function Library.GitDownload(fileName, url)
    local ObjectName = "_RuthlessRemotesObject_" .. tostring(fileName)

    if not isfile(ObjectName) then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "GitDownload",
            Text = "Downloading " .. ObjectName .. "...",
            Duration = 3
        })

        local success, result = pcall(function()
            return game:HttpGet(GithubSnd)
        end)

        if success then
            writefile(ObjectName, result)
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Download Failed",
                Text = "Failed to download " .. ObjectName,
                Duration = 5
            })
            return nil
        end
    end

    return (getcustomasset or getsynasset)(ObjectName)
end

function Library.FireData(Data)
    local function SendData()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. encodeTable(Data)
        game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid"):LoadAnimation(anim):Play()
    end
    local success, result = pcall(SendData)
    if success and getgenv().RuthlessInfo.Debug then
        result = "Data was sent successfully\nData: " .. encodeTable(Data)
        print(result)
    elseif not success and getgenv().RuthlessInfo.Debug then
        newresult = "Library - Error while transfering data: " .. result
        print(newresult)
    end
end

function Library.GetData() return getgenv().RuthlessInfo.CurrentData end

function Library.SetAttribute(AttributeName, AttributeData)
    local function SendData()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. encodeAttribute(AttributeName, AttributeData)
        game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid"):LoadAnimation(anim):Play()
    end
    local success, result = pcall(SendData)
    if success and getgenv().RuthlessInfo.Debug then
        result = "Data was sent successfully\nData: " .. encodeAttribute(AttributeName, AttributeData)
        print(result)
    elseif not success and getgenv().RuthlessInfo.Debug then
        newresult = "Library - Error while transfering data: " .. result
        print(newresult)
    end
end

function Library.Start()
    if getgenv().RuthlessInfo.Debug then
        print("Starting to fetch data from players.")
    end
    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(function(character)
            CheckForData(player, character)
        end)
        if player.Character then CheckForData(player, player.Character) end
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, player in Players:GetPlayers() do onPlayerAdded(player) end
end

return Library
