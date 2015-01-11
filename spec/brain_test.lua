local Brain = require( "../Brain" )

describe("a Brain", function()
  local test_string = "Cogito ergo sum"
  local test_sender = {}

  before_each(function()
    test_sender = {}
    -- implement a dummy object to receive and send events.
    -- its addEventListener records event listeners for 
    -- triggering events later.
    function test_sender:addEventListener(id, listener)
      self.events = self.events or {}
      self.events[#self.events + 1] = {id = id, listener = listener}
      print("register "..id.." count "..#self.events)
    end
    function test_sender:removeEventListener(id, listener)
    end
  end)

  it("should be instantiable", function()
    local brain = Brain:new(function() end)
  end)

  it("should be return a value", function()
    -- Create a Brain that returns a string.
    local brain = Brain:new(function() 
      return test_string
    end)

    local expected = brain.start();
    assert.are.same(expected, test_string)
  end)

  it("should register a listener", function()
    local s = spy.on(test_sender, "addEventListener")

    -- Create a Brain that waits for 'foo' and 
    -- then returns a string.
    local brain = Brain:new(function(self) 
      self:waitForEvent('foo', test_sender)
      return test_string
    end)

    local expected = brain.start();
    assert.is_nil(expected) -- Waiting for 'foo' event.
    assert.stub(test_sender.addEventListener).was.called()
  end)

  it("should respond to an event", function()
    local s = spy.on(test_sender, "addEventListener")
    -- Create a Brain that waits for 'foo' and 
    -- then returns a string.
    local brain = Brain:new(function(self) 
      local event = self:waitForEvent('foo', test_sender)
      return event
    end)

    local expected = brain.start();
    assert.is_nil(expected) -- Waiting for 'foo' event.
    assert.stub(test_sender.addEventListener).was.called(1)
    expected = test_sender.events[1].listener(test_string);
    assert.are.same(expected, test_string) -- the call to the listener will finish the brain.
  end)

  it("should wait on multiple events", function()
    local s = spy.on(test_sender, "addEventListener")
    -- Create a Brain that waits for 'foo' and 
    -- then returns a string.
    local brain = Brain:new(function(self) 
      local events = {}
      local event, eventData = self:waitForEvents({
        foo = test_sender,
        bar = test_sender
      })
      return event, eventData
    end)

    local expected = brain.start();
    assert.is_nil(expected) -- Waiting for 'foo' event.
    assert.stub(test_sender.addEventListener).was.called(2)
    expected, data = test_sender.events[1].listener(test_string);
    assert.are.same(expected, test_string) -- the call to the listener will finish the brain.
  end)

end)

