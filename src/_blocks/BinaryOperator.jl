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
    i1 = expr_setvalue(blk.left.var, expr_refvalue(blk.left.line.var))
    i2 = expr_setvalue(blk.right.var, expr_refvalue(blk.right.line.var))

    left = expr_refvalue(blk.left.var)
    right = expr_refvalue(blk.right.var)
    operator = blk.operator

    b = expr_setvalue(blk.outport.var, :($left $operator $right))

    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]
    Expr(:block, i1, i2, b, o...)
end

function next(blk::BinaryOperator)
    [line.dest.parent for line = blk.outport.lines]
end

function defaultInPort(blk::BinaryOperator)
    nothing
end

function defaultOutPort(blk::BinaryOperator)
    blk.outport
end

