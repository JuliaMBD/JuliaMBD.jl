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
    i = expr_setvalue(blk.timeport.var, expr_refvalue(blk.timeport.line.var))

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
    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]

    ## Expr
    Expr(:block, i, b, o...)
end

function next(blk::Step)
    [line.dest.parent for line = blk.outport.lines]
end

function defaultInPort(blk::Step)
    nothing
end

function defaultOutPort(blk::Step)
    blk.outport
end