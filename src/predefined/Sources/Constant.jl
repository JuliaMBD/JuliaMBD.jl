export Constant

function Constant(; out = OutPort(),
    value = ParameterPort())
    b = SimpleBlock(:Constant)
    set!(b, :out, out)
    set!(b, :value, value)
    b
end

function expr(b::SimpleBlock, ::Val{:Constant})
    value = b.env[:value].name
    out = b.outports[1].name
    :($out = $value)
end

