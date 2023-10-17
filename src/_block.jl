### SimpleBlock

mutable struct SimpleBlock <: AbstractSimpleBlock
    name::Symbol
    desc::String
    inports::Vector{AbstractInPortBlock}
    outports::Vector{AbstractOutPortBlock}
    parameters::Vector{AbstractParameterPortBlock}
    env::Dict{Symbol,Any}
    type::DataType

    function SimpleBlock(name::Symbol, ::Type{Tv}) where {Tv <: AbstractBlockType}
        b = new(name,
            "",
            AbstractInPortBlock[],
            AbstractOutPortBlock[],
            AbstractParameterPortBlock[],
            Dict{Symbol,Any}(),
            Tv)
        b
    end
end

function set!(b::AbstractSimpleBlock, s::Symbol, x::AbstractInPortBlock)
    x.parent = b
    push!(b.inports, x)
    b.env[s] = x
end

function set!(b::AbstractSimpleBlock, s::Symbol, x::AbstractOutPortBlock)
    x.parent = b
    push!(b.outports, x)
    b.env[s] = x
end

function set!(b::AbstractSimpleBlock, s::Symbol, x::AbstractParameterPortBlock)
    x.parent = b
    push!(b.parameters, x)
    b.env[s] = x
end

