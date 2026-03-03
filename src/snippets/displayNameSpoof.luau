type Callback<Args...> = (Args...) -> ()

type Signal<Args...> = {
    Connect: (self: Signal<Args...>, callback: Callback<Args...>) -> RBXScriptConnection,
    Once: (self: Signal<Args...>, callback: Callback<Args...>) -> RBXScriptConnection?,
    Wait: (self: Signal<Args...>) -> (...any),
    Fire: (self: Signal<Args...>, Args...) -> (),
    Destroy: (self: Signal<Args...>) -> (),

    _bindable: BindableEvent, -- internal
    --_connections: {RBXScriptConnection?}
}

local Signal = {} -- NOTE: no speed is required
Signal.__index = Signal

function Signal.new<Args...>(): Signal<Args...>
    local signal: Signal<Args...> = setmetatable({}, Signal) :: any
    signal._bindable = Instance.new("BindableEvent")
    return signal
end

function Signal:Connect<Args...>(callback: Callback<Args...>): RBXScriptConnection
    return (self :: Signal<Args...>)._bindable.Event:Connect(callback)
end

function Signal:Once<Args...>(callback: Callback<Args...>): RBXScriptConnection?
    local connection: RBXScriptConnection?
    local function wrapper(...: Args...)
        if connection then
            connection:Disconnect()
            connection = nil
        end
        callback(...)
    end
    connection = (self :: Signal<Args...>)._bindable.Event:Connect(wrapper)
    return connection
end

function Signal:Wait<Args...>(): (Args...)
    return (self :: Signal<Args...>)._bindable.Event:Wait()
end

function Signal:Fire<Args...>(...: Args...)
    (self :: Signal<Args...>)._bindable:Fire(...)
end

function Signal:Destroy<Args...>()
    (self :: Signal<Args...>)._bindable:Destroy()
end

local addPlz: Signal<number, number> = Signal.new()
addPlz:Once(function(a0: number, a1: number)
    print(a0 + a1)
end)
addPlz:Fire(1, 1)
addPlz:Destroy()
addPlz:Once(function(a0: number, a1: number)
    print(a0 + a1)
end)
addPlz:Fire(1, 1)