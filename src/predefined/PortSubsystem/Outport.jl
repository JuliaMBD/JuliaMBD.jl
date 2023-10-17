export Outport

struct OutportBlockType{Tv} <: AbstractBlockType end

function Outport(name::Symbol, ::Type{Tv}; in = InPort()) where Tv
    b = SimpleBlock(name, OutportBlockType{Tv})
    out = OutPort(name, Tv)
    set!(b, :in, in)
    set!(b, out.name, out)
    b
end

function Outport(name::Symbol; in = InPort())
    Outport(name, Auto, in = in)
end

function expr(b::SimpleBlock, ::Type{OutportBlockType{Tv}}) where Tv
    Expr(:(=), b.name, Expr(:call, Tv, b.inports[1].name))
end

function expr(b::SimpleBlock, ::Type{OutportBlockType{Auto}})
    Expr(:(=), b.name, b.inports[1].name)
end
