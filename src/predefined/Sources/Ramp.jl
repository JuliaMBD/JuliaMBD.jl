export Ramp

function Ramp(; out = OutPort(),
    time = ParameterPort(),
    slope = ParameterPort(),
    starttime = ParameterPort(),
    initialoutput = ParameterPort())
    b = SimpleBlock(:Ramp)
    set!(b, :out, out)
    set!(b, :time, time)
    set!(b, :slope, slope)
    set!(b, :starttime, starttime)
    set!(b, :initialoutput, initialoutput)
    b
end

function expr(b::SimpleBlock, ::Val{:Ramp})
    time = b.env[:time].name
    slope = b.env[:slope].name
    starttime = b.env[:starttime].name
    initialoutput = b.env[:initialoutput].name
    out = b.outports[1].name
    quote
        $out = if $time < $starttime
            $initialoutput
        else
            $slope * ($time - $starttime) + $initialoutput
        end
    end
end
