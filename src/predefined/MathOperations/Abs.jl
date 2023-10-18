export Abs

function Abs(;in = InPort(), out = OutPort())
    b = SimpleBlock(:Abs)
    set!(b, :in, in)
    set!(b, :out, out)
    b
end

function expr(b::SimpleBlock, ::Val{:Abs})
    in = b.inports[1].name
    out = b.outports[1].name
    :($out = abs($in))
end
