export Gain

function Gain(; K = ParameterPort(), in = InPort(), out = OutPort())
    b = SimpleBlock(:Gain)
    set!(b, :in, in)
    set!(b, :out, out)
    set!(b, :K, K)
    b
end

function expr(b::SimpleBlock, ::Val{:Gain})
    Expr(:(=), b.outports[1].name, Expr(:call, :*, b.parameters[1].name, b.inports[1].name))
end
