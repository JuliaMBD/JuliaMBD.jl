export TrigonometricFunction

function TrigonometricFunction(;operator=:sin, in = InPort(), out = OutPort())
    b = SimpleBlock(:TrigonometricFunction)
    setport!(b, :in, in)
    setport!(b, :out, out)
    b.env[:operator] = operator
    b
end

function expr(b::SimpleBlock, ::Val{:TrigonometricFunction})
    in = getport(b, :in).name
    out = getport(b, :out).name
    f = b.env[:operator]
    :($out = $f($in))
end
