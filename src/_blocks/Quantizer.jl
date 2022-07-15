export Quantizer

mutable struct Quantizer <: AbstractBlock
    inport::AbstractInPort
    outport::AbstractOutPort
    quantizationinterval::Parameter

    function Quantizer(; inport::AbstractInPort = InPort(),
        outport::AbstractOutPort = OutPort(),
        quantizationinterval = Float64(1))
        blk = new()
        blk.quantizationinterval = quantizationinterval
        blk.inport = inport
        blk.outport = outport
        blk.inport.parent = blk
        blk.outport.parent = blk
        blk
    end
end

function expr(blk::Quantizer)
    i = expr_set_inports(blk.inport)

    x = expr_refvalue(blk.inport.var)
    quantizationinterval = expr_refvalue(blk.quantizationinterval)

    b = expr_setvalue(blk.outport.var, :($quantizationinterval * round($x / $quantizationinterval)))

    o = expr_set_outports(blk.outport)
    Expr(:block, i, b, o)
end

function next(blk::Quantizer)
    [line.dest.parent for line = blk.outport.lines]
end

get_default_inport(blk::Quantizer) = blk.inport
get_default_outport(blk::Quantizer) = blk.outport
get_inports(blk::Quantizer) = [blk.inport]
get_outports(blk::Quantizer) = [blk.outport]
