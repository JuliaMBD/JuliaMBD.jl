export Quantizer

function Quantizer(;
    in = InPort(),
    out = OutPort(),
    qinterval = Float64(1))
    b = SimpleBlock(:Quantizer)
    setport!(b, :in, in)
    setport!(b, :out, out)
    setparameter!(b, :qinterval, qinterval)
    b
end

function expr(b::SimpleBlock, ::Val{:Quantizer})
    in = b.inports[1].name
    qinterval = b.env[:qinterval].name
    out = b.outports[1].name
    :($out = $qinterval * round($in / $qinterval))
end
