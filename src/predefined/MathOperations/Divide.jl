export Divide

function Divide(;in1 = InPort(), in2 = InPort(), out = OutPort())
    b = SimpleBlock(:Divide)
    setport!(b, :in1, in1)
    setport!(b, :in2, in2)
    setport!(b, :out, out)
    b
end

function expr(b::SimpleBlock, ::Val{:Divide})
    in1 = b.inports[1].name
    in2 = b.inports[2].name
    out = b.outports[1].name
    :($out = $in1 / $in2)
end
