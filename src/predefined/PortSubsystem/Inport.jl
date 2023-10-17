export Inport

struct InportBlockType{Tv} <: AbstractBlockType end

function Inport(name::Symbol, ::Type{Tv}; out = OutPort(:out)) where Tv
    @assert out.name == :out
    b = SimpleBlock(name, InportBlockType{Tv})
    in = InPort(name, Tv)
    set!(b, in.name, in)
    set!(b, out.name, out)
    b
end

function Inport(name::Symbol; out = OutPort(:out))
    Inport(name, Auto, out = out)
end

function expr(b::SimpleBlock, ::Type{InportBlockType{Tv}}) where Tv
    Expr(:(=), b.env[:out].name, Expr(:call, Tv, b.name))
end

function expr(b::SimpleBlock, ::Type{InportBlockType{Auto}})
    Expr(:(=), b.env[:out].name, b.name)
end
