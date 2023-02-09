local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");
local Players = game:GetService("Players");

IsPerm = ReplicatedStorage.Network:WaitForChild("IsPerm", 5):InvokeServer() or false;


function GetAdmin()
    local HasAdmin
    if IsPerm then return; end

    local plrAdminName = Players.LocalPlayer.Name .. "'s admin";
    local currentCFrame = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart", math.huge).CFrame;
    local AdminPadPos = workspace.SecureParts.AdminPads:FindFirstChild("Touch to get admin").Head.CFrame;

    HasAdmin = if workspace.SecureParts.AdminPads:FindFirstChild(plrAdminName) then true else false
    if HasAdmin then return end

    repeat
        HasAdmin = if workspace.SecureParts.AdminPads:FindFirstChild(plrAdminName) then true else false
        Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart", math.huge).CFrame = AdminPadPos - Vector3.new(0, 2.6, 0);
        task.wait();
    until HasAdmin 

    Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart", math.huge).CFrame = currentCFrame;
end

function runc(cmd, getadmin)
    assert(typeof(getadmin) == "boolean", "Incorrect 'runc' usage");
    assert(typeof(cmd) == "string", "Incorrect 'runc' usage");

    local plrAdminName = Players.LocalPlayer.Name .. "'s admin";
    HasAdmin = if IsPerm or workspace.SecureParts.AdminPads:FindFirstChild(plrAdminName) then true else false
    if not HasAdmin and getadmin then
        GetAdmin();
    end
    
    Players:Chat(cmd);
end

function KeepAdmin(state) -- This is used for the toggle in the GUI
    local currentCFrame
    local AdminPadPos
    local function GetAdmin_event()
        HasAdmin = if IsPerm or workspace.SecureParts.AdminPads:FindFirstChild(plrAdminName) then true else false
        if HasAdmin and currentCFrame then 
            Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = currentCFrame;
            currentCFrame = nil;
        end

        if HasAdmin then
            return;
        end

        if currentCFrame == nil then
            currentCFrame = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame;
        end

        for _, child in pairs(Players.LocalPlayer.Character:GetDescendants()) do
            if child:IsA("BasePart") and child.CanCollide then
                child.CanCollide = false;
            end
        end

        AdminPadPos = workspace.SecureParts.AdminPads:FindFirstChild("Touch to get admin").Head.CFrame;
        Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = AdminPadPos - Vector3.new(0, 2.6, 0);
    end

    if typeof(KeepAdminEvent) == 'RBXScriptConnection' and KeepAdminEvent.Connected then
        KeepAdminEvent:Disconnect();
    end
    
    if state then
        KeepAdminEvent = RunService.Stepped:Connect(GetAdmin_event);
    end
end