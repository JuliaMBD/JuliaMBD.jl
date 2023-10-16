mutable struct Integrator <: AbstractBlock
    name::Symbol
    parameters::Vector{AbstractSymbolicValue}
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}
    env::Dict{Symbol,Any}
    
    function Integrator(;in::AbstractInPort = InPort(:in), out::AbstractOutPort = OutPort(:out)) where Tv
        b = new(:Integrator, AbstractSymbolicValue[], AbstractInPort[], AbstractOutPort[], Dict{Symbol,Any}())
        set_inport!(b, in)
        set_outport!(b, out)
        b
    end
end

function expr_body(blk::Integrator)
    :(out = in)
end
