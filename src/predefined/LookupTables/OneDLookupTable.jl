export OneDLookupTable

function OneDLookupTable(;
    in = InPort(),
    out = OutPort(),
    breaks = :breaks,
    y = :y)
    b = SimpleBlock(:OneDLookupTable)
    setport!(b, :in, in)
    setport!(b, :out, out)
    setparameter!(b, :breaks, breaks)
    setparameter!(b, :y, y)
    b
end

function expr(b::SimpleBlock, ::Val{:OneDLookupTable})
    in = b.inports[1].name
    out = b.outports[1].name
    breaks = b.env[:breaks].name
    y = b.env[:y].name
    :($out = LookupTable.lookup($in, breaks=$breaks, y=$y))
end
