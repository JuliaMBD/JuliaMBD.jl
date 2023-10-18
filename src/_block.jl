### SimpleBlock

mutable struct SimpleBlock <: AbstractSimpleBlock
    name::Symbol
    desc::String
    inports::Vector{AbstractInPortBlock}
    outports::Vector{AbstractOutPortBlock}
    parameterports::Vector{AbstractParameterPortBlock}
    env::Dict{Symbol,Any}

    function SimpleBlock(name::Symbol)
        b = new(name,
            "",
            AbstractInPortBlock[],
            AbstractOutPortBlock[],
            AbstractParameterPortBlock[],
            Dict{Symbol,Any}())
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
    push!(b.parameterports, x)
    b.env[s] = x
end
