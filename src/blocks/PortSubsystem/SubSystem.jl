mutable struct SubSystem <: AbstractBlock
    name::Symbol
    parameters::Vector{AbstractSymbolicValue}
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}
    env::Dict{Symbol,Any}
    blks::Vector{AbstractBlock}
    
    function SubSystem()
        b = new(:SubSystem,
            AbstractSymbolicValue[],
            AbstractInPort[],
            AbstractOutPort[],
            Dict{Symbol,Any}(),
            AbstractBlock[])
        b
    end
end

"""
get_blocks(blk::SubSystem)

Get a vector of blocks
"""
function get_blocks(blk::SubSystem)
    blk.blks
end

"""
set_block!(blk::SubSystem, s::Symbol, x::AbstractBlock)
set_block!(blk::SubSystem, s::Symbol, x::Inport)
set_block!(blk::SubSystem, s::Symbol, x::Outport)

Set a block
"""
function set_block!(blk::SubSystem, s::Symbol, x::AbstractBlock)
    push!(get_blocks(blk), x)
    # set_to_env!(blk, s, x)
end

function set_block!(blk::SubSystem, s::Symbol, x::Inport)
    push!(get_blocks(blk), x)
    set_label!(x, s)
    p = InPort(s)
    set_inport!(blk, p)
    set_to_env!(blk, s, p)
end

function set_block!(blk::SubSystem, s::Symbol, x::Outport)
    push!(get_blocks(blk), x)
    set_label!(x, s)
    p = OutPort(s)
    set_outport!(blk, p)
    set_to_env!(blk, s, p)
end

function set_block!(blk::SubSystem, s::Symbol, x::SubSystem)
    for b = get_blocks(x)
        push!(get_blocks(blk), b)
    end
    blk.env[s] = x.env
end

function expr(blks::Vector{AbstractBlock})
    body = [expr(b) for b = tsort(blks)]
    Expr(:block, body...)
end
function expr_body(blk::SubSystem)
    expr(get_blocks(blk))
end
