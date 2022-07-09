export Gain

mutable struct Gain <: AbstractFunctionBlock
    K::Union{Value,SymbolicValue}
    inport::InPort
    outport::OutPort

    function Gain(;K::Union{Value,SymbolicValue}, inport::InPort, outport::OutPort)
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
    b = expr_setvalue(blk.outport.var, Expr(:call, :*, expr_refvalue(blk.K), expr_refvalue(blk.inport.var)))
    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]
    Expr(:block, i, b, o...)
end

function next(blk::Gain)
    [line.dest.parent for line = blk.outport.lines]
end