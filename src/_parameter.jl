"""
Definition for parameter values
"""

"""
Type Auto

Auto means the variable type is determined automatically from the code
"""

const Auto = Any

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

"""
expr_refvalue(x::AbstractSymbolicValue)

Get a symbol to refer the symbol
"""
expr_refvalue(x::Any) = x
expr_refvalue(x::AbstractSymbolicValue) = get_name(x)

"""
expr_setvalue(x::AbstractSymbolicValue, expr)
expr_setvalue(x::SymbolicValue{Auto}, expr)

Get an expr to set the expr to the symbolicvalue.
"""
expr_setvalue(x::AbstractSymbolicValue{Tv}, expr) where Tv = Expr(:(=), get_name(x), Expr(:call, Symbol(Tv), expr))
expr_setvalue(x::AbstractSymbolicValue{Auto}, expr) = Expr(:(=), get_name(x), expr)
expr_setpair(x::AbstractSymbolicValue{Tv}, expr) where Tv = (get_name(x), Expr(:call, Symbol(Tv), expr))
expr_setpair(x::AbstractSymbolicValue{Auto}, expr) = (get_name(x), expr)

Base.show(io::IO, x::SymbolicValue{Tv}) where Tv = Base.show(io, Expr(:(::), x.name, Tv))
Base.show(io::IO, x::SymbolicValue{Auto}) = Base.show(io, x.name)

