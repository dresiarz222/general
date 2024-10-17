-- Hello and welcome to my globals list :)

while not game:IsLoaded() do
    task.wait()
end

type globals = {
    logService : LogService,
    plrs : Players,
    plr: Player,
    scriptContext: ScriptContext,
    uis : UserInputService,
    rs : ReplicatedStorage,
    rf : ReplicatedFirst,
    vim : VirtualInputManager,
    vu : VirtualUser,
    mouse : Mouse,
    httpService : HttpService,
    runService : RunService,
    tweenService : TweenService,
}

local d : globals = {} -- for roblox lsp code auto complete

d.doNothing = function() end
d.returnDummyFuncFunc = function() return function() end end
d.dummyfunc = function(...) return ... end
d.returnDummyTableFunc = function() return {} end

d.getgenv = getgenv or d.returnDummyTableFunc
d.clonefunction = clonefunction or d.returnDummyFuncFunc
d.cloneref = clonefunction(cloneref) or d.dummyfunc
local game = cloneref(game)
d.getconnections = clonefunction(getconnections)
d.hookfunction = clonefunction(hookfunction)
d.hookmetamethod = clonefunction(hookmetamethod)
d.scriptContext = cloneref(game:GetService("ScriptContext"))
d.isexecutorclosure = clonefunction(isexecutorclosure)
d.uis = cloneref(game:GetService("UserInputService"))
d.rs = cloneref(game:GetService("ReplicatedStorage"))
d.rf = cloneref(game:GetService("ReplicatedFirst"))
d.vim = cloneref(game:GetService("VirtualInputManager"))
d.logService = cloneref(game:GetService("LogService"))
d.plrs = cloneref(game:GetService("Players"))
d.plr = cloneref(d.plrs.LocalPlayer)
d.runService = cloneref(game:GetService("RunService"))
d.httpService = cloneref(game:GetService("HttpService"))
d.lighting = cloneref(game:GetService("Lighting"))
d.runService = cloneref(game:GetService("RunService"))
d.tweenService = cloneref(game:GetService("TweenService"))
d.httpService = cloneref(game:GetService("HttpService"))
d.tpService = cloneref(game:GetService("TeleportService"))
d.vu = cloneref(game:GetService("VirtualUser"))

d.mouse = d.plr:GetMouse()
d.screenX = d.mouse.ViewSizeX
d.uis.MouseIconEnabled = true

d.screenX = d.mouse.ViewSizeX
d.screenY = d.mouse.ViewSizeY

-- console metrics stuff (some games use this), this fucks up my debugging so i commented it out for now

--[[

for i,v in getconnections(d.logService.MessageOut) do
    if (v.Function and not d.isexecutorclosure(v.Function)) then -- if connection comes from executor then leave it alone
        v:Disable()
    end
end

for i,v in getconnections(d.scriptContext.Error) do
    if (v.Function and not d.isexecutorclosure(v.Function)) then
        v:Disable()
    end
end

]]--

-- console metrics end

local guiParent

function d.gethui() -- for dtc shitsploits that lack gethui() or have no coregui access
    
    if guiParent then -- if cached then just return that
        return guiParent
    end

    local s,r = pcall(function()
        return gethui()
    end)
    
    if s and r then
        guiParent = r
        return r
    end

    local s,r = pcall(function()
        return game:GetService("CoreGui")
    end)

    if s and r then
        guiParent = r
        return r
    end

    guiParent = d.plr.PlayerGui -- no coregui access means playergui is last resort, dtc asf 😔

    return guiParent

end

function d.antiAfk()

    for _,connection in getconnections(d.plr.Idled) do
        connection:Disable()
    end

    task.spawn(function()
        while task.wait(math.random(1,6)*10) do
            
            local randomNum = math.random(1,10)

            xpcall(function()
                d.vu:CaptureController()
                d.vu:ClickButton2(Vector2.new(d.screenX/2+randomNum,d.screenY+randomNum))
            end, function(...)
                warn("antiafk 1 fail", ...)
            end)
    
            xpcall(function()
                d.vu:Button2Down(Vector2.new(d.screenX/2+randomNum,d.screenY+randomNum),workspace.CurrentCamera.CFrame)
                task.wait(1)
                d.vu:Button2Up(Vector2.new(d.screenX/2+randomNum,d.screenY+randomNum),workspace.CurrentCamera.CFrame)
            end, function(...)
                warn("antiafk 2 fail", ...)
            end)

        end
    end)

end

function d.distance(pos1,pos2)
    return (pos2-pos1).Magnitude
end

function d.setPos(t) -- wrap in pcall t = {pos, tween, skipTweenWait, speed}

    if typeof(t.pos) == "Vector3" then
        t.pos = CFrame.new(t.pos)
    end

    if t.tween then

        local hrp = d.plr.Character.HumanoidRootPart
        
        local tweenInfo = TweenInfo.new(
            d.distance(hrp.Position,t.pos.Position)/t.speed,  
            Enum.EasingStyle.Linear,  
            Enum.EasingDirection.Out 
        )
        
        local goal = {
            CFrame = t.pos
        }
        
        local tween = d.tweenService:Create(hrp, tweenInfo, goal)

        tween:Play()
        
        if not t.skipTweenWait then
            tween.Completed:Wait()
            return
        end

        return tween


    else

        d.plr.Character.PrimaryPart.CFrame = t.pos
    end

end

function d.getChar(player)
    if not player then
        player = d.plr
    end
    return player.Character or player.CharacterAdded:Wait()
end

function d.getPos(player)
    if not player then
        player = d.plr
    end
    return (player.Character or player.CharacterAdded:Wait()) and player.Character.PrimaryPart.CFrame
end

function d.sendWebhook(link, jsonpayload) -- payload has to be json encoded
    local s, r = pcall(function()
        request({
            Url = link,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonpayload,
        })
    end)
    if not s then
        warn("webhook send failed", r)
    end
end

function d.optimize(t) -- t = {fps, clearTerrain}
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    settings().Rendering.QualityLevel = "1"
    
    if not t then
        t = {}
    end

    if t.fps then
        task.spawn(function()
            setfpscap(t.fps)
            while task.wait(1) do
                setfpscap(t.fps)
            end
        end)
    end

    if t.clearTerrain then
        workspace.Terrain:Clear()
    end

	sethiddenproperty(d.lighting,"Technology",2)
	sethiddenproperty(workspace.Terrain,"Decoration",false)
	workspace.Terrain.WaterWaveSize = 0
	workspace.Terrain.WaterWaveSpeed = 0
	workspace.Terrain.WaterReflectance = 0
	workspace.Terrain.WaterTransparency = 1
	d.lighting.GlobalShadows = 0
	d.lighting.FogEnd = 9e9
	d.lighting.Brightness = 0
    d.lighting.Brightness = 0
    d.lighting.GlobalShadows = false
    d.lighting.ShadowSoftness = 0
    d.lighting.EnvironmentDiffuseScale = 0
    d.lighting.EnvironmentSpecularScale = 0
end

xpcall(d.antiAfk,function(...) -- u pretty much always want antiafk
    warn("antiafk start failed", ...)
end)

return d
