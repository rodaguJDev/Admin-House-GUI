-- Calling from AH Network
function CallF3X(...)
    local Backpack = Players.LocalPlayer.Backpack;
    local ToolInChar = Players.LocalPlayer.Character:FindFirstChild("Building Tools");

    if ToolInChar then 
        ToolInChar.Parent = Backpack; 
    end

    while not Backpack:WaitForChild("Building Tools", 2) do
        ToolInChar = Players.LocalPlayer.Character:FindFirstChild("Building Tools");
        if ToolInChar then 
            ToolInChar.Parent = Backpack; 
            continue;
        end
        
        runc(':free|:f3x', true);
    end

    return Backpack.Folder.SyncAPI.ServerEndpoint:InvokeServer(...)
end

function CallBuildNetwork(...)
    local BuildSave = ReplicatedStorage:FindFirstChild("Network");
    BuildSave = ReplicatedStorage:FindFirstChild("Network");
    BuildSave = BuildSave:FindFirstChild("BuildSaving");

    if not BuildSave then return; end

    return BuildSave:InvokeServer(...);
end

-- Crashing
function IsLMLoaded()
    local LMPos = CFrame.new(850000, 800000, 850000);

    -- The dummy is used to detect if there are multiple parts touching it
    local dummy = Instance.new("Part");
    dummy.Anchored = true;
    dummy.CFrame = LMPos;
    dummy.Size = Vector3.new(8, 8, 8);
    dummy.Parent = workspace;

    local LMState = if #workspace:GetPartsInPart(dummy) > 4 then true else false
    
    dummy:Destroy();
    return LMState;
end

function LoadLagMachine(CheckBuild)
    if not CheckBuild then
        for _ = 1, 3 do
            CallBuildNetwork({"LOAD", "AHG_crash"});
        end
        return;
    end

    local BuildExists = false;
    local Builds = CallBuildNetwork({"GET"});
    
    for build, _ in pairs(Builds) do
        if build == "AHG_crash" then BuildExists = true; break; end
    end

    if not BuildExists then
        NotifyPlr("The Crash Build does not exist, please execute 'Create Lag Machine' in the Server Exploits tab.");
        return false;
    end
    
    for _ = 1, 3 do
        CallBuildNetwork({"LOAD", "AHG_crash"});
    end
    NotifyPlr("Lag Machine Loaded");
end

function CrashPlayer(plr, Dropdown)
    NotifyPlr("WARNING: IF YOU DIDN'T RUN \"Create Waypoint\" OR \"Create Lag Machine\" BEFORE YOU MIGHT NOT CRASH THE PLAYER AND JUST JAIL HIM");
    if Dropdown then Dropdown:Set(''); end

    -- Special exceptions
    if plr == '' then
        return;
    end

    if plr == Players.LocalPlayer.Name then
        Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart", math.huge).CFrame = CFrame.new(850000, 800300, 850000);
        return;
    end


    local CMD;
    local DisconnectEvent;
    local PlayerDisconnected;

    CMD = ':free PLR|:re PLR|:unview PLR|:fov PLR 0|:tp PLR waypoint-AHG_crash|:jail PLR';
    CMD = string.gsub(CMD, 'PLR', plr);

    NotifyPlr("Crashing "..plr);
    runc(CMD, true);
    LoadLagMachine();

    -- Reset the player if he isn't crashed quickly enough.
    local NewCMD = string.gsub(':free PLR|:tp PLR waypoint-AHG_crash|:jail PLR', 'PLR', plr);
    if not Players:FindFirstChild(plr) then
        return;
    end
    PlayerDisconnected = false;

    DisconnectEvent = Players.PlayerRemoving:Connect(function(player) 
        if player.Name ~= plr then
            return;
        end

        NotifyPlr("The player has Disconnected.");
        runc(':unloadb', true);
        PlayerDisconnected = true;
        DisconnectEvent:Disconnect();
    end);

    for _ = 1, 3 do
        task.wait(6);
        if PlayerDisconnected then break; end
        runc(NewCMD, true);
        LoadLagMachine();
    end
end

function CreateLagMachine()
    local builds = CallBuildNetwork({"GET"});
    local BuildExists;

    for build, _ in pairs(builds) do
        if build == "AHG_crash" then
            BuildExists = true;
            LoadLagMachine(false);
            break;
        end
    end

    if BuildExists then
        NotifyPlr("The build already exists, creating it through save and load");
        return;
    end

    local LagMachinePos = CFrame.new(850000, 800000, 850000);

    local MainPart = CallF3X("CreatePart", "Normal", LagMachinePos, workspace);
    CallF3X("SyncMaterial", {
        {
            ["Part"] = MainPart,
            ["Material"] = Enum.Material.Plastic,
            ["Reflectance"] = 1
        }
    });

    CallF3X("CreateMeshes", {
        {
            ["Part"] = MainPart
        }
    });

    CallF3X("SyncMesh", {
        {
            ["Part"] = MainPart,
            ["MeshType"] = Enum.MeshType.FileMesh,
            ["Scale"] = Vector3.new(0.75, 0.75, 0.75),
            ["Offset"] = Vector3.new(0, 0, 0),
            ["MeshId"] = "rbxassetid://8299534208"
        }
    });

    local PartsToClone = {MainPart};
    local ClonedParts
    for _ = 1, 9 do
        ClonedParts = CallF3X("Clone", PartsToClone, workspace);

        for _, v in pairs(ClonedParts) do
            table.insert(PartsToClone, v);
        end
    end

    CallBuildNetwork({"SAVE", "AHG_crash", ClonedParts});
    
    NotifyPlr("Lag Machine Loaded.");
end

local CheckHumanoidEvent
function NoTextKick(state) -- Needs Testing
    if typeof(CheckHumanoidEvent) == "RBXScriptConnection" and CheckHumanoidEvent.Connected then
        CheckHumanoidEvent:Disconnect();
    end

    if not state then return; end

    CheckHumanoidEvent = workspace.DescendantAdded:Connect(function(desc) 
        if not desc:IsA("Humanoid") then
            return;
        end

        if desc:FindFirstAncestor("SecureParts") then
            return;
        end

        if Players:GetPlayerFromCharacter(desc.Parent) then
            desc.DisplayName = ''
            desc.Parent.Name = Players:GetPlayerFromCharacter(desc.Parent).Name
            return;
        end

        desc.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end);

    for _, desc in pairs(workspace:GetDescendants()) do
        if not desc:IsA("Humanoid") then
            continue;
        end

        if desc:FindFirstAncestor("SecureParts") then
            continue;
        end

        if Players:GetPlayerFromCharacter(desc.Parent) then
            desc.DisplayName = ''
            desc.Parent.Name = Players:GetPlayerFromCharacter(desc.Parent).Name
            continue;
        end

        desc.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
end

local CheckMeshesEvent
function NoMeshes(state)
    if typeof(CheckMeshesEvent) == "RBXScriptConnection" and CheckMeshesEvent.Connected then
        CheckMeshesEvent:Disconnect();
    end

    if not state then return; end

    CheckMeshesEvent = workspace.DescendantAdded:Connect(function(desc) 
        if not desc:IsA("SpecialMesh") then
            return;
        end

        if Players:GetPlayerFromCharacter(desc:FindFirstAncestorOfClass("Model")) then
            return;
        end

        if desc:FindFirstAncestor("SecureParts") then
            return;
        end

        spawn(function() desc:Destroy(); end);
    end);

    for _, desc in pairs(workspace:GetDescendants()) do
        if not desc:IsA("SpecialMesh") then
            continue;
        end

        if Players:GetPlayerFromCharacter(desc:FindFirstAncestorOfClass("Model")) then
            return;
        end

        if desc:FindFirstAncestor("SecureParts") then
            continue;
        end

        desc:Destroy();
    end
end

local UnrenderLMEvent
function UnrenderLagMachines(state) 
    local TouchingPartLimit = 100;
    
    if typeof(UnrenderLMEvent) == "RBXScriptConnection" and UnrenderLMEvent.Connected then
        UnrenderLMEvent:Disconnect();
    end

    if not state then return; end

    local function PartIsFromPlayer(instance)
        if instance.Parent == nil then return false; end

        local isPlayer = if Players:GetPlayerFromCharacter(instance) then true else false

        if isPlayer then
            return true;
        end
        
        return instance ~= workspace and PartIsFromPlayer(instance.Parent) or false
    end

    local function GetDescendantsOfClass(object, class)
        local descendants = object:GetDescendants();
        local DescOfClass = {};

        for _, desc in pairs(descendants) do
            if desc.ClassName == class then table.insert(DescOfClass, desc); end
        end

        return DescOfClass;
    end

    local function IsInstanceValid(instance)
        if instance == nil then
            return false;
        end

        if not instance:IsA("BasePart") or instance.Name == 'Terrain' then
            return false;
        end

        if PartIsFromPlayer(instance) then
            return false;
        end

        if instance:FindFirstAncestor("SecureParts") then
            return false;
        end

        return true;
    end

    local function DeleteValidParts(parts)
        for _, part in pairs(parts) do
            if not IsInstanceValid(part) then continue; end

            part:Destroy();
        end
    end

    UnrenderLMEvent = workspace.DescendantAdded:Connect(function(desc) 
        if not IsInstanceValid(desc) then return; end
        
        local TouchingParts = workspace:GetPartsInPart(desc);
        if #TouchingParts >= TouchingPartLimit then 
            DeleteValidParts(TouchingParts);
        end
    end);

    for _, desc in pairs(workspace:GetDescendants()) do
        if not IsInstanceValid(desc) then continue; end
        
        local TouchingParts = workspace:GetPartsInPart(desc);
        if #TouchingParts >= TouchingPartLimit then 
            DeleteValidParts(TouchingParts);
        end
    end
end

function UnrenderExtraParts()
    for _, instance in pairs(workspace:GetChildren()) do
        if instance.Name == 'SecureParts' then continue; end

        if instance:IsA('BasePart') and instance.Name ~= 'Terrain' then
            instance:Destroy();
        end
    
        if instance:IsA("Folder") or instance:IsA('Model') and not Players:GetPlayerFromCharacter(instance) then
            instance:Destroy();
        end

    end
end

function DeleteF3XExtraParts()
    NotifyPlr("Exploits using f3x may not work properly, you might have to run it a couple of times.")

    local PartsToDelete = {};

    for _, instance in pairs(workspace:GetChildren()) do
        if instance:IsA("BasePart") and instance.Name ~= 'Terrain' then
            table.insert(PartsToDelete, instance);
        end

        if instance:IsA("Folder") then
            table.insert(PartsToDelete, instance);
        end

        if instance:IsA("Model") and Players:GetPlayerFromCharacter(instance) then
            continue;
        end

        if instance:IsA("Model") and instance.Name ~= 'SecureParts' then
            table.insert(PartsToDelete, instance);
        end

    end
    
    CallF3X("Remove", PartsToDelete);
end