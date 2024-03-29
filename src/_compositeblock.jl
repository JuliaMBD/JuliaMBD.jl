export SubSystemBlock
export add!
export set!

mutable struct SubSystemBlock <: AbstractCompositeBlock
    name::Symbol
    desc::String
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}
    stateinports::Vector{AbstractPort}
    stateoutports::Vector{AbstractPort}
    dstateinports::Vector{AbstractPort}
    dstateoutports::Vector{AbstractPort}
    parameterports::Vector{AbstractParameterPort}
    blocks::Vector{AbstractBlock}
    # parameters::Vector{Tuple{Symbol,Any}}
    parameters::Dict{Symbol,AbstractConstSignal}
    scopes::Vector{Tuple{Symbol,AbstractPort}}
    timeport::AbstractPort
    env::Dict{Symbol,Any}

    function SubSystemBlock(name::Symbol; timeport = OutPort(:time))
        b = new(name,
            "",
            AbstractInPort[], # inports
            AbstractOutPort[], # outports
            AbstractInPort[], # stateinports
            AbstractOutPort[], # stateoutports
            AbstractInPort[], # dstateinports
            AbstractOutPort[], # dstateoutports
            AbstractParameterPort[], # parameterports
            AbstractBlock[],
            Dict{Symbol,AbstractConstSignal}(),
            Tuple{Symbol,AbstractPort}[],
            timeport,
            Dict{Symbol,Any}())
        b
    end
end

# function addparameter!(b::AbstractCompositeBlock, x::Symbol)
#     push!(b.parameters, (x, x))
# end

function addparameter!(b::AbstractCompositeBlock, s::Symbol, x::Any, ::Type{Tv}) where Tv
    if !haskey(b.parameters, s)
        ## set for parameter port
        p = ParameterPort(s)
        push!(b.parameterports, p)
        b.env[s] = p
        ## set for constsignal
        cs = ConstSignal(x, p, Tv)
        b.parameters[s] = cs
    end
end

function addscope!(b::AbstractCompositeBlock, s::Symbol, p::AbstractPort)
    push!(b.scopes, (s, p))
end

# function set!(b::AbstractCompositeBlock, s::Symbol, x::AbstractParameterPort)
#     push!(b.parameterports, x)
#     b.env[s] = x
# end

function add!(b::AbstractCompositeBlock, x::AbstractCompositeBlock)
    push!(b.stateinports, x.stateinports...)
    push!(b.stateoutports, x.stateoutports...)
    push!(b.dstateinports, x.dstateinports...)
    push!(b.dstateoutports, x.dstateoutports...)
    push!(b.scopes, x.scopes...)
    push!(b.blocks, x.blocks...)
    # for p = x.parameterports
    #     s = p.name
    #     if !haskey(b.parameters, s)
    #         push!(b.parameterports, p)
    #         b.parameters[s] = x.parameters[s]
    #     end
    # end
    if hastimeport(x)
        LineSignal(b.timeport, gettimeport(x))
    end
end

function add!(b::AbstractCompositeBlock, x::AbstractSimpleBlock)
    _add!(b, x, Val(x.name))
    push!(b.blocks, x)
    if hastimeport(x)
        LineSignal(b.timeport, gettimeport(x))
    end
end

function _add!(::AbstractCompositeBlock, x::SimpleBlock, ::Any)
end

function _add!(b::AbstractCompositeBlock, x::SimpleBlock, ::Val{:Inport})
    p = x.inports[1]
    push!(b.inports, p)
    b.env[x.env[:label]] = p
end

function _add!(b::AbstractCompositeBlock, x::SimpleBlock, ::Val{:Outport})
    p = x.outports[1]
    push!(b.outports, p)
    b.env[x.env[:label]] = p
end
