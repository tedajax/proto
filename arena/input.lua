function input_init(config)
    config = config or {}
    controls = config.controls or {}
    bindings = config.bindings or {}

    -- controls are tables with the following parameters
    --  id:     string; id for the control
    --  type:   string; correspondign to type ("button" or "axis")
    --  min:    number; minimum value of axis (default=0)
    --  max:    number; maximum value of axis (default=1)

    -- bindings are tables with the following parameters
    --  controlId:  string, id for which control this binding corresponds to
    --  key:        string, key identifier
    --  value:      number, how much this binding contributes to the axis (default=1)

    input = {
        controls = {},
        bindings = {}
    }

    for i, control in ipairs(controls) do
        control.min = control.min or 0
        control.max = control.max or 1
        control.thresh = control.thresh or 0.5

        input.controls[control.id] = {
            def = control,
            value = 0,
            lastValue = 0,
        }
    end

    table.sort(bindings, function(a, b) return a.controlId < b.controlId end)

    for i, binding in ipairs(bindings) do
        assert(input.controls[binding.controlId] ~= nil)

        binding.value = binding.value or 1

        binding.control = input.controls[binding.controlId]
        table.insert(input.bindings, binding)
    end
end

function input_update()
    assert(input ~= nil, "initialize input with input_init before calling input_update")

    for id, control in pairs(input.controls) do
        control.lastValue = control.value
    end

    local control = nil
    for i, binding in ipairs(input.bindings) do
        if control ~= binding.control then
            control = binding.control
            control.value = 0
        end
        if love.keyboard.isScancodeDown(binding.key) then
            control.value = control.value + binding.value
        end
    end
end

local function clamp(v, control)
    return math.min(math.max(control.def.min, v or 0), control.def.max)
end

function input_get_axis(controlId)
    local control = input.controls[controlId]
    return clamp(control.value, control)
end

function input_get_axis_delta(controlId)
    local control = input.controls[controlId]
    return clamp(control.value, control) - clamp(control.lastValue, control)
end

function input_get_button(controlId)
    local control = input.controls[controlId]
    return clamp(control.value, control) >= control.def.thresh
end

function input_get_button_down(controlId)
    local control = input.controls[controlId]
    return clamp(control.value, control) >= control.def.thresh and
        clamp(control.lastValue, control) < control.def.thresh
end

function input_get_button_up(controlId)
    local control = input.controls[controlId]
    return clamp(control.value, control) < control.def.thresh and
        clamp(control.lastValue, control) >= control.def.thresh
end
