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
    i = expr_set_inports(blk.left, blk.right)

    left = expr_refvalue(blk.left.var)
    right = expr_refvalue(blk.right.var)

    b = expr_setvalue(blk.outport.var, :($left + $right))

    o = expr_set_outports(blk.outport)
    Expr(:block, i, b, o)
end

function next(blk::Plus)
    [line.dest.parent for line = blk.outport.lines]
end

get_default_inport(blk::Plus) = nothing
get_default_outport(blk::Plus) = blk.outport
get_inports(blk::Plus) = [blk.left, blk.right]
get_outports(blk::Plus) = [blk.outport]

"""
Add
"""

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
    i = expr_set_inports(blk.inports...)

    b0 = expr_setvalue(blk.outport.var, 0)
    b = [expr_setvalue(blk.outport.var, Expr(:call, s, expr_refvalue(blk.outport.var), expr_refvalue(b.var))) for (s,b) = zip(blk.signs, blk.inports)]

    o = expr_set_outports(blk.outport)
    Expr(:block, i, b0, b..., o)
end

function next(blk::Add)
    [line.dest.parent for line = blk.outport.lines]
end

get_default_inport(blk::Add) = nothing
get_default_outport(blk::Add) = blk.outport
get_inports(blk::Add) = blk.inports
get_outports(blk::Add) = [blk.outport]
