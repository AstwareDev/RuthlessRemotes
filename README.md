
# RuthlessRemotes  

RuthlessRemotes is a Lua-based system that allows you to send and receive encoded data using animations in **Roblox**.

## 📜 Features  
- **FireData(Data)** → Sends encoded data.  
- **GetData()** → Retrieves stored data.
- **Start()** → Starts the system to capture incoming data.  
- **OnDataReceivedCallback = function(player, dataTable)** → Triggered when data is received from another player.  

## 📥 Installation  
Load RuthlessRemotes using:  
```lua
local RuthlessRemotes = loadstring(game:HttpGet("https://raw.githubusercontent.com/ScripterTSBG/custom-libraries/refs/heads/main/RuthlessRemotes.lua"))()
```

---

## 🚀 Usage  

### 🔥 Sending Data  
You can send data using `FireData`. The data must be a table.  
```lua
RuthlessRemotes.FireData({Message = "Hello", Number = 123})
```

---

### 📡 Receiving Data  
Call `GetData()` to retrieve stored data. It returns a table with player names as keys.  
```lua
local data = RuthlessRemotes.GetData()
print(data["PlayerName"]) -- Prints the received data for "PlayerName"
```

---

### 🚦 Starting the System  
To capture incoming data, **start** the system:  
```lua
RuthlessRemotes.Start()
```
This listens for animations from other players and stores the decoded data.

---

### 📢 Custom Event for Data Reception  
You can assign a custom function to run when data is received by setting `OnDataReceived` in `RuthlessInfo`. This function will be triggered whenever new data is decoded:  
```lua
RuthlessRemotes.OnDataReceivedCallback = function(player, data)
    print("Data received from " .. player.Name)
    print(data)
end
```

---

## 📝 Example Script  
```lua
local RuthlessRemotes = loadstring(game:HttpGet("https://raw.githubusercontent.com/ScripterTSBG/custom-libraries/refs/heads/main/RuthlessRemotes.lua"))()

RuthlessRemotes.OnDataReceivedCallback = function(player, data)
    print("Data received from " .. player.Name .. ": " .. data.Action)
end

RuthlessRemotes.Start() -- Start listening for data

task.wait(2) 
RuthlessRemotes.FireData({Action = "Jump", Speed = 25}) -- Send data

task.wait(2)
local receivedData = RuthlessRemotes.GetData() -- Get stored data
for player, data in pairs(receivedData) do
    print("Data from " .. player .. ": " .. data.Action .. " at speed " .. data.Speed)
end
```

---

## 📌 Notes  
- Data is encoded into **animations** and decoded upon reception.  
- It only works on **Roblox Executors**.
- Both exploiters must use the library to transfer data between them. 
- Make sure to call `Start()` to begin receiving data.
- The system will automatically retry data sending if it fails, up to a set number of attempts.
- Due to the limitations of animations and Roblox's potato servers, table sizes are restricted, and you can only send numbers and strings (the library is open-source so you can change the encryption for shorter animationids)
