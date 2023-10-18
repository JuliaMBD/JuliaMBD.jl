export Step

function Step(; out = OutPort(),
    time = ParameterPort(),
    steptime = ParameterPort(),
    initialvalue = ParameterPort(),
    finalvalue = ParameterPort())
    b = SimpleBlock(:Step)
    set!(b, :out, out)
    set!(b, :time, time)
    set!(b, :steptime, steptime)
    set!(b, :initialvalue, initialvalue)
    set!(b, :finalvalue, finalvalue)
    b
end

function expr(b::SimpleBlock, ::Val{:Step})
    time = b.env[:time].name
    steptime = b.env[:steptime].name
    initialvalue = b.env[:initialvalue].name
    finalvalue = b.env[:finalvalue].name
    quote
        if $time < $steptime
            $initialvalue
        else
            $finalvalue
        end
    end
end

