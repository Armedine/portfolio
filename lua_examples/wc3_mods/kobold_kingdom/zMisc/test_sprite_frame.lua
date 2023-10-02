function debugfunc( func, name )
  local name = name or ""
  local passed, data = pcall( function() func() return "func " .. name .. " passed" end )
  if not passed then
    print(name, passed, data)
  end
end


function create_frames()
    debugfunc( function()
        -- 1) in order for this to work properly, the model must be edited to have an indexed camera (BlzFrameSetModel) in front of the unit and at its base.
        -- 2) the camera can either be moved (PORTRAIT_CAMERA usually), or a 2nd one can be made.
        -- 3) if the model is in use in-game, a 2nd camera should be copy and pasted.
        fh = BlzCreateFrameByType("SPRITE", "testfh", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        BlzFrameSetModel(fh, "war3mapImported\\kobold_reforged_tunneler.mdx", 1)  -- here we target the camera copy we made (0-based, 1 = 2nd camera)
        BlzFrameClearAllPoints(fh)
        BlzFrameSetAbsPoint(fh, FRAMEPOINT_CENTER, 0.4, 0.3)
        BlzFrameSetVisible(fh, true)
        BlzFrameSetSize(fh, 0.3, 0.3)
        BlzFrameSetScale(fh, 0.04)
        -- BlzFrameSetSpriteAnimate(fh, 2, 0)  -- stand
    end, "test")
end
