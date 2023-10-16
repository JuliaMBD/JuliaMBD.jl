mutable struct Outport <: AbstractBasicBlock
    name::Symbol
    parameters::Vector{AbstractSymbolicValue}
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}
    env::Dict{Symbol,Any}
    
    function Outport(label::Symbol; in::AbstractInPort = InPort(:in)) where Tv
        b = new(:Outport, AbstractSymbolicValue[], AbstractInPort[], AbstractOutPort[], Dict{Symbol,Any}())
        set_outport!(b, out)
        b.env[:label] = :none
        b
    end
end

function get_label(x::Outport)
    x.env[:label]
end

function set_label!(x::Outport, label::Symbol)
    x.env[:label] = label
end

function expr_body(blk::Outport)
    :($(get_label(blk)) = in)
end
