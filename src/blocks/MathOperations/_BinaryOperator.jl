mutable struct BinaryOperator <: AbstractBlock
    blkname::Symbol
    operator::Symbol
    inports::Dict{Symbol,AbstractInPort}
    outports::Dict{Symbol,AbstractOutPort}

    function BinaryOperator(name::Symbol, operator::Symbol;
        left::AbstractInPort = InPort(),
        right::AbstractInPort = InPort(),
        out::AbstractOutPort = OutPort())
        blk = new()
        blk.name = name
        blk.operator = operator
        left.parent = blk
        right.parent = blk
        out.parent = blk
        blk.inports = Dict{Symbol,AbstractInPort}(:left => left, :right => right)
        blk.outport = Dict{Symbol,AbstractOutPort}(:out => outport)
        blk
    end
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
