# module Symbolic

# import Base

export @v

abstract type AbstractSymbolic end

struct SymbolicVal <: AbstractSymbolic
    val
end

struct SymbolicVar <: AbstractSymbolic
    var::Symbol
end

struct SymbolicExpr <: AbstractSymbolic
    head::Symbol
    args::Vector{AbstractSymbolic}
end

"""
Operations
"""

const operations = [:+, :-, :*, :/, :^, :exp, :sqrt, :log]

for op = operations
    @eval function Base.$op(x::T, y::S) where {T <: AbstractSymbolic, S <: Number}
        SymbolicExpr($(Expr(:quote, op)), [x, SymbolicVal(y)])
    end
end

for op = operations
    @eval function Base.$op(x::T, y::S) where {T <: Number, S <: AbstractSymbolic}
        SymbolicExpr($(Expr(:quote, op)), [SymbolicVal(x), y])
    end
end

for op = operations
    @eval function Base.$op(x::T, y::S) where {T <: AbstractSymbolic, S <: AbstractSymbolic}
        SymbolicExpr($(Expr(:quote, op)), [x, y])
    end
end

function _expr(x::SymbolicExpr)
    args = [_expr(u) for u = x.args]
    Expr(:call, x.head, args...)
end

function _expr(x::SymbolicVar)
    x.var
end

function _expr(x::SymbolicVal)
    x.val
end

macro v(x)
    if typeof(x) == Symbol
        :(SymbolicVar($(Expr(:quote, x))))
    else
        x
    end
end    

# end