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
        blk.outport = outport
        blk.f.parent = blk
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
    i = expr_setvalue(blk.inport.var, expr_refvalue(blk.inport.line.var))

    x = expr_refvalue(blk.inport.var)
    f = blk.f

    b = expr_setvalue(blk.outport.var, Expr(:call, f, x))

    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]
    Expr(:block, i, b, o...)
end

function next(blk::MathFunction)
    [line.dest.parent for line = blk.outport.lines]
end

function defaultInPort(blk::MathFunction)
    blk.inport
end

function defaultOutPort(blk::MathFunction)
    blk.outport
end

