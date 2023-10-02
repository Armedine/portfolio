speffect = {
    scale  = 1.0,
    effect = '',
    timed  = false,
    dur    = 3.0,
    death  = true,
    point  = 'origin',
    loadx  = 18000,
    loady  = 17000,
    stack  = {},
    vertex = { 255, 255, 255 },
}


function speffect:new(effectstring, scale, point, _vertext)
    -- create a canned speffect that can be referenced over and over.
    o = {}
    setmetatable(o, self)
    o.effect = effectstring
    o.scale  = scale or self.scale
    o.point  = point
    o.vertex = _vertext or nil
    -- capture preload needs in one spot:
    self.__index = self
    speffect.stack[#speffect.stack+1] = o
    return o
end


function speffect:preload()
    -- stagger to prevent any chance of desync from competing data overload:
    for i = 1,#self.stack do
        Preload(speffect.stack[i].effect)
        speffect.stack[i]:play(speffect.loadx, speffect.loady)
    end
end


-- @x,y = play canned effect at this location (e.g. myeffect:play(x,y) )
-- [@_dur] = destroy after this many seconds.
function speffect:play(x, y, _dur, _scale)
    local e = AddSpecialEffect(self.effect, x, y)
    local s = _scale or self.scale
    if self.vertex then
        BlzSetSpecialEffectColor(e, self.vertex[1], self.vertex[2], self.vertex[3])
    end
    BlzSetSpecialEffectScale(e, s)
    if _dur then
        TimerStart(NewTimer(), _dur, false, function()
            self:removalcheck(e)
            DestroyEffect(e)
            ReleaseTimer()
        end)
        return e
    elseif self.timed then
        TimerStart(NewTimer(), self.dur, false, function()
            self:removalcheck(e)
            DestroyEffect(e)
            ReleaseTimer()
        end)
        return e
    else
        DestroyEffect(e)
    end
end


-- @x,y = create a non-obj canned effect at this location.
function speffect:create(x, y, _scale)
    local e = AddSpecialEffect(self.effect, x, y)
    if _scale then
        BlzSetSpecialEffectScale(e, _scale)
    end
    if self.vertex then
        BlzSetSpecialEffectColor(e, self.vertex[1], self.vertex[2], self.vertex[3])
    end
    return e
end


-- @unit  = play at unit x,y.
function speffect:playu(unit)
    self:play(GetUnitX(unit), GetUnitY(unit))
end

-- @unit  = attach to this unit.
-- @dur   = [optional] give it a duration.
-- @point = [optional] override the special effect point.
-- @scale = [optional] set new scale (e.g. 1.75).
-- @returns special effect
function speffect:attachu(unit, dur, point, scale)
    local attach = point or self.point
    local e = AddSpecialEffectTarget(self.effect, unit, attach)
    if scale then BlzSetSpecialEffectScale(e, scale) end
    if dur then
        TimerStart(NewTimer(), dur, false, function()
            utils.debugfunc(function()
                if e then
                    self:removalcheck(e, attach)
                end
            end, "effect timer")
            DestroyEffect(e) ReleaseTimer()
        end)
    end
    return e
end


 -- if effect has no death anim, hide it instantly to prevent lingering.
function speffect:removalcheck(e, _isattach)
    -- *NOTE: in 1.32 game *crashes* when Z is set for attached effects.
    if not self.death then
        utils.playerloop(function(p)
            if p == utils.localp() then
                BlzSetSpecialEffectScale(e, 0.01)
                BlzSetSpecialEffectAlpha(e, 0)
                if not _isattach then
                    BlzSetSpecialEffectZ(e, 3500.0)
                end
            end
        end)
    end
end


function speffect:addz(e, z)
    if utils.localp() then
        BlzSetSpecialEffectZ(e, BlzGetLocalSpecialEffectZ(e) + z)
    end
end


-- @d   = diameter to play in (circular)
-- @c   = number of effects to play in @d
-- @x,y = location to play at
function speffect:playradius(d, c, x, y, _dur)
    local r     = math.floor(d/2)            -- convert to radius
    local a     = math.random(0,360)         -- starting angle
    local inc   = 360/c                      -- angle increment 
    local x2,y2                              -- effect point
    for i = 1,c do
        x2,y2 = utils.projectxy(x, y, r, a)
        a     = a + inc
        self:play(x2, y2, _dur or nil)
    end
end
