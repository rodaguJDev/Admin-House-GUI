if game.PlaceId ~= 333164326 and game.PlaceId ~= 12023670162 then
    return;
end


local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local TeleportService = game:GetService("TeleportService");
local HttpService = game:GetService("HttpService");

local PlayerModuleURL = 'https://raw.githubusercontent.com/rodaguJDev/Admin-House-GUI/main/PlayerModule.lua';
local AdminModuleURL = 'https://raw.githubusercontent.com/rodaguJDev/Admin-House-GUI/main/AdminModule.lua';
local InstanceModuleURL = 'https://raw.githubusercontent.com/rodaguJDev/Admin-House-GUI/main/InstanceModule.lua';

local HttpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request;
local AntiPlayerFilePath = 'AHG_Settings/AntiPlayer.txt';

-- Initiate Libraries
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))();
local Window = OrionLib:MakeWindow(
    {
        Name = "Admin House GUI",
        IntroEnabled = false,
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "AHG_Settings"
    }
);

loadstring(game:HttpGet(PlayerModuleURL))();
loadstring(game:HttpGet(AdminModuleURL))();
loadstring(game:HttpGet(InstanceModuleURL))();

-- Format:
-- Tab & Section
-- Variables
-- Function
-- Auto Initiate
-- Button Load

local AdminTab = Window:MakeTab({Name = "Admin"});

AdminTab:AddButton({
    Name = "Infinite Yield",
    Callback = loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))
});

local KeepAdminEvent;
local plrAdminName = Players.LocalPlayer.Name .. "'s admin";

if not IsPerm then 
    AdminTab:AddToggle({
        Name = 'Keep Admin',
        Default = false,
        Callback = KeepAdmin
    }); 
end

local SpawnHouseEvent
function SpawnAtHouse(state)
    if typeof(SpawnHouseEvent) == 'RBXScriptConnection' and SpawnHouseEvent.Connected then
        SpawnHouseEvent:Disconnect();
    end

    if state then
        SpawnHouseEvent = Players.LocalPlayer.CharacterAdded:Connect(function(plr) 
            plr:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-0, 28, 83);
        end)
    end
end
AdminTab:AddToggle({
    Name = 'Spawn at House',
    Default = false,
    Callback = SpawnAtHouse
});

AdminTab:AddTextbox({
    Name = 'Run Command',
    Default = '',
    TextDisapear = true,
    Callback = function(cmd)
        runc(':' .. cmd, true);
    end
});

local CrashPlrList
CrashPlrList = AdminTab:AddDropdown({
    Name = 'Crash Player',
    Default = '',
    Options = {},
    Callback = function(value)
        CrashPlayer(value, CrashPlrList);
    end
});
local RefreshCrashList = function() 
    local plrs = {};
    for _, plr in pairs(Players:GetPlayers()) do
        table.insert(plrs, plr.Name);
    end

    CrashPlrList:Refresh(plrs, true);
end
RefreshCrashList();
Players.PlayerAdded:Connect(RefreshCrashList);
Players.PlayerRemoving:Connect(RefreshCrashList);

local PlayerTab = Window:MakeTab({Name = 'Local Player'});
local PlayerSection = PlayerTab:AddSection({Name = "Player"});
local AntiAbuseSection = PlayerTab:AddSection({Name = "Anti Abuse"});
local TeleportSection = PlayerTab:AddSection({Name = "Teleports"});

PlayerSection:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Color = Color3.fromRGB(72, 0, 255),
    Callback = function(speed)
        Players.LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = speed;
    end
});

iyflyspeed = 4;
PlayerSection:AddSlider({
    Name = "Fly Speed",
    Min = 0.5,
    Max = 10,
    Default = 4,
    Increment = 0.5,
    Color = Color3.fromRGB(72, 0, 255),
    Callback = function(fs)
        iyflyspeed = fs;
    end
})

local FlyToggle = PlayerSection:AddToggle({
    Name = "Flying",
    Default = false,
    Callback = ToggleFly
});

local NoclipToggle = PlayerSection:AddToggle({
    Name = "Noclipping",
    Default = false,
    Callback = ToggleNoclip
});


AntiAbuseSection:AddButton({
    Name = "Bypass Punish",
    Callback = RespawnPlr
});

local CAMERALOCK
function LockCamera(state)
    if typeof(CAMERALOCK) == 'RBXScriptConnection' and CAMERALOCK.Connected then
        CAMERALOCK:Disconnect();
    end

    if state then
        CAMERALOCK = RunService.Stepped:Connect(function() 
            while not Players.LocalPlayer.Character:FindFirstChild("Humanoid") do task.wait() end
            workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character.Humanoid;
        end);
    end
end
local LockCameraToggle = AntiAbuseSection:AddToggle({
    Name = "Protect Camera",
    Default = false,
    Save = true,
    Flag = "LockCamera",
    Callback = LockCamera
});

local PLAYERLOCK
function ToggleLock(state)
    local PlrPos = CFrame.new(math.random(100000, 700000), math.random(100000, 700000), math.random(100000, 700000));
    local HousePos = CFrame.new(-0, 28, 83);

    if typeof(PLAYERLOCK) == 'RBXScriptConnection' and PLAYERLOCK.Connected then
        PLAYERLOCK:Disconnect();
        Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = HousePos;
    end

    if not state then return; end
    
    PLAYERLOCK = RunService.Stepped:Connect(function() 
        Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Velocity = Vector3.zero;
        Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = PlrPos;
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, HousePos.Position);
    end)
end
AntiAbuseSection:AddToggle({
    Name = 'Lock Player Away',
    Default = false,
    Save = true,
    Flag = "LockPlayer",
    Callback = ToggleLock
});

local F3XLoopCheck
function KeepF3X(state)
    local Backpack
    local F3XToolWait

    if typeof(F3XLoopCheck) == "RBXScriptConnection" and F3XLoopCheck.Connected then
        F3XLoopCheck:Disconnect();
    end
    if not state then return; end

    local function LoopForF3X()
        repeat
            runc(':free|:f3x', true);
            task.wait(6);
        until not F3XToolWait
    end

    F3XLoopCheck = RunService.Stepped:Connect(function() 
        Backpack = Backpack or Players.LocalPlayer:WaitForChild("Backpack");

        local Tool = Backpack:FindFirstChild("Building Tools") or Players.LocalPlayer.Character:FindFirstChild("Building Tools");
        F3XToolWait = if Tool then false else F3XToolWait;
        
        if Tool or F3XToolWait then return; end

        task.spawn(LoopForF3X);
        F3XToolWait = true;
    end);
end
local SpawnF3XToggle = AntiAbuseSection:AddToggle({
    Name = "Keep F3X",
    Callback = KeepF3X
});


TeleportSection:AddButton({
    Name = "Teleport House",
    Callback = function() 
        Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Velocity = Vector3.zero;
        Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-0, 28, 83)
    end
});

TeleportSection:AddButton({
    Name = "Teleport Spawn",
    Callback = function() 
        Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Velocity = Vector3.zero;
        Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(8, 23, -46);
    end
});

TeleportSection:AddButton({
    Name = "Teleport Far Away",
    Callback = function() 
        Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Velocity = Vector3.zero;
        Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(10000, 10000, -10000);

        -- Change camera rotation so you're looking at the house
        local CameraPos = workspace.CurrentCamera.CFrame.Position;
        local HouseLookAt = Vector3.new(-0, 28, 83);

        workspace.CurrentCamera.CFrame = CFrame.new(CameraPos, HouseLookAt);
    end
});


local RenderingTab = Window:MakeTab({Name = "Rendering"});
local MiscellaneousSection = RenderingTab:AddSection({Name = "Miscellaneous"});
local NoCrashSection = RenderingTab:AddSection({Name = "No Crash"});

MiscellaneousSection:AddButton({
    Name = 'Unrender Parts (Client)',
    Callback = UnrenderExtraParts
});

MiscellaneousSection:AddButton({
    Name = 'Remove Obby',
    Callback = function() 
        pcall(function()
            workspace.SecureParts.Lava:Destroy(); 
        end);
    end
});

NoCrashSection:AddToggle({
    Name = "Unrender Lag Machines",
    Default = false,
    Save = true,
    Flag = "NoLagMachines",
    Callback = UnrenderLagMachines
});

NoCrashSection:AddToggle({
    Name = "Remove Meshes (Client)",
    Default = false,
    Save = true,
    Flag = "NoMeshes",
    Callback = NoMeshes
});

NoCrashSection:AddToggle({
    Name = "Prevent TextKick",
    Default = false,
    Save = true,
    Flag = "NoTextKick",
    Callback = NoTextKick
});

local WSCheckEvent
function LimitWorkspace(state)
    local WSLimit = 50;

    local function FilterPart(v)
        if v.Name == "SecureParts" or v.Name == "Terrain" then
            return false;
        end
        
        if v:IsA("Model") and (Players:GetPlayerFromCharacter(v) or Players:GetPlayerFromCharacter( v:FindFirstChildOfClass( "Model"))) then
            return false;
        end

        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Folder") then
            return true;
        end
    end

    if typeof(WSCheckEvent) == "RBXScriptConnection" and WSCheckEvent.Connected then
        WSCheckEvent:Disconnect();
    end

    if not state then return; end

    local WSParts = {};

    for _, v in pairs(workspace:GetChildren()) do
        if not FilterPart(v) then  continue; end

        table.insert(WSParts, v);
        if #WSParts < WSLimit then continue; end
        
        spawn(function() v:Destroy() end);
    end

    WSCheckEvent = workspace.ChildAdded:Connect(function(child)
        table.clear(WSParts);
        for _, v in pairs(workspace:GetChildren()) do
            if not FilterPart(v) then continue; end
    
            table.insert(WSParts, v);
            if #WSParts < WSLimit then continue; end
            
            spawn(function() v:Destroy() end);
        end
    end);
end
NoCrashSection:AddToggle({
    Name = "Limit Workspace Size",
    Default = false, 
    Callback = LimitWorkspace
});


local ServerTab = Window:MakeTab({Name = "Server Exploits"});
local ServerSection = ServerTab:AddSection({Name = "Server Connection"});
local LagSection = ServerTab:AddSection({Name = "LagMachine"});

ServerSection:AddButton({
    Name = 'Delete Parts (F3X)',
    Callback = DeleteF3XExtraParts
});

function ServerRejoin()
    local JobId = game.JobId;
    local PlaceId = game.PlaceId;

    if #Players:GetPlayers() <= 1 then
        Players.LocalPlayer:Kick("Rejoining...");
        task.wait();
        TeleportService:Teleport(PlaceId, Players.LocalPlayer);
    end

    TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer);
end
ServerSection:AddButton({
    Name = 'Rejoin Server',
    Callback = ServerRejoin
});

function ServerHop(JoinFull) -- The variable is to determine if you should join the server with the most people, or the one with the least
    if not HttpRequest then
        NotifyPlr("Your exploit does not support http requests. Please use KRNL or SynapseX.");
    end

    local JobId = game.JobId;
    local PlaceId = game.PlaceId;

    local servers = {};
    local req = HttpRequest({Url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", PlaceId)});
    local body = HttpService:JSONDecode(req.Body);

    if not(body or body.data) then
        return;
    end

    for _, v in next, body.data do
        if typeof(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
            table.insert(servers, v.id);
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer);
    else
        return NotifyPlr("No servers were found");
    end
end
ServerSection:AddButton({
    Name = 'Server Hop',
    Callback = ServerHop
});

ServerSection:AddButton({
    Name = "Join \"Admin House!\"",
    Callback = function() 
        TeleportService:Teleport(333164326, Players.LocalPlayer)
    end
})

local AntiPlayerEvent
function AntiPlayer(state)
    if not (writefile and readfile and isfile) then
        return;
    end 

    if typeof(AntiPlayerEvent) == "RBXScriptConnection" and AntiPlayerEvent.Connected then
        AntiPlayerEvent:Disconnect();
    end

    if not state then return; end

    Players.PlayerAdded:Connect(function(plr) 
        if not isfile(AntiPlayerFilePath) then
            return;
        end

        local players = readfile(AntiPlayerFilePath);
        
        if not string.match(players, plr.Name) then
            print("New player not found")
            return;
        end

        CrashPlayer(plr.Name);
    end);
end
if writefile and readfile and isfile then
    LagSection:AddToggle({
        Name = 'Anti Player',
        Default = true,
        Callback = AntiPlayer
    });
end

LagSection:AddButton({
    Name = 'Create Lag Machine',
    Callback = CreateLagMachine
});

function CreateLagWaypoint()
    -- Stopping if LagMachine is already loaded
    if IsLMLoaded() then
        NotifyPlr("LagMachine is loaded, please unrender it using Delete Parts (Client) or Delete Parts (F3X)");
        return;
    end

    -- Prevent "LockCamera" from affecting this
    CameraModuleValue = LockCameraToggle.Value;
    LockCameraToggle:Set(false);

    local TemporaryCamera = Instance.new("Part");
    TemporaryCamera.CanCollide = false;
    TemporaryCamera.Anchored = true;
    TemporaryCamera.Transparency = 1;
    TemporaryCamera.CFrame = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart", math.huge).CFrame;
    TemporaryCamera.Parent = workspace;

    GetAdmin();

    local TeleportEvent = RunService.Stepped:Connect(function() 
        workspace.Camera.CameraSubject = TemporaryCamera;
        Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart", math.huge).Velocity = Vector3.zero;
        Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart", math.huge).CFrame = CFrame.new(850000, 800000, 850000);
    end);

    local AddedEvent
    local MayReturn
    AddedEvent = Players.LocalPlayer.PlayerGui.DescendantAdded:Connect(function(desc)
        if not desc:IsA('TextLabel') then return; end

        if desc.Text:match("Made waypoint") or desc.Text:match("Set waypoint") then
            MayReturn = true;
            AddedEvent:Disconnect();
        end
    end)

    task.spawn(function()
        repeat 
            runc(":waypoint AHG_crash", false);
            task.wait(3);
        until MayReturn
    end);

    repeat task.wait(); until MayReturn

    TeleportEvent:Disconnect();
    Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart", math.huge).CFrame = TemporaryCamera.CFrame;
    TemporaryCamera:Destroy();

    workspace.Camera.CameraSubject = Players.LocalPlayer.Character:WaitForChild("Humanoid", math.huge);
    LockCameraToggle:Set(CameraModuleValue);
end
LagSection:AddButton({
    Name = 'Create Lag Waypoint',
    Callback = CreateLagWaypoint
});


local SettingsTab = Window:MakeTab({Name = "Settings"});

local AntiPlayerList;
function UpdatePlayerList()
    if not AntiPlayerList then
        return;
    end

    if not (isfile and isfile(AntiPlayerFilePath)) then
        AntiPlayerList:Set('');
        return;
    end

    local players = readfile(AntiPlayerFilePath);
    AntiPlayerList:Set(players);
end

function AddPlayer(plr)
    if not (readfile and writefile and isfile) then
        return;
    end

    if players == '' then
        return;
    end

    local FileExists = isfile(AntiPlayerFilePath);

    if not FileExists then
        writefile(AntiPlayerFilePath, plr);
        UpdatePlayerList();
        return;
    end
    
    local players = readfile(AntiPlayerFilePath);

    if string.match(players, plr) then
        return;
    end

    appendfile(AntiPlayerFilePath, '\n'..plr);
    UpdatePlayerList();
end

if writefile and readfile and isfile and delfile then
    local AntiPlayerSection = SettingsTab:AddSection({Name = "Anti Player"});

    AntiPlayerSection:AddTextbox({
        Name = "Add Player",
        Default = "",
        TextDisapear = false,
        Callback = AddPlayer
    });
    AntiPlayerList = AntiPlayerSection:AddParagraph("Banned Players", "");
    
    AntiPlayerSection:AddButton({
        Name = "Clear Players",
        Callback = function() 
            if isfile(AntiPlayerFilePath) then
                delfile(AntiPlayerFilePath);
                UpdatePlayerList();
            end
        end
    });

    UpdatePlayerList();
end


local KeybindsSection = SettingsTab:AddSection({Name = "Keybinds"});

KeybindsSection:AddBind({
    Name = "Toggle Fly Noclip",
    Default = Enum.KeyCode.R,
    Hold = false,
    Callback = function()
        FlyToggle:Set(not FlyToggle.Value);
        NoclipToggle:Set(not NoclipToggle.Value);
    end
});

KeybindsSection:AddBind({
    Name = "Hold Player Far Away",
    Default = Enum.KeyCode.F,
    Hold = true,
    Callback = ToggleLock
});


OrionLib:Init();

--[[
    Transform this script into a github project (Learn how to), so that you can add libraries like "Player State or Admin Library", so that the code is less long\
    Transform "Limit Workspace" into something that keeps f3x with you and deletes any newly added parts (except players) in order to try to prevent server crashes

    DeletePartsF3X doesn't work on the BuildingBlocks (It does, it's just glitched on the Admin House, see if you can fix that) [Havent been able to replicate that]
    For some reason in the actual game, some GetDescendants values ignore some lag machines, see if you can try to fix it [Havent been able to replicate that]
    Take a look at the methods of string and table(table.clear, etc)
    Fix your bookmarks

    If you feel like it, and have the time, you can try to make the AdminHouse Replica work

    Ideas:
    Crash Server Idea: Running a command like "loadb" so many times at once that the server can't keep up and crashes
    ":talk others something" will make players send a message, could be used for crashing others
    You can also try to make the Humanoid LongText crash a button on the GUI
    Use the first idea for the CMDBOX crasher (start listening to remotes, run :cmdbox, press execute, grab the remote given and get
    the key, with that you can run any command you want)
    God I'm dumb, ok... sigh... use cmdbox to make your name huge, instead of using chat ya know...
    See if I can connect the cmdbox's button to the function it runs, doing that might bring us the result we need to get that value
    firesignal(ButtonPath.MouseButton1Down) clicks a gui button for you
]]--
