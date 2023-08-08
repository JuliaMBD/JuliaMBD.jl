mutable struct Abs <: AbstractBlock
    name::Symbol
    parameters::Vector{AbstractSymbolicValue}
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}
    env::Dict{Symbol,Any}
    
    function Abs(;in::AbstractInPort = InPort(:in), out::AbstractOutPort = OutPort(:out))
        b = new(:Abs, AbstractSymbolicValue[], AbstractInPort[], AbstractOutPort[], Dict{Symbol,Any}())
        set_inport!(b, in)
        set_outport!(b, out)
        b
    end
end

function expr_body(blk::Abs)
    :(out = abs(in))
end
