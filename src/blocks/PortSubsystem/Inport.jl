mutable struct Inport <: AbstractBlock
    name::Symbol
    parameters::Vector{AbstractSymbolicValue}
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}
    env::Dict{Symbol,Any}
    
    function Inport(; in::AbstractInPort = InPort(:in), out::AbstractOutPort = OutPort(:out)) where Tv
        b = new(:Inport, AbstractSymbolicValue[], AbstractInPort[], AbstractOutPort[], Dict{Symbol,Any}())
        set_inport!(b, in)
        set_outport!(b, out)
        b
    end
end

function get_label(x::Inport)
    get_name(get_inports(x)[1])
end

function set_label!(x::Inport, s::Symbol)
    p = InPort(s)
    get_inports(x)[1] = p
end

function expr_body(blk::Inport)
    :(out = $(get_label(blk)))
end
