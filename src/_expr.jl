function _expr(::AbstractComponent)
    Expr(:tuple)
end

function _expr(x::InPort{Tv}) where Tv
    if !(x.in in undefset)
        Expr(:(=), x.name, Expr(:call, Tv, _expr(x.in)))
    else
        Expr(:tuple)
    end
end

function _expr(x::InPort{Auto})
    if !(x.in in undefset)
        Expr(:(=), x.name, _expr(x.in))
    else
        Expr(:tuple)
    end
end

function _expr(x::OutPort{Tv}) where Tv
    expr = [Expr(:(=), _expr(u), Expr(:call, Tv, x.name)) for u = x.outs]
    Expr(:block, expr...)
end

function _expr(x::OutPort{Auto})
    expr = [Expr(:(=), _expr(u), x.name) for u = x.outs]
    Expr(:block, expr...)
end

function _expr(x::ParameterPort{Tv}) where Tv
    if !(x.in in undefset)
        Expr(:(=), x.name, Expr(:call, Tv, _expr(x.in)))
    else
        Expr(:tuple)
    end
end

function _expr(x::ParameterPort{Auto})
    if !(x.in in undefset)
        Expr(:(=), x.name, _expr(x.in))
    else
        Expr(:tuple)
    end
end

function _expr(x::LineSignal)
    x.name
end

function _expr(x::ConstSignal{Tv}) where Tv
    Expr(:call, Tv, x.val)
end

function _expr(x::ConstSignal{Auto})
    x.val
end

function _expr(x::SimpleBlock)
    expr(x, Val(x.name))
end

### compile

function expr_function(b::AbstractCompositeBlock)
    inargs = []
    for p = [b.inports..., b.stateoutports...]
        if typeof(p.type) != Auto
            push!(inargs, Expr(:(::), p.name, p.type))
        else
            push!(inargs, p.name)
        end
    end
    outargs = []
    for p = [b.outports..., b.stateinports...]
        if typeof(p.type) != Auto
            push!(outargs, Expr(:(=), p.name, Expr(:call, p.type, p.name)))
        else
            push!(outargs, Expr(:(=), p.name, p.name))
        end
    end
    paramargs = []
    for p = b.parameters
        if typeof(p.type) != Auto
            v = Expr(:(::), p.name, p.type)
        else
            v = p.name
        end
        if haskey(b.env, p.name)
            push!(paramargs, Expr(:kw, v, b.env[p.name]))
        else
            push!(paramargs, v)
        end
    end
    body = [_expr(m) for m = tsort(allcomponents(b))]
    Expr(:function,
        Expr(:call, Symbol(b.name, "_systemfunction"),
            Expr(:parameters, paramargs...), inargs...),
        Expr(:block, body..., Expr(:tuple, outargs...)))
end

"""
(:function, (:call, :f, (:parameters, (:kw, (:(::), :a, :Any), 1.0), (:(::), :b, :Float64)), (:(::), :x, :Float64), (:(::), :y, :Int)), (:block,
"""
  