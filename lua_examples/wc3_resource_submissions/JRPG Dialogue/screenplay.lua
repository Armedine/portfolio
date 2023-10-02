function buildactors()
    --[[
        there are three methods to building a portrait object:
            1)  simply declare a table and speak.actor:assign
                will handle initializing the portrait object.
            2)  if you want to be more formal, you can declare
                the new object then assign emotions as needed.
            3)  if you're a terse-junky, you can build a new
                portrait object by passing in an anonymous table.
    --]]

    -- example 01) simple table - you just really like tables.
    portrait_grunt = {
        none        = 'war3mapImported\\portrait-orc.blp',
        angry       = 'war3mapImported\\portrait-orc_anger.blp',
        blush       = 'war3mapImported\\portrait-orc_blush.blp',
        happy       = 'war3mapImported\\portrait-orc_happy.blp',
    }
    actor_grunt     = speak.actor:new()
    actor_grunt:assign(udg_grunt, portrait_grunt)

    -- example 02) formal - you may be wanting to modify portrait objects or change an actor's portrait kit.
    portrait_footman = speak.portrait:new()
    portrait_footman.none   = 'war3mapImported\\portrait-hu.blp'
    portrait_footman.angry  = 'war3mapImported\\portrait-hu_anger.blp'
    portrait_footman.blush  = 'war3mapImported\\portrait-hu_blush.blp'
    portrait_footman.happy  = 'war3mapImported\\portrait-hu_happy.blp'
    actor_footman   = speak.actor:new()
    actor_footman:assign(udg_footman, portrait_footman)

    -- example 03) terse-junky - keep the code really tight.
    actor_peon      = speak.actor:new()
    actor_peon:assign(
        udg_peon,
        { none  = 'war3mapImported\\portrait-orc_peon.blp', angry = 'war3mapImported\\portrait-orc_peon.blp',
          blush = 'war3mapImported\\portrait-orc_peon.blp', happy = 'war3mapImported\\portrait-orc_peon.blp', })
    -- (in the future, you could change actor_peon's portrait with 'actor_peon.portrait.angry', etc.)

end

function buildscreenplay()
    --[[

        there are two ways to build chained dialogue items:
            1) simple:

                using a table with index-values, build a dialogue chain
                by inserting the text and actor (auto generating
                each speech item automatically).

                item format:
                { text, actor [, emotion, anim, sound, func] }
                { "My dialogue text.", actor_object [, "angry", "stand victory", sound_var, func_var] }

                example: 
                    my_table = {
                        [1] = { "Your character's dialogue", my_actor_object_a, "angry" },
                        [2] = { "Your other character's dialogue", my_actor_object_b },
                    }
                    my_scene = scene.chain:build(my_table)

            2) specified:

                build each speech item separately. this can be useful
                if you are going to add and remove speech items
                yourself i.e. if user actions influence dialogue.

                example:
                    my_dynamic_item       = speak.item:new()
                    my_dynamic_item.actor = my_actor_object_a
                    my_dynamic_item.text  = "This is my dynamic dialogue."

                    scene_01 = speak.chain:new()
                    scene_01:add(some_other_item)
                    scene_01:add(my_dynamic_item)
                    scene_01:add(some_other_item)
                    (...)

                    you decide to remove it later based on a player's action and insert a different item:
                        scene_01:remove(my_dynamic_item)
    --]]

    --[[
        simple build example:
            this method is useful for visually building screenplays,
            allowing you to traverse them vertically as you would
            pages from a normal screenplay in real life.
    --]]

    local spawngrunts = function()
        -- create some grunts for the scene when the grunt calls for his squad:
        local unit
        unit = CreateUnit(Player(0), FourCC('ogru'), 700, 400, 0)
        SetUnitInvulnerable(unit, true)
        IssuePointOrderById(unit, 851986, 230, 75)
        unit = CreateUnit(Player(0), FourCC('ogru'), 700, 380, 0)
        SetUnitInvulnerable(unit, true)
        IssuePointOrderById(unit, 851986, 465, -300)
        unit = CreateUnit(Player(0), FourCC('ogru'), 700, 360, 0)
        SetUnitInvulnerable(unit, true)
        IssuePointOrderById(unit, 851986, 500, 0)
    end

    scene_01 = {
        [1] = {
            "|cffff0000Who goes there!?|r",
            actor_footman,
        },
        [2] = {
            "...",
            actor_grunt,
            "blush",
            "stand two",
            soundt.grunt01,
        },
        [3] = {
            "What are you doing in Lordaeron, |cffff0000Horde|r filth?",
            actor_footman,
            "angry"
        },
        [4] = nil, -- left empty to demonstrate :add functionality.
        [5] = {
            "Wait, if there's one of you, then that means...",
            actor_footman,
            "blush",
        },
        [6] = {
            "Form ranks!",
            actor_grunt,
            "angry",
            "spell",
            soundt.grunt02,
            spawngrunts,
        },
        [7] = {
            "Hah!|n|nYou think you've outwitted the Alliance with sheer numbers? We Alliance are never alone!",
            actor_footman,
            "happy",
        },
        [8] = {
            "...",
            actor_footman,
            "blush",
        },
        [9] = {
            "Garland? Erik? Where are you fools?",
            actor_footman,
            "blush",
        },
        [10] = {
            "It looks like your men have forsaken you, human. Typical Alliance cowardice!",
            actor_grunt,
            "happy",
        },
        [11] = {
            "Fine! I'll take you all on myself!",
            actor_footman,
            "angry",
            "stand defend",
            soundt.footman01,
        },
        [12] = {
            "Others would call you a fool, human. But, you have the courage of a warrior. This is no honorable way to die."
            .." Stand back troops; we meet tomorrow on the battlefield. Lok'tar ogar!",
            actor_grunt,
        },
        [13] = {
            "So be it. Tomorrow we meet on the hills of steel and bone and flesh. And now I've run out of things to say so I'm"
            .." just meandering on and on and on to test this dialogue system. Yea, I'm still going. And going, and going. Wow,"
            .." can you believe this scrolling text frame even works? It probably could use a footprint though. I think you can"
            .." even use your mousewheel to scroll up when it's done spamming you with awesome lore content, just in case you"
            .." missed something important. Really, really important. You might not understand this map without it. If it ever"
            .." finishes, that is. You better not click that continue button. Hey! How DARE you!",
            actor_footman,
        },
    }
    -- we take the table outline above and convert it to a chain of speech items:
    scene_01 = speak.chain:build(scene_01)

    --[[
        specified example where we fill the empty [4] slot:
    --]]

    peon_flee01         = speak.item:new()
    peon_flee01.text    = "Aaaggh!"     -- (required)
    peon_flee01.actor   = actor_peon    -- (required)
    peon_flee01.emotion = "none"        -- (optional)
    peon_flee01.sound   = soundt.peon01 -- (optional)
    peon_flee01.func    = function()    -- (optional)
        -- in this example, we'll also add a function that runs when the dialogue item is played.
        PauseUnit(peon_flee01.actor.unit, false)
        IssuePointOrderById(peon_flee01.actor.unit, 851986, 735, 750)
        UnitApplyTimedLifeBJ( 6.0, FourCC('BTLF'), peon_flee01.actor.unit )
    end
    -- insert into the nil [4] slot in scene_01:
    scene_01:add(peon_flee01, 4)

end
