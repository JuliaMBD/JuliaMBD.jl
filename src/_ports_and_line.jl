mutable struct InPort <: AbstractInPort
    var::SymbolicValue
    parent::Union{AbstractBlock,Nothing}
    line::Union{AbstractLine,Nothing}
end

mutable struct OutPort <: AbstractOutPort
    var::SymbolicValue
    parent::Union{AbstractBlock,Nothing}
    lines::Vector{AbstractLine}
end

function Base.show(io::IO, x::AbstractPort)
    Base.show(io, x.var)
end

function InPort(name, ::Type{Tv}) where Tv
    InPort(SymbolicValue{Tv}(name), nothing, nothing)
end

function InPort(name)
    InPort(SymbolicValue{Auto}(name), nothing, nothing)
end

function InPort(::Type{Tv}) where Tv
    InPort(SymbolicValue{Tv}(gensym()), nothing, nothing)
end

function InPort()
    InPort(SymbolicValue{Auto}(gensym()), nothing, nothing)
end

function OutPort(name, ::Type{Tv}) where Tv
    OutPort(SymbolicValue{Tv}(name), nothing, AbstractLine[])
end

function OutPort(name)
    OutPort(SymbolicValue{Auto}(name), nothing, AbstractLine[])
end

function OutPort(::Type{Tv}) where Tv
    OutPort(SymbolicValue{Tv}(gensym()), nothing, AbstractLine[])
end

function OutPort()
    OutPort(SymbolicValue{Auto}(gensym()), nothing, AbstractLine[])
end

mutable struct Line <: AbstractLine
    var::SymbolicValue{Auto}
    source::AbstractOutPort
    dest::AbstractInPort
    
    function Line(o::AbstractOutPort, i::AbstractInPort)
        name = Symbol(o.var.name, i.var.name)
        line = new(SymbolicValue{Auto}(name), o, i)
        i.line = line
        push!(o.lines, line)
        line
    end

    function Line(o::AbstractOutPort, i::AbstractInPort, name::Symbol)
        line = new(SymbolicValue{Auto}(name), o, i)
        i.line = line
        push!(o.lines, line)
        line
    end
end

function Base.show(io::IO, x::AbstractLine)
    Base.show(io, x.var)
end
