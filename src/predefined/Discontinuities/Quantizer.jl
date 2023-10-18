export Quantizer

function Quantizer(;
    in = InPort(),
    out = OutPort(),
    quantizationinterval = ParameterPort())
    b = SimpleBlock(:Quantizer)
    set!(b, :in, in)
    set!(b, :out, out)
    set!(b, :quantizationinterval, quantizationinterval)
    b
end

function expr(b::SimpleBlock, ::Val{:Quantizer})
    in = b.inports[1].name
    quantizationinterval = b.env[:quantizationinterval].name
    out = b.outports[1].name
    :($out = $quantizationinterval * round($in / $quantizationinterval))
end
