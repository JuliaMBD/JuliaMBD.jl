function _toparam(x::Any, m)
    x
end

function _toparam(x::Symbol, m)
    :(addParameter!($m, SymbolicValue{Auto}($(Expr(:quote, x)))))
end

function _toparam(x::Expr, m)
    if Meta.isexpr(x, :(::)) && length(x.args) == 2
        :(addParameter!($m, SymbolicValue{$(x.args[2])}($(Expr(:quote, x.args[1])))))
    elseif Meta.isexpr(x, :(=)) && typeof(x.args[1]) == Symbol && length(x.args) == 2
        :(addParameter!($m, SymbolicValue{Auto}($(Expr(:quote, x.args[1]))), $(x.args[2])))
    elseif Meta.isexpr(x, :(=)) && Meta.isexpr(x.args[1], :(::)) && length(x.args) == 2
        :(addParameter!($m, SymbolicValue{$(x.args[1].args[2])}($(Expr(:quote, x.args[1].args[1]))), $(x.args[2])))
    else
        x
    end
end

macro parameter(m, b)
    if Meta.isexpr(b, :block)
        body = [_toparam(x, m) for x = b.args]
        esc(Expr(:block, body...))
    else
        esc(_toparam(b, m))
    end
end

function _toblk(x::Any, m)
    x
end

function _toblk(x::Expr, m)
    if Meta.isexpr(x, :(=)) && typeof(x.args[1]) == Symbol && length(x.args) == 2
        quote
            $x
            addBlock!($m, $(x.args[1]))
        end
    else
        x
    end
end

macro block(m, b)
    if Meta.isexpr(b, :block)
        body = [_toblk(x, m) for x = b.args]
        esc(Expr(:block, body...))
    else
        esc(_toblk(b, m))
    end
end

function _addscope(x::Any, m)
    x
end

function _addscope(x::Symbol, m)
    :(addBlock!($m, Scope($x)))
end

function _addscope(x::Expr, m)
    :(addBlock!($m, Scope($x)))
end

macro scope(m, b)
    if Meta.isexpr(b, :block)
        body = [_addscope(x, m) for x = b.args]
        esc(Expr(:block, body...))
    else
        esc(_addscope(b, m))
    end
end

macro model(f, e::Bool, block)　　
    body = []
    push!(body, Expr(:(=), :tmp, Expr(:call, :SystemBlockDefinition, Expr(:quote, f))))
    if Meta.isexpr(block, :block)
        for x = block.args
            push!(body, _replace_macro(x))
        end
    end
    if e == true
        push!(body, :(eval(expr_define_function(tmp))))
        push!(body, :(eval(expr_define_initialfunction(tmp))))
        push!(body, :(eval(expr_define_structure(tmp))))
        push!(body, :(eval(expr_define_next(tmp))))
        push!(body, :(eval(expr_define_expr(tmp))))
    end
    push!(body, :tmp)
    esc(Expr(:block, body...))
end

macro model(f, block)　　
    body = []
    push!(body, Expr(:(=), :tmp, Expr(:call, :SystemBlockDefinition, Expr(:quote, f))))
    if Meta.isexpr(block, :block)
        for x = block.args
            push!(body, _replace_macro(x))
        end
    end
    push!(body, :(eval(expr_define_function(tmp))))
    push!(body, :(eval(expr_define_initialfunction(tmp))))
    push!(body, :(eval(expr_define_structure(tmp))))
    push!(body, :(eval(expr_define_next(tmp))))
    push!(body, :(eval(expr_define_expr(tmp))))
    push!(body, :tmp)
    esc(Expr(:block, body...))
end

function _replace_macro(x::Any)
    x
end

function _replace_macro(x::Expr)
    if Meta.isexpr(x, :macrocall) && (x.args[1] == Symbol("@block") || x.args[1] == Symbol("@parameter") || x.args[1] == Symbol("@scope"))
        Expr(:macrocall, x.args[1], x.args[2], :tmp, [_replace_macro(u) for u = x.args[3:end]]...)
    else
        Expr(x.head, [_replace_macro(u) for u = x.args]...)
    end
end