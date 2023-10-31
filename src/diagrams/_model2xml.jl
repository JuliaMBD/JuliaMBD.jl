export buildxml
export @buildxml

function mkmxCell(; id::Int=-1, style::String="", parent::Int=-1, type::Symbol = :none)
    node = ElementNode("mxCell")
    if style != ""
        link!(node, AttributeNode("style", style))
    end
    if id >= 0
        link!(node, AttributeNode("id", string(id)))
    end
    if parent >= 0
        link!(node, AttributeNode("parent", string(parent)))
    end
    if type == :vertex
        link!(node, AttributeNode("vertex", "1"))
    end
    node
end

function mkmxGeometry(; x = 0, y = 0, width, height)
    node = ElementNode("mxGeometry")
    if x != 0.0
        link!(node, AttributeNode("x", string(x)))
    end
    if y != 0.0
        link!(node, AttributeNode("y", string(y)))
    end
    link!(node, AttributeNode("width", string(width)))
    link!(node, AttributeNode("height", string(height)))
    link!(node, AttributeNode("as", "geometry"))
    node
end

function mkuserblock(; block::Symbol, id::Int, parent::Int, width=90, height=60)
    node = ElementNode("object")
    link!(node, AttributeNode("label", "%block%"))
    link!(node, AttributeNode("block", string(block)))
    link!(node, AttributeNode("type", "block"))
    link!(node, AttributeNode("name", ""))
    link!(node, AttributeNode("placeholders", "1"))
    link!(node, AttributeNode("id", string(id)))
    tmp = mkmxCell(
        parent=parent,
        style="rounded=0;"*
            "whiteSpace=wrap;"*
            "html=1;"*
            "fontSize=11;"*
            "points=[[0,0.5,0,0,0],[1,0.5,0,0,0]];"*
            "metaEdit=1;"*
            "snapToPoint=0;"*
            "resizable=0;"*
            "rotatable=0;"*
            "allowArrows=0;"*
            "container=1;"*
            "resizeHeight=0;"*
            "connectable=0;"*
            "collapsible=0;"*
            "movable=1;",
        type=:vertex
    )
    link!(tmp, mkmxGeometry(width=width, height=height))
    link!(node, tmp)
    node
end

function mkinport(; name::Symbol, id::Int, parent::Int, width=10, height=10, x=-5.0, y=25.0)
    node = ElementNode("object")
    link!(node, AttributeNode("label", ""))
    link!(node, AttributeNode("type", "inport"))
    link!(node, AttributeNode("name", string(name)))
    link!(node, AttributeNode("id", string(id)))
    tmp = mkmxCell(
        parent=parent,
        style="whiteSpace=wrap;"*
            "html=1;"*
            "aspect=fixed;"*
            "snapToPoint=1;"*
            "resizable=0;"*
            "metaEdit=1;"*
            "points=[[0,0.5,0,0,0]];"*
            "editable=1;"*
            "movable=1;"*
            "rotatable=1;"*
            "deletable=1;"*
            "locked=0;"*
            "connectable=1;"*
            "noLabel=0;"*
            "overflow=visible;",
        type=:vertex
    )
    link!(tmp, mkmxGeometry(width=width, height=height, x=x, y=y))
    link!(node, tmp)
    node
end

function mkoutport(; name::Symbol, id::Int, parent::Int, width=10, height=10, x=85.0, y=25.0)
    node = ElementNode("object")
    link!(node, AttributeNode("label", ""))
    link!(node, AttributeNode("type", "outport"))
    link!(node, AttributeNode("name", string(name)))
    link!(node, AttributeNode("id", string(id)))
    tmp = mkmxCell(
        parent=parent,
        style="whiteSpace=wrap;"*
            "html=1;"*
            "aspect=fixed;"*
            "snapToPoint=1;"*
            "resizable=0;"*
            "metaEdit=1;"*
            "points=[[1,0.5,0,0,0]];"*
            "editable=1;"*
            "movable=1;"*
            "rotatable=1;"*
            "deletable=1;"*
            "locked=0;"*
            "connectable=1;"*
            "noLabel=0;"*
            "overflow=visible;"*
            "fillColor=#000000;",
        type=:vertex
    )
    link!(tmp, mkmxGeometry(width=width, height=height, x=x, y=y))
    link!(node, tmp)
    node
end

function addxmlparams(node, k, v::Any)
    link!(node, AttributeNode(string(k), string(v)))
end

function addxmlparams(node, k, v::Expr)
    link!(node, AttributeNode(string(k), string(v)))
end

function addxmlparams(node, k, v::Symbol)
    link!(node, AttributeNode(string(k), string(v)))
end

function getsymbol(p, env)
    for (k,x) = env
        if p == x
            return k
        end
    end
    return :none
end
    
function _mkxmlblock(b::JuliaMBD.AbstractBlock, width=90, height=60)
    id = 2
    xmlb = mkuserblock(; block=b.name, id=id, parent=1, width=width, height=height)
    id += 1
    xmlinports = []
    y = collect(range(0.0, height, length(b.inports)+2))
    for (i,p) = enumerate(b.inports)
        k = getsymbol(p, b.env)
        push!(xmlinports, mkinport(name=k, id=id, parent=2, y=y[i+1]-5))
        id += 1
    end
    xmloutports = []
    y = collect(range(0.0, height, length(b.outports)+2))
    for (i,p) = enumerate(b.outports)
        k = getsymbol(p, b.env)
        push!(xmloutports, mkoutport(name=k, id=id, parent=2, y=y[i+1]-5))
        id += 1
    end

    for p = b.parameterports
        k = getsymbol(p, b.env)
        v = JuliaMBD._expr(b.parameters[k])
        addxmlparams(xmlb, k, v)
    end
    mxgraph = ElementNode("mxGraphModel")
    root = ElementNode("root")
    link!(mxgraph, root)
    link!(root, mkmxCell(id=0))
    link!(root, mkmxCell(id=1, parent=0))
    link!(root, xmlb)
    for x = xmlinports
        link!(root, x)
    end
    for x = xmloutports
        link!(root, x)
    end
    io = IOBuffer()
    print(io, mxgraph)
    str = String(take!(io)) |> x->replace(x, "<"=>"&lt;") |> x->replace(x, ">"=>"&gt;")
    
    data = Dict()
    data["xml"] = str
    data["w"] = width
    data["h"] = height
    data["aspect"] = "fixed"
    data["title"] = string(b.name)
    data
end

function buildxml(bs...; width=[90 for _ = bs], height=[60 for _ = bs])
    "<mxlibrary>$(JSON.json([_mkxmlblock(b,w,h) for (b,w,h) = zip(bs, width, height)]))</mxlibrary>"
end

macro buildxml(fn, bs...)
    xs = []
    for s = bs
        push!(xs, :($(s)()))
    end
    expr = quote
        open($fn, "w") do iow
            write(iow, buildxml($(xs...)))
        end
    end
    esc(expr)
end
