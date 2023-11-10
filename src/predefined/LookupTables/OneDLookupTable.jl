export OneDLookupTable

function OneDLookupTable(;
    in = InPort(),
    out = OutPort(),
    breaks = :breaks,
    y = :y,
    interpmethod = "LinearPointSlope",
    extrapmethod = "LinearEx",
    indexsearchmethod = "BinarySearch")
    b = SimpleBlock(:OneDLookupTable)
    setport!(b, :in, in)
    setport!(b, :out, out)
    setparameter!(b, :breaks, breaks)
    setparameter!(b, :y, y)
    setparameter!(b, :interpmethod, interpmethod)
    setparameter!(b, :extrapmethod, extrapmethod)
    setparameter!(b, :indexsearchmethod, indexsearchmethod)
    b
end

function expr(b::SimpleBlock, ::Val{:OneDLookupTable})
    in = b.inports[1].name
    out = b.outports[1].name
    breaks = b.env[:breaks].name
    y = b.env[:y].name
    interpmethod = b.env[:interpmethod].name
    extrapmethod = b.env[:extrapmethod].name
    indexsearchmethod = b.env[:indexsearchmethod].name
    :($out = LookupTable.lookup($in, breaks=$breaks, y=$y,
        interpmethod=Symbol($interpmethod),
        extrapmethod=Symbol($extrapmethod),
        indexsearchmethod=Symbol($indexsearchmethod)))
end
