module Diagram

export xmlmodel

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

function output(io::IO, params, blks, edges, scopes)
    blkvars = Dict()
    println(io, "@parameter begin")
    println(io, params)
    println(io, "end")
    println(io, "@block begin")
    for h = blks
        println(io, makeblk(h, blkvars))
    end
    println(io, "end")
    println(io, "@connect begin")
    for h = edges
        println(io, makeconn(h, blkvars))
    end
    println(io, "end")
    println(io, "@scope begin")
    println(io, scopes)
    println(io, "end")
end

function xmlmodel(modelname, params, scopes, xmlfile)
    mxgraph = getmxgraph(xmlfile)
    io = IOBuffer()
    println(io, "@model $modelname begin")
    blkdict, blks, edgedict, edges = parsemodel(mxgraph)
    output(io, params, blks, edges, scopes)
    println(io, "end")
    String(take!(io))
end

end