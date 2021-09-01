"""
Block
"""

"""
SystemBlock

The structure to represent a system block.

- inports: inports of system block
- outports: outports of system block
- blocks: inner blocks of system block
"""

# struct SystemBlock <: AbstractBlock
#     inports::Dict{Symbol,InPort}
#     outports::Dict{Symbol,OutPort}
#     blocks::Dict{Symbol,Any}
# end

"""
systemequation

Generate function
"""

# function systemequation(system::SystemBlock, label::Symbol = :model)
#     u = gensym()
#     du = Symbol("d", u)
#     states = sort(collect(keys(system.states)))
#     n = length(states)
#     dict = Dict(zip(states, [:($u[$i]) for i = 1:n]))
#     expr = [Expr(:(=), :($(du)[$i]), _replace(dict, _tosystemexpr(system.states[states[i]]))) for i = 1:n]
#     initvec = [_toexpr(system.states[x].initialcondition) for x = states]
#     init = Symbol(label, "init")
#     func = Symbol(label, "!")
#     quote
#         $init = $initvec
#         function $func($(du), $(u), p, t)
#             $(Expr(:block, expr...))
#         end
#     end
# end

# function _systemequation_func(system::SystemBlock)
#     u = gensym()
#     du = Symbol("d", u)
#     states = sort(collect(keys(system.states)))
#     n = length(states)
#     dict = Dict(zip(states, [:($u[$i]) for i = 1:n]))
#     expr = [Expr(:(=), :($(du)[$i]), _replace(dict, _tosystemexpr(system.states[states[i]]))) for i = 1:n]
#     func = quote
#         ($(du), $(u), p, t) -> begin
#             $(Expr(:block, expr...))
#         end
#     end
#     eval(func)
# end

# function _tosystemexpr(blk)
#     s = Set{AbstractBlock}()
#     _toexpr(s, blk.inport)
#     saturationlimits = [_toexpr(x) for x = blk.saturationlimits]
#     if length(saturationlimits) == 0
#         _toexpr(blk.inport[1])
#     else
#         lower, upper = saturationlimits
#         Expr(:if, Expr(:comparison, lower, :<=, blk.state, :<=, uupper), _toexpr(blk.inport[1]), 0)
#     end

# end

"""
AbstractBlock

An abstract object of block.
"""

abstract type AbstractBlock end

"""
Var

A struct of symbol and datatype
"""

struct Var
    label::Symbol
    datatype::DataType
end


"""
Line

An object of line with one symbol
"""

const Line = Var

"""
InPort

An object of an inport. InPort has only at most one line. If InPort has no line, line is Nothing

- line An object of Line. If it has no line, line is Nothing
- parent An object of parent block.
"""

mutable struct InPort
    line::Union{Line,Nothing}
    parent::AbstractBlock
end

InPort(parent::AbstractBlock) = InPort(nothing, parent)

"""
OutPort

An object of an outport. OutPort may have multiple lines.

- lines A vector of Line. If it has no line, line is length 0
- parent An object of parent block.
"""

mutable struct OutPort
    lines::Vector{Line}
    parent::AbstractBlock
end

OutPort(parent::AbstractBlock) = OutPort(Vector{Line}(), parent)

"""
connect

A function to connect OutPort and InPort with a line
"""

function connect(source::OutPort, target::InPort, line::Line)
    push!(source.lines, line)
    target.line = line
end

"""
toexpr
"""

_toexpr(v::Number) = v
_toexpr(v::Symbol) = v
_toexpr(v::Var) = v.label

function _toexpr(p::InPort)
    if isnothing(p.line)
        throw(ErrorException("inport is nothing"))
    else
        p.line.label
    end
end

function _toexpr(p::OutPort)
    Expr(:block, [Expr(:(=), Expr(:(::), x.label, Symbol(x.datatype)), _toexpr(p.parent)) for x = p.lines]...)
end

"""
Constant block
"""

mutable struct ConstantBlock <: AbstractBlock
    outport::OutPort
    value
    
    function ConstantBlock(value)
        blk = new()
        blk.outport = OutPort(blk)
        blk.value = value
        blk
    end
end

function _toexpr(blk::ConstantBlock)
    _toexpr(blk.value)
end

"""
Gain block
"""

mutable struct GainBlock <: AbstractBlock
    inport::InPort
    outport::OutPort
    K
    
    function GainBlock(K)
        blk = new()
        blk.inport = InPort(blk)
        blk.outport = OutPort(blk)
        blk.K = K
        blk
    end
end

function _toexpr(blk::GainBlock)
    Expr(:call, :*, _toexpr(blk.K), _toexpr(blk.inport))
end

