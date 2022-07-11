export Add

mutable struct Add <: AbstractBlock
    left::InPort
    right::InPort
    outport::OutPort

    function Add(;left::InPort, right::InPort, outport::OutPort)
        blk = new()
        blk.left = left
        blk.right = right
        blk.outport = outport
        blk.left.parent = blk
        blk.right.parent = blk
        blk.outport.parent = blk
        blk
    end
end
    

function expr(blk::Add)
    i1 = expr_setvalue(blk.left.var, expr_refvalue(blk.left.line.var))
    i2 = expr_setvalue(blk.right.var, expr_refvalue(blk.right.line.var))

    left = expr_refvalue(blk.left.var)
    right = expr_refvalue(blk.right.var)

    b = expr_setvalue(blk.outport.var, :($left + $right))

    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]
    Expr(:block, i1, i2, b, o...)
end

function next(blk::Add)
    [line.dest.parent for line = blk.outport.lines]
end