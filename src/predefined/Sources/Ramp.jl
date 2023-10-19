export Ramp

function Ramp(; out = OutPort(),
    time = InPort(),
    slope = Float64(0),
    starttime = Float64(0),
    initialoutput = Float64(0))
    b = SimpleBlock(:Ramp)
    setport!(b, :out, out)
    setport!(b, :time, time)
    setparameter!(b, :slope, slope)
    setparameter!(b, :starttime, starttime)
    setparameter!(b, :initialoutput, initialoutput)
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
