-- Magnet Blocks Script
-- Puxa blocos soltos e empilha acima do personagem

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "MagnetGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 120)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.Text = "MAGNET BLOCKS"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(35,35,35)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0.85,0,0,40)
toggleBtn.Position = UDim2.new(0.075,0,0.45,0)
toggleBtn.Text = "ATIVAR"
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 14
toggleBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
toggleBtn.TextColor3 = Color3.new(1,1,1)

-- Configurações
local magnetOn = false
local heightOffset = 6
local spacing = 3
local controlledBlocks = {}

-- Função para pegar blocos soltos
local function getLooseBlocks()
    local blocks = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart")
        and not obj.Anchored
        and not obj:IsDescendantOf(character) then
            table.insert(blocks, obj)
        end
    end
    return blocks
end

-- Aplicar força para puxar bloco
local function magnetizeBlock(block, index)
    if controlledBlocks[block] then return end
    controlledBlocks[block] = true

    block.CanCollide = false

    local att = Instance.new("Attachment", block)

    local alignPos = Instance.new("AlignPosition", block)
    alignPos.Attachment0 = att
    alignPos.MaxForce = 50000
    alignPos.Responsiveness = 25
    alignPos.RigidityEnabled = false

    local alignOri = Instance.new("AlignOrientation", block)
    alignOri.Attachment0 = att
    alignOri.MaxTorque = 50000
    alignOri.Responsiveness = 25

    RunService.RenderStepped:Connect(function()
        if not magnetOn or not block or not block.Parent then
            alignPos:Destroy()
            alignOri:Destroy()
            att:Destroy()
            controlledBlocks[block] = nil
            return
        end

        local targetPos =
            humanoidRootPart.Position +
            Vector3.new(0, heightOffset + (index * spacing), 0)

        alignPos.Position = targetPos
    end)
end

-- Loop principal
task.spawn(function()
    while true do
        task.wait(1)
        if magnetOn then
            local blocks = getLooseBlocks()
            for i, block in ipairs(blocks) do
                magnetizeBlock(block, i)
            end
        end
    end
end)

-- Botão
toggleBtn.MouseButton1Click:Connect(function()
    magnetOn = not magnetOn
    toggleBtn.Text = magnetOn and "DESATIVAR" or "ATIVAR"

    if not magnetOn then
        for block, _ in pairs(controlledBlocks) do
            if block and block.Parent then
                block.CanCollide = true
            end
        end
        controlledBlocks = {}
    end
end)
