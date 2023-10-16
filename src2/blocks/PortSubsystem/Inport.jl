mutable struct Inport <: AbstractBasicBlock
    name::Symbol
    parameters::Vector{AbstractSymbolicValue}
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}
    env::Dict{Symbol,Any}
    
    function Inport(; out::AbstractOutPort = OutPort(:out)) where Tv
        b = new(:Inport, AbstractSymbolicValue[], AbstractInPort[], AbstractOutPort[], Dict{Symbol,Any}())
        set_outport!(b, out)
        b.env[:label] = :none
        b
    end
end

function get_label(x::Inport)
    x.env[:label]
end

function set_label!(x::Inport, label::Symbol)
    x.env[:label] = label
end

function expr_body(blk::Inport)
    :(out = $(get_label(blk)))
end
