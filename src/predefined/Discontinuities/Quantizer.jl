export Quantizer

function Quantizer(;
    in = InPort(),
    out = OutPort(),
    quantizationinterval = Float64(1))
    b = SimpleBlock(:Quantizer)
    setport!(b, :in, in)
    setport!(b, :out, out)
    setparameter!(b, :quantizationinterval, quantizationinterval)
    b
end

function expr(b::SimpleBlock, ::Val{:Quantizer})
    in = b.inports[1].name
    quantizationinterval = b.env[:quantizationinterval].name
    out = b.outports[1].name
    :($out = $quantizationinterval * round($in / $quantizationinterval))
end
