"""
AbstractBlock

- name::Symbol The name of block (class name)
- inports::Vector{AbstractInPort}
- outports::Vector{AbstractOutPort}
- env::Dict{Symbol,Any}
"""

"""
AbstractBasicBlock <: AbstractBlock

- name::Symbol The name of block (class name)
- parameters::Vector{AbstractSymbolicValue}
- inports::Vector{AbstractInPort}
- outports::Vector{AbstractOutPort}
- env::Dict{Symbol,Any}
"""

"""
AbstractSystemBlockDefinition

- name::Symbol The name of block (class name)
- parameters::Vector{AbstractSymbolicValue}
- inports::Vector{Inport}
- outports::Vector{Outport}
- ports::Dict{Symbol,Any}
"""

"""
AbstractSystemBlockInstance <: AbstractBlock

- inports::Vector{AbstractInPort}
- outports::Vector{AbstractOutPort}
- env::Dict{Symbol,Any}
- definiton::AbstractSystemBlockDefinition
"""

"""
Base.show(io::IO, x::AbstractBlock)

Show the block
"""
function Base.show(io::IO, x::AbstractBlock)
    Base.show(io, get_name(x))
end

"""
Base.show(io::IO, x::AbstractSystemBlockDefinition)

Show the block
"""
function Base.show(io::IO, x::AbstractSystemBlockDefinition)
    Base.show(io, Symbol(x.name, "Definition"))
end

"""
get_name(blk::AbstractBlock)
get_name(blk::AbstractSystemBlockInstance)
get_name(blk::AbstractSystemBlockDefinition)

Get the symbol representing the class of block
"""
function get_name(blk::AbstractBlock)
    blk.name
end

function get_name(blk::AbstractSystemBlockInstance)
    get_name(blk.definiton)
end

function get_name(blk::AbstractSystemBlockDefinition)
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
get_parameters(blk::AbstractSystemBlockInstance)
get_parameters(blk::AbstractSystemBlockDefinition)

Get a vector of parameters
"""
function get_parameters(blk::AbstractBlock)
    blk.parameters
end

function get_parameters(blk::AbstractSystemBlockInstance)
    get_parameters(blk.definiton)
end

function get_parameters(blk::AbstractSystemBlockDefinition)
    blk.parameters
end

"""
getindex(blk::AbstractBlock, x::Symbol)

Get an element
"""
function Base.getindex(blk::AbstractBlock, x::Symbol)
    blk.env[x]
end

"""
set_parameter!(blk::AbstractBasicBlock, s::Symbol, x::Tv) where Tv

Set a parameter.
"""
function set_parameter!(blk::AbstractBasicBlock, s::Symbol, x::Tv) where Tv
    # push!(blk.parameters, SymbolicValue{Tv}(s))
    push!(blk.parameters, SymbolicValue{Auto}(s))
    blk.env[s] = x
end

"""
set_inport!(blk::AbstractBasicBlock, p::AbstractInPort)

Set an inport.
"""
function set_inport!(blk::AbstractBlock, p::AbstractInPort)
    set_parent!(p, blk)
    push!(blk.inports, p)
    blk.env[get_name(p)] = p
end

"""
set_outport!(blk::AbstractBasicBlock, p::AbstractOutPort)

Set an outport.
"""
function set_outport!(blk::AbstractBlock, p::AbstractOutPort)
    set_parent!(p, blk)
    push!(blk.outports, p)
    blk.env[get_name(p)] = p
end

"""
expr(blk::AbstractBasicBlock)

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
function expr(blk::AbstractBasicBlock)
    # ins = []
    # outs_left = []
    # outs_right = []
    # for p = get_inports(blk)
    #     l = get_line(p)
    #     if !isnothing(l)
    #         push!(ins, Expr(:(=), expr_setpair(get_var(p), expr_refvalue(l))...))
    #     else
    #         # push!(ins, expr_refvalue(p))
    #         push!(ins, Expr(:(=), expr_refvalue(p), expr_refvalue(p)))
    #     end
    # end
    # for p = get_outports(blk)
    #     push!(ins, expr_refvalue(p))
    #     if length(get_lines(p)) == 0
    #         push!(outs_left, expr_refvalue(p))
    #         push!(outs_right, expr_refvalue(p))
    #     else
    #         for l = get_lines(p)
    #             left, right = expr_setpair(get_var(l), expr_refvalue(p))
    #             push!(outs_left, left)
    #             push!(outs_right, right)
    #         end
    #     end
    # end
    # for x = get_parameters(blk)
    #     push!(ins, Expr(:(=), expr_setpair(x, expr_refvalue(blk[get_name(x)]))...))
    # end
    # body = expr_body(blk)
    # Expr(:(=), Expr(:tuple, outs_left...),
    #     Expr(:let, Expr(:block, ins...),
    #         Expr(:block, body, Expr(:tuple, outs_right...))))
    _expr(get_inports(blk), get_outports(blk),
        Tuple{AbstractSymbolicValue,Any}[(p, blk[get_name(p)]) for p = get_parameters(blk)],
        expr_body(blk))
end

function _expr(inports::Vector{AbstractInPort}, outports::Vector{AbstractOutPort},
    params::Vector{Tuple{AbstractSymbolicValue,Any}}, body::Expr)
    ins = []
    outs_left = []
    outs_right = []
    for p = inports
        l = get_line(p)
        if !isnothing(l)
            push!(ins, Expr(:(=), expr_setpair(get_var(p), expr_refvalue(l))...))
        else
            # push!(ins, expr_refvalue(p))
            push!(ins, Expr(:(=), expr_refvalue(p), expr_refvalue(p)))
        end
    end
    for p = outports
        push!(ins, expr_refvalue(p))
        if length(get_lines(p)) == 0
            push!(outs_left, expr_refvalue(p))
            push!(outs_right, expr_refvalue(p))
        else
            for l = get_lines(p)
                left, right = expr_setpair(get_var(l), expr_refvalue(p))
                push!(outs_left, left)
                push!(outs_right, right)
            end
        end
    end
    for (x,v) = params
        push!(ins, Expr(:(=), expr_setpair(x, expr_refvalue(v))...))
    end
    Expr(:(=), Expr(:tuple, outs_left...),
        Expr(:let, Expr(:block, ins...),
            Expr(:block, body, Expr(:tuple, outs_right...))))
end

"""
expr_body(blk::AbstractBasicBlock)

Get an expr for the process of block. This is called from `expr`
"""
function expr_body(blk::AbstractBasicBlock)
    :(())
end

# """
# expr_function(blk::AbstractBlock, f::Symbol)

# Get Expr of function for a given block.

# Rule:
# - The name of an inport is used in the local scope of block.
# - The name of an outport is used in the local scope.
# - Example
# ```
#   function f((a tuple of the names of inports) = (a tuple of the names of lines)
#     ...
#     body
#     ...
#     (a tuple of the names of outports)
#   end
# ```
# """
# function expr(blk::AbstractBlock)
#     ins = []
#     outs_left = []
#     outs_right = []
#     for p = get_inports(blk)
#         l = get_line(p)
#         if !isnothing(l)
#             push!(ins, Expr(:(=), expr_setpair(get_var(p), expr_refvalue(l))...))
#         else
#             push!(ins, expr_refvalue(p))
#         end
#     end
#     for p = get_outports(blk)
#         push!(ins, expr_refvalue(p))
#         for l = get_lines(p)
#             left, right = expr_setpair(get_var(l), expr_refvalue(p))
#             push!(outs_left, left)
#             push!(outs_right, right)
#         end
#     end
#     for x = get_parameters(blk)
#         push!(ins, Expr(:(=), expr_setpair(x, expr_refvalue(blk[get_name(x)]))...))
#     end
#     body = expr_body(blk)
#     Expr(:(=), Expr(:tuple, outs_left...),
#         Expr(:let, Expr(:block, ins...),
#             Expr(:block, body, Expr(:tuple, outs_right...))))
# end

"""
next(blk::AbstractBlock)

Get a vector of next blocks
"""
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

"""
next(line::AbstractLine)

Get a vector of next lines
"""
function next(line::AbstractLine)
    b = AbstractLine[]
    nextinport = get_dest(line)
    nextblk = get_parent(nextinport)
    if !isnothing(nextblk)
        for p = get_outports(nextblk)
            for l = get_lines(p)
                push!(b, l)
            end
        end
    end
    b
end

"""
prev(line::AbstractLine)

Get a vector of prev lines
"""
function prev(line::AbstractLine)
    b = AbstractLine[]
    prevoutport = get_source(line)
    prevblk = get_parent(prevoutport)
    if !isnothing(prevblk)
        for p = get_inports(prevblk)
            l = get_line(p)
            if !isnothing(l)
                push!(b, l)
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


## precompile

"""
```julia
function precompile(b::Inport)
    inblocks = []
    outblocks = []
    ex = []
    for x = tsort(allblocks(b))
        push!(ex, expr(x))
        if typeof(x) == Inport
            push!(inblocks, get_label(x))
        end
        if typeof(x) == Outport
            push!(outblocks, get_label(x))
        end
    end
    Expr(:block, ex...), inblocks, outblocks
end
```
"""
