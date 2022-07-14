export Ramp

mutable struct Ramp <: AbstractTimeBlock
    slope::Parameter
    starttime::Parameter
    initialoutput::Parameter
    timeport::AbstractInPort
    outport::AbstractOutPort

    function Ramp(;
        slope::Parameter = Float64(0),
        starttime::Parameter = Float64(0),
        initialoutput::Parameter = Float64(0),
        timeport::AbstractInPort = InPort(),
        outport::AbstractOutPort = OutPort())
        blk = new()
        blk.slope = slope
        blk.starttime = starttime
        blk.initialoutput = initialoutput
        blk.timeport = timeport
        blk.outport = outport
        blk.timeport.parent = blk
        blk.outport.parent = blk
        blk
    end
end

function expr(blk::Ramp)
    ## inports
    i = expr_setvalue(blk.timeport.var, expr_refvalue(blk.timeport.line.var))

    ## parameters
    time = expr_refvalue(blk.timeport.var)
    slope = expr_refvalue(blk.slope)
    starttime = expr_refvalue(blk.starttime)
    initialoutput = expr_refvalue(blk.initialoutput)

    ## body
    b = expr_setvalue(blk.outport.var,
    quote
        if $time < $starttime
            $initialoutput
        else
            $slope * ($time - $starttime)
        end
    end)

    ## outports
    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]

    ## Expr
    Expr(:block, i, b, o...)
end

function next(blk::Ramp)
    [line.dest.parent for line = blk.outport.lines]
end

function defaultInPort(blk::Ramp)
    nothing
end

function defaultOutPort(blk::Ramp)
    blk.outport
end