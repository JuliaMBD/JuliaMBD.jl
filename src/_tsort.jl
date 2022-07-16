"""
tsort

Tomprogical sort to determine the sequence of expression in SystemBlock
"""

function tsort(blks::Vector{AbstractBlock})
    l = []
    check = Dict()
    for n = blks
        check[n] = 0
    end
    for n = blks
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

"""
all blocks

Get all blocks backward from a set of blocks
"""

function allblocks(blks::Vector{AbstractBlock})
    visit = Set{AbstractBlock}()
    while !isempty(blks)
        b = pop!(blks)
        if in(b, visit)
            continue
        else
            push!(visit, b)
            push!(blks, prev(b)...)
        end
    end
    collect(visit)
end
