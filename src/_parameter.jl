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

const Parameter = Any

