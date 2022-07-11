export Constant

mutable struct Constant <: AbstractBlock
    value::Parameter
    outport::OutPort

    function Constant(;value::Parameter, outport::OutPort)
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

    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]
    Expr(:block, b, o...)
end

function next(blk::Constant)
    [line.dest.parent for line = blk.outport.lines]
end

function Base.show(io::IO, x::Constant)
    Base.show(io, "Constant($(x.value))")
end
