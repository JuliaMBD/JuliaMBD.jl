const default_derivative_h = 0.0001

function expr_sfunc_derivative(b::AbstractCompositeBlock, bs = tsort(allcomponents(b)))
    if length(b.inports) != 0
        @warn "This system requires inputs"
    end
    xargs = []
    for p = b.stateinports
        if p.type != Auto
            push!(xargs, Expr(:(::), p.name, p.type))
        else
            push!(xargs, p.name)
        end
    end
    xdashargs = []
    for p = b.dstateinports
        if p.type != Auto
            push!(xdashargs, Expr(:(::), p.name, p.type))
        else
            push!(xdashargs, p.name)
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
    for p = b.dstateoutports
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
    for p = b.parameterports
        x = p.name
        v = _expr(p.in)
        push!(paramargs, Expr(:kw, x, v))
    end
    body = [_expr(m) for m = bs]
    expr1 = Expr(:function,
        Expr(:call, Symbol(b.name, "_sfunc_derivative"),
            Expr(:parameters, Expr(:kw, b.timeport.name, 0), paramargs...), xargs..., xdashargs..., inargs...),
        Expr(:block, body..., Expr(:tuple, dxargs...)))

    x2args = []
    for p = b.stateinports
        if p.type != Auto
            push!(x2args, Expr(:(::), Symbol(p.name, :dash), p.type))
        else
            push!(x2args, Symbol(p.name, :dash))
        end
    end
    dxx0 = [Symbol(p.name, :dummy) for p = b.stateinports]
    dxx = [Symbol(p.name, :dummy) for p = b.dstateinports]
    expr2 = Expr(:function,
        Expr(:call, Symbol(b.name, "_sfunc"),
            Expr(:parameters, Expr(:kw, b.timeport.name, 0), paramargs..., Expr(:kw, :derivative_h, default_derivative_h)), xargs..., x2args..., inargs...),
        Expr(:block,
            Expr(:(=),
                Expr(:tuple, dxx0..., [p.name for p = b.dstateoutports]...),
                Expr(:call, Symbol(b.name, "_sfunc_derivative"), xargs...,
                    [0 for _ = b.dstateinports]..., inargs...,
                    Expr(:kw, b.timeport.name, b.timeport.name), paramargs...)),
            Expr(:(=),
                Expr(:tuple, dxx0..., [Symbol(p.name, "dash") for p = b.dstateoutports]...),
                Expr(:call, Symbol(b.name, "_sfunc_derivative"), x2args...,
                    [0 for _ = b.dstateinports]..., inargs...,
                    Expr(:kw, b.timeport.name, Expr(:call, :+, b.timeport.name, :derivative_h)), paramargs...)),
            Expr(:(=), Expr(:tuple, xargs..., dxx...), Expr(:call, Symbol(b.name, "_sfunc_derivative"), xargs...,
                [Expr(:call, :/, Expr(:call, :-, Symbol(p.name, "dash"), p.name), :derivative_h) for p = b.dstateoutports]...,
                inargs...,  Expr(:kw, b.timeport.name, b.timeport.name), paramargs...)),
            Expr(:(=), Expr(:tuple, x2args..., dxx...), Expr(:call, Symbol(b.name, "_sfunc_derivative"), x2args...,
                [Expr(:call, :/, Expr(:call, :-, Symbol(p.name, "dash"), p.name), :derivative_h) for p = b.dstateoutports]...,
                inargs...,  Expr(:kw, b.timeport.name, Expr(:call, :+, b.timeport.name, :derivative_h)), paramargs...)),
            Expr(:tuple, xargs..., x2args...)))
    Expr(:block, expr1, expr2)
end

function expr_odemodel_sfunc_derivative(b::AbstractCompositeBlock)
    j = 1
    xargs = []
    for (i,_) = enumerate(b.stateinports)
        push!(xargs, Expr(:ref, :x, j))
        j += 1
    end
    for (i,_) = enumerate(b.stateinports)
        push!(xargs, Expr(:ref, :x, j))
        j += 1
    end
    inargs = []
    for (i,_) = enumerate(b.inports)
        push!(inargs, Expr(:ref, :x, j))
        j += 1
    end
    j = 1
    dxargs = []
    for (i,_) = enumerate(b.stateoutports)
        push!(dxargs, Expr(:ref, :dx, j))
        j += 1
    end
    for (i,_) = enumerate(b.stateoutports)
        push!(dxargs, Expr(:ref, :dx, j))
        j += 1
    end
    dx0args = []
    for (i,_) = enumerate(b.inports)
        push!(dx0args, Expr(:ref, :dx, j))
        j += 1
    end
    j = 1
    paramargs = []
    for (i,p) = enumerate(b.parameterports)
        push!(paramargs, Expr(:kw, p.name, Expr(:ref, :p, j)))
        j += 1
    end
    push!(paramargs, Expr(:kw, :derivative_h, Expr(:ref, :p, j)))
    push!(paramargs, Expr(:kw, b.timeport.name, :t))
    Expr(:->, Expr(:tuple, :dx, :x, :p, :t), Expr(:block,
        Expr(:(=), Expr(:tuple, dxargs..., dx0args...),
        Expr(:call, Symbol(b.name, "_sfunc"), xargs..., inargs..., paramargs...,))))
end

function expr_ofunc_derivative(b::AbstractCompositeBlock, bs = tsort(allcomponents(b)))
    xargs = []
    for p = b.stateinports
        if p.type != Auto
            push!(xargs, Expr(:(::), p.name, p.type))
        else
            push!(xargs, p.name)
        end
    end
    xdashargs = []
    for p = b.dstateinports
        if p.type != Auto
            push!(xdashargs, Expr(:(::), p.name, p.type))
        else
            push!(xdashargs, p.name)
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
    for p = b.parameterports
        x = p.name
        v = _expr(p.in)
        push!(paramargs, Expr(:kw, x, v))
    end
    body = [_expr(m) for m = bs]
    expr1 = Expr(:function,
        Expr(:call, Symbol(b.name, "_ofunc_derivative"),
            Expr(:parameters, Expr(:kw, b.timeport.name, 0), paramargs...), xargs..., xdashargs..., inargs...),
        Expr(:block, body..., Expr(:tuple, scopeargs...)))

    x2args = []
    for p = b.stateinports
        if p.type != Auto
            push!(x2args, Expr(:(::), Symbol(p.name, :dash), p.type))
        else
            push!(x2args, Symbol(p.name, :dash))
        end
    end
    dxx0 = [Symbol(p.name, :dummy) for p = b.stateinports]
    expr2 = Expr(:function,
        Expr(:call, Symbol(b.name, "_ofunc"),
            Expr(:parameters, Expr(:kw, b.timeport.name, 0), paramargs..., Expr(:kw, :derivative_h, default_derivative_h)), xargs..., x2args..., inargs...),
        Expr(:block,
            Expr(:(=),
                Expr(:tuple, dxx0..., [p.name for p = b.dstateoutports]...),
                Expr(:call, Symbol(b.name, "_sfunc_derivative"), xargs...,
                    [0 for _ = b.dstateinports]..., inargs...,
                    Expr(:kw, b.timeport.name, b.timeport.name), paramargs...)),
            Expr(:(=),
                Expr(:tuple, dxx0..., [Symbol(p.name, "dash") for p = b.dstateoutports]...),
                Expr(:call, Symbol(b.name, "_sfunc_derivative"), x2args...,
                    [0 for _ = b.dstateinports]..., inargs...,
                    Expr(:kw, b.timeport.name, Expr(:call, :+, b.timeport.name, :derivative_h)), paramargs...)),
            Expr(:call, Symbol(b.name, "_ofunc_derivative"), xargs...,
                [Expr(:call, :/, Expr(:call, :-, Symbol(p.name, "dash"), p.name), :derivative_h) for p = b.dstateoutports]...,
                inargs...,  Expr(:kw, b.timeport.name, b.timeport.name), paramargs...)))
    Expr(:block, expr1, expr2)
end

function expr_odemodel_ofunc_derivative(b::AbstractCompositeBlock)
    j = 1
    xargs = []
    for (i,_) = enumerate(b.stateinports)
        push!(xargs, Expr(:ref, Expr(:call, :x, :t), j))
        j += 1
    end
    for (i,_) = enumerate(b.stateinports)
        push!(xargs, Expr(:ref, Expr(:call, :x, :t), j))
        j += 1
    end
    inargs = []
    for (i,_) = enumerate(b.inports)
        push!(inargs, Expr(:ref, Expr(:call, :x, :t), j))
        j += 1
    end
    scopeargs = []
    for (s,p) = b.scopes
        if p.type != Auto
            push!(scopeargs, Expr(:(=), s, Expr(:call, p.type, p.name)))
        else
            push!(scopeargs, Expr(:(=), s, p.name))
        end
    end
    j = 1
    paramargs = []
    for (i,p) = enumerate(b.parameterports)
        push!(paramargs, Expr(:kw, p.name, Expr(:ref, :p, j)))
    end
    push!(paramargs, Expr(:kw, :derivative_h, Expr(:ref, :p, j)))
    push!(paramargs, Expr(:kw, b.timeport.name, :t))
    xscopes = [:($s = [u.$s for u = result]) for (s,_) = b.scopes]
    Expr(:->, Expr(:tuple, :x, :p, :ts), Expr(:block,
        Expr(:(=), :result,
            Expr(:comprehension,
                Expr(:generator,
                    Expr(:call, Symbol(b.name, "_ofunc"), xargs..., inargs..., paramargs...,),
                    Expr(:(=), :t, :ts)))),
        Expr(:tuple, xscopes...)
    ))
end

function expr_ifunc_derivative(b::AbstractCompositeBlock, bs = tsort(allcomponents(b)))
    xargs = []
    for p = b.stateinports
        push!(xargs, Expr(:kw, p.name, 0))
    end
    xdashargs = []
    for p = b.dstateinports
        push!(xdashargs, Expr(:kw, p.name, 0))
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
    for p = b.parameterports
        x = p.name
        v = _expr(p.in)
        push!(paramargs, Expr(:kw, x, v))
    end
    xinit = [Symbol(p.name, :init) for p = b.stateinports]
    dx = [Symbol(p.name, :dummy) for p = b.stateinports]
    x2 = [Symbol(p.name, :x2) for p = b.stateinports]
    body = [_expr_initial(m) for m = bs]
    expr1 = Expr(:function,
        Expr(:call, Symbol(b.name, "_ifunc_derivative"),
            Expr(:parameters, Expr(:kw, b.timeport.name, 0), paramargs..., xargs..., xdashargs..., inargs...)),
        Expr(:block, body..., Expr(:vect, dxargs...)))
    expr2 = Expr(:function,
        Expr(:call, Symbol(b.name, "_ifunc"),
            Expr(:parameters, Expr(:kw, b.timeport.name, 0), paramargs..., inargs..., Expr(:kw, :derivative_h, default_derivative_h))),
        Expr(:block,
            Expr(:(=),
                Expr(:tuple, xinit...),
                Expr(:call, Symbol(b.name, "_ifunc_derivative"),
                    Expr(:kw, b.timeport.name, b.timeport.name), paramargs..., inargs...)),
            Expr(:(=),
                Expr(:tuple, dx..., [p.name for p = b.dstateoutports]...),
                Expr(:call, Symbol(b.name, "_sfunc_derivative"), xinit...,
                    [0 for _ = b.dstateinports]..., inargs...,
                    Expr(:kw, b.timeport.name, b.timeport.name), paramargs...)),
            Expr(:(=),
                Expr(:tuple, x2...),
                Expr(:call, :.+, Expr(:tuple, xinit...),
                    Expr(:call, :.*, :derivative_h, Expr(:tuple, dx...)))),
            # Expr(:(=), :x2,
            #     Expr(:call, Symbol(b.name, "_ifunc_derivative"),
            #         Expr(:kw, b.timeport.name, Expr(:call, :+, b.timeport.name, :derivative_h)), paramargs..., inargs...)),
            Expr(:vect, xinit..., x2...)
        ))
    Expr(:block, expr1, expr2)
end

function expr_odemodel_ifunc_derivative(b::AbstractCompositeBlock)
    j = 1
    paramargs = []
    for (i,p) = enumerate(b.parameterports)
        push!(paramargs, Expr(:kw, p.name, Expr(:ref, :p, j)))
    end
    push!(paramargs, Expr(:kw, :derivative_h, Expr(:ref, :p, j)))
    push!(paramargs, Expr(:kw, b.timeport.name, 0))
    Expr(:->, Expr(:tuple, :p), Expr(:call, Symbol(b.name, "_ifunc"), paramargs...,))
end

# function expr_pfunc(b::AbstractCompositeBlock)
#     xargs = []
#     for p = b.stateinports
#         push!(xargs, Expr(:kw, p.name, 0))
#     end
#     inargs = []
#     for p = b.inports
#         push!(inargs, Expr(:kw, p.name, 0))
#     end
#     paramargs = []
#     for p = b.parameterports
#         x = p.name
#         v = _expr(p.in)
#         push!(paramargs, Expr(:kw, x, v))
#     end
#     push!(paramargs, Expr(:kw, b.timeport.name, 0))
#     dxargs = []
#     for p = b.parameterports
#         push!(dxargs, Expr(:(=), p.name, p.name))
#     end
#     Expr(:function,
#         Expr(:call, Symbol(b.name, "_pfunc"),
#             Expr(:parameters, paramargs..., xargs..., inargs...)),
#             Expr(:tuple, dxargs...))
# end

function expr_odemodel_pfunc_derivative(b::AbstractCompositeBlock)
    paramargs = []
    for p = b.parameterports
        x = p.name
        v = _expr(p.in)
        push!(paramargs, Expr(:kw, x, v))
    end
    push!(paramargs, Expr(:kw, :derivative_h, default_derivative_h))
    dxargs = []
    for p = b.parameterports
        push!(dxargs, p.name)
    end
    push!(dxargs, :derivative_h)
    Expr(:->, Expr(:tuple, Expr(:parameters, paramargs...)), Expr(:tuple, dxargs...))
end
