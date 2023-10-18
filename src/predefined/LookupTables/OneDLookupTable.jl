export OneDLookupTable

function OneDLookupTable(;
    in = InPort(),
    out = OutPort(),
    breaks = ParameterPort(),
    y = ParameterPort())
    b = SimpleBlock(:OneDLookupTable)
    set!(b, :in, in)
    set!(b, :out, out)
    set!(b, :breaks, breaks)
    set!(b, :y, y)
    b
end

function expr(b::SimpleBlock, ::Val{:OneDLookupTable})
    in = b.inports[1].name
    out = b.outports[1].name
    breaks = b.env[:breaks].name
    y = b.env[:y].name
    :($out = LookupTable.interplinear($in, $breaks, $y))
end
