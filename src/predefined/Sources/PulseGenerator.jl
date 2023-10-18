export PulseGenerator

function PulseGenerator(; out = OutPort(),
    time = ParameterPort(),
    amplitude = ParameterPort(),
    period = ParameterPort(),
    pulsewidth = ParameterPort(),
    phasedelay = ParameterPort(),
    steptime = ParameterPort())
    b = SimpleBlock(:PulseGenerator)
    set!(b, :out, out)
    set!(b, :time, time)
    set!(b, :amplitude, amplitude)
    set!(b, :period, period)
    set!(b, :pulsewidth, pulsewidth)
    set!(b, :phasedelay, phasedelay)
    set!(b, :steptime, steptime)
    b
end

function expr(b::SimpleBlock, ::Val{:PulseGenerator})
    time = b.env[:time].name
    amplitude = b.env[:amplitude].name
    period = b.env[:period].name
    pulsewidth = b.env[:pulsewidth].name
    phasedelay = b.env[:phasedelay].name
    steptime = b.env[:steptime].name
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

