mutable struct InPort{Tv} <: AbstractInPortBlock
    name::Symbol
    type::Type{Tv}
    parent::AbstractBlock
    in::AbstractSignal
    outs::Vector{AbstractSignal}

    InPort() = new{Auto}(gensym(), Auto, UndefBlock(), UndefSignal(), AbstractSignal[])
    InPort(::Type{Tv}) where Tv = new{Tv}(gensym(), Tv, UndefBlock(), UndefSignal(), AbstractSignal[])
    InPort(name::Symbol) = new{Auto}(name, Auto, UndefBlock(), UndefSignal(), AbstractSignal[])
    InPort(name::Symbol, ::Type{Tv}) where Tv = new{Tv}(name, Tv, UndefBlock(), UndefSignal(), AbstractSignal[])
end

mutable struct OutPort{Tv} <: AbstractOutPortBlock
    name::Symbol
    type::Type{Tv}
    parent::AbstractBlock
    in::AbstractSignal
    outs::Vector{AbstractSignal}

    OutPort() = new{Auto}(gensym(), Auto, UndefBlock(), UndefSignal(), AbstractSignal[])
    OutPort(::Type{Tv}) where Tv = new{Tv}(gensym(), Tv, UndefBlock(), UndefSignal(), AbstractSignal[])
    OutPort(name::Symbol) = new{Auto}(name, Auto, UndefBlock(), UndefSignal(), AbstractSignal[])
    OutPort(name::Symbol, ::Type{Tv}) where Tv = new{Tv}(name, Tv, UndefBlock(), UndefSignal(), AbstractSignal[])
end

mutable struct ParameterPort{Tv} <: AbstractParameterPortBlock
    name::Symbol
    type::Type{Tv}
    parent::AbstractBlock
    in::AbstractSignal
    outs::Vector{AbstractSignal}

    ParameterPort() = new{Auto}(gensym(), Auto, UndefBlock(), UndefSignal(), AbstractSignal[])
    ParameterPort(::Type{Tv}) where Tv = new{Tv}(gensym(), Tv, UndefBlock(), UndefSignal(), AbstractSignal[])
    ParameterPort(name::Symbol) = new{Auto}(name, Auto, UndefBlock(), UndefSignal(), AbstractSignal[])
    ParameterPort(name::Symbol, ::Type{Tv}) where Tv = new{Tv}(name, Tv, UndefBlock(), UndefSignal(), AbstractSignal[])
end
