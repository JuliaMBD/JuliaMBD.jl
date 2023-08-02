mutable struct UnaryOperator <: AbstractBlock
    name::Symbol
    inport::AbstractInPort
    outport::AbstractOutPort
    f::Symbol

    function UnaryOperator(f::Symbol;
        name::Symbol = gensym(),
        inport::AbstractInPort = InPort(),
        outport::AbstractOutPort = OutPort())
        blk = new()
        blk.name = name
        blk.f = f
        blk.inport = inport
        blk.outport = outport
        blk.inport.parent = blk
        blk.outport.parent = blk
        blk
    end
end

function expr(blk::UnaryOperator)
    i = expr_set_inports(blk.inport)

    x = expr_refvalue(blk.inport.var)
    f = blk.f

    b = expr_setvalue(blk.outport.var, Expr(:call, f, x))

    o = expr_set_outports(blk.outport)
    Expr(:block, i, b, o)
end

get_default_inport(blk::UnaryOperator) = blk.inport
get_default_outport(blk::UnaryOperator) = blk.outport
get_inports(blk::UnaryOperator) = [blk.inport]
get_outports(blk::UnaryOperator) = [blk.outport]