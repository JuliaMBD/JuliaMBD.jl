export From

function From(; tag, in=InPort(), out=OutPort())
    b = SimpleBlock(:From)
    setport!(b, :in, in)
    setport!(b, :out, out)
    FromSignal(in, tag)
    b
end

function expr(b::SimpleBlock, ::Val{:From})
    in = getport(b, :in).name
    out = getport(b, :out).name
    :($out = $in)
end
