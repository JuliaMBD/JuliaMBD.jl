export Inport

function Inport(name::Symbol, ::Type{Tv}; out = OutPort()) where Tv
    b = SimpleBlock(:Inport)
    in = InPort(name, Tv)
    setport!(b, in.name, in)
    setport!(b, :out, out)
    b
end

function Inport(name::Symbol; out = OutPort())
    Inport(name, Auto, out = out)
end

function expr(b::SimpleBlock, ::Val{:Inport})
    Tv = b.inports[1].type
    if  Tv == Auto
        Expr(:(=), b.outports[1].name, b.inports[1].name)
    else
        Expr(:(=), b.outports[1].name, Expr(:call, Tv, b.inports[1].name))
    end
end
