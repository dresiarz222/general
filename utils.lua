-- COMPATIBILITY
local doNothing = function() end
local dummyReturnFuncFunc = function(...)
    return function(...) end
end
local dummyfunc = function(...) return ... end
local clonefunction = clonefunction or dummyfunc
local cloneref = clonefunction(cloneref) or dummyfunc
local getgenv = clonefunction(getgenv) or {}
local getconnections = clonefunction(getconnections) or function(...) return {} end
local hookfunction = clonefunction(hookfunction) or dummyReturnFuncFunc
local hookmetamethod = clonefunction(hookmetamethod) or dummyReturnFuncFunc

-- COMPATIBILITY END

local logService:LogService = cloneref(game:GetService("LogService"))

local plrs:Players = cloneref(game:GetService("Players"))
local plr:Player = cloneref(plrs.LocalPlayer)

local d = {}

local _ = Instance.new("ScreenGui").AbsoluteSize
local screenX = _.X
local screenY = _.Y

function d:antiAfk()

    for _,connection:RBXScriptConnection in getconnections(plr.Idled) do
        connection:Disable()
    end

    local vu:VirtualUser = cloneref(game:GetService("VirtualUser"))

    task.spawn(function()
        while task.wait(math.random(1,6)*100) do
            
            xpcall(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new(math.random(0,screenX),math.random(0,screenY)))
            end, function(...)
                warn("antiafk 1 fail", ...)
            end)
    
            xpcall(function()
                vu:Button2Down(Vector2.new(math.random(0,screenX),math.random(0,screenY)),workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(math.random(0,screenX),math.random(0,screenY)),workspace.CurrentCamera.CFrame)
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
    repeat task.wait() s = pcall(function() plr.Character.PrimaryPart.CFrame = pos end) until s
end

function d:getPos()
    local s, r
    repeat task.wait() s, r = pcall(function() return plr.Character.PrimaryPart.CFrame end) until s and r
    return r
end

xpcall(d.antiAfk,function(...)
    warn("antiafk start failed", ...)
end)
