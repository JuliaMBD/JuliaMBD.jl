export Quantizer

mutable struct Quantizer <: AbstractBlock
    inport::AbstractInPort
    outport::AbstractOutPort
    quantizationinterval::Parameter

    function Quantizer(; inport::AbstractInPort = InPort(),
        outport::AbstractOutPort = OutPort(),
        quantizationinterval = Float64(0))
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
    i = expr_setvalue(blk.inport.var, expr_refvalue(blk.inport.line.var))

    x = expr_refvalue(blk.inport.var)
    quantizationinterval = expr_refvalue(blk.quantizationinterval)

    b = expr_setvalue(blk.outport.var, :($quantizationinterval * round($x / $quantizationinterval)))

    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]
    Expr(:block, i, b, o...)
end

function next(blk::Quantizer)
    [line.dest.parent for line = blk.outport.lines]
end

function defaultInPort(blk::Quantizer)
    blk.inport
end

function defaultOutPort(blk::Quantizer)
    blk.outport
end

