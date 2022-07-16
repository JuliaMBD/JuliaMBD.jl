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

InPort(name, ::Type{Tv}) where Tv = InPort(SymbolicValue{Tv}(name), nothing, nothing)
InPort(name) = InPort(SymbolicValue{Auto}(name), nothing, nothing)
InPort(::Type{Tv}) where Tv = InPort(SymbolicValue{Tv}(gensym()), nothing, nothing)
InPort() = InPort(SymbolicValue{Auto}(gensym()), nothing, nothing)

OutPort(name, ::Type{Tv}) where Tv = OutPort(SymbolicValue{Tv}(name), nothing, AbstractLine[])
OutPort(name) = OutPort(SymbolicValue{Auto}(name), nothing, AbstractLine[])
OutPort(::Type{Tv}) where Tv = OutPort(SymbolicValue{Tv}(gensym()), nothing, AbstractLine[])
OutPort() = OutPort(SymbolicValue{Auto}(gensym()), nothing, AbstractLine[])

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

function Base.:(=>)(o::AbstractComponent, i::AbstractComponent)
    Line(get_default_outport(o), get_default_inport(i))
    get_default_inport(o)
end

function Base.:(=>)(o::AbstractComponent, is::Vector{<:AbstractComponent})
    for i = is
        Line(get_default_outport(o), get_default_inport(i))
    end
    get_default_inport(o)
end

# ## This is for tsort
# function Base.:(=>)(o::To, x::Number) where {To<:Union{AbstractOutPort,AbstractBlock}}
#     throw(ErrorException("Cannot use => for AbstractBlock"))
# end

# function Base.:(=>)(o::To, is::Any) where {To<:Union{AbstractOutPort,AbstractBlock}}
#     throw(ErrorException("Type mismatch for =>"))
# end

