trg = {}


function trg:init()
    self.__index = self
    self.debug   = false
    self.total   = 0
    self.dis     = false
    self.trig    = nil    -- attached game trigger.
    self.allp    = false  -- triggered for any unit?
    self.burner  = false  -- when true, trig is destroyed on first event.
    self.trgt    = {} -- object storage.
    self.trgpmap = 
    {
        attacked = EVENT_PLAYER_UNIT_ATTACKED,
        order    = EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER,
        death    = EVENT_PLAYER_UNIT_DEATH,
        spell    = EVENT_PLAYER_UNIT_SPELL_EFFECT,
    }
    self.trgmap = 
    {
        death    = EVENT_UNIT_DEATH,
    }
end


function trg:new(eventstr, _powner, _rect)
    local o = {}
    setmetatable(o, self)
    if _powner then o.powner = _powner else o.allp = true end
    o.trig     = CreateTrigger()
    o.actiont  = {}     -- stored actions
    o.condt    = {}     -- stored conditions
    o.unitt    = {}     -- stored trigger units (for referencing and loops).
    o.pass     = true   -- flag for running actions.
    if eventstr == "rect" and _rect then
        TriggerRegisterEnterRectSimple( _rect, o.trig )
        print("reg")
    else
        o:regevent(eventstr)
    end
    TriggerAddAction(o.trig, function()
        utils.debugfunc(function()
            o.pass = true
            if o.condt and #o.condt > 0 then
                for _,cond in ipairs(o.condt) do
                    if not cond() then
                        o.pass = false
                        break
                    end
                end
            end
            if o.pass and o.actiont then
                for _,action in ipairs(o.actiont) do
                    action()
                end
                o:wrapup()
            end
        end, "trigaction")
    end)
    self.total = self.total + 1
    self.trgt[self] = self
    return o
end


function trg:regevent(eventstr)
    local found = false
    if self.allp then
        for str,event in pairs(self.trgmap) do
            if eventstr == str then
                if self.debug then print("found eventstr "..str.." with event id "..GetHandleId(event)) end
                TriggerRegisterAnyUnitEventBJ(self.trig, event)
                found = true
                break
            end
        end
    else
        for str,event in pairs(self.trgpmap) do
            if eventstr == str then
                if self.debug then print("found eventstr "..str.." with event id "..GetHandleId(event)) end
                TriggerRegisterPlayerUnitEventSimple(self.trig, self.powner, event)
                found = true
                break
            end
        end
    end
    if found then
        self.event = eventstr
        if self.debug then print("register trigger event success") end
    else
        print("error: attempted to register an event that is not yet mapped: '"..eventstr.."'")
    end
end


function trg:regaction(func)
    self.actiont[#self.actiont+1] = func
    return #self.actiont -- id.
end


function trg:regcond(func)
    self.condt[#self.condt+1] = func
    return #self.condt -- id.
end


function trg:removeaction(id)
    self.condt[id] = nil
    self:sortcollapse()
end


function trg:removecond(id)
    self.actiont[id] = nil
    self:sortcollapse()
end


function trg:sortcollapse()
    -- collapse tables after removing function.
    utils.tablecollapse(self.condt)
    utils.tablecollapse(self.actiont)
end


function trg:attachtrigu(unit)
    -- attach a condition for a triggering unit.
    self:regcond(function() return unit == utils.trigu() end)
    self.unitt[#self.unitt+1] = unit
end


function trg:attachspellid(id)
    -- attach a condition for a matching spell id (FourCC rawcode)
    self:regcond(function() return id == GetSpellAbilityId() end)
end


function trg:attachuniteffect(unit, effect)
    -- if a trig unit is present and in the unit table, run an effect on them.
    local unit  = unit
    self.effect = effect
    self:regaction(function()
        if self.unitt then
            for _,unit in ipairs(self.unitt) do
                if self.trigu == unit then self.effect:playu(unit) end
            end
        end
    end)
end


function trg:disable()
    self.dis = true
    DisableTrigger(self.trig)
end


function trg:enable()
    self.dis = false
    EnableTrigger(self.trig)
end


function trg:wrapup()
    if self.burner then self:destroy() end
end


function trg:destroy()
    TriggerClearActions(self.trig)
    TriggerClearConditions(self.trig)
    for i,v in pairs(self.actiont) do v = nil i = nil end
    for i,v in pairs(self.condt)   do v = nil i = nil end
    for i,v in pairs(self.unitt)   do v = nil i = nil end
    self.actiont    = nil
    self.condt      = nil
    self.unitt      = nil
    self.trgt[self] = nil
    self.total      = self.total - 1
end


function trg:newdeathtrig(unit, func, _effect)
    -- one-time burner Trigger for a single unit (destroyed on death).
    local unit, func = unit, func
    local trig = trg:new("death", utils.powner(unit))
    trig:attachtrigu(unit)
    trig:regaction(func)
    if _effect then trig:attachuniteffect(unit, _effect) end
    return trig
end


function trg:newspelltrig(unit, func)
    -- trigger listening for ability casts.
    local trig = trg:new("spell", utils.powner(unit))
    trig:regaction(func)
    return trig
end
