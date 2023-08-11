"""
Properties of AbstractBlock

- blkname::Symbol The name of block (class name)
- parameters::Vector{AbstractSymbolicValue}
- inports::Vector{AbstractInPort}
- outports::Vector{AbstractOutPort}
- env::Dict{Symbol,Any}
"""

"""
Base.show(io::IO, x::AbstractBlock)

Show the block
"""
function Base.show(io::IO, x::AbstractBlock)
    Base.show(io, get_name(x))
end

"""
get_name(blk::AbstractBlock)

Get the symbol representing the class of block
"""
function get_name(blk::AbstractBlock)
    blk.name
end

"""
get_inports(blk::AbstractBlock)

Get inports of block as Dict{Symbol,AbstractInPort}.
"""
function get_inports(blk::AbstractBlock)
    blk.inports
end

"""
get_outports(blk::AbstractBlock)

Get outports of block as Dict{Symbol,AbstractOutPort}.
"""
function get_outports(blk::AbstractBlock)
    blk.outports
end

"""
get_default_inport(blk::AbstractBlock)

Get an inport
"""
function get_default_inport(blk::AbstractBlock)
    get_inports(blk)[1]
end

"""
get_default_outport(blk::AbstractBlock)

Get an outport
"""
function get_default_outport(blk::AbstractBlock)
    get_outports(blk)[1]
end

"""
get_parameters(blk::AbstractBlock)

Get a vector of parameters
"""
function get_parameters(blk::AbstractBlock)
    blk.parameters
end

"""
set_parameter!(blk::AbstractBlock, s::Symbol, x::Tv) where Tv

Set a parameter.
"""
function set_parameter!(blk::AbstractBlock, s::Symbol, x::Tv) where Tv
    # push!(blk.parameters, SymbolicValue{Tv}(s))
    push!(blk.parameters, SymbolicValue{Auto}(s))
    set_to_env!(blk, s, x)
end

"""
set_to_env!(blk::AbstractBlock, s::Symbol, x::Any)

Set a variable x to env.
"""
function set_to_env!(blk::AbstractBlock, s::Symbol, x::Any)
    blk.env[s] = x
end

"""
set_inport!(blk::AbstractBlock, p::AbstractInPort)

Set an inport.
"""
function set_inport!(blk::AbstractBlock, p::AbstractInPort)
    set_parent!(p, blk)
    push!(get_inports(blk), p)
    set_to_env!(blk, get_name(p), p)
end

"""
set_outport!(blk::AbstractBlock, p::AbstractOutPort)

Set an outport.
"""
function set_outport!(blk::AbstractBlock, p::AbstractOutPort)
    set_parent!(p, blk)
    push!(get_outports(blk), p)
    set_to_env!(blk, get_name(p), p)
end

"""
getindex(blk::AbstractBlock, x::Symbol)

Get an element
"""
function Base.getindex(blk::AbstractBlock, x::Symbol)
    blk.env[x]
end

"""
expr_body(blk::AbstractBlock)

Get an expr for the process of block. This is called from `expr`
"""
function expr_body(blk::AbstractBlock)
    :(())
end

"""
expr(blk::AbstractBlock)

Get Expr for a given block.

Rule:
- The name of an inport is used in the local scope of block.
- The name of an outport is used in the local scope.
- Example
```
  (a tuple of the names of lines) = let (a tuple of the names of inports) = (a tuple of the names of lines)
    ...
    body
    ...
    (a tuple of the names of outports)
  end
```
"""
function expr(blk::AbstractBlock)
    ins = []
    outs_left = []
    outs_right = []
    for p = get_inports(blk)
        l = get_line(p)
        if !isnothing(l)
            push!(ins, Expr(:(=), expr_setpair(get_var(p), expr_refvalue(l))...))
        else
            push!(ins, expr_refvalue(p))
        end
    end
    for p = get_outports(blk)
        push!(ins, expr_refvalue(p))
        for l = get_lines(p)
            left, right = expr_setpair(get_var(l), expr_refvalue(p))
            push!(outs_left, left)
            push!(outs_right, right)
        end
    end
    for x = get_parameters(blk)
        push!(ins, Expr(:(=), expr_setpair(x, expr_refvalue(blk[get_name(x)]))...))
    end
    body = expr_body(blk)
    Expr(:(=), Expr(:tuple, outs_left...),
        Expr(:let, Expr(:block, ins...),
            Expr(:block, body, Expr(:tuple, outs_right...))))
end

"""
prev(blk::AbstractBlock)

Get a vector of previous blocks
"""
function prev(blk::AbstractBlock)
    b = AbstractBlock[]
    for p = get_inports(blk)
        line = get_line(p)
        if !isnothing(line)
            tmp = get_parent(get_source(line))
            if !isnothing(tmp)
                push!(b, tmp)
            end
        end
    end
    b
end

function next(blk::AbstractBlock)
    b = AbstractBlock[]
    for p = get_outports(blk)
        for line = get_lines(p)
            tmp = get_parent(get_dest(line))
            if !isnothing(tmp)
                push!(b, tmp)
            end
        end
    end
    b
end


# function expr()
#     i = [expr_set_inports(blk.left, blk.right) for (k,p) = get_inports(blk)]

#     left = expr_refvalue(blk.left.var)
#     right = expr_refvalue(blk.right.var)
#     operator = blk.operator

#     b = expr_setvalue(blk.outport.var, Expr(:call, operator, left, right))

#     o = expr_set_outports(blk.outport)
#     Expr(:block, i, b, o)
# end

# function expr_set_inports(inports...)
#     body = [Expr(:block, expr_setvalue(p.var, expr_refvalue(p.line.var))) for p = inports]
#     Expr(:block, body...)
# end
