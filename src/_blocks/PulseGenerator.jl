export PulseGenerator

mutable struct PulseGenerator <: AbstractTimeBlock
    amplitude::Parameter
    period::Parameter
    pulsewidth::Parameter
    phasedelay::Parameter
    timeport::AbstractInPort
    outport::AbstractOutPort

    function PulseGenerator(;
        amplitude::Parameter = Float64(1),
        period::Parameter = Float64(10),
        pulsewidth::Parameter = Float64(5),
        phasedelay::Parameter = Float64(0),
        timeport::AbstractInPort = InPort(),
        outport::AbstractOutPort = OutPort())
        blk = new()
        blk.amplitude = amplitude
        blk.period = period
        blk.pulsewidth = pulsewidth
        blk.phasedelay = phasedelay
        blk.timeport = timeport
        blk.outport = outport
        blk.timeport.parent = blk
        blk.outport.parent = blk
        blk
    end
end

function expr(blk::PulseGenerator)
    ## inports
    i = expr_set_inports(blk.timeport)

    ## parameters
    time = expr_refvalue(blk.timeport.var)
    amplitude = expr_refvalue(blk.amplitude)
    phasedelay = expr_refvalue(blk.phasedelay)
    period = expr_refvalue(blk.period)
    pulsewidth = expr_refvalue(blk.pulsewidth)

    ## body
    b = expr_setvalue(blk.outport.var,
    quote
        if $time < $phasedelay
            0
        else
            tmpu =  (($time - $phasedelay) % $period) / $period * 100
            if tmpu < $pulsewidth
                $amplitude
            else
                0
            end
        end
    end)

    ## outports
    o = expr_set_outports(blk.outport)

    ## Expr
    Expr(:block, i, b, o)
end

get_default_inport(blk::PulseGenerator) = nothing
get_default_outport(blk::PulseGenerator) = blk.outport
get_inports(blk::PulseGenerator) = [blk.timeport]
get_outports(blk::PulseGenerator) = [blk.outport]
