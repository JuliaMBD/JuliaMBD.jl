mutable struct Plus <: AbstractBasicBlock
    name::Symbol
    parameters::Vector{AbstractSymbolicValue}
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}
    env::Dict{Symbol,Any}
    
    function Plus(;in1::AbstractInPort = InPort(:in1), in2::AbstractInPort = InPort(:in2), out::AbstractOutPort = OutPort(:out))
        b = new(:Plus, AbstractSymbolicValue[], AbstractInPort[], AbstractOutPort[], Dict{Symbol,Any}())
        set_inport!(b, in1)
        set_inport!(b, in2)
        set_outport!(b, out)
        b
    end
end

function expr_body(blk::Plus)
    :(out = in1 + in2)
end
