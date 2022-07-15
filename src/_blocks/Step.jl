export Step

mutable struct Step <: AbstractTimeBlock
    steptime::Parameter
    initialvalue::Parameter
    finalvalue::Parameter
    timeport::AbstractInPort
    outport::AbstractOutPort

    function Step(;
        steptime::Parameter = Float64(0),
        initialvalue::Parameter = Float64(0),
        finalvalue::Parameter = Float64(0),
        timeport::AbstractInPort = InPort(),
        outport::AbstractOutPort = OutPort())
        blk = new()
        blk.steptime = steptime
        blk.initialvalue = initialvalue
        blk.finalvalue = finalvalue
        blk.timeport = timeport
        blk.outport = outport
        blk.timeport.parent = blk
        blk.outport.parent = blk
        blk
    end
end

function expr(blk::Step)
    ## inports
    i = expr_set_inports(blk.timeport)

    ## parameters
    time = expr_refvalue(blk.timeport.var)
    steptime = expr_refvalue(blk.steptime)
    initialvalue = expr_refvalue(blk.initialvalue)
    finalvalue = expr_refvalue(blk.finalvalue)

    ## body
    b = expr_setvalue(blk.outport.var,
    quote
        if $time < $steptime
            $initialvalue
        else
            $finalvalue
        end
    end)

    ## outports
    o = expr_set_outports(blk.outport)

    ## Expr
    Expr(:block, i, b, o)
end

function next(blk::Step)
    [line.dest.parent for line = blk.outport.lines]
end

get_default_inport(blk::Step) = nothing
get_default_outport(blk::Step) = blk.outport
get_inports(blk::Step) = [blk.timeport]
get_outports(blk::Step) = [blk.outport]
