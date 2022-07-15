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
    i = expr_set_inports(blk.timeport)

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
            $slope * ($time - $starttime) + $initialoutput
        end
    end)

    ## outports
    o = expr_set_outports(blk.outport)

    ## Expr
    Expr(:block, i, b, o)
end

function next(blk::Ramp)
    [line.dest.parent for line = blk.outport.lines]
end

get_default_inport(blk::Ramp) = nothing
get_default_outport(blk::Ramp) = blk.outport
get_inports(blk::Ramp) = [blk.timeport]
get_outports(blk::Ramp) = [blk.outport]
