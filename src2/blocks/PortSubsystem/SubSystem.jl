mutable struct SystemBlockDefinition <: AbstractSystemBlockDefinition
    name::Symbol
    parameters::Vector{AbstractSymbolicValue}
    inports::Vector{Inport}
    outports::Vector{Outport}
    ports::Dict{Symbol,Any}
    blks::Dict{Symbol,Any}
    
    function SystemBlockDefinition(name::Symbol)
        b = new(name,
            AbstractSymbolicValue[],
            Inport[],
            Outport[],
            Dict{Symbol,Any}(),
            Dict{Symbol,Any})
        b
    end
end

mutable struct SubSystem <: AbstractSystemBlockInstance
    definiton::SystemBlockDefinition
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}
    env::Dict{Symbol,Any}
    
    function SubSystem(m::SystemBlockDefinition)
        b = new(m, AbstractInPort[], AbstractOutPort[], Dict{Symbol,Any}())
        for x = m.inports
            p = InPort(get_label(x))
            set_inport!(b, p)
        end
        for x = m.outports
            p = OutPort(get_label(x))
            set_outport!(b, p)
        end
    end
end

"""
set_block!(blk::SystemBlockDefinition, s::Symbol, x::AbstractBlock)
set_block!(blk::SystemBlockDefinition, s::Symbol, x::Inport)
set_block!(blk::SystemBlockDefinition, s::Symbol, x::Outport)

Set a block
"""
function set_block!(blk::SystemBlockDefinition, s::Symbol, x::AbstractBlock)
    blk.blks[s] = x
end

function set_block!(blk::SystemBlockDefinition, s::Symbol, x::Inport)
    set_label!(x, s)
    blk.blks[s] = x
    push!(blk.inports, x)
    ports[s] = x
end

function set_block!(blk::SystemBlockDefinition, s::Symbol, x::Outport)
    set_label!(x, s)
    blk.blks[s] = x
    push!(blk.outports, x)
    ports[s] = x
end

# function get_block(blk::SystemBlockDefinition, s::Symbol)
#     blk.blks[s]
# end

function get_block(blk::SystemBlockDefinition, x::InPort)
    blk.blks[get_name(x)]
end

function expr(blks::Vector{AbstractBlock})
    body = [expr(b) for b = tsort(blks)]
    Expr(:block, body...)
end

function expr_body(blk::SystemBlockDefinition)
    expr(get_blocks(blk))
end
