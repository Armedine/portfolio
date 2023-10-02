--[[------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*    TimerQueue and Stopwatch 1.0 by AGD and Eikonium
*    -> https://www.hiveworkshop.com/threads/timerqueue-stopwatch.339411/
*
* --------------------
* | TimerQueue class |
* --------------------
*        - A TimerQueue is an object that can queue any number of delayed function calls, while being based on a single timer.
*        - The main use of a timer queue is to simplify delayed function calls. The class however also provides methods to pause, resume, reset and destroy a TimerQueue as a whole - and even includes error handling.
*        - As such, you can create as many independent TimerQueues as you like, which you can individually pause, reset, etc.
*        - All methods can also be called on the class directly, which frees you from needing to create a TimerQueue object in the first place. You still need colon-notation!
*    TimerQueue.create() --> TimerQueue
*        - Creates a new TimerQueue with its own independent timer and function queue.
*    <TimerQueue>:call_delayed(number delay, function callback, ...)
*        - Calls the specified function (or callable table) after the specified delay (in seconds) with the specified arguments (...). Does not delay the following lines of codes.
*    <TimerQueue>:reset()
*        - Discards all queued function calls from the Timer Queue. Discarded function calls are not executed.
*        - You can continue to use <TimerQueue>:call_delayed after resetting it.
*    <TimerQueue>:pause()
*        - Pauses the TimerQueue at its current point in time, effectively freezing all delayed function calls that it currently holds, until the queue is resumed.
*        - Using <TimerQueue>:call_delayed on a paused queue will correctly add the new callback to the queue, but time will start ticking only after resuming the queue.
*    <TimerQueue>:resume()
*        - Resumes a TimerQueue that was previously paused. Has no effect on TimerQueues that are not paused.
*    <TimerQueue>:destroy()
*        - Destroys the Timer Queue. Remaining function calls are discarded and not being executed.
*    <TimerQueue>.debugMode : boolean
*        - Set to true to let erroneous function calls through <TimerQueue>:call_delayed print error messages on screen.
*        - Default: true.
* -------------------
* | Stopwatch class |
* -------------------
*        - Stopwatches are similar to normal timers, except that they count upwards instead of downwards. Thus, they can't trigger any callbacks (use normal timers or TimerQueues for that),
*           but are just measures for how much time has passed since you have started it.
*    Stopwatch.create(boolean startImmediately_yn) --> Stopwatch
*        - Creates a Stopwatch, which you can choose to start immediately.
*    <Stopwatch>:start()
*        - Starts or restarts a Stopwatch, i.e. resets the elapsed time of the Stopwatch to zero and starts counting upwards.
*    <Stopwatch>:getElapsed() --> number
*        - Returns the time in seconds that a Stopwatch is currently running, i.e. the elapsed time since start.
*    <Stopwatch>:pause()
*        - Pauses a Stopwatch, so it will retain its current elapsed time, until resumed.
*    <Stopwatch>:resume()
*        - Resumes a Stopwatch after having been paused.
*    <Stopwatch>:destroy()
*        - Destroys a Stopwatch. Necessary to prevent memory leaks.
---------------------------------------------------------------------------------------------------------------------------------------------------------]]

do

    ---@class TimerQueue
    TimerQueue = {
        timer = nil                     ---@type timer the single timer this system is based on (one per instance of course)
        ,   elapsed = 0.                ---@type number current elapsed mark that gets added to the callback delay to receive the "absolute" point in time, where a function will be called.
        ,   queue = {}                  ---@type table queue of waiting callbacks to be executed in the future
        ,   n = 0                       ---@type integer number of elements in the queue
        ,   on_expire = function() end  ---@type function callback upon expiring.
        ,   debugMode = true            ---@type boolean setting this to true will print error messages, when the input function couldn't be executed properly
    }
    TimerQueue.__index = TimerQueue

    --Creates a timer on first access of the static TimerQueue:call_delayed method. Avoids timer creation inside the Lua root.
    setmetatable(TimerQueue, {__index = function(t,k) if k == 'timer' then t[k] = CreateTimer() end; return rawget(t,k) end})

    local pack, unpack, timerStart, pauseTimer, getElapsed = table.pack, table.unpack, TimerStart, PauseTimer, TimerGetElapsed

    ---@param timerQueue TimerQueue
    local function on_expire(timerQueue)
        local queue, timer = timerQueue.queue, timerQueue.timer
        local topOfQueue = queue[timerQueue.n] --localize top element of queue
        queue[timerQueue.n] = nil --pop top element of queue to prevent pcall (below) from resorting the queue (might happen for nested call_delayed)
        timerQueue.n = timerQueue.n - 1
        timerQueue.elapsed = topOfQueue[1]
        if timerQueue.n > 0 then
            timerStart(timer, queue[timerQueue.n][1] - topOfQueue[1], false, timerQueue.on_expire)
        else
            timerQueue.elapsed = 0.
            -- These two functions below may not be necessary
            timerStart(timer, 0, false, nil)
            pauseTimer(timer)
        end
        local errorStatus, errorMessage = pcall(topOfQueue[2], unpack(topOfQueue[3], 1, topOfQueue[3].n))
        if timerQueue.debugMode and not errorStatus then
            print("|cffff5555" .. errorMessage .. "|r")
        end
    end

    TimerQueue.on_expire = function() on_expire(TimerQueue) end

    ---Creates a new TimerQueue.
    ---@return TimerQueue
    function TimerQueue.create()
        local new = {}
        setmetatable(new, TimerQueue)
        new.timer = CreateTimer()
        new.elapsed = 0.
        new.queue = {}
        new.n = 0
        new.on_expire = function() on_expire(new) end
        return new
    end

    ---Calls a function (or callable table) after the specified timeout (in seconds) with all specified arguments (...). Does not delay the following lines of codes.
    ---@param timeout number
    ---@param callback function|table if table, must be callable
    ---@vararg any arguments of the callback function
    function TimerQueue:call_delayed(timeout, callback, ...)
        timeout = math.max(timeout, 0.)
        local queue, timer = self.queue, self.timer
        local queue_timeout = timeout + self.elapsed + math.max(getElapsed(timer), 0.) --TimerGetElapsed() can return negative values sometimes, not sure why.
        self.n = self.n + 1
        local i = self.n
        queue[i] = {queue_timeout, callback, pack(...)}
        -- Sort timeouts in descending order
        while i > 1 and queue_timeout >= queue[i - 1][1] do
            queue[i], queue[i - 1] = queue[i - 1], queue[i]
            i = i - 1
        end
        if i == self.n then --New callback is the next to expire (i == self.n means that no sorting happened)
            -- Update timer timeout to the new callback timeout.
            self.elapsed = queue_timeout - timeout
            timerStart(timer, timeout, false, self.on_expire)
        end
    end

    ---Call a function repeatedly until its returned condition is true (i.e. lite-mimic of a 'while' loop where returning true is 'break').
    ---@param user_func fun():boolean -- return true to end the timer.
    function TimerQueue:call_echo(timeout, user_func)
        local function wrapper()
            if not user_func() then
                TimerQueue:call_delayed(timeout, wrapper)
            end
        end
        TimerQueue:call_delayed(timeout, wrapper)
    end

    ---Removes all queued calls from the Timer Queue, so any remaining actions will not be executed.
    ---Using <TimerQueue>:call_delayed afterwards will still work.
    function TimerQueue:reset()
        timerStart(self.timer, 0., false, nil)
        pauseTimer(self.timer)
        self.elapsed = 0.
        self.n = 0
        self.queue = {}
    end

    ---Pauses the TimerQueue at its current point in time, preventing all queued callbacks from being executed, until the queue is resumed.
    ---Using <TimerQueue>:call_delayed on a paused queue will correctly add the new callback to the queue, but time will start ticking only after the queue is being resumed.
    function TimerQueue:pause()
        local timer = self.timer
        local queue, elapsed = self.queue, self.elapsed + math.max(getElapsed(timer), 0.)
        self.elapsed = 0.
        for i = 1, self.n do
            queue[i][1] = queue[i][1] - elapsed
        end
        timerStart(timer, (self.n > 0 and queue[self.n][1]) or 0., false, self.on_expire) --lets TimerGetElapsed return the new elapsed value, when calling call_delayed, while the queue is paused.
        pauseTimer(self.timer)
    end

    ---Resumes a TimerQueue that was paused previously. Has no effect on running TimerQueues.
    function TimerQueue:resume()
        ResumeTimer(self.timer) --ResumeTimer has no effects on timers that are not paused.
    end

    ---Destroys the timer object behind the TimerQueue. The Lua object will be automatically garbage collected once you ensure that there is no more reference to it.
    function TimerQueue:destroy()
        pauseTimer(self.timer) --https://www.hiveworkshop.com/threads/issues-with-timer-functions.309433/ suggests that non-paused destroyed timers can still execute their callback
        DestroyTimer(self.timer)
    end

    ---@class Stopwatch
    Stopwatch = {
        timer = {}                                  ---@type timer the countdown-timer permanently cycling
        ,   elapsed = 0.                            ---@type number the number of times the timer reached 0 and restarted
        ,   increaseElapsed = function() end        ---@type function timer callback function to increase numCycles by 1 for a specific Stopwatch.
    }
    Stopwatch.__index = Stopwatch

    local CYCLE_LENGTH = 3600. --time in seconds that a timer needs for one cycle. doesn't numberly matter.

    ---Creates a Stopwatch.
    ---@param startImmediately_yn boolean Set to true to start immediately. If not specified or set to false, the Stopwatch will not start to count upwards.
    function Stopwatch.create(startImmediately_yn)
        local new = {}
        setmetatable(new, Stopwatch)
        new.timer = CreateTimer()
        new.elapsed = 0.
        new.increaseElapsed = function() new.elapsed = new.elapsed + CYCLE_LENGTH end
        if startImmediately_yn then
            new:start()
        end
        return new
    end

    ---Starts or restarts a Stopwatch, i.e. resets the elapsed time of the Stopwatch to zero and starts counting upwards.
    function Stopwatch:start()
        self.elapsed = 0.
        timerStart(self.timer, CYCLE_LENGTH, true, self.increaseElapsed)
    end

    ---Returns the time in seconds that a Stopwatch is currently running, i.e. the elapsed time since start.
    ---@return number
    function Stopwatch:getElapsed()
        return self.elapsed + getElapsed(self.timer)
    end

    ---Pauses a Stopwatch, so it will retain its current elapsed time, until resumed.
    function Stopwatch:pause()
        pauseTimer(self.timer)
    end

    ---Resumes a Stopwatch after having been paused.
    function Stopwatch:resume()
        self.elapsed = self.elapsed + getElapsed(self.timer)
        timerStart(self.timer, CYCLE_LENGTH, true, self.increaseElapsed) --not using ResumeTimer here, as it actually starts timer from new with the remaining time and thus screws up TimerGetElapsed().
    end

    ---Destroys the timer object behind the Stopwatch. The Lua object will be automatically garbage collected once you ensure that there is no more reference to it.
    function Stopwatch:destroy()
        DestroyTimer(self.timer)
    end
end
