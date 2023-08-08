"""
Definition for parameter values
"""

"""
Type Auto

Auto means the variable type is determined automatically from the code
"""

struct Auto end

"""
SymbolicValue{Tv}

The type expresses a symbolic parameter
"""

struct SymbolicValue{Tv} <: AbstractSymbolicValue{Tv}
    name::Symbol
end

function SymbolicValue(x::Symbol)
    SymbolicValue{Auto}(x)
end

const Parameter = Any

"""
expr_refvalue(x::AbstractSymbolicValue)

Get a symbol to refer the symbol
"""
function expr_refvalue(x::Any)
    x
end

function expr_refvalue(x::AbstractSymbolicValue)
    get_name(x)
end

"""
expr_setvalue(x::AbstractSymbolicValue, expr)
expr_setvalue(x::SymbolicValue{Auto}, expr)

Get an expr to set the expr to the symbolicvalue.
"""
function expr_setvalue(x::AbstractSymbolicValue{Tv}, expr) where Tv
    Expr(:(=), get_name(x), Expr(:call, Symbol(Tv), expr))
end

function expr_setvalue(x::AbstractSymbolicValue{Auto}, expr)
    Expr(:(=), get_name(x), expr)
end

function expr_setpair(x::AbstractSymbolicValue{Tv}, expr) where Tv
    (get_name(x), Expr(:call, Symbol(Tv), expr))
end

function expr_setpair(x::AbstractSymbolicValue{Auto}, expr)
    (get_name(x), expr)
end
