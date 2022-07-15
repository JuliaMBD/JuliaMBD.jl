export MathFunction, Abs

mutable struct MathFunction <: AbstractBlock
    inport::AbstractInPort
    outport::AbstractOutPort
    f::Symbol

    function MathFunction(f::Symbol;
        inport::AbstractInPort = InPort(),
        outport::AbstractOutPort = OutPort())
        blk = new()
        blk.f = f
        blk.inport = inport
        blk.outport = outport
        blk.inport.parent = blk
        blk.outport.parent = blk
        blk
    end
end

function Abs(;
    inport::AbstractInPort = InPort(),
    outport::AbstractOutPort = OutPort())
    MathFunction(:abs, inport=inport, outport=outport)
end

function expr(blk::MathFunction)
    i = expr_set_inports(blk.inport)

    x = expr_refvalue(blk.inport.var)
    f = blk.f

    b = expr_setvalue(blk.outport.var, Expr(:call, f, x))

    o = expr_set_outports(blk.outport)
    Expr(:block, i, b, o)
end

get_default_inport(blk::MathFunction) = blk.inport
get_default_outport(blk::MathFunction) = blk.outport
get_inports(blk::MathFunction) = [blk.inport]
get_outports(blk::MathFunction) = [blk.outport]