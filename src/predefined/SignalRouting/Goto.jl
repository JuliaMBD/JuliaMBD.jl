export Goto

function Goto(; tag, in=InPort(), out=OutPort())
    b = SimpleBlock(:Goto)
    setport!(b, :in, in)
    setport!(b, :out, out)
    GotoSignal(out, tag)
    b
end

function expr(b::SimpleBlock, ::Val{:Goto})
    in = getport(b, :in).name
    out = getport(b, :out).name
    :($out = $in)
end
