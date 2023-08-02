mutable struct Add <: AbstractBlock
    name::Symbol
    inports::Vector{InPort}
    signs::Vector{Symbol}
    outport::AbstractOutPort

    function Add(;name::Symbol = gensym(), inports::Vector{InPort}, signs::Vector{Symbol}, outport::AbstractOutPort = OutPort())
        blk = new()
        blk.name = name
        blk.inports = inports
        blk.signs = signs
        blk.outport = outport
        for b = blk.inports
            b.parent = blk
        end
        blk.outport.parent = blk
        blk
    end
end
    
function expr(blk::Add)
    i = expr_set_inports(blk.inports...)

    b0 = expr_setvalue(blk.outport.var, 0)
    b = [expr_setvalue(blk.outport.var, Expr(:call, s, expr_refvalue(blk.outport.var), expr_refvalue(b.var))) for (s,b) = zip(blk.signs, blk.inports)]

    o = expr_set_outports(blk.outport)
    Expr(:block, i, b0, b..., o)
end

get_default_inport(blk::Add) = nothing
get_default_outport(blk::Add) = blk.outport
get_inports(blk::Add) = blk.inports
get_outports(blk::Add) = [blk.outport]
