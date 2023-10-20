export Step

function Step(; out = OutPort(),
    time = InPort(),
    steptime = Float64(0),
    initialvalue = Float64(0),
    finalvalue = Float64(0))
    b = SimpleBlock(:Step)
    setport!(b, :out, out)
    settimeport!(b, time)
    setparameter!(b, :steptime, steptime)
    setparameter!(b, :initialvalue, initialvalue)
    setparameter!(b, :finalvalue, finalvalue)
    b
end

function expr(b::SimpleBlock, ::Val{:Step})
    time = gettimeport(b).name
    steptime = b.env[:steptime].name
    initialvalue = b.env[:initialvalue].name
    finalvalue = b.env[:finalvalue].name
    out = b.outports[1].name
    quote
        $out = if $time < $steptime
            $initialvalue
        else
            $finalvalue
        end
    end
end

