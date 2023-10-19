export Abs

function Abs(;in = InPort(), out = OutPort())
    b = SimpleBlock(:Abs)
    setport!(b, :in, in)
    setport!(b, :out, out)
    b
end

function expr(b::SimpleBlock, ::Val{:Abs})
    in = b.inports[1].name
    out = b.outports[1].name
    :($out = abs($in))
end
