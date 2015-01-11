-- File: brain.lua
-- Author: Mark Palange
-- Date: August 21, 2014
-- Note: Brain class definition

local setmetatable = setmetatable
local coroutine = coroutine
local pairs = pairs
local ipairs = ipairs
local unpack = unpack
local print = print
local timer = timer
module("brain")

-- Public: Brain class
--
-- Brain implements convenience methods for a coroutine 
Brain = {}

function Brain:new(func)
    -- Construct the instance 
    local brain_instance = {}

    -- assign Brain as the metatable and the __index for inheritence
    setmetatable(brain_instance, self)
    self.__index = self
    
    -- brain_instance ref to the brain func... why?
    brain_instance._func = func

    -- wrap the coro func in a closure to pass in the 'self' argument.
    brain_instance.resume = coroutine.wrap(function() return func(brain_instance) end)
    brain_instance.start = brain_instance.resume
    return brain_instance    
end

-- Public: waitForEvent causes the brain to yield
--         until the given event is triggered.
--
-- sender - the sender of the event
-- id - the event to listen for 
--
-- Examples
-- 
--   local myButton = display.newRect( 100, 100, 200, 50 )
--   function buttonBrain()
--     print("started")
--     local event = self:waitForEvent("touch", myButton)
--     print(event)
--     print("finished")
--     return "brain over"
--   end
--
-- Returns the event object ( see corona addEventListener docs )
function Brain:waitForEvent(id, sender, timeout)
    local brain = self
    local brainTimeout = nil
    if timeout then
      brainTimeout = timer.performWithDelay(timeout, function(event)
          print(event.name)
          brain.resume{name="timeout", target=brain}
      end)
    end
    local function listener(event)
      if brainTimeout then
        timer.cancel(brainTimeout)
      end
      
      return brain.resume(event)
    end
    timer.performWithDelay(1, function() 
        sender:addEventListener(id, listener) 
    end)
    
    local returns = { coroutine.yield() }
    sender:removeEventListener(id, listener)
    return unpack(returns)
end

-- Public: waitOnEvents causes the coroutine to yield
--         until the first of the given set of events
--         is triggered.
--
-- events - a table of event pairs ({id, sender}) to listen to.

--
-- Examples
-- 
--   local myButton1 = display.newRect( 100, 100, 200, 50 )
--   local myButton2 = display.newRect( 100, 200, 200, 50 )
--   function buttonsBrain()
--     print("started")
--     local event, event_id_and_sender = self:waitForEvents({
--       {"touch", myButton1},
--       {"touch", myButton2}
--     })

--     print(event)
--     print("finished")
--     return "brain_over"  
--   end
--
-- Returns two params, the event sent to the listener and the 
-- pair ({id, sender}) which was registered. 
function Brain:waitForEvents(events)
  local eventSet = {}
  timer.performWithDelay(1, function() 
    for _,id_and_sender in ipairs(events) do
      local id, sender = unpack(id_and_sender)
      local function listener(event)
        return self.resume(event, {id,sender})
      end
      sender:addEventListener(id, listener)
      eventSet[#eventSet+1] = {listener = listener, id = id, sender = sender}
    end
  end)

  local returns = { coroutine.yield() }

  for i, event in ipairs(eventSet) do
    event.sender:removeEventListener(event.id, event.listener)
  end

  return unpack(returns)
end

-- Public: wait() causes the coroutine to yield for the given number of ms
--
-- timeout - duration to wait.

--
-- Examples
-- 
--   local myButton1 = display.newRect( 100, 100, 200, 50 )
--   local myButton2 = display.newRect( 100, 200, 200, 50 )
--   function buttonsBrain()
--     print("started")
--     self:wait(2000)
--     print("finished")
--     return "brain_over"  
--   end
function Brain:wait(timeout)
  local brain = self
  timer.performWithDelay( timeout, function()
    brain.resume() 
  end)
  coroutine.yield()
end

return Brain