module Diagram

export @xmlmodel

using EzXML

const kw = ["name", "label", "id", "type", "block"]

function getmxgraph(file)
    doc = readxml(file)
    findfirst("//mxGraphModel", doc)
end

function parsemodel(mxGraphModel)
    blkdict = Dict()
    edgedict = Dict()
    blks = []
    edges = []

    for x = eachelement(mxGraphModel)
        for y = eachelement(x)
            if y.name == "object" && y["type"] == "block"
                b = Dict()
                for a = eachattribute(y)
                    k = nodename(a)
                    b[k] = y[k]
                end
                blkdict[y["id"]] = b
                push!(blks, b)
            end
            if y.name == "object" && y["type"] == "line"
                edge = Dict()
                edge["sourceport"] = y["source"]
                edge["targetport"] = y["target"]
                mxcell = firstelement(y)
                if haskey(mxcell, "source") && haskey(mxcell, "target")
                    edge["parent"] = mxcell["parent"]
                    edge["source"] = mxcell["source"]
                    edge["target"] = mxcell["target"]
                    edgedict[y["id"]] = edge
                    push!(edges, edge)
                else
                    println("An edge without connection")
                end
            end
        end
    end

    for x = eachelement(mxGraphModel)
        for y = eachelement(x)
            if y.name == "mxCell" && haskey(y, "style") && occursin("edgeLabel", y["style"])
                if haskey(edgedict, y["parent"])
                    edge = edgedict[y["parent"]]
                    edge["label"] = y["value"]
                end
            end
        end
    end

    (blkdict, blks, edgedict, edges)
end

function makeblk(h, blkvars)
    if h["name"] == ""
        s = "blk$(length(blkvars))"
    else
        s = h["name"]
    end
    if haskey(blkvars, s)
        println("error?")
    else
        blkvars[h["id"]] = s
    end
    p = Val(Symbol(h["block"]))
    _makeblk(h, s, p)
end

function _makeblk(h, s, ::Any)
    args = ["$k = $v" for (k,v) = h if !(k in kw)]
    "$s = $(h["block"])($(join(args, ", ")))"
end

function _makeblk(h, s, ::Val{:Inport})
    args = ["$k = $v" for (k,v) = h if !(k in kw)]
    pushfirst!(args, ":$(h["name"])")
    "$s = $(h["block"])($(join(args, ", ")))"
end

function _makeblk(h, s, ::Val{:Outport})
    args = ["$k = $v" for (k,v) = h if !(k in kw)]
    pushfirst!(args, ":$(h["name"])")
    "$s = $(h["block"])($(join(args, ", ")))"
end

function makeconn(h, blkvars)
    sourcevar = blkvars[h["source"]]
    targetvar = blkvars[h["target"]]
    "$(sourcevar).$(h["sourceport"]) => $(targetvar).$(h["targetport"])"
end

function mkblocksection(blks, blkvars)
    io = IOBuffer()
    println(io, "begin")
    for h = blks
        println(io, makeblk(h, blkvars))
    end
    println(io, "end")
    Meta.parse(String(take!(io)))
end

function mkconnectsection(edges, blkvars)
    io = IOBuffer()
    println(io, "begin")
    for h = edges
        println(io, makeconn(h, blkvars))
    end
    println(io, "end")
    Meta.parse(String(take!(io)))
end

function xmlmodel(m, xmlfile)
    mxgraph = getmxgraph(xmlfile)
    blkdict, blks, edgedict, edges = parsemodel(mxgraph)
    blkvars = Dict()
    quote
        @block $m $(mkblocksection(blks, blkvars))
        @connect $m $(mkconnectsection(edges, blkvars))
    end
end

"""
@model RLC begin
    @parameter begin
        R
        L
        C
    end

    @xmlmodel "RLC.drawio"
end
"""
macro xmlmodel(m, xmlfile)
    expr = xmlmodel(m, xmlfile)
    esc(expr)
end

end