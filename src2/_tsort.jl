"""
all blocks

Get all blocks from a block
"""
function allblocks(blk::AbstractBlock)
    visited = Set{AbstractBlock}()
    _allblocks(blk, visited)
    collect(visited)
end

function _allblocks(blk::AbstractBlock, visited::Set{AbstractBlock})::Nothing
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
all lines

Get all lines from a block
"""
function alllines(line::AbstractLine)
    visited = Set{AbstractLine}()
    _alllines(line, visited)
    collect(visited)
end

function _alllines(line::AbstractLine, visited::Set{AbstractLine})::Nothing
    if line in visited
        return nothing
    end
    push!(visited, line)
    for x = next(line)
        _alllines(x, visited)
    end
    for x = prev(line)
        _alllines(x, visited)
    end
    nothing
end

"""
tsort

Tomprogical sort to determine the sequence of expression in SystemBlock
"""
function tsort(elem)
    l = []
    check = Dict()
    for n = elem
        check[n] = 0
    end
    for n = elem
        if check[n] != 2
            _visit(n, check, l)
        end
    end
    l
end

function _visit(n, check, l)
    if check[n] == 1
        throw(ErrorException("DAG has a closed path"))
    elseif check[n] == 0
        check[n] = 1
        for m = next(n)
            _visit(m, check, l)
        end
        check[n] = 2
        pushfirst!(l, n)
    end
end

###

# function tsort2(blks::Vector{AbstractBasicBlock}, parent::AbstractBlock)
#     l = AbstractBasicBlock[]
#     s = Stack{AbstractBlock}()
#     push!(s, parent)
#     check = Dict{Tuple{AbstractBasicBlock,AbstractBlock},Int}()
#     for n = blks
#         check[(n,first(s))] = 0
#     end
#     for n = blks
#         if check[(n,first(s))] != 2
#             _visit2(n, check, l, s)
#         end
#     end
#     l
# end

# function _visit2(n::AbstractBasicBlock, check, l, s)
#     if !haskey(check, (n,first(s)))
#         check[(n,first(s))] = 0
#     end
#     if check[(n,first(s))] == 1
#         throw(ErrorException("DAG has a closed path"))
#     end
#     if check[(n,first(s))] == 0
#         check[(n,first(s))] = 1
#         for m = nextblk(n)
#             _visit2(m, check, l, s)
#         end
#         check[(n,first(s))] = 2
#         pushfirst!(l, n)
#     end
# end

# function _visit2(n::AbstractInPort, check, l, s)
#     m = get_parent(n)
#     push!(s, m)
#     _visit2(m.definiton.ports[get_name(n)], check, l, s)
#     pop!(s)
# end

# function _visit2(n::Outport, check, l, s)
#     if typeof(first(s)) != GlobalSystem
#     m = get_parent(n)
#     push!(s, m)
#     _visit2(m.definiton.ports[get_name(n)], check, l, s)
#     pop!(s)
# end

