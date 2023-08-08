mutable struct Gain <: AbstractBlock
    name::Symbol
    parameters::Vector{AbstractSymbolicValue}
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}
    env::Dict{Symbol,Any}
    
    function Gain(;K::Tv, in::AbstractInPort = InPort(:in), out::AbstractOutPort = OutPort(:out)) where Tv
        b = new(:Gain, AbstractSymbolicValue[], AbstractInPort[], AbstractOutPort[], Dict{Symbol,Any}())
        set_inport!(b, in)
        set_outport!(b, out)
        set_parameter!(b, :K, K)
        b
    end

    function Gain(K::Tv; in::AbstractInPort = InPort(:in), out::AbstractOutPort = OutPort(:out)) where Tv
        b = new(:Gain, AbstractSymbolicValue[], AbstractInPort[], AbstractOutPort[], Dict{Symbol,Any}())
        set_inport!(b, in)
        set_outport!(b, out)
        set_parameter!(b, :K, K)
        b
    end
end

function expr_body(blk::Gain)
    :(out = K * in)
end
