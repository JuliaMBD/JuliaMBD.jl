mutable struct LineSignal <: AbstractLineSignal
    name::Symbol
    desc::String
    src::AbstractPort
    dest::AbstractPort

    function LineSignal(src::AbstractPort, dest::AbstractPort, desc::String)
        if !(typeof(src) <: AbstractOutPort && typeof(dest) <: AbstractInPort)
            @warn "The direction of signal may be wrong: $(src) $(dest)"
        end
        line = new(gensym(), desc, src, dest)
        push!(src.outs, line)
        dest.in = line
        line
    end

    function LineSignal(src::AbstractPort, dest::AbstractPort)
        if !(typeof(src) <: AbstractOutPort && typeof(dest) <: AbstractInPort)
            @warn "The direction of signal may be wrong: $(src) $(dest)"
        end
        line = new(gensym(), "", src, dest)
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
    dest::AbstractPort

    function ConstSignal(val::Any, dest::AbstractPort)
        s = new{Auto}(val, Auto, dest)
        dest.in = s
        s
    end

    function ConstSignal(val::Any, dest::AbstractPort, ::Type{Tv}) where Tv
        s = new{Tv}(val, Tv, dest)
        dest.in = s
        s
    end
end

const jumpprefix = :jumpprefix_

mutable struct GotoSignal <: AbstractJumpSignal
    name::Symbol
    src::AbstractPort

    function GotoSignal(src::AbstractPort, tag::Symbol)
        s = new(Symbol(jumpprefix, tag), src)
        push!(src.outs, s)
        s
    end
end

mutable struct FromSignal <: AbstractJumpSignal
    name::Symbol
    dest::AbstractPort

    function FromSignal(dest::AbstractPort, tag::Symbol)
        s = new(Symbol(jumpprefix, tag), dest)
        dest.in = s
        s
    end
end
