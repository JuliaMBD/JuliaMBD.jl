export PulseGeneratorBlock

export PulseGenerator

mutable struct PulseGenerator <: AbstractFunctionBlock
    amplitude::Union{Value,SymbolicValue}
    period::Union{Value,SymbolicValue}
    pulsewidth::Union{Value,SymbolicValue}
    phasedelay::Union{Value,SymbolicValue}
    timeport::InPort
    outport::OutPort

    function PulseGenerator(;
        amplitude::Union{Value,SymbolicValue}=Value{Float64}(1),
        period::Union{Value,SymbolicValue}=Value{Float64}(10),
        pulsewidth::Union{Value,SymbolicValue}=Value{Float64}(5),
        phasedelay::Union{Value,SymbolicValue}=Value{Float64}(0),
        timeport::InPort,
        outport::OutPort)
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

macro assign(x, y)
    Expr(:call, :expr_setvalue, x, y)
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
