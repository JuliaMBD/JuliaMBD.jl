export Outport

struct OutportBlockType{Tv} <: AbstractBlockType end

function Outport(name::Symbol, ::Type{Tv}; in = InPort(:in)) where Tv
    @assert in.name == :in
    b = SimpleBlock(name, OutportBlockType{Tv})
    out = OutPort(name, Tv)
    set!(b, in.name, in)
    set!(b, out.name, out)
    b
end

function Outport(name::Symbol; in = InPort(:in))
    Outport(name, Auto, in = in)
end

function expr(b::SimpleBlock, ::Type{OutportBlockType{Tv}}) where Tv
    Expr(:(=), b.name, Expr(:call, Tv, b.env[:in].name))
end

function expr(b::SimpleBlock, ::Type{OutportBlockType{Auto}})
    Expr(:(=), b.name, b.env[:in].name)
end
