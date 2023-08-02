mutable struct Gain <: AbstractBlock
    name::Symbol
    parameters::Vector{Tuple{SymbolicValue,Any}}
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}

    function Gain(;K::Parameter, name::Symbol = gensym(), inport::AbstractInPort = InPort(), outport::AbstractOutPort = OutPort())
        blk = new()
        blk.name = name
        blk.parameters = Tuple{SymbolicValue,Any}[(SymbolicValue(:K), K)]
        blk.inports = AbstractInPort[inport]
        blk.outports = AbstractOutPort[outport]
        inport.parent = blk
        outport.parent = blk
        blk
    end

    function Gain(K::Parameter;name::Symbol = gensym(), inport::AbstractInPort = InPort(), outport::AbstractOutPort = OutPort())
        blk = new()
        blk.name = name
        blk.parameters = Tuple{SymbolicValue,Any}[(SymbolicValue(:K), K)]
        blk.inports = AbstractInPort[inport]
        blk.outports = AbstractOutPort[outport]
        inport.parent = blk
        outport.parent = blk
        blk
    end
end
    
function expr(blk::Gain)
    i = expr_set_inports(blk.inports[1])

    inport = expr_refvalue(blk.inports[1].var)
    K = expr_refvalue(blk.parameters[1][2])
    b = expr_setvalue(blk.outports[1].var, :($K * $inport))

    o = expr_set_outports(blk.outports[1])
    Expr(:block, i, b, o)
end

get_default_inport(blk::Gain) = blk.inports[1]
get_default_outport(blk::Gain) = blk.outports[1]
get_inports(blk::Gain) = blk.inports
get_outports(blk::Gain) = blk.outports
