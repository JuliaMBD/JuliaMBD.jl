module Diagram

export @xmlmodel
export show_xmlmodel

using EzXML

const kw = ["name", "label", "id", "type", "block", "placeholders"]

function getdocs(file)
    docs = []
    docdict = Dict()
    doc = readxml(file)
    for x = findall("//diagram", doc)
        push!(docs, x)
        docdict[x["name"]] = length(docs)
    end
    docs, docdict
end

function getmxgraph(doc)
    findfirst("mxGraphModel", doc)
end

function parsemodel(mxGraphModel)
    blkdict = Dict()
    portdict = Dict()
    edgedict = Dict()
    blks = []
    ports = []
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
            if y.name == "object" && (y["type"] == "inport" || y["type"] == "outport")
                b = Dict()
                for a = eachattribute(y)
                    k = nodename(a)
                    b[k] = y[k]
                end
                mxcell = firstelement(y)
                b["parent"] = mxcell["parent"]
                portdict[y["id"]] = b
                push!(ports, b)
            end
            if y.name == "mxCell" && haskey(y, "edge") && y["edge"] == "1"
                edge = Dict()
                if haskey(y, "source") && haskey(y, "target")
                    edge["parent"] = y["parent"]
                    edge["source"] = y["source"]
                    edge["target"] = y["target"]
                    edgedict[y["id"]] = edge
                    push!(edges, edge)
                else
                    @warn "The edge without connection: $(y["id"])"
                end
            end
        end
    end
    (blkdict, blks, portdict, ports, edgedict, edges)
end

function mkblocksection(blks, blkvars)
    io = IOBuffer()
    blknames = Set()
    println(io, "begin")
    for h = blks
        println(io, makeblk(h, blkvars, blknames))
    end
    println(io, "end")
    Meta.parse(String(take!(io)))
end

function makeblk(h, blkvars, blknames)
    if h["name"] == ""
        s = "blk$(length(blkvars))"
    else
        s = h["name"]
    end
    if s in blknames
        @warn "Duplicate block name $(s)"
    else
        push!(blknames, s)
        blkvars[h["id"]] = s
    end
    _makeblk(h, s, Val(Symbol(h["block"])))
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

function mkconnectsection(edges, blkvars, portdict)
    io = IOBuffer()
    println(io, "begin")
    for h = edges
        println(io, makeconn(h, blkvars, portdict))
    end
    println(io, "end")
    Meta.parse(String(take!(io)))
end

function makeconn(h, blkvars, portdict)
    srcid = h["source"]
    srcport = portdict[srcid]
    srcblk = blkvars[srcport["parent"]]
    tgtid = h["target"]
    tgtport = portdict[tgtid]
    tgtblk = blkvars[tgtport["parent"]]
    "$(srcblk).$(srcport["name"]) => $(tgtblk).$(tgtport["name"])"
end

function xmlmodel(m, xmlfile, name)
    docs, docdict = getdocs(xmlfile)
    if name != ""
        doc = docs[docdict[name]]
    else
        if length(docs) > 1
            @warn "Diagram has multiple pages. Use the diagram at the first page"
        end
        doc = docs[1]
    end
    mxgraph = getmxgraph(doc)
    blkdict, blks, portdict, ports, edgedict, edges = parsemodel(mxgraph)
    blkvars = Dict()
    quote
        @block $m $(mkblocksection(blks, blkvars))
        @connect $m $(mkconnectsection(edges, blkvars, portdict))
    end
end

function show_xmlmodel(xmlfile, name)
    docs, docdict = getdocs(xmlfile)
    if name != ""
        doc = docs[docdict[name]]
    else
        if length(docs) > 1
            @warn "Diagram has multiple pages. Use the diagram at the first page"
        end
        doc = docs[2]
    end
    mxgraph = getmxgraph(doc)
    blkdict, blks, portdict, ports, edgedict, edges = parsemodel(mxgraph)
    blkvars = Dict()
    quote
        @block $(mkblocksection(blks, blkvars))
        @connect $(mkconnectsection(edges, blkvars, portdict))
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
macro xmlmodel(m, xmlfile, name = "")
    expr = xmlmodel(m, xmlfile, name)
    esc(expr)
end

end