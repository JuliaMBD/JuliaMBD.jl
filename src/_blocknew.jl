"""
Block
"""

"""
Abstract
"""

abstract type AbstractSignal end
abstract type AbstractBlock end

"""
instance
"""

generate_instance(x::Number) = x
generate_instance(x::Symbol) = x
generate_instance(x::Nothing) = Expr(:tuple)

"""
InPort
"""

mutable struct InPort
    name::Symbol
    in::Union{AbstractSignal,Nothing}
    parent::AbstractBlock

    InPort(name, blk) = new(name, nothing, blk)
end

function generate_instance(p::InPort)
    generate_instance(p.in)
end

"""
OutPort
"""

mutable struct OutPort
    name::Symbol
    out::Vector{AbstractSignal}
    parent::AbstractBlock

    OutPort(name, blk) = new(name, Vector{AbstractSignal}(), blk)
end

"""
Signal
"""

mutable struct ContinuousSignal <: AbstractSignal
    name::Symbol
    source::Union{OutPort,Nothing}
    target::Union{InPort,Nothing}
    
    function ContinuousSignal(name::Symbol)
        s = new()
        s.name = name
        s.source = nothing
        s.target = nothing
        s
    end
end

function generate_instance(s::ContinuousSignal)
    s.name
end

"""
input/output
"""

function connect(signal::AbstractSignal, inport::InPort)
    if !isnothing(inport.in)
        throw(ErrorException(inport.name, ": inport has already input signal."))
    else
        inport.in = signal
        signal.target = inport
    end
end

function connect(signal::AbstractSignal, outport::OutPort)
    push!(outport.out, signal)
    signal.source = outport
end

function connect(signal::AbstractSignal, outport::OutPort, inport::InPort)
    connect(signal, inport)
    connect(signal, outport)
end

"""
GainBlock
"""

mutable struct GainBlock <: AbstractBlock
    name::Symbol
    inport::InPort
    outport::OutPort
    K

    function GainBlock(name::Symbol, K)
        b = new()
        b.name = name
        b.inport = InPort(:in, b)
        b.outport = OutPort(:out, b)
        b.K = K
        b
    end
end

function generate_instance(b::GainBlock)
    Expr(:call, :*, generate_instance(b.K), generate_instance(b.inport))
end

"""
InBlock
"""

mutable struct InBlock <: AbstractBlock
    name::Symbol
    inport::Nothing
    outport::OutPort

    function InBlock(name::Symbol)
        b = new()
        b.inport = nothing
        b.outport = OutPort(name, b)
        b.name = name
        b
    end
end

function generate_instance(b::InBlock)
    b.name
end

"""
OutBlock
"""

mutable struct OutBlock <: AbstractBlock
    name::Symbol
    inport::InPort
    outport::Nothing

    function OutBlock(name::Symbol)
        b = new()
        b.inport = InPort(name, b)
        b.outport = nothing
        b.name = name
        b
    end
end

function generate_instance(b::OutBlock)
    b.name
end

"""
System block
"""

mutable struct SystemBlock <: AbstractBlock
    name::Symbol
    inport::Vector{InPort}
    outport::Vector{OutPort}
    blocks::Dict{Symbol,AbstractBlock}
    
    function SystemBlock(name::Symbol)
        b = new()
        b.name = name
        b.inport = Vector{InPort}()
        b.outport = Vector{OutPort}()
        b.blocks = Dict{Symbol,AbstractBlock}()
        b
    end
end

function add_block(b::SystemBlock, x::AbstractBlock)
    b.blocks[x.name] = x
    b
end

function add_block(b::SystemBlock, x::InBlock)
    b.blocks[x.name] = x
    push!(b.inport, InPort(x.name, b))
    b
end

function add_block(b::SystemBlock, x::OutBlock)
    b.blocks[x.name] = x
    push!(b.outport, OutPort(x.name, b))
    b
end

function generate_instance(b::SystemBlock)
    Expr(:call, b.name, [Expr(:kw, i.name, generate_instance(i.inport)) for i = b.inport]...)
end

function generate_definition(blk::SystemBlock)
    q = tsort(blk)
    body = []
    for x = q
        b = blk.blocks[x]
        tmp = _generate_assignment(b.outport, generate_instance(b))
        append!(body, tmp)
    end
    push!(body, Expr(:return, Expr(:tuple, [p.name for p = blk.outport]...)))
    Expr(:function,
        Expr(:call, blk.name, Expr(:parameters, [p.name for p = blk.inport]...)),
        Expr(:block, body...))
end

function _generate_assignment(out::Nothing, s)
    []
end

function _generate_assignment(out::OutPort, s)
    tmp = gensym()
    body = [Expr(:(=), tmp, s)]
    for x = out.out
        push!(body, Expr(:(=), x.name, tmp))
    end
    body
end

function _generate_assignment(out::Vector{OutPort}, s)
    tmp = [gensym() for x = out]
    body = [Expr(:(=), Expr(:tuple, tmp...), s)]
    for (i,o) = enumerate(out)
        for x = o.out
            push!(body, Expr(:(=), x.name, tmp[i]))
        end
    end
    body
end

function _get_next_block(x::Nothing)
    []
end

function _get_next_block(x::OutPort)
    [s.target.parent.name for s = x.out]
end

function _get_next_block(x::Vector{OutPort})
    ss = []
    for p = x
        append!(ss, get_next_block(p))
    end
    ss
end

"""
tsort

Tomprogical sort to determine the sequence of expression in SystemBlock
"""

function tsort(blk::SystemBlock)
    l = Symbol[]
    check = Dict([n => 0 for (n,_) = blk.blocks])
    for (n,_) = blk.blocks
        if check[n] != 2
            _visit(n, check, blk, l)
        end
    end
    l
end

function _visit(n, check, blk, l)
    if check[n] == 1
        throw(ErrorException("DAG has a closed path"))
    elseif check[n] == 0
        check[n] = 1
        for m = _get_next_block(blk.blocks[n].outport)
            _visit(m, check, blk, l)
        end
        check[n] = 2
        pushfirst!(l, n)
    end
end
