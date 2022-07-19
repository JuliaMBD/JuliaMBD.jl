"""
Define the default methods for AbstractBlock
"""

get_default_inport(p::AbstractInPort) = p
get_default_inport(p::AbstractOutPort) = get_default_inport(p.parent)
get_default_outport(p::AbstractOutPort) = p
get_default_outport(p::AbstractInPort) = get_default_outport(p.parent)
get_default_inport(blk::AbstractBlock) = nothing
get_default_outport(blk::AbstractBlock) = nothing

get_inports(blk::AbstractBlock) = []
get_outports(blk::AbstractBlock) = []
expr_call(blk::AbstractBlock) = Expr(:tuple)

get_timeport(blk::AbstractTimeBlock) = blk.timeport

get_parameters(blk::AbstractBlock) = blk.pfunc(blk)

function prev(blk::AbstractBlock)
    b = AbstractBlock[]
    for p = get_inports(blk)
        if !isnothing(p.line)
            push!(b, p.line.source.parent)
        end
    end
    b
end

function next(blk::AbstractBlock)
    b = AbstractBlock[]
    for p = get_outports(blk)
        for line = p.lines
            push!(b, line.dest.parent)
        end
    end
    b
end

function expr_set_inports(inports...)
    body = [Expr(:block, expr_setvalue(p.var, expr_refvalue(p.line.var))) for p = inports]
    Expr(:block, body...)
end

function expr_set_outports(outports...)
    body = []
    for p = outports
        for line = p.lines
            push!(body, expr_setvalue(line.var, expr_refvalue(p.var)))
        end
    end
    Expr(:block, body...)
end

        
function expr_initial(b::AbstractBlock)
    expr(b)
end

name(x::SymbolicValue) = x.name
name(x::AbstractPort) = x.var.name
name(x::Vector{Ts}) where Ts = [name(e) for e = x]

macro q(x)
    esc(:(_toquote($x)))
end

_toquote(x::Symbol) = Expr(:quote, x)
_toquote(x::Any) = x

expr_refvalue(x::Any) = x
expr_refvalue(x::SymbolicValue{Tv}) where Tv = x.name
expr_setvalue(x::SymbolicValue{Tv}, expr) where Tv = Expr(:(=), x.name, Expr(:call, Symbol(Tv), expr))
expr_setvalue(x::SymbolicValue{Auto}, expr) = Expr(:(=), x.name, expr)

function expr_kwvalue(x::SymbolicValue{Tv}, expr) where Tv
    Expr(:call, :Expr, Expr(:quote, :kw), Expr(:quote, x.name),
    Expr(:call, :Expr, Expr(:quote, :call), Expr(:call, :Symbol, Tv), expr))
end

function expr_kwvalue(x::SymbolicValue{Auto}, expr)
    Expr(:call, :Expr, Expr(:quote, :kw), Expr(:quote, x.name), expr)
end


expr_defvalue(x::SymbolicValue{Tv}) where Tv = Expr(:(::), x.name, Symbol(Tv))
expr_defvalue(x::SymbolicValue{Auto}) = x.name
expr_defvalue(x::Tuple{SymbolicValue,Any}) = Expr(:kw, expr_defvalue(x[1]), x[2])

expr_setpair(x::SymbolicValue{Tv}, expr) where Tv = Expr(:call, :(=>), @q(x.name), Expr(:call, Symbol(Tv), expr))
expr_setpair(x::SymbolicValue{Auto}, expr) = Expr(:call, :(=>), @q(x.name), expr)

