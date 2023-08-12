mutable struct Outport <: AbstractBlock
    name::Symbol
    parameters::Vector{AbstractSymbolicValue}
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}
    env::Dict{Symbol,Any}
    
    function Outport(; in::AbstractInPort = InPort(:in), out::AbstractOutPort = OutPort(:out)) where Tv
        b = new(:Outport, AbstractSymbolicValue[], AbstractInPort[], AbstractOutPort[], Dict{Symbol,Any}())
        set_inport!(b, in)
        set_outport!(b, out)
        b
    end
end

function get_label(x::Outport)
    get_name(get_outports(x)[1])
end

function set_label!(x::Outport, s::Symbol)
    p = OutPort(s)
    get_outports(x)[1] = p
end

function expr_body(blk::Outport)
    :($(get_label(blk)) = in)
end
