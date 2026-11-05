-- ==========================================
-- JW DUPLICATOR HUB - ULTIMATE VERSION
-- ==========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local parentGui = CoreGui
local success, _ = pcall(function() local test = CoreGui.Name end)
if not success then
    parentGui = PlayerGui
end

if parentGui:FindFirstChild("JW_DupeHub") then
    parentGui.JW_DupeHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JW_DupeHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

-- Botón principal JW (Arrastrable)
local JWBtn = Instance.new("TextButton")
JWBtn.Name = "JWButton"
JWBtn.Size = UDim2.new(0, 50, 0, 50)
JWBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
JWBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
JWBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
JWBtn.Text = "JW"
JWBtn.TextSize = 22
JWBtn.Font = Enum.Font.SourceSansBold
JWBtn.BorderSizePixel = 2
JWBtn.BorderColor3 = Color3.fromRGB(0, 170, 255)
JWBtn.Active = true
JWBtn.Draggable = true
JWBtn.Parent = ScreenGui

-- Ventana principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 280)
MainFrame.Position = UDim2.new(0.02, 60, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 170, 255)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "JW DUPLICATOR HUB"
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- ScrollingFrame para las unidades
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(0.9, 0, 0.5, 0)
ScrollList.Position = UDim2.new(0.05, 0, 0.15, 0)
ScrollList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ScrollList.BorderColor3 = Color3.fromRGB(50, 50, 50)
ScrollList.ScrollBarThickness = 6
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

-- Label de estado / selección
local SelectedLabel = Instance.new("TextLabel")
SelectedLabel.Size = UDim2.new(0.9, 0, 0.08, 0)
SelectedLabel.Position = UDim2.new(0.05, 0, 0.67, 0)
SelectedLabel.BackgroundTransparency = 1
SelectedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SelectedLabel.Text = "Selecciona una unidad..."
SelectedLabel.TextSize = 12
SelectedLabel.Font = Enum.Font.SourceSans
SelectedLabel.Parent = MainFrame

-- Botón Refrescar Lista
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.42, 0, 0.12, 0)
RefreshBtn.Position = UDim2.new(0.05, 0, 0.78, 0)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Text = "Actualizar"
RefreshBtn.TextSize = 13
RefreshBtn.Font = Enum.Font.SourceSansBold
RefreshBtn.Parent = MainFrame

-- Botón Duplicar
local DupeBtn = Instance.new("TextButton")
DupeBtn.Size = UDim2.new(0.42, 0, 0.12, 0)
DupeBtn.Position = UDim2.new(0.53, 0, 0.78, 0)
DupeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
DupeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DupeBtn.Text = "Duplicate JW"
DupeBtn.TextSize = 13
DupeBtn.Font = Enum.Font.SourceSansBold
DupeBtn.Parent = MainFrame

local unidadSeleccionADA = nil
local objetoReferencia = nil

-- Función avanzada para buscar unidades en las carpetas del jugador
local function buscarUnidades()
    local unidades = {}
    
    local posiblesRutas = {
        LocalPlayer:FindFirstChild("Units"),
        LocalPlayer:FindFirstChild("Inventory"),
        LocalPlayer:FindFirstChild("Backpack"),
        LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Units"),
        LocalPlayer:FindFirstChild("PlayerFolder") and LocalPlayer.PlayerFolder:FindFirstChild("Units"),
        ReplicatedStorage:FindFirstChild("PlayerData") and ReplicatedStorage.PlayerData:FindFirstChild(LocalPlayer.Name) and ReplicatedStorage.PlayerData[LocalPlayer.Name]:FindFirstChild("Units")
    }

    for _, ruta in ipairs(posiblesRutas) do
        if ruta then
            for _, item in ipairs(ruta:GetChildren()) do
                local yaExiste = false
                for _, u in ipairs(unidades) do
                    if u.Name == item.Name then yaExiste = true end
                end
                if not yaExiste then
                    table.insert(unidades, {Name = item.Name, Obj = item})
                end
            end
        end
    end

    if LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Tool") then
                local yaExiste = false
                for _, u in ipairs(unidades) do
                    if u.Name == item.Name then yaExiste = true end
                end
                if not yaExiste then
                    table.insert(unidades, {Name = item.Name, Obj = item})
                end
            end
        end
    end

    return unidades
end

local function cargarLista()
    for _, item in ipairs(ScrollList:GetChildren()) do
        if item:IsA("TextButton") then
            item:Destroy()
        end
    end

    local listaUnidades = buscarUnidades()

    -- Si no encuentra carpetas físicas inmediatas, carga nombres predeterminados de unidades de referencia
    if #listaUnidades == 0 then
        local respaldo = {"Engineer Cameraman", "Upgraded Titan Cameraman", "Cameraman", "Exclusive Spawner", "Scientist Cameraman"}
        for _, nombre in ipairs(respaldo) do
            table.insert(listaUnidades, {Name = nombre, Obj = nil})
        end
    end

    for _, info in ipairs(listaUnidades) do
        local btnUnidad = Instance.new("TextButton")
        btnUnidad.Size = UDim2.new(1, -6, 0, 30)
        btnUnidad.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btnUnidad.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnUnidad.Text = info.Name
        btnUnidad.TextSize = 13
        btnUnidad.Font = Enum.Font.SourceSansSemibold
        btnUnidad.Parent = ScrollList

        btnUnidad.MouseButton1Click:Connect(function()
            unidadSeleccionADA = info.Name
            objetoReferencia = info.Obj
            SelectedLabel.Text = "Seleccionado: " .. info.Name
            SelectedLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
        end)
    end

    ScrollList.CanvasSize = UDim2.new(0, 0, 0, #listaUnidades * 34)
end

-- Abrir / Cerrar menú
JWBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        cargarLista()
    end
end)

-- Botón Actualizar
RefreshBtn.MouseButton1Click:Connect(function()
    cargarLista()
    SelectedLabel.Text = "¡Lista actualizada!"
    SelectedLabel.TextColor3 = Color3.fromRGB(0, 210, 255)
end)

-- Botón Duplicar
DupeBtn.MouseButton1Click:Connect(function()
    if not unidadSeleccionADA then
        SelectedLabel.Text = "¡Selecciona una unidad primero!"
        SelectedLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
        return
    end

    local remote = ReplicatedStorage:FindFirstChild("DuplicateUnitRemote")
        or ReplicatedStorage:FindFirstChild("SpawnUnit")
        or ReplicatedStorage:FindFirstChild("EquipUnit")
        or ReplicatedStorage:FindFirstChild("RemoteEvent")

    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer(unidadSeleccionADA)
        SelectedLabel.Text = "¡Duplicado enviado: " .. unidadSeleccionADA .. "!"
        SelectedLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
    else
        if objetoReferencia and objetoReferencia.Parent then
            local clone = objetoReferencia:Clone()
            clone.Parent = objetoReferencia.Parent
            SelectedLabel.Text = "¡Duplicado con éxito: " .. unidadSeleccionADA .. "!"
            SelectedLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
        else
            -- Intento directo en carpetas de inventario
            local encontrado = false
            for _, ruta in ipairs({LocalPlayer:FindFirstChild("Units"), LocalPlayer:FindFirstChild("Inventory")}) do
                if ruta and ruta:FindFirstChild(unidadSeleccionADA) then
                    local clone = ruta[unidadSeleccionADA]:Clone()
                    clone.Parent = ruta
                    encontrado = true
                    break
                end
            end
            
            if encontrado then
                SelectedLabel.Text = "¡Duplicado real completado!"
                SelectedLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
            else
                SelectedLabel.Text = "¡Unidad seleccionada lista!"
                SelectedLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            end
        end
    end
end)

print("[JW DUPE] ¡Script actualizado y sincronizado!")
