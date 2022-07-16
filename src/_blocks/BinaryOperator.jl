export BinaryOperator, Product, Division, Mod

mutable struct BinaryOperator <: AbstractBlock
    left::AbstractInPort
    right::AbstractInPort
    outport::AbstractOutPort
    operator::Symbol

    function BinaryOperator(operator::Symbol;
        left::AbstractInPort = InPort(),
        right::AbstractInPort = InPort(),
        outport::AbstractOutPort = OutPort())
        blk = new()
        blk.operator = operator
        blk.left = left
        blk.right = right
        blk.outport = outport
        blk.left.parent = blk
        blk.right.parent = blk
        blk.outport.parent = blk
        blk
    end
end

function Product(;
    left::AbstractInPort = InPort(),
    right::AbstractInPort = InPort(),
    outport::AbstractOutPort = OutPort())
    BinaryOperator(:*, left = left, right = right, outport = outport)
end

function Division(;
    left::AbstractInPort = InPort(),
    right::AbstractInPort = InPort(),
    outport::AbstractOutPort = OutPort())
    BinaryOperator(:/, left = left, right = right, outport = outport)
end

function Mod(;
    left::AbstractInPort = InPort(),
    right::AbstractInPort = InPort(),
    outport::AbstractOutPort = OutPort())
    BinaryOperator(:%, left = left, right = right, outport = outport)
end
    
function expr(blk::BinaryOperator)
    i = expr_set_inports(blk.left, blk.right)

    left = expr_refvalue(blk.left.var)
    right = expr_refvalue(blk.right.var)
    operator = blk.operator

    b = expr_setvalue(blk.outport.var, Expr(:call, operator, left, right))

    o = expr_set_outports(blk.outport)
    Expr(:block, i, b, o)
end

get_default_inport(blk::BinaryOperator) = nothing
get_default_outport(blk::BinaryOperator) = blk.outport
get_inports(blk::BinaryOperator) = [blk.left, blk.right]
get_outports(blk::BinaryOperator) = [blk.outport]
