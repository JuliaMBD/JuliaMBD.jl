export SubSystemBlock
export set!

mutable struct SubSystemBlock <: AbstractCompositeBlock
    name::Symbol
    desc::String
    inports::Vector{AbstractInPortBlock}
    outports::Vector{AbstractOutPortBlock}
    parameters::Vector{AbstractParameterPortBlock}
    blocks::Vector{AbstractBlock}
    env::Dict{Symbol,Any}

    function SubSystemBlock(name::Symbol)
        b = new(name,
            "",
            AbstractInPortBlock[],
            AbstractOutPortBlock[],
            AbstractParameterPortBlock[],
            AbstractBlock[],
            Dict{Symbol,Any}())
        b
    end
end

function set!(b::AbstractCompositeBlock, s::Symbol, x::AbstractParameterPortBlock)
    x.parent = b
    push!(b.parameters, x)
    b.env[s] = x
end

function set!(b::AbstractCompositeBlock, s::Symbol, x::SimpleBlock)
    push!(b.blocks, x)
    b.env[s] = x
    _set!(b, s, x, x.type)
end

function _set!(::AbstractCompositeBlock, s::Symbol, x::SimpleBlock, ::Type{Tb}) where {Tb <: AbstractBlockType}
end

function _set!(b::AbstractCompositeBlock, s::Symbol, x::SimpleBlock, ::Type{InportBlockType{Tv}}) where Tv
    p = x.inports[1]
    push!(b.inports, p)
    b.env[s] = p
end

function _set!(b::AbstractCompositeBlock, s::Symbol, x::SimpleBlock, ::Type{OutportBlockType{Tv}}) where Tv
    p = x.outports[1]
    push!(b.outports, p)
    b.env[s] = p
end
