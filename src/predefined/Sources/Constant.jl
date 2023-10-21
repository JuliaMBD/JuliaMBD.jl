export Constant

function Constant(; value = Float64(0), out = OutPort())
    b = SimpleBlock(:Constant)
    setport!(b, :out, out)
    setparameter!(b, :value, value)
    b
end

function expr(b::SimpleBlock, ::Val{:Constant})
    value = b.env[:value].name
    out = b.outports[1].name
    :($out = $value)
end

