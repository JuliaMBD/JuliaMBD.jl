export Inport

struct InportBlockType{Tv} <: AbstractBlockType end

function Inport(name::Symbol, ::Type{Tv}; out = OutPort()) where Tv
    b = SimpleBlock(name, InportBlockType{Tv})
    in = InPort(name, Tv)
    set!(b, in.name, in)
    set!(b, :out, out)
    b
end

function Inport(name::Symbol; out = OutPort())
    Inport(name, Auto, out = out)
end

function expr(b::SimpleBlock, ::Type{InportBlockType{Tv}}) where Tv
    Expr(:(=), b.outports[1].name, Expr(:call, Tv, b.name))
end

function expr(b::SimpleBlock, ::Type{InportBlockType{Auto}})
    Expr(:(=), b.outports[1].name, b.name)
end
