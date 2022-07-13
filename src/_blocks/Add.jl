export Add, Plus

mutable struct Plus <: AbstractBlock
    left::AbstractInPort
    right::AbstractInPort
    outport::AbstractOutPort

    function Plus(;left::AbstractInPort = InPort(), right::AbstractInPort = InPort(),
        outport::AbstractOutPort = OutPort())
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
    
function expr(blk::Plus)
    i1 = expr_setvalue(blk.left.var, expr_refvalue(blk.left.line.var))
    i2 = expr_setvalue(blk.right.var, expr_refvalue(blk.right.line.var))

    left = expr_refvalue(blk.left.var)
    right = expr_refvalue(blk.right.var)

    b = expr_setvalue(blk.outport.var, :($left + $right))

    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]
    Expr(:block, i1, i2, b, o...)
end

function next(blk::Plus)
    [line.dest.parent for line = blk.outport.lines]
end

function defaultInPort(blk::Plus)
    nothing
end

function defaultOutPort(blk::Plus)
    blk.outport
end

mutable struct Add <: AbstractBlock
    inports::Vector{InPort}
    signs::Vector{Symbol}
    outport::AbstractOutPort

    function Add(; inports::Vector{InPort}, signs::Vector{Symbol}, outport::AbstractOutPort = OutPort())
        blk = new()
        blk.inports = inports
        blk.signs = signs
        blk.outport = outport
        for b = blk.inports
            b.parent = blk
        end
        blk.outport.parent = blk
        blk
    end
end
    
function expr(blk::Add)
    i = [expr_setvalue(b.var, expr_refvalue(b.line.var)) for b = blk.inports]

    b0 = expr_setvalue(blk.outport.var, 0)
    b = [expr_setvalue(blk.outport.var, Expr(:call, s, expr_refvalue(blk.outport.var), expr_refvalue(b.var))) for (s,b) = zip(blk.signs, blk.inports)]

    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]
    Expr(:block, i..., b0, b..., o...)
end

function next(blk::Add)
    [line.dest.parent for line = blk.outport.lines]
end

function defaultInPort(blk::Add)
    nothing
end

function defaultOutPort(blk::Add)
    blk.outport
end
