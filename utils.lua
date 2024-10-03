-- Hello and welcome to my globals list :)

-- COMPATIBILITY

local doNothing = function() end
local dummyReturnFuncFunc = function() return function() end end
local dummyfunc = function(...) return ... end
local dummyReturnTableFunc = function() return {} end

local getgenv = clonefunction(getgenv) or dummyReturnTableFunc
local clonefunction = getgenv().clonefunction or dummyfunc
local cloneref = clonefunction(getgenv().cloneref) or dummyfunc
local getconnections = clonefunction(getgenv().getconnections) or dummyReturnTableFunc
local hookfunction = clonefunction(getgenv().hookfunction) or dummyReturnFuncFunc
local hookmetamethod = clonefunction(getgenv().hookmetamethod) or dummyReturnFuncFunc
local scriptContext:ScriptContext = cloneref(game:GetService("ScriptContext"))

-- COMPATIBILITY END

local logService:LogService = cloneref(game:GetService("LogService"))

-- anticheat stuff

--[[
for i,v in getconnections(scriptContext.Error) do
    xpcall(function()
        v:Disable()
    end,warn)
end
]]---


-- ac end

local d = {}

d.plrs = cloneref(game:GetService("Players"))
d.plr = cloneref(d.plrs.LocalPlayer)

local _ = Instance.new("ScreenGui").AbsoluteSize

d.screenX = _.X
d.screenY = _.Y

function d:antiAfk()

    for _,connection:RBXScriptConnection in getconnections(d.plr.Idled) do
        connection:Disable()
    end

    local vu:VirtualUser = cloneref(game:GetService("VirtualUser"))

    task.spawn(function()
        while task.wait(math.random(1,6)*100) do
            
            xpcall(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new(math.random(0,d.screenX),math.random(0,d.screenY)))
            end, function(...)
                warn("antiafk 1 fail", ...)
            end)
    
            xpcall(function()
                vu:Button2Down(Vector2.new(math.random(0,d.screenX),math.random(0,d.screenY)),workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(math.random(0,d.screenX),math.random(0,d.screenY)),workspace.CurrentCamera.CFrame)
            end, function(...)
                warn("antiafk 2 fail", ...)
            end)

        end
    end)

end

function d:distance(pos1,pos2)
    return (pos2-pos1).Magnitude
end

function d:setPos(pos: CFrame | Vector3)
    if typeof(pos) == "Vector3" then
        pos = CFrame.new(pos)
    end
    local s
    repeat task.wait() s = pcall(function() d.plr.Character.PrimaryPart.CFrame = pos end) until s
end

function d:getPos()
    local s, r
    repeat task.wait() s, r = pcall(function() return d.plr.Character.PrimaryPart.CFrame end) until s and r
    return r
end

xpcall(d.antiAfk,function(...) -- u pretty much always want antiafk
    warn("antiafk start failed", ...)
end)

return d