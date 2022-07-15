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

get_timeport(blk::AbstractTimeBlock) = nothing

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

        
