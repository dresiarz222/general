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
}

local d : globals = {} -- for roblox lsp code auto complete

d.doNothing = function() end
d.returnDummyFuncFunc = function() return function() end end
d.dummyfunc = function(...) return ... end
d.returnDummyTableFunc = function() return {} end

-- COMPATIBILITY

d.getgenv = getgenv or d.returnDummyTableFunc
d.clonefunction = clonefunction or d.returnDummyFuncFunc
d.cloneref = clonefunction(cloneref) or d.dummyfunc
d.getconnections = clonefunction(getconnections) or d.returnDummyTableFunc
d.hookfunction = clonefunction(hookfunction) or d.returnDummyFuncFunc
d.hookmetamethod = clonefunction(hookmetamethod) or d.returnDummyFuncFunc
d.scriptContext = cloneref(game:GetService("ScriptContext"))
d.isexecutorclosure = clonefunction(isexecutorclosure)
d.uis = cloneref(game:GetService("UserInputService"))
d.rs = cloneref(game:GetService("ReplicatedStorage"))
d.rf = cloneref(game:GetService("ReplicatedFirst"))
d.vim = cloneref(game:GetService("VirtualInputManager"))
d.logService = cloneref(game:GetService("LogService"))

local guiParent

function d:gethui() -- for dtc shitsploits that lack gethui() or have no coregui access
    
    if guiParent then
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

    guiParent = d.plr.PlayerGui

    return guiParent

end

-- COMPATIBILITY END

-- anticheat stuff

for i,v in getconnections(d.logService.MessageOut) do
    if v.Function or (v.Function and not d.isexecutorclosure(v.Function)) then -- if connection comes from executor then leave it alone
        v:Disable()
    end
end

for i,v in getconnections(d.scriptContext.Error) do
    if v.Function or (v.Function and not d.isexecutorclosure(v.Function)) then
        v:Disable()
    end
end

-- ac end

d.plrs = cloneref(game:GetService("Players"))
d.plr = cloneref(d.plrs.LocalPlayer)

d.screenX = 1920 -- hardcoded cuz screengui absolute size was fking up
d.screenY = 1080

function d.antiAfk()

    for _,connection in getconnections(d.plr.Idled) do
        connection:Disable()
    end

    d.vu = cloneref(game:GetService("VirtualUser"))

    task.spawn(function()
        while task.wait(math.random(1,6)*10) do
            
            xpcall(function()
                d.vu:CaptureController()
                d.vu:ClickButton2(Vector2.new(math.random(0,d.screenX),math.random(0,d.screenY)))
            end, function(...)
                warn("antiafk 1 fail", ...)
            end)
    
            xpcall(function()
                d.vu:Button2Down(Vector2.new(math.random(0,d.screenX),math.random(0,d.screenY)),workspace.CurrentCamera.CFrame)
                task.wait(1)
                d.vu:Button2Up(Vector2.new(math.random(0,d.screenX),math.random(0,d.screenY)),workspace.CurrentCamera.CFrame)
            end, function(...)
                warn("antiafk 2 fail", ...)
            end)

        end
    end)

end

function d.distance(pos1,pos2)
    return (pos2-pos1).Magnitude
end

function d.setPos(pos: CFrame | Vector3)
    if typeof(pos) == "Vector3" then
        pos = CFrame.new(pos)
    end
    local s
    repeat task.wait() s = pcall(function() d.plr.Character.PrimaryPart.CFrame = pos end) until s
end

function d.getPos()
    local s, r
    repeat task.wait() s, r = pcall(function() return d.plr.Character.PrimaryPart.CFrame end) until s and r
    return r
end

xpcall(d.antiAfk,function(...) -- u pretty much always want antiafk
    warn("antiafk start failed", ...)
end)

return d -- for loadstring :)
