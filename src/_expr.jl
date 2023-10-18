function _expr(::AbstractComponent)
    Expr(:tuple)
end

function _expr_initial(x::AbstractComponent)
    _expr(x)
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

function _expr_initial(x::SimpleBlock)
    expr_initial(x, Val(x.name))
end

function expr_initial(x::SimpleBlock, t::Any)
    expr(x, t)
end

### compile

function expr_sfunc(b::AbstractCompositeBlock)
    # @assert length(b.stateinports) == length(b.stateoutports) && length(b.stateinports) != 0
    xargs = []
    for p = b.stateinports
        if p.type != Auto
            push!(xargs, Expr(:(::), p.name, p.type))
        else
            push!(xargs, p.name)
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
    dxargs = []
    for p = b.stateoutports
        if p.type != Auto
            push!(dxargs, Expr(:call, p.type, p.name))
        else
            push!(dxargs, p.name)
        end
    end
    for _ = b.inports
        push!(dxargs, 0)
    end
    paramargs = []
    for (x,v) = b.parameters
        push!(paramargs, Expr(:kw, x, v))
    end
    push!(paramargs, Expr(:kw, b.timeport.name, 0))
    body = [_expr(m) for m = tsort(allcomponents(b))]
    Expr(:function,
        Expr(:call, Symbol(b.name, "_sfunc"),
            Expr(:parameters, paramargs...), xargs..., inargs...),
        Expr(:block, body..., Expr(:tuple, dxargs...)))
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
    # @assert length(b.stateinports) == length(b.stateoutports) && length(b.stateinports) != 0
    xargs = []
    for (i,_) = enumerate(b.stateinports)
        push!(xargs, Expr(:ref, :x, i))
    end
    inargs = []
    for (i,_) = enumerate(b.inports)
        push!(inargs, Expr(:ref, :x, i + length(b.stateinports)))
    end
    dxargs = []
    for (i,_) = enumerate(b.stateoutports)
        push!(dxargs, Expr(:ref, :dx, i))
    end
    dx0args = []
    for (i,_) = enumerate(b.inports)
        push!(dx0args, Expr(:ref, :dx, i + length(b.stateoutports)))
    end
    # outargs = []
    # for (_,_) = enumerate(b.inports)
    #     push!(outargs, :_)
    # end
    paramargs = []
    for (i,(x,_)) = enumerate(b.parameters)
        push!(paramargs, Expr(:kw, x, Expr(:ref, :p, i)))
    end
    push!(paramargs, Expr(:kw, b.timeport.name, :t))
    Expr(:->, Expr(:tuple, :dx, :x, :p, :t), Expr(:block,
        Expr(:(=), Expr(:tuple, dxargs..., dx0args...),
        Expr(:call, Symbol(b.name, "_sfunc"), xargs..., inargs..., paramargs...,))))
end

function expr_ofunc(b::AbstractCompositeBlock)
    xargs = []
    for p = b.stateinports
        if p.type != Auto
            push!(xargs, Expr(:(::), p.name, p.type))
        else
            push!(xargs, p.name)
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
    scopeargs = []
    for (s,p) = b.scopes
        if p.type != Auto
            push!(scopeargs, Expr(:(=), s, Expr(:call, p.type, p.name)))
        else
            push!(scopeargs, Expr(:(=), s, p.name))
        end
    end
    paramargs = []
    for (x,v) = b.parameters
        push!(paramargs, Expr(:kw, x, v))
    end
    push!(paramargs, Expr(:kw, b.timeport.name, 0))
    body = [_expr(m) for m = tsort(allcomponents(b))]
    Expr(:function,
        Expr(:call, Symbol(b.name, "_ofunc"),
            Expr(:parameters, paramargs...), xargs..., inargs...),
        Expr(:block, body..., Expr(:tuple, scopeargs...)))
end

function expr_odemodel_ofunc(b::AbstractCompositeBlock)
    xargs = []
    for (i,_) = enumerate(b.stateinports)
        push!(xargs, Expr(:ref, Expr(:call, :x, :t), i))
    end
    inargs = []
    for (i,_) = enumerate(b.inports)
        push!(inargs, Expr(:ref, Expr(:call, :x, :t), i + length(b.stateinports)))
    end
    scopeargs = []
    for (s,p) = b.scopes
        if p.type != Auto
            push!(scopeargs, Expr(:(=), s, Expr(:call, p.type, p.name)))
        else
            push!(scopeargs, Expr(:(=), s, p.name))
        end
    end
    paramargs = []
    for (i,(x,_)) = enumerate(b.parameters)
        push!(paramargs, Expr(:kw, x, Expr(:ref, :p, i)))
    end
    push!(paramargs, Expr(:kw, b.timeport.name, :t))
    xscopes = [:($(Expr(:quote, s)) => [u.$s for u = result]) for (s,_) = b.scopes]
    Expr(:->, Expr(:tuple, :x, :p, :ts), Expr(:block,
        Expr(:(=), :result,
            Expr(:comprehension,
                Expr(:generator,
                    Expr(:call, Symbol(b.name, "_ofunc"), xargs..., inargs..., paramargs...,),
                    Expr(:(=), :t, :ts)))),
        Expr(:call, :Dict, xscopes...)
    ))
end

#         ofunc = Expr(:->, Expr(:tuple, :u, :p, :ts),
#                 Expr(:block,
#                     :(result = [$(Expr(:call, Symbol(blk.name, "Function"), Expr(:kw, :time, :t), xparams..., xsins1...)) for t = ts]),
#                     Expr(:call, :Dict, xscopes...)
#                 )
#             )

"""
(:->, (:tuple, :dx, :x, :p, :t), (:block,
      (:(=), (:tuple, (:ref, :x, 1), (:ref, :x, 2), :_), (:call, :XXX_sfunc, (:ref, :dx, 1), (:ref, :dx, 2), (:ref, :p, 1), (:ref, :p, 2), (:kw, :a, (:ref, :p, 3)), (:kw, :time, :t)))

(:function, (:call, :f, (:parameters, (:kw, (:(::), :a, :Any), 1.0), (:(::), :b, :Float64)), (:(::), :x, :Float64), (:(::), :y, :Int)), (:block,
"""

function expr_ifunc(b::AbstractCompositeBlock)
    # @assert length(b.stateinports) == length(b.stateoutports) && length(b.stateinports) != 0
    xargs = []
    for p = b.stateinports
        push!(xargs, Expr(:kw, p.name, 0))
    end
    inargs = []
    for p = b.inports
        push!(inargs, Expr(:kw, p.name, 0))
    end
    dxargs = []
    for p = b.stateoutports
        if p.type != Auto
            push!(dxargs, Expr(:call, p.type, p.name))
        else
            push!(dxargs, p.name)
        end
    end
    for p = b.inports
        push!(dxargs, p.name)
    end
    paramargs = []
    for (x,v) = b.parameters
        push!(paramargs, Expr(:kw, x, v))
    end
    push!(paramargs, Expr(:kw, b.timeport.name, 0))
    body = [_expr_initial(m) for m = tsort(allcomponents(b))]
    Expr(:function,
        Expr(:call, Symbol(b.name, "_ifunc"),
            Expr(:parameters, paramargs..., xargs..., inargs...)),
        Expr(:block, body..., Expr(:vect, dxargs...)))
end

function expr_odemodel_ifunc(b::AbstractCompositeBlock)
    # @assert length(b.stateinports) == length(b.stateoutports) && length(b.stateinports) != 0
    # dxargs = []
    # for (i,_) = enumerate(b.stateinports)
    #     push!(dxargs, Expr(:ref, :dx, i))
    # end
    # inargs = []
    # for (i,_) = enumerate(b.inports)
    #     push!(inargs, Expr(:ref, :dx, i + length(b.stateinports)))
    # end
    # xargs = []
    # for (i,_) = enumerate(b.stateoutports)
    #     push!(xargs, Expr(:ref, :x, i))
    # end
    # x0args = []
    # for (i,_) = enumerate(b.inports)
    #     push!(x0args, Expr(:ref, :x, i + length(b.stateoutports)))
    # end
    # outargs = []
    # for (_,_) = enumerate(b.inports)
    #     push!(outargs, :_)
    # end
    paramargs = []
    for (i,(x,_)) = enumerate(b.parameters)
        push!(paramargs, Expr(:kw, x, Expr(:ref, :p, i)))
    end
    push!(paramargs, Expr(:kw, b.timeport.name, 0))
    Expr(:->, Expr(:tuple, :p), Expr(:call, Symbol(b.name, "_ifunc"), paramargs...,))
end
