sync = {}


function sync:init()
    self.trig = CreateTrigger()
    self.__index = self
end


function sync:new(str, synctable, index, vartype)
    -- vartype should be "string" or "number"
    local o = {}
    setmetatable(o,self)
    o.str     = str
    o.index   = index
    o.vartype = "string" or vartype
    o:initread(synctable)
    return o
end


function sync:send(varinput)
    -- register data out-flow (varinput should be a string)
    if BlzSendSyncData(self.str, varinput) then
        --utils.textall("send data success: "..self.str.." "..varinput)
    else
        --utils.textall("send data failed: "..self.str.." "..varinput)
    end
end


function sync:initread(synctable)
    -- register data in-flow
    for p,_ in pairs(kobold.playing) do
        BlzTriggerRegisterPlayerSyncEvent(self.trig, p, self.str, false)
    end
    TriggerAddAction(self.trig, function()
        if BlzGetTriggerSyncPrefix() == self.str then
            --utils.textall("data fetched: "..sync:getdata())
            if self.vartype == "string" then
                synctable[self.index] = sync:getdata()
                --utils.textall("synctable set to: "..synctable[self.index])
            elseif self.vartype == "number" then
                synctable[self.index] = sync:getdata()
                synctable[self.index] = tonumber(synctable[self.index])
                --utils.textall("synctable set to: "..synctable[self.index])
                if type(synctable[self.index]) == "number" then print("is number true") end
            else
                print("error: sync event has incorrect 'vartype' - should be 'string' or 'number'")
            end
        end
    end)
end


function sync:getdata()
    return BlzGetTriggerSyncData()
end
