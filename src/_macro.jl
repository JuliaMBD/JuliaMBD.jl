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
        throw(TypeError(x, "Invalid format for parameter"))
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
            $m.addBlock!($(x.args[1]))
        end
    else
        throw(TypeError(x, "Invalid format for block"))
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

function _toconnect(x::Any)
    x
end

function _toconnect(x::Expr)
    if Meta.isexpr(x, :call) && x.args[1] == :(=>) && length(x.args) == 3
        :(Line($(x.args[2]), $(x.args[3])))
    else
        throw(TypeError(x, "Invalid format for block"))
    end
end

macro connection(b)
    if Meta.isexpr(b, :block)
        body = [_toconnect(x) for x = b.args]
        esc(Expr(:block, body...))
    else
        esc(_toconnect(b))
    end
end