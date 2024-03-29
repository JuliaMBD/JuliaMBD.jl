export Outport

function Outport(name::Symbol, ::Type{Tv}; in = InPort()) where Tv
    b = SimpleBlock(:Outport)
    out = OutPort(Tv)
    setport!(b, :in, in)
    setport!(b, :out, out)
    b.env[:label] = name
    b
end

function Outport(name::Symbol; in = InPort())
    Outport(name, Auto, in = in)
end

function expr(b::SimpleBlock, ::Val{:Outport})
    Tv = b.outports[1].type
    if  Tv == Auto
        Expr(:(=), b.outports[1].name, b.inports[1].name)
    else
        Expr(:(=), b.outports[1].name, Expr(:call, Tv, b.inports[1].name))
    end
end

