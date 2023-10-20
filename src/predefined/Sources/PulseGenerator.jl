export PulseGenerator

function PulseGenerator(; out = OutPort(),
    time = InPort(),
    amplitude = Float64(1),
    period = Float64(10),
    pulsewidth = Float64(5),
    phasedelay = Float64(0))
    b = SimpleBlock(:PulseGenerator)
    setport!(b, :out, out)
    settimeport!(b, time)
    setparameter!(b, :amplitude, amplitude)
    setparameter!(b, :period, period)
    setparameter!(b, :pulsewidth, pulsewidth)
    setparameter!(b, :phasedelay, phasedelay)
    b
end

function expr(b::SimpleBlock, ::Val{:PulseGenerator})
    time = gettimeport(b).name
    amplitude = getport(b, :amplitude).name
    period = getport(b, :period).name
    pulsewidth = getport(b, :pulsewidth).name
    phasedelay = getport(b, :phasedelay).name
    out = b.outports[1].name
    quote
        $out = if $time < $phasedelay
            0
        else
            tmpu =  (($time - $phasedelay) % $period) / $period * 100
            if tmpu < $pulsewidth
                $amplitude
            else
                0
            end
        end
    end
end

