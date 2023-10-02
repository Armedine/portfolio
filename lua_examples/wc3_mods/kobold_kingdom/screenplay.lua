screenplay = {}
screenplay.chains = {} -- store built screenplay objects.
screenplay.chains.quest = {}
screenplay.pause_camera = false -- stop camera lock features when needed.
screenplay.__index = screenplay

function screenplay:new()
    local o = {}
    setmetatable(o, self)
    return o
end


function screenplay:run(chain)
    utils.debugfunc(function()
        speak:startscene(chain)
    end, "screenplay:run")
end


function screenplay:build()
    -- quest lineage id builder:
    local id  = 0
    local idf = function() id = id + 1 return id end

    -- uses pre-placed units (will break if they are deleted).
    actor_worker        = speak.actor:new()
    actor_worker:assign(udg_actors[1],       { none = 'war3mapImported\\portrait_worker.blp' })
    actor_shinykeeper   = speak.actor:new()
    actor_shinykeeper:assign(udg_actors[2],  { none = 'war3mapImported\\portrait_blacksmith.blp' })
    actor_digmaster     = speak.actor:new()
    actor_digmaster:assign(udg_actors[3],    { none = 'war3mapImported\\portrait_taskmaster.blp' })
    actor_elementalist  = speak.actor:new()
    actor_elementalist:assign(udg_actors[4], { none = 'war3mapImported\\portrait_gemhoarder.blp' })
    actor_narrator      = speak.actor:new()
    actor_narrator:assign(udg_actors[5],     { none = 'war3mapImported\\portrait_narrator.blp' })
    actor_grog          = speak.actor:new()
    actor_grog:assign(udg_actors[6],         { none = 'war3mapImported\\portrait_grog.blp' })
    actor_slog          = speak.actor:new()
    actor_slog:assign(udg_actors[7],         { none = 'war3mapImported\\portrait_slog.blp' })
    actor_greywhisker   = speak.actor:new()
    actor_greywhisker:assign(udg_actors[8],  { none = 'war3mapImported\\portrait_greywhisker.blp' })

    --[[
    ***************************************************************************
    ******************************* screenplays *******************************
    ***************************************************************************
    item format:
    { text, actor [, emotion, anim, sound, func] }
    --]]

    screenplay.chains.narrator_intro = speak.chain:build({
        [1] = {"...", actor_narrator},
        [2] = {"Oh, I didn't see you there.", actor_narrator},
        [3] = {"Very well, no need for long introductions. Let's get you on your journey, shall we? I sense your hunger for adventure and treasure.", actor_narrator},
        [4] = {"This is the cave of the Tunnel Rat Clan.", actor_narrator},
        [5] = {"They've seen... better times. Can you help them reclaim their glory in the depths?", actor_narrator},
        [6] = {"Well, what are we waiting for?", actor_narrator},
        [7] = {"Use the |c0000f066D|r key to speak to characters in the world. Try it on the kobold marked by a yellow |c0000f066'!'|r.", actor_narrator},
        [8] = {"If you ever miss a piece of dialogue or want to re-read it, try the Message Log (|c0000f066F12|r).", actor_narrator},
    })

    screenplay.chains.narrator_intro_freeplay = speak.chain:build({
        [1] = {"Welcome to |c0000f066free play|r mode.", actor_narrator},
        [2] = {"This is intended for players who have completed the story, or for those who don't care for it in the first place.", actor_narrator},
        [3] = {"In this mode, no story quests are available, and |c00ff3e3esaving is disabled|r.", actor_narrator},
        [4] = {"Instead, you start at |c0000f066level 45|r with items and a stash of ore and gold.", actor_narrator},
        [5] = {"Additionally, the speed of leveling is greatly accelerated.", actor_narrator},
        [6] = {"Explore, run missions, and fight bosses at your leisure. Have fun!", actor_narrator},
    })
    
    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"The kobold jumps, not noticing you walk up behind him. How rude.", actor_narrator},
        [2] = {"Scrat scrat! Welcome to depths, greenwhisker.", actor_worker},
        [3] = {"Why you come? You here for treasure? We have no treasure.", actor_worker},
        [4] = {"Big boyos in tunnels keep miners away. Come from old chambers sometimes. Take kobolds. Kobolds never return.", actor_worker},
        [5] = {"The kobold examines your torn pants, missing shirt, and mostly-melted candle. And your complete lack of treasure.", actor_narrator},
        [6] = {"Ah, you loser like me!", actor_worker},
        [7] = {"The kobold bursts into laughter, nearly falling to the floor. Before long, his face freezes as his eyes meet your gaze.", actor_narrator},
        [8] = {"Ah, but you different. It clear. You determined, why else you come all the way down?", actor_worker},
        [9] = {"I sense Koboltagonist! I see it! Prophecy? Koboltagonist return to save us? Could be? Is! Is be!", actor_worker},
        [10] = {"You look at the kobold with peculiar eyes as he babbles incoherently, but it does not deter his excitement.", actor_narrator},
        [11] = {"Yes, yes, you save us from big boyos! But, but...", actor_worker},
        [12] = {"...but first, see Shinykeeper. Shinykeeper have shinies for you. Your dull shinies no good for Koboltagonist.", actor_worker},
        [13] = {"Now go! For Kingdom! Rock and stone, to the bo- err, wrong game. Ahem.", actor_worker},
        [14] = {"...", actor_worker},
        [15] = {"I can't come up with phrase, I give up. Okay, you go now! Scrat!", actor_worker},
        [16] = {"Well, that was fast. The Shinykeeper is just south of you. By the piles of junk.", actor_narrator},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"Strange tinkering noises can be heard as the Shinykeeper rummages through a bag of what is obviously junk.", actor_narrator},
        [2] = {"...", actor_shinykeeper},
        [3] = {"Baah!", actor_shinykeeper},
        [4] = {"Me no see you there!", actor_shinykeeper},
        [5] = {"What you want?", actor_shinykeeper},
        [6] = {"...", actor_shinykeeper},
        [7] = {"Oh, I see. The silent Kolbotagonist type. See what I do there? I break fourth tunnel.", actor_shinykeeper},
        [8] = {"...", actor_shinykeeper},
        [9] = {"Shinies? I see in your eye. Scrat! Okay, you have some of my shinies, but not all!", actor_shinykeeper},
        [10] = {"With reluctance to let go, the Shinykeeper gives you a handful of junk.", actor_narrator},
        [11] = {"Wha? You no like? You wear on head, see!", actor_shinykeeper},
        [12] = {"The Shinykeeper puts a bucket on his head and lights a pile of dirty wax to demonstrate his mastery, then places it on your head.", actor_narrator},
        [13] = {"The follow-up grin is too wide for any sane kobold.", actor_narrator},
        [14] = {"See! Shiny fit perfect. Okay, now you go! Dig Master waiting.", actor_shinykeeper},
        [15] = {"Don't forget to equip your... new junk. The equipment and inventory pages can be opened with the |c0000f066V|r and |c0000f066B|r keys respectively.", actor_narrator},
    })
    
    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"The Dig Master notices your presence, but continues to stare at what resembles a paper map of tunnels.", actor_narrator},
        [2] = {"You casually point out to him that the map is upside down.", actor_narrator},
        [3] = {"...", actor_digmaster},
        [4] = {"Bagh!? A greenwhisker know best, aye?", actor_digmaster},
        [5] = {"What appears as anger suddenly fades as The Dig Master bursts out in laughter.", actor_narrator},
        [6] = {"By dirt, no one talk like that in long time. You okay to me, greenwhisker. You tough to authority. Definitely Koboltagonist.", actor_digmaster},
        [7] = {"We save HARDEST missions for Koboltagonist. You prove worth, okay?", actor_digmaster},
        [9] = {"The Dig Master points to his now-correctly-oriented map.", actor_narrator},
        [10] = {"Here, you go here. Many shinies left by miners long ago.", actor_digmaster},
        [11] = {"You careful though, greenie. There two strong guardians!", actor_digmaster},
        [12] = {"You defeat them, yes? Gather shinies? No come back with shinies means no come back at all!", actor_digmaster},
        [13] = {"Well, what you wait for? Go fetch shinies!", actor_digmaster},
        [14] = {"The Dig Master has given you a quest to complete a dig in a random biome.", actor_narrator},
        [15] = {"Use the |c0000f066Tab|r key to open the dig map, or select it with its icon in the lower right. All main interface pages have a menu button there.", actor_narrator},
        [16] = {"Inside a dig, your candle light will dwindle over time. The powers of The Darkness will be attracted to you as it fades.", actor_narrator},
        [17] = {"|c00fdff6fWax Canisters|r can be acquired within digs from certain creatures or events to replenish your wax capacity.", actor_narrator},
        [18] = {"Now, get going. And good luck! Oh, almost forgot. If your candle light goes out |c00ff3e3eThe Darkness|r itself will hunt you. No pressure!", actor_narrator},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"The Dig Master looks confused while flipping his map around in random directions.", actor_narrator},
        [2] = {"Greenwhisker! You back, by dirt!", actor_digmaster},
        [3] = {"Little faith, but here you! Good, good.", actor_digmaster},
        [4] = {"You shuffle through your treasure bag and pull out a recovered item.", actor_narrator},
        [5] = {"...", actor_digmaster},
        [6] = {"What this? This is junk!", actor_digmaster},
        [7] = {"The Dig Master twirls the piece in his hand rapidly while examining it.", actor_narrator},
        [8] = {"But, you new and green. We do better next time, yea?", actor_digmaster},
        [9] = {"He quickly pockets the junk.", actor_narrator},
        [10] = {"Now, go see Shinykeeper. They have new task for you.", actor_digmaster},
        [11] = {"You've leveled up after finishing a dig and this quest!", actor_narrator},
        [12] = {"If you haven't done so already, browse the new items acquired from your successful dig and see if they're worthy of a 'Koboltagonist'.", actor_narrator},
        [13] = {"You should also have character attribute and mastery points available to spend.", actor_narrator},
        [14] = {"To begin spending, open the character page with the |c0000f066C|r key, and the mastery page with the |c0000f066N|r key.", actor_narrator},
        [15] = {"Use character attributes to boost certain stats. Mastery points offer similar benefits, but can ultimately unlock new abilities deeper in.", actor_narrator},
        [16] = {"Spend your earned points wisely, as they are non-refundable!", actor_narrator},
        [17] = {"Oh, and one last thing, promise.", actor_narrator},
        [18] = {"Abilities unlock every 3 levels. You should have a new one unlocked now. See what it is in your skillbook, which opens with the |c0000f066K|r key.", actor_narrator},
        [19] = {"If that was too much, here's a tip: whenever you earn new things, a green alert icon will appear over the menu button in the lower right.", actor_narrator},
    })
    
    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"The Shinykeeper appears distraught, running around frantically.", actor_narrator},
        [2] = {"Scrat! It gone! Scrat, it gone for good!", actor_shinykeeper},
        [3] = {"...", actor_shinykeeper},
        [4] = {"Ah, Koboltagonist! You help, yes? Like you help Dig Master.", actor_shinykeeper},
        [5] = {"My hammer, it is taken. Taken by filthy tunnel vermin on last dig.", actor_shinykeeper},
        [6] = {"Without hammer, cannot make shinies! See...", actor_shinykeeper},
        [7] = {"The Shinykeeper attempts to bash a nail in with the tip of an old boot. Kobolds seem to have an affection for shoes.", actor_narrator},
        [8] = {"...see, you see! No good!", actor_shinykeeper},
        [9] = {"What say you? You hunt bests? Slay them! Return hammer?", actor_shinykeeper},
        [10] = {"Yes, yes. You do that, we make and trade shinies!", actor_shinykeeper},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"The Shinykeeper stops removing nails from his boot and looks up to greet you.", actor_narrator},
        [2] = {"...", actor_shinykeeper},
        [3] = {"How? We thought you dead for good! We thought you turn to slag. But... is that...", actor_shinykeeper},
        [4] = {"The hammer disappears from your hands before you can extend it outward.", actor_narrator},
        [5] = {"...now! Now we in business!", actor_shinykeeper},
        [6] = {"He dances around like a maniac.", actor_narrator},
        [7] = {"...", actor_shinykeeper},
        [8] = {"Ah yes. Yes, yes! You need any shinies, you see me. Okay, Kolbotagonist?", actor_shinykeeper},
        [9] = {"They not powerful. Not yet. Still need more tools. But for now, fill missing shoe? Missing bucket? Scrat! Anything!", actor_shinykeeper},
        [10] = {"You now have access to the Shinykeeper's shop outside of digs. Open it by clicking his icon near your skill bar.", actor_narrator},
        [11] = {"At this new shop, you can turn your earned gold into items with random features.", actor_narrator},
        [12] = {"I suspect the hammer was not the only thing missing. We'll find out soon enough.", actor_narrator},
        [13] = {"Well, this is great progress thus far, Koboltagonist. And you haven't event died yet! Surely by now-", actor_narrator},
        [14] = {"...well, anyways. The Elementalist was making strange poses earlier. Shall you, ahem, get moving?", actor_narrator},
    })

    
    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"Oh, so that's how it will be!?", actor_elementalist},
        [2] = {"You?! You! Why you...!", actor_elementalist},
        [3] = {"...", actor_elementalist},
        [4] = {"The kobold wizard points a finger at a rock while holding up a shoe.", actor_narrator},
        [5] = {"By the power of STONE, I transmute and convert thee!", actor_elementalist},
        [6] = {"...", actor_elementalist},
        [7] = {"Nothing happens.", actor_narrator},
        [8] = {"Blast, no good stones! Not again!", actor_elementalist},
        [9] = {"The Elementalist turns to you, now pointing his finger at your nose.", actor_narrator},
        [10] = {"Kolbotagonist, I can sense it. The rocks speak, and do not lie. They tell of the shinies you bring for the Dig Master.", actor_elementalist},
        [11] = {"We need different shinies. We need magical shinies. Can you bring?", actor_elementalist},
        [12] = {"Bring me shinies and I will show you the true power of geomancy!", actor_elementalist},
        [13] = {"The Elementalist resumes his incantation, this time holding a spoon.", actor_narrator},
        [14] = {"You'd best be off, before something terrible happens.", actor_narrator},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"You step over a bent spoon.", actor_narrator},
        [2] = {"Ah! Koboltagonist! You bring good stone?", actor_elementalist},
        [3] = {"...", actor_elementalist},
        [4] = {"The Elementalist takes an imbued rock from your outstretched hand.", actor_narrator},
        [5] = {"Good.. good! Glow wax will do wonders on this specimen.", actor_elementalist},
        [6] = {"The Elementalist waves his arms around like a lunatic while chanting 'bobbity shmobbity' at his shoe.", actor_narrator},
        [7] = {"The Elementalist lowers his hands in disappointment before trying once more.", actor_narrator},
        [8] = {"By shroom and fungus! Glow wax too viscose? Candle calibration low? Hand waving not fas-", actor_elementalist},
        [9] = {"The shoe bursts in a glow of light, sending the Elementalist back over a table.", actor_narrator},
        [10] = {"He peers over the table with a coal-black face save for his two beady eyes.", actor_narrator},
        [11] = {"Ahah!", actor_elementalist},
        [12] = {"He picks up his shoe from across the cave floor, dancing around in celebration.", actor_narrator},
        [13] = {"Today, you do good. You now no longer a greenwhisker, greenwhisker. You ever need magic shoe, you come to me.", actor_elementalist},
        [14] = {"Oh, almost forget! Here, you have some stones. We don't need all.", actor_elementalist},
        [15] = {"The Elementalist hands you 10 pieces of magical ore. You guessed it right: it's a freebie to test out his new fancy shop.", actor_narrator},
        [16] = {"You can |c0000f066craft|r new items at the Elementalist with ore mined on digs. Keep track of your ore count your inventory (|c0000f066B|r).", actor_narrator},
        [17] = {"Click his head icon near the center of your skillbar to start making new 'shinies', as they say.", actor_narrator},
        [18] = {"Crafting an elemental item will yield a guaranteed damage modifier matching the chosen ore's element type.", actor_narrator},
        [19] = {"Additionally, the Elementalist's items will roll slightly higher stats than the Shinykeeper. Less... hammering, is involved.", actor_narrator},
    })
    
    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"Koboltagonist!", actor_digmaster},
        [2] = {"The Dig Master flips his map around in circles as a fellow kobold scout leaves the table.", actor_narrator},
        [3] = {"He steps from his mount and slams the paper on the table.", actor_narrator},
        [4] = {"Perfect solution. No fooling. Master plan. Look here.", actor_digmaster},
        [5] = {"He points to an assortment of illegible scribbles on his map.", actor_narrator},
        [6] = {"...", actor_digmaster},
        [7] = {"What? No see?", actor_digmaster},
        [8] = {"New tunnel! Or, chamber. Big chamber. But, kept shut by old machine. Requires key.", actor_digmaster},
        [9] = {"Elementalist say we need ancient stones to open.", actor_digmaster},
        [10] = {"Could be room we heard of long ago.", actor_digmaster},
        [11] = {"Uncertain. Risky. But BIG shiny worth all risk! But, for getting ancient stones...", actor_digmaster},
        [12] = {"He looks at you and grins.", actor_narrator},
        [13] = {"In luck. Elementalist say Greywhisker have stones, stashed away for many winters. He once a Geomancer. Knows ancient magic. Sadly, years numbered.", actor_digmaster},
        [14] = {"Here, take to Greywhisker and trade for stones. Ask to use old magic to make key. Perfect trade. No better trade.", actor_digmaster},
        [15] = {"He places a giant block of cheese in your hands. A sheet of paper featuring a drawing of a strange jewel is nailed to its top.", actor_narrator},
        [16] = {"You look at The Dig Master with a raised brow, your lip half-agape.", actor_narrator},
        [17] = {"Well? Why wait? Go get stones! Get key!", actor_digmaster},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"The Greywhisker twists his roast on the fire, not looking up as you approach.", actor_narrator},
        [2] = {"You step forward, extending your two open hands with the giant chunk of cheese.", actor_narrator},
        [3] = {"The Greywhisker's face does not budge. After a pause, his nose fidgets in your direction with a burst of sniffs.", actor_narrator},
        [4] = {"With a sudden clang of metal and stone, he lunges over loose stones and empty pots to stand in front of you.", actor_narrator},
        [5] = {"He holds an old cane with twirling designs before meeting a broken tip where a jewel might've been, where he rests a shaking hand.", actor_narrator},
        [6] = {"He grunts.", actor_narrator},
        [7] = {"You grunt.", actor_narrator},
        [8] = {"He grunts again, louder.", actor_narrator},
        [9] = {"You raise your hands a little higher.", actor_narrator},
        [10] = {"The old kobold uses the tip of his staff to unfold the paper stuck to the block.", actor_narrator},
        [11] = {"His white eyes study the paper for a long while. They dart to you occasionally, measuring your attire and pickaxe.", actor_narrator},
        [12] = {"In another—surprisingly hasty—dash, he goes to his tent and disappears.", actor_narrator},
        [13] = {"There's a clattering of boxes and unfurled bags before he emerges again. He approaches you with a small satchel.", actor_narrator},
        [14] = {"From the bag, he pulls a series of glowing stones, each a different color. With precision, he slams a prismatic specimen into his staff.", actor_narrator},
        [15] = {"To your amazement, the old kobold manages to let a grin slip.", actor_narrator},
        [16] = {"His arm bolts to his his beard of whiskers, rummaging about.", actor_narrator},
        [17] = {"From it, he pulls a strange looking slab. It glows orange and emits a strange hum.", actor_narrator},
        [18] = {"In the blink of an eye, his hand snatches the chunk of cheese from your hand, leaving the glowing fragment in its place.", actor_narrator},
        [19] = {"He grunts a final time before returning to the fire, cutting at the cheese with a broken dagger and placing it atop his roast.", actor_narrator},
        [20] = {"When you are ready, young one, come see me. I know this blueprint, from long ago.", actor_greywhisker},
        [21] = {"His hand moves to a blackened scar on forearm. His fingers rub at its rough edges.", actor_narrator},
        [22] = {"I will make the keys you seek. But, be warned: there is only doom on the other side of the lost chambers. Come to me when you are ready.", actor_greywhisker},
        [23] = {"You can now craft |c0047c9ffDig Site Keys|r in exchange for |c00ff9c00Ancient Fragments|r at the Greywhisker.", actor_narrator},
        [24] = {"A new icon in the middle of your skillbar allows for easy access. |c00ff9c00Ancient Fragments|r are acquired from certain shrines found within digs.", actor_narrator},
    })

    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"See, Koboltagonist! Easy.", actor_digmaster},
        [2] = {"Cheese never fail.", actor_digmaster},
        [3] = {"Now, take new key and open vault.", actor_digmaster},
        [4] = {"...", actor_digmaster},
        [5] = {"Okay fine. Risk mean reward. We pay you, too. Koboltagonist need gold, too, aye?", actor_digmaster},
        [6] = {"Gold and treasure! Yeehehehe-hoo!", actor_digmaster},
        [7] = {"...", actor_digmaster},
        [8] = {"Okay, go. Best only be you, how else you remain Koboltagonist? Kingdom fall for good without Dig Master.", actor_digmaster},
        [9] = {"He smiles to reveal staggered golden teeth.", actor_narrator},
        [10] = {"No problem, promise. Easy job! What worst that can happen?", actor_digmaster},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"The sheen of the Slag King's Relic glows bright in the wonderous eyes of the Dig Master.", actor_narrator},
        [2] = {"...you... you...", actor_digmaster},
        [3] = {"...you did it! By dirt! The Koboltagonist did it! Knew Koboltagonist was Koboltagonist, knew it!", actor_digmaster},
        [4] = {"He takes the relic and flails about excitedly before placing it on a giant pedastal.", actor_narrator},
        [5] = {"There are several empty pedastals nearby. Your eye pans across them before meeting the Dig Master, who looks at you with a keen brow.", actor_narrator},
        [6] = {"Koboltagonist, I see your gaze. You are smart one. Observing. Calculating.", actor_digmaster},
        [7] = {"True, this not the last relic to seek.", actor_digmaster},
        [8] = {"He places his map on the table. With careful hands, he peels the top of it away to reveal a hidden outline underneath.", actor_narrator},
        [9] = {"The new map features a series of colored diamonds: orange, green, red and blue. They each connect via odd shapes to its center, "
            .."which is marked by a red 'X'", actor_narrator},
        [10] = {"We get all four, from lost chambers. We unlock secret deep within tunnel, far below. Ancient vault. Treasure-filled.", actor_digmaster},
        [11] = {"He says the words while shifting a silver chain between his fingers. He then grips it and stands straight.", actor_narrator},
        [12] = {"You give a concerned shake of your head.", actor_narrator},
        [13] = {"Wha'? Always treasure in center of odd maps and strange doors! Puzzle, aye? What else?", actor_digmaster},
        [14] = {"We do this, Koboltagonist, for Kingdom. Must. Necessary. Required.", actor_digmaster},
        [15] = {"His confident facade quickly fades and he collapses his shoulders.", actor_narrator},
        [16] = {"Scrat! No... Fine! You right. I don't know how to find others. But you, Koboltagonist, have makings of Goldwhisker. Tales for next hundred years!", actor_digmaster},
        [17] = {"That why you here, no? But first, see Shinykeeper. To fight more big boyos, need more shinies.", actor_digmaster},
    })
    

    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"The Shinykeeper flips through a book while scratching his head. He notices you, placing the book upright on his workbench.", actor_narrator},
        [2] = {"It falls open, revealing empty pages.", actor_narrator},
        [3] = {"Kolbotagonist, we got problem. See book? You see?", actor_shinykeeper},
        [4] = {"He holds the book up. The empty pages fall out and scatter about the floor.", actor_narrator},
        [5] = {"No good... no good at all! How can we have shinies with book with no scribbles?", actor_shinykeeper},
        [6] = {"You look at him oddly.", actor_narrator},
        [7] = {"What? I scribble? I can't! Don't know how. Can only swing HAMMER!", actor_shinykeeper},
        [8] = {"The Shinykeeper holds his hammer outward in a daring pose.", actor_narrator},
        [9] = {"Now, you go! Get shiny book! Then we make all the shinies!", actor_shinykeeper},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"Ah! You got scribbles!", actor_shinykeeper},
        [2] = {"The Shinykeeper snatches the book from your hands and jumps to a page with expert precision.", actor_narrator},
        [3] = {"His eyes dart around, observing the details of... another blank page.", actor_narrator},
        [4] = {"You look at him confusedly. He shuts the book and grabs his hammer.", actor_narrator},
        [5] = {"Tweak the gizmo, slam the doohickey, polish the dinger!", actor_shinykeeper},
        [6] = {"Despite the chaotic display, the Shinykeeper emerges with a fancy slab that actually resembles boots.", actor_narrator},
        [7] = {"Here, for you, Koboltagonist. And much more coming! You bring gold, I make shinies. Many shinies! UNLIMITED shinies!", actor_shinykeeper},
        [8] = {"He returns to his workbench and raises his hammer, only to realize the table is now empty of supplies.", actor_narrator},
        [9] = {"Hehe... scrat. Koboltagonist. You got... gold, yes?", actor_shinykeeper},
        [10] = {"You have unlocked |c0000f066improved crafting|r at the Shinykeeper.", actor_narrator},
        [11] = {"Items sold by the Shinykeeper will roll with an additional stat, and have a chance to roll secondary attributes.", actor_narrator},
    })
    
    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"The Elementalist places his latest pair of boots on a carefully arranged pile of other enchanted boots.", actor_narrator},
        [2] = {"He stands still for a moment, observing his collection triumphantly with both hands at his hips.", actor_narrator},
        [3] = {"Koboltagonist! Timing always perfect, always where needed. Like true Koboltagonist. I have task.", actor_elementalist},
        [4] = {"Magic stones are very nice. Yes, very nice, indeed. But, something missing. Not quite right.", actor_elementalist},
        [5] = {"He rubs his brow with one hand while pacing slowly. You suspect he might hurt himself in intense thought before he jumps upright.", actor_narrator},
        [6] = {"By all that is gold! Of course...", actor_elementalist},
        [7] = {"...we missing crystals. Can't have shiniest of shinies with no crystals. Clear rock complement solid rock, yea?", actor_elementalist},
        [8] = {"You squint at the suggestion, but he continues before you can interject.", actor_narrator},
        [9] = {"You find for me? Crystals help make newer shinies to defeat big boyos.", actor_elementalist},
        [10] = {"The Elementalist returns to his collection. A pair of boots slips slightly, which he instantly fixes with a quick gesture and nod.", actor_narrator},
        [11] = {"He's clearly... busy. Best we be off.", actor_narrator},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"You slam the crystalline gizmo on the ground in front of the Elementalist.", actor_narrator},
        [2] = {"He screeches and jumps back in surprise, hiding behind a stack of debris.", actor_narrator},
        [3] = {"He hastily pokes his nose out from the pile of stone, sniffing intensely.", actor_narrator},
        [4] = {"My nose... it never lies... could it be...", actor_elementalist},
        [5] = {"The Elementalist bolts from behind the rubble, clattering his fingers over the crystal object with intense interest.", actor_narrator},
        [6] = {"...pure crystal! Strong infusion, high longevity, minimal energy input required. Maximal output guaranteed.", actor_elementalist},
        [7] = {"...", actor_elementalist},
        [8] = {"But... red?! Why always red?! Needed clear!", actor_elementalist},
        [9] = {"No, no matter. Red will do. Reverse arcane energy stream, fortify amplification process, borrow Shinykeeper hammer. He won't mind.", actor_elementalist},
        [10] = {"We begin immediately!", actor_elementalist},
        [11] = {"The Elementalist hands you a pile of magical ore.", actor_narrator},
        [12] = {"You have unlocked |c0000f066improved crafting|r at the Elementalist.", actor_narrator},
        [13] = {"Items crafted by the Elementalist will now roll secondary attributes.", actor_narrator},
    })
    
    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"Koboltagonist, news of next chamber! Thanks to Shinykeeper's new book.", actor_digmaster},
        [2] = {"The glimpse of empty pages enters your mind. You decide not to dwell on the Shinykeeper's methods. It's probably for the best.", actor_narrator},
        [3] = {"Tales speak of big creature in Mire, deep within. Lurking.", actor_digmaster},
        [4] = {"Big fish boyo ate adventurer carrying ancient relic...", actor_digmaster},
        [5] = {"The Dig Master rubs his belly while grinning.", actor_narrator},
        [6] = {"...understand? Of course you understand! You Koboltagonist! You expert! Probably done many times before.", actor_digmaster},
        [7] = {"...", actor_digmaster},
        [8] = {"Ahem. So, you slay big beastie? Second relic means halfway to vault!", actor_digmaster},
        [9] = {"Me? I go? No... no, can't go. See?", actor_digmaster},
        [10] = {"He raises his leg, which is wrapped in a bandage, and points with a frown.", actor_narrator},
        [11] = {"The Dig Master places it down without effort. You notice an apparent delay before he forces a wince out and clutches it dramatically.", actor_narrator},
        [12] = {"He grins with assumed innocence.", actor_narrator},
        [13] = {"You look on, unconvinced.", actor_narrator},
        [14] = {"*Sigh*... Koboltagonist, I be straight. I too old. Hard to admit, but can barely ride rat for much longer. Greywhisker years approaching.", actor_digmaster},
        [15] = {"And Elementalist, he too blind. Shinykeeper? Too cowardly, like most scouts.", actor_digmaster},
        [16] = {"But you? You so brave it almost stupid! Already have one relic, what's one more?", actor_digmaster},
        [17] = {"What you say?", actor_digmaster},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"The Dig Master notices you approaching and quickly resumes a limping position.", actor_narrator},
        [2] = {"You pull the ancient relic from your backpack and place it on the ground. It's fresh with slime.", actor_narrator},
        [3] = {"Ugh! Smells!", actor_digmaster},
        [4] = {"...", actor_digmaster},
        [5] = {"But... so... shiny!", actor_digmaster},
        [6] = {"The Dig Master grabs the relic, ripping the bandage from his leg and wiping it clean.", actor_narrator},
        [7] = {"He stops, grinning nervously with the relic held above.", actor_narrator},
        [8] = {"Ah, such shinies. Make leg better. Hehe...", actor_digmaster},
        [9] = {"The Dig Master places the relic on an empty pedastal. It seems to glow slightly brighter when paired with the first.", actor_narrator},
        [10] = {"So much closer to vault, Koboltagonist!", actor_digmaster},
        [11] = {"Unclear where next relic. I keep eye to ground, yea? Doh! I mean ear! Yes, ear. Or, eye? No, both!", actor_digmaster},
    })

    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"The Shinykeeper studies his hammer intently as you approach.", actor_narrator},
        [2] = {"Koboltagonist, proposition for you.", actor_shinykeeper},
        [3] = {"You like shinies, ya?", actor_shinykeeper},
        [4] = {"You nod.", actor_narrator},
        [5] = {"You like shinies that are more shiny than other shinies, ya?", actor_shinykeeper},
        [6] = {"You nod again.", actor_narrator},
        [7] = {"The Shinykeeper pulls out his 'scribbles' and looks over a page.", actor_narrator},
        [8] = {"It's another empty page. As you tilt your head sideways in typical, confused fashion, he slams the book shut.", actor_narrator},
        [9] = {"Design, I have. To make best of all shinies. But, big order coming up for Dig Master. Can't venture to acquire.", actor_shinykeeper},
        [10] = {"Requires research. Requires plans. Have plenty of research, but missing blueprint.", actor_shinykeeper},
        [10] = {"He doesn't say anything else. Instead, he looks at you in expected, measured silence.", actor_narrator},
        [11] = {"...", actor_shinykeeper},
        [12] = {"You grab your pickaxe and shoulder it. The Shinykeeper gives a familiar, whacky grin, then returns to hammering at a pile of junk.", actor_narrator},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"You place the discovered 'blueprint' on the Shinykeeper's workbench.", actor_narrator},
        [2] = {"He unfurls the document, only to be met with... an empty sheet of paper.", actor_narrator},
        [3] = {"Sensing disappointment in the silent stare, you turn to leave...", actor_narrator},
        [4] = {"...OF COURSE!", actor_shinykeeper},
        [5] = {"He rips the blank blueprint from the table and pins it to a drawing board.", actor_narrator},
        [6] = {"The Shinykeeper darts around his workshop, sifting through planks, bolts, cans, shoes, rods and pots.", actor_narrator},
        [7] = {"Around you turns to dust in the frenzy, with only the sound of clattering metal and a banging hammer.", actor_narrator},
        [8] = {"As the dust settles, the shape of a strange device can be made out in the corner of the room.", actor_narrator},
        [9] = {"Test, shall we? Yes, test! What you need... what useful. Hmm. Potions? Artifacts? No problem!", actor_shinykeeper},
        [10] = {"He throws a concoction of random junk into the machine, twists dials, turns knobs, inserts gold coins, then pulls a lever.", actor_narrator},
        [11] = {"The device roars to life, churning internally with crunching vibrations. As it comes to a halt, two thuds can be heard.", actor_narrator},
        [12] = {"Well, what you think? SUPER SHINY!", actor_shinykeeper},
        [13] = {"He hands you the two pieces of... well, they're not actually junk anymore. You raise your eyebrows, then nod slowly with satisfaction.", actor_narrator},
        [14] = {"Can't always get shinier shinies, but what fun if always shiny?", actor_shinykeeper},
        [15] = {"You have unlocked |c0000f066improved crafting|r at the Shinykeeper.", actor_narrator},
        [16] = {"Items crafted by the Shinykeeper now have a chance to be |c00c445ffEpic|r in quality.", actor_narrator},
    })

    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"The Elementalist stares blankly into the infusion crystal.", actor_narrator},
        [2] = {"You begin to move forward, but a loud crackle sends the Elementalist flying.", actor_narrator},
        [3] = {"He picks himself up and dusts off the black coal front his pant legs.", actor_narrator},
        [4] = {"New problem, Koboltagonist. Trying to make better shinies, but crystal not giving in. Overworked. Oversaturated.", actor_elementalist},
        [5] = {"Solution, I have.", actor_elementalist},
        [6] = {"More crystal! Only way. Twice the crystal, twice the work.", actor_elementalist},
        [7] = {"Bring new one, and I show you what is possible.", actor_elementalist},
        [8] = {"...", actor_elementalist},
        [9] = {"Oh, and not red! Anything but red.", actor_elementalist},
        [10] = {"He resumes his incantation in the reflection of the crystalline mirror.", actor_narrator},
        [11] = {"You notice singed hairs atop his head, but decide to leave him be as he begins to mumble strange sounds.", actor_narrator},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"The Elementalist removes the crystal from your hands.", actor_narrator},
        [2] = {"Bah! Red again!", actor_elementalist},
        [3] = {"He looks at you with contempt for a moment before noticing your torn pants, half-melted candle, and bruised arms.", actor_narrator},
        [4] = {"Ah, Koboltagonist, forgive. Hard to get. Whining too much. Why strange mage always the one to whine?", actor_elementalist},
        [5] = {"Red will do. Stand back.", actor_elementalist},
        [6] = {"...", actor_elementalist},
        [7] = {"He places the crystal on its new podium and begins a new incantation.", actor_narrator},
        [8] = {"You listen intently, placing your backpack on a nearby table and taking a step back, twice as far this time).", actor_narrator},
        [9] = {"Before you can object, the Elementalist grabs your backpack from the table.", actor_narrator},
        [10] = {"A plume of smoke erupts from the crystal, followed by purple lights.", actor_narrator},
        [11] = {"I command thee, backpack, to take on the power of... EPICNESS!", actor_elementalist},
        [12] = {"The area clears, and the Elementalist emerges, covered head to toe in black soot.", actor_narrator},
        [13] = {"You see! Easy! Can't guarantee every time. But, some of the time: EPICNESS.", actor_elementalist},
        [14] = {"You have unlocked |c0000f066improved crafting|r at the Elementalist.", actor_narrator},
        [15] = {"Items crafted by the Elementalist now have a chance to be |c00c445ffEpic|r in quality.", actor_narrator},
    })

    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"The Dig Master stands between the two relics. Occasionally, he pokes at one, but nothing happens.", actor_narrator},
        [2] = {"So close, Koboltagonist. Progress bar half full. Or half empty?", actor_digmaster},
        [3] = {"Bah, no matter. I sense third chamber is near. Look at what scouts bring to me.", actor_digmaster},
        [4] = {"He holds up a massive tooth in his hand, its width double that of his palm.", actor_narrator},
        [5] = {"Scouts dug deep into dry tunnels today. We thought nothing down there!", actor_digmaster},
        [6] = {"Chamber door open already, by previous adventurer.", actor_digmaster},
        [7] = {"Scouts were ambushed! HUGE boyo! Well, haven't seen with own eyes. But, scouts say it looked huge! Smelled huge!", actor_digmaster},
        [8] = {"They say, too, that shiny object stuck in back. Part of hide. Shimmering, like them...", actor_digmaster},
        [9] = {"He points to the glowing orange relic of the Slag King.", actor_narrator},
        [10] = {"...you know what that means, Koboltagonist.", actor_digmaster},
        [11] = {"Sadly, beast dragged scout back into chamber. Door shut once more. Not opened again.", actor_digmaster},
        [12] = {"Vault so close! Progress bar close to full! No, partly empty!", actor_digmaster},
        [13] = {"Go now. But, watch out big teeth.", actor_digmaster},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"You heave the heavy relic onto the pedastal, saving the Dig Master the trouble.", actor_narrator},
        [2] = {"As it settles into the grip of its iron holster, a faint ringing can be heard, and each piece glows slightly brighter.", actor_narrator},
        [3] = {"Ahhhh...", actor_digmaster},
        [4] = {"The Dig Master rubs his hands together and grins.", actor_narrator},
        [5] = {"Hopefully not too much trouble. How big beastie? Super big?", actor_digmaster},
        [6] = {"He looks at you with curiosity. You're covered head to toe in a layer of thick dirt.", actor_narrator},
        [7] = {"Ah, not so bad! Well, at least you okay!", actor_digmaster},
        [8] = {"He slams you on the back, the dust flying everywhere.", actor_narrator},
        [9] = {"Progress bar very close to done, Koboltagonist. Soon, we unlock greatest treasure in Kingdom history!", actor_digmaster},
        [10] = {"Heard of ogres from cold tunnels. Made camp nearby. Rumor of last relic knowledge, but probably need favor.", actor_digmaster},
        [11] = {"Try them. I get scouts and lead way to vault. We prepare. We plan for grand opening. Grand party!", actor_digmaster},
    })

    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"No, it was a dragon!", actor_grog},
        [2] = {"Lizard!", actor_slog},
        [3] = {"Dragggoooonnnnn!", actor_grog},
        [4] = {"The two ogres stare each other down with raised fists before noticing your tiny figure standing between them.", actor_narrator},
        [5] = {"Baaah! What that!", actor_grog},
        [6] = {"Just a kobold, Grog. He won't hurt ye', ya dolt.", actor_slog},
        [7] = {"The blue ogre picks you up with a single hand and dangles you, his other hand pressed to his chin in contemplation.", actor_narrator},
        [8] = {"Having almost been eaten by a giant, ancient dinosaur five times his size, you put on a display of absolutely no trepidation.", actor_narrator},
        [9] = {"I like this one, Grog.", actor_slog},
        [10] = {"He places you back down.", actor_narrator},
        [11] = {"This be the Koboltagonist the Dig Masta been talkin' 'bout! Perfect for us'n, Grog.", actor_slog},
        [12] = {"Dat pipsqueak ain't makin' me go back down 'der! Kobo'tagonist er' not.", actor_grog},
        [13] = {"Whot?! You won't go down that wee lil' tunnel, but this lil' digging rat will?", actor_slog},
        [14] = {"You nod once when the ogre looks to you.", actor_narrator},
        [15] = {"Bah, fine, Grog, you overgrown baby. Why you even carry dat club around wichye? Should hand'it to this 'ere warrior rat instead!", actor_slog},
        [16] = {"The tan ogre turns, waving a hand in disregard and looking the other way.", actor_narrator},
        [16] = {"I ain't got it no more.", actor_grog},
        [17] = {"Wha? You dropped it?! Can't even hold onto ye' club during a mild jog?", actor_slog},
        [18] = {"Hmph!", actor_grog},
        [19] = {"The blue ogre shakes his head in disappointment and turns to you.", actor_narrator},
        [20] = {"Well, lil' rat, I'll have to stay here an' make sure Grog don't wander off down the wrong tunnel. He's bit scared of 'dat big lizard.", actor_slog},
        [21] = {"Dig Master says ye' be looking for the last shiny rock. We knows where it is. We tells ye'.", actor_slog},
        [22] = {"But first, needs something of ye'. I think Grog will get his grips back with his ol' club. Fetch it from the cold tunnels fors 'im, aye?", actor_slog},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"With a thud, you slam the hilt of the giant ogre club near the campfire.", actor_narrator},
        [2] = {"The blue ogre looks at you and cracks a grin before looking to his companion, who takes the club effortlessly with one hand and wields it about.", actor_narrator},
        [3] = {"Ahah! I tolds ye'! You lost, pay up!", actor_slog},
        [4] = {"Bah, fine!", actor_grog},
        [5] = {"Grog reaches into a nearby satchel and retrieves a sack of gold coins and places it in Slog's hand.", actor_narrator},
        [6] = {"Hah! Oi, get your spirits up, mate. This lil' one just got your courage back. By 'imself, too!", actor_slog},
        [7] = {"...", actor_grog},
        [8] = {"You look on with notable indifference.", actor_narrator},
        [9] = {"Ah, you ain't one for the silly bits, lil' rat. No problem 'ere.", actor_slog},
        [10] = {"Looky 'ere, as promised. What yer lookin' for is down this abandon tunnel.", actor_slog},
        [11] = {"He places a thin cloth on your hand featuring a rough map outlined with a shard of campfire coal.", actor_narrator},
        [12] = {"Old magic used down there, long ago. Blue Dragonflight or a thing'a that nature. Some big creature, big lizard...", actor_slog},
        [13] = {"...dragon...", actor_grog},
        [14] = {"No matter, whatever 'tis! It's deadly. We ain't stayed to see what it was. You just be careful down there, y'hear?", actor_slog},
    })

    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"Words spread like hot wax, Koboltagonist! We hear of good news.", actor_digmaster},
        [2] = {"You hand the ogre's cloth map to the Dig Master.", actor_narrator},
        [3] = {"Ah, deep within ice tunnels. Good! Faster we open last chamber, get last relic, faster we get treasure.", actor_digmaster},
        [4] = {"Ogres good idea, glad I let them stay. How else we know of last piece?", actor_digmaster},
        [5] = {"The Dig Master puts on a smug look and stands tall as he looks over his trophies. A little too smug.", actor_narrator},
        [6] = {"He notices you watching him intently.", actor_narrator},
        [7] = {"Aye, aye. All because of you, too. But I help too, this time. Ay?", actor_digmaster},
        [8] = {"No time for idle-scrat, Koboltagonist. Go be Koboltagonist! You well trained for beasties now!", actor_digmaster},
        [9] = {"Kobolds always send the best!", actor_digmaster},
        [10] = {"Now ours, hehehehaha!", actor_digmaster},
        [11] = {"*Cough*... Ahem...", actor_digmaster},
        [12] = {"Off to the lizard-dragon, Koboltagonist!", actor_digmaster},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"The relic has returned! Oh, and Koboltagonist, too.", actor_digmaster},
        [2] = {"The Dig Master rubs his hands together impatiently.", actor_narrator},
        [3] = {"No time to wait. Place it! Place it! Place it!", actor_digmaster},
        [4] = {"...", actor_digmaster},
        [5] = {"...ahem. At your own pace, Koboltagonist. Right. We only have 'cause of you. Scrat! No manners.", actor_digmaster},
        [6] = {"You approach the final pedastal with the glowing blue relic from the slain ice monster. The Dig Master inches forward as you do.", actor_narrator},
        [7] = {"As you bend a knee to release it, a mysterious force rips it from your hands and slams it into place, knocking you back.", actor_narrator,
            nil, nil, nil, function() utils.looplocalp(function() StopSound(kui.sound.menumusic, false, true) end) end},
        [8] = {"The four pieces link together in a series of elemental lights.", actor_narrator, nil, nil, nil, mergeancientrelics},
        [9] = {"The artifacts' colors merge on the ground, forming a single slab of light.", actor_narrator},
        [10] = {"In a flash, a beam projects upward to reveal a strange portal.", actor_narrator},
        [11] = {"...", actor_narrator},
        [12] = {"The light settles, and the room is quiet, save for the the monotonous hum of the portal.", actor_narrator},
        [13] = {"You unshield your eyes, taking in the new scene.", actor_narrator},
        [14] = {"You walk over to the slab of light. You feel the warmth as its energy, but nothing else occurs.", actor_narrator},
        [15] = {"Bah, scrat!", actor_digmaster},
        [16] = {"The Dig Master shuffles from underneath a table, returning to edge of the portal.", actor_narrator},
        [17] = {"By all gold of Azeroth... well, what now?", actor_digmaster},
        [18] = {"For the first time ever, the Dig Master remains still and quiet, contemplating the floor of light with one hand held to his chin.", actor_narrator},
        [19] = {"He tries to move the relics, but they are firmly locked in place by a mysterious force.", actor_narrator},
        [20] = {"After fidgeting with different objects and instruments, the Dig Master surrenders and throws up his arms.", actor_narrator},
        [21] = {"Out of ideas, Koboltagonist.", actor_digmaster},
        [22] = {"Scrat! Can't be end! Shouldn't be!", actor_digmaster},
        [23] = {"So close!", actor_digmaster},
        [24] = {"He rubs at his pockets several times.", actor_narrator},
        [25] = {"Bah, no more cheese!", actor_digmaster},
        [26] = {"You squint at him.", actor_narrator},
        [27] = {"Wha'? Worth shot.", actor_digmaster},
        [28] = {"The Dig Master sighs loudly and returns to his table to tinker.", actor_narrator},
        [29] = {"A thought enters your mind of the old kobold and his scar. He must know more of what is required.", actor_narrator},
    })

    screenplay.chains.quest[idf()] = {}
    screenplay.chains.quest[id].start = speak.chain:build({
        [1] = {"The Greywhisker sits on a petrified stone near his fire with both eyes shut.", actor_narrator},
        [2] = {"He chants on occasion, to which the stones near the fire shift and its embers flare.", actor_narrator},
        [3] = {"You take a seat on the opposite side of the pit and wait patiently.", actor_narrator},
        [4] = {"He opens one eye for a moment, then shuts it again.", actor_narrator},
        [5] = {"Such a sight, is it not? The relics of old, united once more. I have not seen it in many moons.", actor_greywhisker},
        [6] = {"You stop prodding embers in the fire and look to the old mage.", actor_narrator},
        [7] = {"Heh. It is not the first time that portal has graced this cavern.", actor_greywhisker},
        [8] = {"Nearly three and ten winters ago, the old guard of 'mancers, and myself, set foot in that vault.", actor_greywhisker},
        [9] = {"It was a different time. When us kobolds of the deep lacked proper earthly magic. We stood no chance.", actor_greywhisker},
        [10] = {"And we were not the first. Many adventurers from the surface have attempted that place.", actor_greywhisker},
        [11] = {"Evident by their bones that we scoured for loot.", actor_greywhisker},
        [12] = {"We did not scavenge for long. The creaking and churning of gears caught our attention in the edge of the darkness.", actor_greywhisker},
        [13] = {"That is when it struck. Not beast or of flesh, but of gold and jewels. Merged together over millennia, it would seem.", actor_greywhisker},
        [14] = {"Contorted and twisted into a form that is only meant to punish those who seek it.", actor_greywhisker},
        [15] = {"In the silence, embers pop and bursts of sparks float away. The echoes of picks on rock can be heard from deeper within the tunnel as kobolds work.", actor_narrator},
        [16] = {"Do you think you will fare different, young one?", actor_greywhisker},
        [17] = {"You frown and hold your pickaxe, rubbing at its silver edge.", actor_narrator},
        [18] = {"I will not be the one to stand in your way. It was adventure and riches which I desired in my youth, and too many discouraged it.", actor_greywhisker},
        [19] = {"I let their weakness stall my moment of glory.", actor_greywhisker},
        [20] = {"The Greywhisker stands tall, cane in hand.", actor_narrator},
        [21] = {"Is the vault what you desire?", actor_greywhisker},
        [22] = {"You hesitate. A glimpse of gleaming gold fills your head.", actor_narrator},
        [23] = {"You nod once.", actor_narrator},
        [24] = {"So be it.", actor_greywhisker},
        [25] = {"The Greywhisker pulls the prismatic gem from his staff and unties the leather of its hilt, the scabbard showing a luminous circle and strange letters.", actor_narrator},
        [26] = {"This is the last of the old keys, and the human tongue that describes how to use it. However, it has long been drained of its power.", actor_greywhisker},
        [27] = {"He hands you the cloth, which you place carefuly in your dig map.", actor_narrator},
        [28] = {"This map will allow you to access |c0000f066The Vault|r through the portal, so long as you carry it, but not its core chamber.", actor_greywhisker},
        [29] = {"You will need to gather enough |c00ff9c00Ancient Fragments|r so that I can imbue the prism with energy to reach the vault's depths.", actor_greywhisker},
        [30] = {"Only when the vault's guardian is defeated can our kobolds secure its trove.", actor_greywhisker},
        [31] = {"When you have acquired enough fragments, return to me, and we will see if you follow the path to glory, or the path to doom.", actor_greywhisker},
        [32] = {"One of those roads has already been traveled between us. Let us hope it does not repeat itself...", actor_greywhisker},
    })

    screenplay.chains.quest[id].finish = speak.chain:build({
        [1] = {"You step in front of the Dig Master, your clothing scorched by molten gold and your head burned clean of hair.", actor_narrator, nil, nil, nil,
            function() utils.stopsoundall(kui.sound.menumusic) end},
        [2] = {"Bah!", actor_digmaster},
        [3] = {"...", actor_digmaster},
        [4] = {"Oh, Koboltagonist, didn't recognize. Thought you tunnel mole! Naked one, too!", actor_digmaster},
        [5] = {"With a heavy grunt, you drop the solid gold head of the defeated amalgam on the table.", actor_narrator},
        [6] = {"The Dig Master rushes to it, rubbing his hand over its raised brow and pointed teeth while staring into its two ruby sockets.", actor_narrator},
        [7] = {"By skirt—I mean drat—I mean scrat, by dirt!", actor_digmaster},
        [8] = {"He pauses and looks to you from the corner of his eye, per usual.", actor_narrator},
        [9] = {"More?", actor_digmaster},
        [10] = {"You nod, then point to your map with the runic scabbard, then to the portal. You hand the cloth to the Dig Master.", actor_narrator},
        [11] = {"Yes, yes! I get Shinykeeper and diggers, we leave first thing!", actor_digmaster},
        [12] = {"You done good Koboltagonist.", actor_digmaster},
        [13] = {"The Dig Master nearly knocks over his table as he rummages for bags and buckets, stacking and tying them them atop his giant rat steed.", actor_narrator},
        [14] = {"As he comes to a halt—his head now also hosting a silver bucket—he glances to you with eager eyes.", actor_narrator},
        [15] = {"...", actor_digmaster},
        [16] = {"Koboltagonist? You come? Need more buckets!", actor_digmaster},
        [17] = {"You nod.", actor_narrator, nil, nil, nil, function() utils.fadeblack(true, 2.0) end},
        [18] = {"Before long, the Dig Master is gone, making a head start for the great vault through the portal with the Shinykeeper, Elementalist, and diggers in tow.", actor_narrator},
        [19] = {"You look around, frst to the Shinykeeper's forge, then to the infusion crystals lining the back wall.", actor_narrator},
        [20] = {"No other kobolds are in sight. The main tunnel looks to have been left temporarily unattended in the mad dash to the treasure room.", actor_narrator},
        [21] = {"You go to see the Greywhisker, but he is not near his camp. His tent is packed and gone, and the fire pit doused.", actor_narrator},
        [22] = {"You ponder his intentions, but are distracted by the thought of the conquests achieved this day.", actor_narrator},
        [23] = {"Something inside you yearns for it again.", actor_narrator},
        [24] = {"But, later. Rest is well-earned. You did a lot today, for a tiny rat with a candle and pickaxe.", actor_narrator},
        [25] = {"With an unabashed grin, you grab your rucksack, shoulder your trusty tool, and make for the vault portal at a slow and steady pace.", actor_narrator},
        [26] = {"You near the Dig Master's table, where the ogre's club has been placed for whatever reason. They appear to have joined in on the treasure hunt.", actor_narrator},
        [27] = {"As you pass by, the chisel of your pickaxe swings outward from your stride and knocks over the brutish ogre's club.", actor_narrator},
        [28] = {"Its stone head cracks open from the impact. You look around, but there's still no one.", actor_narrator},
        [29] = {"As you shrug and take a step to leave, you catch a reflection from the wreckage.", actor_narrator},
        [30] = {"You reach down to the cracked mallet, tossing it with one hand. It crumbles into dust, leaving only a strange, purple orb.", actor_narrator},
        [31] = {"It pulsates with dark swirls of black and magenta.", actor_narrator},
        [32] = {"You bend down and rub its surface with loose fingers. Something inside it calls to you.", actor_narrator},
        [33] = {"You hesitate. After a short delay, you pick it up and place it in your pack.", actor_narrator},
        [34] = {"But, that's for another day.", actor_narrator},
        [35] = {"", actor_narrator,
            nil, nil, nil, function()
            speak:show(false, true)
            speak.showskip = true
            utils.playsoundall(kui.sound.completebig)
            alert:new(color:wrap(color.tooltip.alert, "The End|n")..color:wrap(color.tooltip.good, " Thanks for playing!"), 7.5)
            utils.timed(9.0, function() utils.fadeblack(false, 2.0) speak:endscene() end)
            utils.timed(11.0, function() utils.playsoundall(kui.sound.menumusic) end)
        end},
    })

end
