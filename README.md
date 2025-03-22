# RuthlessRemotes  

RuthlessRemotes is a Lua-based system that allows you to send, receive, and debug encoded data using animations in **Roblox**.  

## 📜 Features  
- **FireData(Data)** → Sends encoded data.  
- **GetData()** → Retrieves stored data.  
- **Debug(Enabled)** → Toggles debug mode.  
- **Start()** → Starts the system to capture incoming data.  

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
If debug mode is enabled, you'll see a notification confirming the data was sent.  

---

### 📡 Receiving Data  
Call `GetData()` to retrieve stored data. It returns a table with player names as keys.  
```lua
local data = RuthlessRemotes.GetData()
print(data["PlayerName"]) -- Prints the received data for "PlayerName"
```

---

### 🛠️ Enabling Debug Mode  
To get success/failure notifications, enable debug mode:  
```lua
RuthlessRemotes.Debug(true) -- Enables debug mode
RuthlessRemotes.Debug(false) -- Disables debug mode
```

---

### 🚦 Starting the System  
To capture incoming data, **start** the system:  
```lua
RuthlessRemotes.Start()
```
This listens for animations from other players and stores the decoded data.

---

## 📝 Example Script  
```lua
local RuthlessRemotes = loadstring(game:HttpGet("https://raw.githubusercontent.com/ScripterTSBG/custom-libraries/refs/heads/main/RuthlessRemotes.lua"))()

RuthlessRemotes.Debug(true) -- Enable debugging
RuthlessRemotes.Start() -- Start listening for data

wait(2) 
RuthlessRemotes.FireData({Action = "Jump", Speed = 25}) -- Send data

wait(2)
local receivedData = RuthlessRemotes.GetData() -- Get stored data
for player, data in pairs(receivedData) do
    print("Data from " .. player .. ": " .. data.Action .. " at speed " .. data.Speed)
end
```

---

## 📌 Notes  
- Data is encoded into **animations** and decoded upon reception.  
- It only works on **Roblox Executors**.
- Both exploiters have to use the library to transfer data between them. 
- Make sure to call `Start()` to begin receiving data.  
- Debug mode will show notifications for sent/received data.
