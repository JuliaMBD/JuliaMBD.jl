### SimpleBlock

mutable struct SimpleBlock <: AbstractSimpleBlock
    name::Symbol
    desc::String
    inports::Vector{AbstractInPortBlock}
    outports::Vector{AbstractOutPortBlock}
    parameterports::Vector{AbstractParameterPortBlock}
    env::Dict{Symbol,Any}
    parameters::Dict{Symbol,AbstractConstSignal}

    function SimpleBlock(name::Symbol)
        b = new(name,
            "",
            AbstractInPortBlock[],
            AbstractOutPortBlock[],
            AbstractParameterPortBlock[],
            Dict{Symbol,Any}(),
            Dict{Symbol,AbstractConstSignal}())
        b
    end
end

function setport!(b::AbstractSimpleBlock, s::Symbol, x::AbstractInPortBlock)
    x.parent = b
    push!(b.inports, x)
    b.env[s] = x
end

function settimeport!(b::AbstractSimpleBlock, x::AbstractInPortBlock)
    x.parent = b
    push!(b.inports, x)
    b.env[:__time__] = x
end

function setport!(b::AbstractSimpleBlock, s::Symbol, x::AbstractOutPortBlock)
    x.parent = b
    push!(b.outports, x)
    b.env[s] = x
end

# function set!(b::AbstractSimpleBlock, s::Symbol, x::AbstractParameterPortBlock)
#     x.parent = b
#     push!(b.parameterports, x)
#     b.env[s] = x
# end

function setparameter!(b::AbstractSimpleBlock, s::Symbol, x)
    ## set for parameter port
    p = ParameterPort()
    p.parent = b
    push!(b.parameterports, p)
    b.env[s] = p
    ## set for constsignal
    cs = ConstSignal(x, p)
    b.parameters[s] = cs
end

function getport(b::AbstractBlock, s::Symbol)
    b.env[s]
end

function gettimeport(b::AbstractBlock)
    b.env[:__time__]
end

function hastimeport(b::AbstractBlock)
    haskey(b.env, :__time__)
end
