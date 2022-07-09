export Out

mutable struct Out <: AbstractBlock
    inport::InPort
    outport::OutPort

    function Out(;inport::InPort, outport::OutPort)
        blk = new()
        blk.inport = inport
        blk.outport = outport
        blk.inport.parent = blk
        blk.outport.parent = blk
        blk
    end
end

function expr(blk::Out)
    i = expr_setvalue(blk.inport.var, expr_refvalue(blk.inport.line.var))
    b = expr_setvalue(blk.outport.var, expr_refvalue(blk.inport.var))
    # o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]
    Expr(:block, i, b)
end

function next(blk::Out)
    []
end
