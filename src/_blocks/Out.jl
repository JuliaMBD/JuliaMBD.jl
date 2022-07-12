export OutBlock, StateOut

mutable struct OutBlock <: AbstractOutBlock
    inport::AbstractInPort
    outport::AbstractOutPort

    function OutBlock(;inport::AbstractInPort, outport::AbstractOutPort)
        blk = new()
        blk.inport = inport
        blk.outport = outport
        blk.inport.parent = blk
        blk.outport.parent = blk
        blk
    end
end

mutable struct StateOut <: AbstractOutBlock
    inport::AbstractInPort
    outport::AbstractOutPort

    function StateOut(;inport::AbstractInPort, outport::AbstractOutPort)
        blk = new()
        blk.inport = inport
        blk.outport = outport
        blk.inport.parent = blk
        blk.outport.parent = blk
        blk
    end
end

function expr(blk::AbstractOutBlock)
    i = expr_setvalue(blk.inport.var, expr_refvalue(blk.inport.line.var))
    b = expr_setvalue(blk.outport.var, expr_refvalue(blk.inport.var))
    # o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]
    Expr(:block, i, b)
end

function next(blk::AbstractOutBlock)
    []
end

function Base.show(io::IO, x::OutBlock)
    Base.show(io, "Out()")
end

function Base.show(io::IO, x::StateOut)
    Base.show(io, "StateOut()")
end
