local obj = {}

-- Metadata
obj.name = "NineMouseChords"
obj.version = "0.1"
obj.author = "colin <colin@chb.xyz>"
obj.license = "BSD-2-Clause - https://opensource.org/license/bsd-2-clause"
obj.homepage = "https://github.com/colinhb/NineMouseChords"

-- Constants
local DEBUG = false
local MIDDLE_BUTTON = 2
local KEYSTROKE_DELAY = 0.0001
local excludedApps = {"acme"}

-- State
obj.isChording = false

obj.logTime = { lastTime = nil, lastClock = nil }

-- Log message with timing delta since last log
function obj:ulog(message)
    if not DEBUG then return end
    local currTime = os.time()
    local currClock = os.clock()
    
    local deltaStr = self.logTime.lastTime and currTime - self.logTime.lastTime < 5 
        and string.format("%.6f", currClock - self.logTime.lastClock)
        or ">5s"
    
    print(string.format("[%s] %s", deltaStr, message))
    
    obj.logTime = { lastTime = currTime, lastClock = currClock }
end

-- Core chording functions
local function handleChord(action)
    return function(self)
        self:fakeLeftMouseUp()
        action()
        return true
    end
end

local chordActions = {
    middle = handleChord(function()
        obj:ulog("Executing cut chord")
        hs.eventtap.keyStroke({"cmd"}, "c", KEYSTROKE_DELAY)
        hs.eventtap.keyStroke({}, "delete", KEYSTROKE_DELAY)
    end),
    
    right = handleChord(function()
        obj:ulog("Executing paste chord")
        hs.eventtap.keyStroke({"cmd"}, "v")
    end)
}

function obj:fakeLeftMouseUp()
    self.taps.leftMouseUp:stop()
    hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.leftMouseUp,
        hs.mouse.absolutePosition()
    ):post()
    self.taps.leftMouseUp:start()
end

-- Tap configuration
local tapConfigs = {
    leftMouseDown = {
        events = { hs.eventtap.event.types.leftMouseDown },
        fn = function(self) 
            self:ulog("Left mouse down - starting chord")
            self.isChording = true
            return false 
        end
    },
    leftMouseUp = {
        events = { hs.eventtap.event.types.leftMouseUp },
        fn = function(self) 
            self:ulog("Left mouse up - ending chord")
            self.isChording = false
            return false 
        end
    },
    middleMouseDown = {
        events = { hs.eventtap.event.types.otherMouseDown },
        fn = function(self, e)
            local button = e:getProperty(hs.eventtap.event.properties["mouseEventButtonNumber"])
            local isChord = self.isChording and button == MIDDLE_BUTTON
            self:ulog(string.format("Middle button %d - chord: %s", button, isChord))
            return isChord and chordActions.middle(self) or false
        end
    },
    rightMouseDown = {
        events = { hs.eventtap.event.types.rightMouseDown },
        fn = function(self)
            self:ulog(string.format("Right button - chord: %s", self.isChording))
            return self.isChording and chordActions.right(self)
        end
    }
}

-- Tap management methods
function obj:startTaps()
    self:ulog("Starting mouse chord taps")
    for _, tap in pairs(self.taps) do
        if tap then 
            tap:start() 
        end
    end
end

function obj:stopTaps()
    self:ulog("Stopping mouse chord taps")
    for _, tap in pairs(self.taps) do
        if tap then 
            tap:stop() 
        end
    end
end

function obj:init()
    self.taps = {}
    for name, config in pairs(tapConfigs) do
        self.taps[name] = hs.eventtap.new(config.events, function(e)
            return config.fn(self, e)
        end)
    end

    -- Setup application watcher
    self.appWatcher = hs.application.watcher.new(function(appName, eventType)
        if eventType == hs.application.watcher.activated then
            local appTitle = hs.application.frontmostApplication():title()
            self:ulog(string.format("App activated: %s", appTitle))
            
            for _, excludedApp in ipairs(excludedApps) do
                if appTitle:lower() == excludedApp:lower() then
                    self:ulog(string.format("Disabling for excluded app: %s", appTitle))
                    self:stopTaps()
                    return
                end
            end
            self:ulog(string.format("Enabling for allowed app: %s", appTitle))
            self:startTaps()
        end
    end)
    
    self:ulog("Initialized NineMouseChords")
    return self
end

--- NineMouseChords:start()
--- Method
--- Starts all watchers (both mouse chord taps and app watcher).
function obj:start()
    self:ulog("Starting all watchers")
    self:startTaps()
    if self.appWatcher then
        self.appWatcher:start()
    end
    return self
end

--- NineMouseChords:stop()
--- Method
--- Stops all watchers (both mouse chord taps and app watcher).
function obj:stop()
    self:ulog("Stopping all watchers")
    self:stopTaps()
    if self.appWatcher then
        self.appWatcher:stop()
    end
    return self
end

return obj
