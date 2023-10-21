export Gain

function Gain(; K = :K, in = InPort(), out = OutPort())
    b = SimpleBlock(:Gain)
    setport!(b, :in, in)
    setport!(b, :out, out)
    setparameter!(b, :K, K)
    b
end

function expr(b::SimpleBlock, ::Val{:Gain})
    Expr(:(=), b.outports[1].name, Expr(:call, :*, b.parameterports[1].name, b.inports[1].name))
end
