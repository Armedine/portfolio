-- "Speak" JRPG Dialogue System Overview:


    speak:initscene()
--[[
        Run this command to initialize the scene camera and prepare the dialogue box.

        In this function, you may want to add/remove map-wide settings as needed for your use case.

        *Note: if you init scenes instead of playing them immediately, you might want to manually position the camera
        using 'camtargetx' and 'camtargety' (see below).

        Properties:
            .scenecam    = the camera object settings to use (to change before scenes, use 'speak.scenecam = gg_cam_yourCustomCamera')
            .camtargetx  = position the camera here (if unit pan is enabled, it will be automated while items play).
            .camtargety  = ``
--]]


    speak:startscene(chain[, ...])
--[[
        @chain = the chain object containing the sequence of dialogue items, aka the scene, to run.
        You can pass multiple chains as arguments and they will merge in their passed order (e.g. chain01, chain02, chain 03[, ...])

        Run this command to begin the chain of dialogue items.

        You can reference the cached chain object with 'speak.currentchain', which is a temporary clone of @chain.

        To retrieve the current position in the chain, one can use 'speak.currentindex'. This could be useful to check for scene progress
        inside of other functions if needed (an idea that comes to mind is cleaning up eye-candy effects or units made in the area).
--]]


    speak:endscene()
--[[
        This command runs automatically when a scene's current chain object is exhausted (i.e. last item is played).
 
        If desired, you could call this automatically under specified conditions or via hotkeys to cut scenes short.
--]]


    speak:pause()
--[[
        Pause a scene, hiding the dialogue box and preventing continue actions.

        Useful if you want to hide the box, run a cinematic sequence, then resume social interactions.
--]]


    speak:resume()
--[[
        Resume a scene from the stored speech chain point, showing the dialogue box once more.
--]]


    speak.actor:new()
--[[
        @returns table.

        Create a new actor object.

            Properties:
                .unit       = unit; actor's assigned unit (flash indicator and for referencing in functions).
                .portrait   = table; the file paths for displaying character's reaction portrait.
                .name       = string; defaults to assigned unit's name.
--]]


    speak.actor:assign(unit, portrait)
--[[
        @unit = the owner of the speech item.
        @portrait = the portrait object for the actor.

        This function fulfills the requirements of an actor, and will also accept anonymous tables as arguments for @portrait,
        allowing you to quickly build new actors with terse code.

        See the 'screenplay' demo script file for an explicit example.
--]]


    speak.item:new()
--[[
        @returns table.

        Create a new speech item object.

            Properties
                .text       = string; the characters that render in the dialogue box when called.
                .actor      = table; the actor object that owns the speech item.
                .emotion    = string; the emotion string for looking up the actor's matching portrait.
                .anim       = string; string animation to play when called.
                .sound      = sound; the sound to play when called.
                .func       = function; the function to play when called.

        See the 'screenplay' demo script file for an explicit example.
--]]


    speak.chain:new()
--[[
        @returns table.

        Create a new speech item chain object.

        Chains are simple table classes and should be index-value paired, by which they are called in ascending index order when
        injected into 'speak:startscene(chain)'. Chain objects have no config properties other than their indexed item content.
--]]


    speak.chain:add(item, index)
--[[
       @item = speech item object to add.
       @index = [optional] the location to insert (pops into table, pushing other values up if present).

        Add an item to a chain (provide no @index to insert at the top i.e. new index).

        example: my_scene01:add(my_item)
--]]


    speak.chain:remove(item)
--[[
        @item = speech item to remove.

        Remove an item from a chain.

        example: my_scene01:remove(my_item)
--]]


    speak.chain:build(t)
--[[
        @t = a table used as a simple constructor for dialogue items, to allow for vertical reading like you would a real screenplay.
        @returns table.

        Example:
        my_build_table = {
            [1] = { "Some kind of dialogue.", actor1 , emotion1, anim1, sound1, func1 }
            [2] = { "Some kind of dialogue.", actor2 , emotion2, anim2, sound2, func2 }
            [3] = { "Some kind of dialogue.", actor3 , emotion3, anim3, sound3, func3 }
        }
        my_new_scene = speak.chain:build(my_build_table)

        See the 'screenplay' demo script file for an explicit example.
--]]