-- (deprecated feature)
function ability:movecmdbtns(p)
    kui.cmdbar = BlzGetFrameByName("CommandBarFrame",0)
    if p == utils.localp() then
        BlzFrameSetLevel(kui.cmdbar, 3)
        for i = 0,#kui.cmdmap do
            local fh = BlzGetFrameByName(kui.cmdmap[i],0)
            BlzFrameClearAllPoints(fh)
            if i < 5 then
                BlzFrameSetAbsPoint(fh, fp.tl, 0.0, -0.25)
            else
                if i > 7 then -- QWER slots (8,9,10,11)
                    BlzFrameSetSize(fh, kui:px(48), kui:px(48))
                    BlzFrameSetPoint(fh, fp.c, kui.canvas.game.skill.skill[i-7].fh, fp.c, 0.0, kui:px(6))
                else -- 123 slots (5,6,7)
                    BlzFrameSetPoint(fh, fp.c, kui.canvas.game.skill.skill[i-4].fh, fp.c, 0.0, kui:px(6))
                end
                BlzFrameSetLevel(fh, 4)
            end
        end
    end
end