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
    expr(x, x.type)
end
