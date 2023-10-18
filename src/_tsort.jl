### prev, next

prev(x::AbstractSimpleBlock) = [x.inports..., x.parameterports...]
next(x::AbstractSimpleBlock) = x.outports

prev(::AbstractConstSignal) = []
next(x::AbstractConstSignal) = [x.dest]

prev(x::AbstractLineSignal) = [x.src]
next(x::AbstractLineSignal) = [x.dest]

prev(x::AbstractInPortBlock) = [x.in]
next(x::AbstractInPortBlock) = [x.parent]

prev(x::AbstractOutPortBlock) = [x.parent]
next(x::AbstractOutPortBlock) = x.outs

prev(x::AbstractParameterPortBlock) = [x.in]
function next(x::AbstractParameterPortBlock)
    if x.parent in undefset
        x.outs
    else
        [x.parent]
    end
end

"""
all blocks

Get all blocks from a block
"""
function allcomponents(b::AbstractCompositeBlock)
    visited = Set{AbstractComponent}()
    for p = b.inports
        _allblocks(p, visited)
    end
    for p = b.outports
        _allblocks(p, visited)
    end
    collect(visited)
end

function allcomponents(blk::AbstractComponent)
    visited = Set{AbstractComponent}()
    _allblocks(blk, visited)
    collect(visited)
end

function _allblocks(blk::AbstractComponent, visited::Set{AbstractComponent})::Nothing
    if blk in undefset
        return nothing
    end
    if blk in visited
        return nothing
    end
    push!(visited, blk)
    for b = next(blk)
        _allblocks(b, visited)
    end
    for b = prev(blk)
        _allblocks(b, visited)
    end
    nothing
end

"""
tsort

Tomprogical sort
"""
function tsort(bs::Vector{AbstractComponent})
    sorted = AbstractComponent[]
    check = Dict{AbstractComponent,Int}()
    for n = bs
        check[n] = 0 # no visited
    end
    for n = bs
        if check[n] != 2
            _visit(n, check, sorted)
        end
    end
    sorted
end

function _visit(n::AbstractComponent, check::Dict{AbstractComponent,Int}, sorted::Vector{AbstractComponent})
    if check[n] == 1 # under searching
        throw(ErrorException("DAG has a closed path"))
    elseif check[n] == 0 # no visited
        check[n] = 1 # start searching
        for m = next(n)
            if !(m in undefset)
                _visit(m, check, sorted)
            end
        end
        check[n] = 2 # visited
        if !(typeof(n) <: AbstractSignal)
            pushfirst!(sorted, n)
        end
    end
end