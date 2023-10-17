mutable struct LineSignal <: AbstractLineSignal
    name::Symbol
    desc::String
    src::AbstractPortBlock
    dest::AbstractPortBlock

    function LineSignal(src::AbstractPortBlock, dest::AbstractPortBlock, desc::String)
        line = new(gensym(), desc, src, dest)
        push!(src.outs, line)
        dest.in = line
        line
    end
end

default_value(::Type{Int})::Int = 0
default_value(::Type{Float64})::Float64 = 0.0
default_value(::Type{Any}) = 0

mutable struct ConstSignal{Tv} <: AbstractConstSignal
    val::Any
    type::Type{Tv}
    dest::AbstractPortBlock

    function ConstSignal(val::Any, dest::AbstractPortBlock)
        s = new{Auto}(val, Auto, dest)
        dest.in = s
        s
    end

    function ConstSignal(val::Any, dest::AbstractPortBlock, ::Type{Tv}) where Tv
        s = new{Tv}(val, Tv, dest)
        dest.in = s
        s
    end
end
