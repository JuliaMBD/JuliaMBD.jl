export Constant

mutable struct Constant <: AbstractBlock
    value::Parameter
    outport::AbstractOutPort

    function Constant(;value::Parameter, outport::AbstractOutPort = OutPort())
        blk = new()
        blk.value = value
        blk.outport = outport
        blk.outport.parent = blk
        blk
    end
end
    

function expr(blk::Constant)
    value = expr_refvalue(blk.value)
    b = expr_setvalue(blk.outport.var, :($value))
    o = expr_set_outports(blk.outport)
    Expr(:block, b, o)
end

function next(blk::Constant)
    [line.dest.parent for line = blk.outport.lines]
end

get_default_inport(blk::Constant) = nothing
get_default_outport(blk::Constant) = blk.outport
get_inports(blk::Constant) = []
get_outports(blk::Constant) = [blk.outport]
