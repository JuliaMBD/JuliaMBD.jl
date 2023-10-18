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

function expr_sfunc(b::AbstractCompositeBlock)
    @assert length(b.stateinports) != 0
    dxargs = []
    for p = b.stateinports
        if p.type != Auto
            push!(dxargs, Expr(:(::), p.name, p.type))
        else
            push!(dxargs, p.name)
        end
    end
    inargs = []
    for p = b.inports
        if p.type != Auto
            push!(inargs, Expr(:(::), p.name, p.type))
        else
            push!(inargs, p.name)
        end
    end
    xargs = []
    for p = b.stateoutports
        if p.type != Auto
            push!(xargs, Expr(:(=), p.name, Expr(:call, p.type, p.name)))
        else
            push!(xargs, Expr(:(=), p.name, p.name))
        end
    end
    outargs = []
    for p = b.outports
        if p.type != Auto
            push!(outargs, Expr(:(=), p.name, Expr(:call, p.type, p.name)))
        else
            push!(outargs, Expr(:(=), p.name, p.name))
        end
    end
    paramargs = []
    for (x,v) = b.parameters
        push!(paramargs, Expr(:kw, x, v))
    end
    push!(paramargs, Expr(:kw, b.timeport.name, 0))
    body = [_expr(m) for m = tsort(allcomponents(b))]
    Expr(:function,
        Expr(:call, Symbol(b.name, "_sfunc"),
            Expr(:parameters, paramargs...), dxargs..., inargs...),
        Expr(:block, body..., Expr(:tuple, xargs..., outargs...)))
end

"""
function sfunc!(dx, x, p, t)
    (x[1], x[2], _) = XXX_sfunc(dx[1], dx[2], p[1], p[2], a = p[3], time = t)
end

(dx, x, p, t) -> begin
    (x[1], x[2], _) = XXX_sfunc(dx[1], dx[2], p[1], p[2], a = p[3], time = t)
end

"""
function expr_odemodel_sfunc(b::AbstractCompositeBlock)
    @assert length(b.stateinports) != 0
    dxargs = []
    for (i,_) = enumerate(b.stateinports)
        push!(dxargs, Expr(:ref, :dx, i))
    end
    inargs = []
    for (i,_) = enumerate(b.inports)
        push!(inargs, Expr(:ref, :p, i))
    end
    xargs = []
    for (i,_) = enumerate(b.stateoutports)
        push!(xargs, Expr(:ref, :x, i))
    end
    outargs = []
    for _ = b.outports
        push!(outargs, :_)
    end
    paramargs = []
    j = length(inargs) + 1
    for (x,_) = b.parameters
        push!(paramargs, Expr(:kw, x, Expr(:ref, :p, j)))
        j += 1
    end
    Expr(:->, Expr(:tuple, :dx, :x, :p, :t), Expr(:block,
        Expr(:(=), Expr(:tuple, xargs..., outargs...),
        Expr(:call, Symbol(b.name, "_sfunc"), dxargs..., inargs..., paramargs..., Expr(:kw, :time, :t)))))
end

"""
(:->, (:tuple, :dx, :x, :p, :t), (:block,
      (:(=), (:tuple, (:ref, :x, 1), (:ref, :x, 2), :_), (:call, :XXX_sfunc, (:ref, :dx, 1), (:ref, :dx, 2), (:ref, :p, 1), (:ref, :p, 2), (:kw, :a, (:ref, :p, 3)), (:kw, :time, :t)))

(:function, (:call, :f, (:parameters, (:kw, (:(::), :a, :Any), 1.0), (:(::), :b, :Float64)), (:(::), :x, :Float64), (:(::), :y, :Int)), (:block,
"""
  