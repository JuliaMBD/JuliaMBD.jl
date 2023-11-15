export Add

function Add(; signs::Vector{Symbol}, out = OutPort())
    b = SimpleBlock(:Add)
    for (i,_) = enumerate(signs)
        setport!(b, Symbol(:in, i), InPort())
    end
    setport!(b, :out, out)
    b.env[:signs] = signs
    b
end

function Add(; signs::AbstractString, out = OutPort())
    b = SimpleBlock(:Add)
    signs = [Symbol(u) for u = signs]
    for (i,_) = enumerate(signs)
        setport!(b, Symbol(:in, i), InPort())
    end
    setport!(b, :out, out)
    b.env[:signs] = signs
    b
end

function expr(b::SimpleBlock, ::Val{:Add})
    signs = b.env[:signs]
    expr = 0
    for (i,s) = enumerate(signs)
        expr = Expr(:call, s, expr, b.inports[i].name)
    end
    Expr(:(=), b.outports[1].name, expr...)
end

