export PulseGenerator

mutable struct PulseGenerator <: AbstractBlock
    amplitude::Parameter
    period::Parameter
    pulsewidth::Parameter
    phasedelay::Parameter
    timeport::AbstractInPort
    outport::AbstractOutPort

    function PulseGenerator(;
        amplitude::Parameter=Value{Float64}(1),
        period::Parameter=Value{Float64}(10),
        pulsewidth::Parameter=Value{Float64}(5),
        phasedelay::Parameter=Value{Float64}(0),
        timeport::AbstractInPort,
        outport::AbstractOutPort)
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
    i = expr_setvalue(blk.timeport.var, expr_refvalue(blk.timeport.line.var))

    ## parameters
    time = expr_refvalue(blk.timeport.var)
    amplitude = expr_refvalue(blk.amplitude)
    phasedelay = expr_refvalue(blk.phasedelay)
    period = expr_refvalue(blk.period)
    pulsewidth = expr_refvalue(blk.phasedelay)

    ## body
    b = expr_setvalue(blk.outport.var,
    quote
        if $time < $(phasedelay)
            0
        else
            tmpu = (($time - $(phasedelay)) % $(period)) / $(period) * 100
            if tmpu < $(pulsewidth)
                $(amplitude)
            else
                0
            end
        end
    end)

    ## outports
    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]

    ## Expr
    Expr(:block, i, b, o...)
end

function next(blk::PulseGenerator)
    [line.dest.parent for line = blk.outport.lines]
end
