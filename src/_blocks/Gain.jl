export Gain

mutable struct Gain <: AbstractBlock
    K::Parameter
    inport::AbstractInPort
    outport::AbstractOutPort

    function Gain(;K::Parameter, inport::AbstractInPort = InPort(), outport::AbstractOutPort = OutPort())
        blk = new()
        blk.K = K
        blk.inport = inport
        blk.outport = outport
        blk.inport.parent = blk
        blk.outport.parent = blk
        blk
    end
end
    
function expr(blk::Gain)
    i = expr_setvalue(blk.inport.var, expr_refvalue(blk.inport.line.var))

    inport = expr_refvalue(blk.inport.var)
    K = expr_refvalue(blk.K)

    b = expr_setvalue(blk.outport.var, :($K * $inport))

    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]
    Expr(:block, i, b, o...)
end

function next(blk::Gain)
    [line.dest.parent for line = blk.outport.lines]
end

function defaultInPort(blk::Gain)
    blk.inport
end

function defaultOutPort(blk::Gain)
    blk.outport
end