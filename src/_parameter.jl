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

struct SymbolicValue{Tv}
    name::Symbol
end

function SymbolicValue(x::Symbol)
    SymbolicValue{Auto}(x)
end

function name(x::SymbolicValue)
    x.name
end

function Base.show(io::IO, x::SymbolicValue{Tv}) where Tv
    Base.show(io, Expr(:(::), x.name, Tv))
end

function Base.show(io::IO, x::SymbolicValue{Auto})
    Base.show(io, x.name)
end

function expr_refvalue(x::SymbolicValue{Tv}) where Tv
    x.name
end

function expr_setvalue(x::SymbolicValue{Tv}, expr) where Tv
    Expr(:(=), x.name, Expr(:call, Symbol(Tv), expr))
end

function expr_setvalue(x::SymbolicValue{Auto}, expr)
    Expr(:(=), x.name, expr)
end

function expr_kwvalue(x::SymbolicValue{Tv}, expr) where Tv
    Expr(:call, :Expr, Expr(:quote, :kw), Expr(:quote, x.name), Expr(:call, :Expr, Expr(:quote, :call), Expr(:call, :Symbol, Tv), expr))
end

function expr_kwvalue(x::SymbolicValue{Auto}, expr)
    Expr(:call, :Expr, Expr(:quote, :kw), Expr(:quote, x.name), expr)
end

const Parameter = Any

function expr_refvalue(x::Any)
    x
end

function _toquote(x::Symbol)
    Expr(:quote, x)
end

function _toquote(x::Any)
    x
end
