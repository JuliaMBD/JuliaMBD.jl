export @model
export @parameter
export @block
export @connect
export @scope

macro parameter(m, b)
    if Meta.isexpr(b, :block)
        body = [_toparam(x, m) for x = b.args]
        esc(Expr(:block, body...))
    else
        esc(_toparam(b, m))
    end
end

_toparam(x::Any, m) = x
_toparam(x::Symbol, m) = :(JuliaMBD.addparameter!($m, $(Expr(:quote, x)), $x, JuliaMBD.Auto))

function _toparam(x::Expr, m)
    if Meta.isexpr(x, :(::)) && length(x.args) == 2
        :(JuliaMBD.addparameter!($m, $(Expr(:quote, x.args[1])), $(x.args[1]), $(x.args[2])))
    elseif Meta.isexpr(x, :(=)) && typeof(x.args[1]) == Symbol && length(x.args) == 2
        :(JuliaMBD.addparameter!($m, $(Expr(:quote, x.args[1])), $(x.args[2]), JuliaMBD.Auto))
    elseif Meta.isexpr(x, :(=)) && Meta.isexpr(x.args[1], :(::)) && length(x.args) == 2
        :(JuliaMBD.addparameter!($m, $(Expr(:quote, x.args[1].args[1])), $(x.args[2]), $(x.args[1].args[2])))
    else
        x
    end
end

###

function getargs(x::Any, res)
end

function getargs(x::Expr, res)
    if Meta.isexpr(x, :macrocall) && x.args[1] == Symbol("@parameter")
        for u = x.args[3:end]
            toarg(u, res)
        end
    else
        for u = x.args
            getargs(u, res)
        end
    end
end

function toarg(b, res)
    if Meta.isexpr(b, :block)
        for x = b.args
            _toarg(x, res)
        end
    else
        _toarg(b, res)
    end
end

function _toarg(x::Any, res)
end

function _toarg(x::Symbol, res)
    push!(res, Expr(:kw, x, Expr(:quote, x)))
end

function _toarg(x::Expr, res)
    if Meta.isexpr(x, :(::)) && length(x.args) == 2
        push!(res, Expr(:kw, x, 0))
    elseif Meta.isexpr(x, :(=)) && typeof(x.args[1]) == Symbol && length(x.args) == 2
        push!(res, Expr(:kw, x.args[1], x.args[2]))
    elseif Meta.isexpr(x, :(=)) && Meta.isexpr(x.args[1], :(::)) && length(x.args) == 2
        push!(res, Expr(:kw, x.args[1], x.args[2]))
    end
end

###

macro block(m, b)
    if Meta.isexpr(b, :block)
        body = [_toblk(x, m) for x = b.args]
        esc(Expr(:block, body...))
    else
        esc(_toblk(b, m))
    end
end

_toblk(x::Any, m) = x

function _toblk(x::Expr, m)
    if Meta.isexpr(x, :(=)) && typeof(x.args[1]) == Symbol && length(x.args) == 2
        quote
            $x
            JuliaMBD.add!($m, $(x.args[1]))
        end
    else
        x
    end
end

###

_togetport(x::Any) = x

function _togetport(x::Expr)
    if Meta.isexpr(x, :.) && length(x.args) == 2 && typeof(x.args[1]) == Symbol && typeof(x.args[2]) == QuoteNode
        :(JuliaMBD.getport($(x.args[1]), $(x.args[2])))
    else
        x
    end
end

###

macro scope(m, b)
    if Meta.isexpr(b, :block)
        body = [_addscope(x, m) for x = b.args]
        esc(Expr(:block, body...))
    else
        esc(_addscope(b, m))
    end
end

_addscope(x::Any, m) = x

function _addscope(x::Expr, m)
    if Meta.isexpr(x, :call) && x.args[1] == :(=>) && length(x.args) == 3
        :(JuliaMBD.addscope!($m, $(Expr(:quote, x.args[3])), $(_togetport(x.args[2]))))
    else
        x
    end
end

###

macro connect(m, b)
    if Meta.isexpr(b, :block)
        body = [_connect(x, m) for x = b.args]
        esc(Expr(:block, body...))
    else
        esc(_connect(b, m))
    end
end

_connect(x::Any, m) = x

function _connect(x::Expr, m)
    if Meta.isexpr(x, :call) && x.args[1] == :(=>) && length(x.args) == 3
        :(JuliaMBD.LineSignal($(_togetport(x.args[2])), $(_togetport(x.args[3]))))
    else
        x
    end
end

###

macro model(f, block)
    params = []
    if Meta.isexpr(block, :block)
        for x = block.args
            getargs(x, params)
        end
    end
    body = []
    push!(body, :(tmp = JuliaMBD.SubSystemBlock($(Expr(:quote, f)))))
    if Meta.isexpr(block, :block)
        for x = block.args
            push!(body, _replace_macro(x))
        end
    end
    push!(body, :tmp)
    esc(Expr(:function, Expr(:call, f, Expr(:parameters, params...)), Expr(:block, body...)))

    # expr = []
    # push!(expr, Expr(:function, Expr(:call, f, Expr(:parameters, params...)), Expr(:block, body...)))
    # push!(expr, :(tmp = $f()))
    # push!(expr, :(eval(JuliaMBD.expr_sfunc(tmp))))
    # push!(expr, :(eval(JuliaMBD.expr_ofunc(tmp))))
    # push!(expr, :(eval(JuliaMBD.expr_ifunc(tmp))))
    # push!(expr, :(eval(JuliaMBD.expr_pfunc(tmp))))
    # esc(Expr(:block, expr...))
end

"""
(:function, (:call, :f, (:parameters, (:kw, :x, 1), :y)), (:block,
      :(#= REPL[6]:2 =#),
      :(#= REPL[6]:3 =#),
      (:call, :+, 1, 1)
    ))
"""

function _replace_macro(x::Any)
    x
end

function _replace_macro(x::Expr)
    if Meta.isexpr(x, :macrocall) && (x.args[1] == Symbol("@block") || x.args[1] == Symbol("@parameter") || x.args[1] == Symbol("@scope") || x.args[1] == Symbol("@connect"))
        Expr(:macrocall, x.args[1], x.args[2], :tmp, [_replace_macro(u) for u = x.args[3:end]]...)
    else
        Expr(x.head, [_replace_macro(u) for u = x.args]...)
    end
end