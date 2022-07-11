export In

mutable struct In <: AbstractInBlock
    inport::AbstractInPort
    outport::AbstractOutPort

    function In(;inport::AbstractInPort, outport::AbstractOutPort)
        blk = new()
        blk.inport = inport
        blk.outport = outport
        blk.inport.parent = blk
        blk.outport.parent = blk
        blk
    end
end

function expr(blk::In)
    # i = expr_setvalue(blk.inport.var, expr_refvalue(blk.inport.line.var))
    b = expr_setvalue(blk.outport.var, expr_refvalue(blk.inport.var))
    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]
    Expr(:block, b, o...)
end

function next(blk::In)
    [line.dest.parent for line = blk.outport.lines]
end
