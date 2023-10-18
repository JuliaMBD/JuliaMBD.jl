export SubSystemBlock
export add!

mutable struct SubSystemBlock <: AbstractCompositeBlock
    name::Symbol
    desc::String
    inports::Vector{AbstractInPortBlock}
    outports::Vector{AbstractOutPortBlock}
    stateinports::Vector{AbstractPortBlock}
    stateoutports::Vector{AbstractPortBlock}
    parameters::Vector{AbstractParameterPortBlock}
    blocks::Vector{AbstractBlock}
    env::Dict{Symbol,Any}

    function SubSystemBlock(name::Symbol)
        b = new(name,
            "",
            AbstractInPortBlock[],
            AbstractOutPortBlock[],
            AbstractInPortBlock[],
            AbstractOutPortBlock[],
            AbstractParameterPortBlock[],
            AbstractBlock[],
            Dict{Symbol,Any}())
        b
    end
end

function add!(b::AbstractCompositeBlock, x::AbstractParameterPortBlock)
    x.parent = b
    push!(b.parameters, x)
end

function add!(b::AbstractCompositeBlock, x::AbstractCompositeBlock)
    push!(b.blocks, x)
end

function add!(b::AbstractCompositeBlock, x::AbstractSimpleBlock)
    _add!(b, x, Val(x.name))
    push!(b.blocks, x)
end

function _add!(::AbstractCompositeBlock, x::SimpleBlock, ::Any)
end

function _add!(b::AbstractCompositeBlock, x::SimpleBlock, ::Val{:Inport})
    p = x.inports[1]
    push!(b.inports, p)
    b.env[x.inports[1].name] = p
end

function _add!(b::AbstractCompositeBlock, x::SimpleBlock, ::Val{:Outport})
    p = x.outports[1]
    push!(b.outports, p)
    b.env[x.outports[1].name] = p
end
