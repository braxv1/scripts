-- brax's esp library
-- Version: 1.1 (Auto Team Color Update)

local ESP = {
    Enabled = true,
    TeamCheck = false,
    AutoTeamColor = true, -- basically uses the provided team color directly from the game
    
    -- some features
    Boxes = true,
    BoxOutline = true,
    HealthBar = true,
    Names = true,
    Distance = true,
    Tool = true,
    HeadCircle = true,
    
    -- visuals
    Colors = {
        Team = Color3.fromRGB(0, 255, 100), 
        enemy = Color3.fromRGB(255, 50, 50),
        Text = Color3.fromRGB(255, 255, 255)
    }, -- will get override if useteamcolor is on
    
    -- don't touch this
    Objects = {}
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function Drawesp(Player)
    local obj = {
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        HealthBarBg = Drawing.new("Line"),
        HealthBar = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Info = Drawing.new("Text"),
        HeadCircle = Drawing.new("Circle")
    }

    obj.BoxOutline.Thickness = 3
    obj.BoxOutline.Color = Color3.new(0, 0, 0)
    obj.HealthBarBg.Thickness = 4
    obj.HealthBarBg.Color = Color3.new(0, 0, 0)
    obj.Box.Thickness = 1
    obj.HealthBar.Thickness = 2
    obj.Name.Size = 14
    obj.Name.Center = true
    obj.Name.Outline = true
    obj.Info.Size = 13
    obj.Info.Center = true
    obj.Info.Outline = true
    obj.HeadCircle.Thickness = 1
    obj.HeadCircle.NumSides = 12

    ESP.Objects[Player] = obj
end

function ESP:Init()
    -- old guys
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then Drawesp(p) end
    end

    -- new guys
    Players.PlayerAdded:Connect(function(p)
        if p ~= LocalPlayer then Drawesp(p) end
    end)

    -- remove on leave
    Players.PlayerRemoving:Connect(function(p)
        if self.Objects[p] then
            for _, v in pairs(self.Objects[p]) do v:Remove() end
            self.Objects[p] = nil
        end
    end)

    -- loop
    RunService.RenderStepped:Connect(function()
        for Player, Visuals in pairs(self.Objects) do
            local Char = Player.Character
            local Root = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChild("Humanoid")
            local Head = Char and Char:FindFirstChild("Head")

            if self.Enabled and Char and Root and Hum and Head and Hum.Health > 0 then
                local _, onScreen = Camera:WorldToViewportPoint(Root.Position)

                if onScreen then
                    local Orientation, Size = Char:GetBoundingBox()
                    local Top = Camera:WorldToViewportPoint((Orientation * CFrame.new(0, Size.Y/2, 0)).Position)
                    local Bottom = Camera:WorldToViewportPoint((Orientation * CFrame.new(0, -Size.Y/2, 0)).Position)
                    
                    local boxHeight = math.abs(Top.Y - Bottom.Y)
                    local boxWidth = boxHeight / 1.8
                    local boxPos = Vector2.new(Top.X - boxWidth/2, Top.Y)

                    -- team
                    local isTeammate = (Player.Team == LocalPlayer.Team)
                    if self.TeamCheck and isTeammate then
                        for _, v in pairs(Visuals) do v.Visible = false end
                        continue
                    end

                    -- auto color
                    local color = self.Colors.enemy
                    if self.AutoTeamColor then
                        color = Player.TeamColor.Color
                    else
                        color = isTeammate and self.Colors.Team or self.Colors.enemy
                    end

                    -- box
                    Visuals.Box.Visible = self.Boxes
                    Visuals.BoxOutline.Visible = self.Boxes and self.BoxOutline
                    if self.Boxes then
                        Visuals.Box.Size = Vector2.new(boxWidth, boxHeight)
                        Visuals.Box.Position = boxPos
                        Visuals.Box.Color = color
                        Visuals.BoxOutline.Size = Visuals.Box.Size
                        Visuals.BoxOutline.Position = Visuals.Box.Position
                    end

                    -- head circle
                    Visuals.HeadCircle.Visible = self.HeadCircle
                    if self.HeadCircle then
                        local headPos = Camera:WorldToViewportPoint(Head.Position)
                        Visuals.HeadCircle.Position = Vector2.new(headPos.X, headPos.Y)
                        Visuals.HeadCircle.Radius = math.clamp(boxHeight / 10, 2, 100)
                        Visuals.HeadCircle.Color = color
                    end

                    -- hp
                    Visuals.HealthBar.Visible = self.HealthBar
                    Visuals.HealthBarBg.Visible = self.HealthBar
                    if self.HealthBar then
                        local hp = math.clamp(Hum.Health / Hum.MaxHealth, 0, 1)
                        local barX = boxPos.X - 6
                        Visuals.HealthBarBg.From = Vector2.new(barX, boxPos.Y + boxHeight)
                        Visuals.HealthBarBg.To = Vector2.new(barX, boxPos.Y)
                        Visuals.HealthBar.From = Visuals.HealthBarBg.From
                        Visuals.HealthBar.To = Vector2.new(barX, (boxPos.Y + boxHeight) - (boxHeight * hp))
                        Visuals.HealthBar.Color = Color3.new(1, 0, 0):Lerp(Color3.new(0, 1, 0), hp)
                    end

                    -- texts
                    Visuals.Name.Visible = self.Names
                    if self.Names then
                        Visuals.Name.Text = Player.Name
                        Visuals.Name.Position = Vector2.new(boxPos.X + boxWidth/2, boxPos.Y - 18)
                        Visuals.Name.Color = self.Colors.Text
                    end

                    local showInfo = self.Distance or self.Tool
                    Visuals.Info.Visible = showInfo
                    if showInfo then
                        local dist = math.floor((Camera.CFrame.Position - Root.Position).Magnitude)
                        local tool = Char:FindFirstChildOfClass("Tool")
                        local str = ""
                        if self.Distance then str = str .. "[" .. dist .. "m] " end
                        if self.Tool then str = str .. (tool and tool.Name or "None") end
                        Visuals.Info.Text = str
                        Visuals.Info.Position = Vector2.new(boxPos.X + boxWidth/2, boxPos.Y + boxHeight + 2)
                    end
                    continue
                end
            end
            for _, v in pairs(Visuals) do v.Visible = false end
        end
    end)
end

return ESP
