mutable struct InPort{Tv} <: AbstractInPort{Tv}
    var::SymbolicValue{Tv}
    parent::Union{AbstractBlock,Nothing}
    line::Union{AbstractLine{Auto},Nothing}
end

mutable struct OutPort{Tv} <: AbstractOutPort{Tv}
    var::SymbolicValue{Tv}
    parent::Union{AbstractBlock,Nothing}
    lines::Vector{AbstractLine{Auto}}
end

InPort(name, ::Type{Tv}) where Tv = InPort{Tv}(SymbolicValue{Tv}(name), nothing, nothing)
InPort(name) = InPort{Auto}(SymbolicValue{Auto}(name), nothing, nothing)
InPort(::Type{Tv}) where Tv = InPort{Tv}(SymbolicValue{Tv}(gensym()), nothing, nothing)
InPort() = InPort{Auto}(SymbolicValue{Auto}(gensym()), nothing, nothing)

OutPort(name, ::Type{Tv}) where Tv = OutPort{Tv}(SymbolicValue{Tv}(name), nothing, AbstractLine[])
OutPort(name) = OutPort{Auto}(SymbolicValue{Auto}(name), nothing, AbstractLine[])
OutPort(::Type{Tv}) where Tv = OutPort{Tv}(SymbolicValue{Tv}(gensym()), nothing, AbstractLine[])
OutPort() = OutPort{Auto}(SymbolicValue{Auto}(gensym()), nothing, AbstractLine[])

mutable struct Line <: AbstractLine{Auto}
    var::SymbolicValue{Auto}
    source::AbstractOutPort
    dest::AbstractInPort
    
    function Line(o::AbstractOutPort, i::AbstractInPort)
        # name = Symbol(o.var.name, gensym(), i.var.name)
        name = gensym()
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

"""
get_name(x::AbstractSymbolicValue)

Get the name of variable.
"""
function get_name(x::AbstractSymbolicValue)
    x.name
end

"""
get_name(x::AbstractPort)

Get the name of port.
"""
function get_name(x::AbstractPort)
    get_name(x.var)
end

"""
get_name(x::AbstractLine)

Get the name of line.
"""
function get_name(x::AbstractLine)
    get_name(x.var)
end

"""
get_source(x::AbstractLine)

Get a source
"""
function get_source(x::AbstractLine)
    x.source
end

"""
get_dest(x::AbstractLine)

Get a dest
"""
function get_dest(x::AbstractLine)
    x.dest
end

"""
get_var(x::AbstractPort)

Get the var of port.
"""
function get_var(x::AbstractPort)
    x.var
end

"""
get_line(x::AbstractInPort)

Get a line
"""
function get_line(x::AbstractInPort)
    x.line
end

"""
get_line(x::AbstractOutPort)

Get lines
"""
function get_lines(x::AbstractOutPort)
    x.lines
end

"""
get_var(x::AbstractLine)

Get the var of line.
"""
function get_var(x::AbstractLine)
    x.var
end

"""
get_parent(p::AbstractPort)

Get a parent block
"""
function get_parent(p::AbstractPort)
    p.parent
end

"""
set_parent!(p::AbstractPort, x::AbstractBlock)

Set a parent
"""
function set_parent!(p::AbstractPort, x::AbstractBlock)
    p.parent = x
end

# function Base.:(=>)(o::AbstractComponent, i::AbstractComponent)
#     Line(get_default_outport(o), get_default_inport(i))
#     get_default_inport(o)
# end

# function Base.:(=>)(o::AbstractComponent, is::Vector{<:AbstractComponent})
#     for i = is
#         Line(get_default_outport(o), get_default_inport(i))
#     end
#     get_default_inport(o)
# end

# ## This is for tsort
# function Base.:(=>)(o::To, x::Number) where {To<:Union{AbstractOutPort,AbstractBlock}}
#     throw(ErrorException("Cannot use => for AbstractBlock"))
# end

# function Base.:(=>)(o::To, is::Any) where {To<:Union{AbstractOutPort,AbstractBlock}}
#     throw(ErrorException("Type mismatch for =>"))
# end

Base.show(io::IO, x::AbstractLine) = Base.show(io, get_var(x))
Base.show(io::IO, x::AbstractPort) = Base.show(io, get_var(x))
