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
    i = expr_set_inports(blk.inport)

    inport = expr_refvalue(blk.inport.var)
    K = expr_refvalue(blk.K)
    b = expr_setvalue(blk.outport.var, :($K * $inport))

    o = expr_set_outports(blk.outport)
    Expr(:block, i, b, o)
end

get_default_inport(blk::Gain) = blk.inport
get_default_outport(blk::Gain) = blk.outport
get_inports(blk::Gain) = [blk.inport]
get_outports(blk::Gain) = [blk.outport]