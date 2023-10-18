export SubSystemBlock
export add!
export set!

mutable struct SubSystemBlock <: AbstractCompositeBlock
    name::Symbol
    desc::String
    inports::Vector{AbstractInPortBlock}
    outports::Vector{AbstractOutPortBlock}
    stateinports::Vector{AbstractPortBlock}
    stateoutports::Vector{AbstractPortBlock}
    parameterports::Vector{AbstractParameterPortBlock}
    blocks::Vector{AbstractBlock}
    parameters::Vector{Tuple{Any,Any}}
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
            Any[],
            Dict{Symbol,Any}())
        b
    end
end

# function addparameter!(b::AbstractCompositeBlock, x::Any, default::Any)
#     push!(b.parameters, (x, default))
# end

function set!(b::AbstractCompositeBlock, s::Symbol, x::AbstractParameterPortBlock)
    push!(b.parameterports, x)
    b.env[s] = x
end

function add!(b::AbstractCompositeBlock, x::AbstractCompositeBlock)
    for p = x.stateinports
        push!(b.stateinports, p)
    end
    for p = x.stateoutports
        push!(b.stateoutports, p)
    end
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
