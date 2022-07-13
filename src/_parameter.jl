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

function Base.show(io::IO, x::SymbolicValue{Tv}) where Tv
    Base.show(io, Expr(:(::), x.name, Tv))
end

function Base.show(io::IO, x::SymbolicValue{Auto})
    Base.show(io, x.name)
end

const Parameter = Any

