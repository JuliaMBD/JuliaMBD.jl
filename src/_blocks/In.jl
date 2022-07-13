export InBlock, StateIn

mutable struct InBlock <: AbstractInBlock
    inport::AbstractInPort
    outport::AbstractOutPort

    function InBlock(;inport::AbstractInPort, outport::AbstractOutPort)
        blk = new()
        blk.inport = inport
        blk.outport = outport
        blk.inport.parent = blk
        blk.outport.parent = blk
        blk
    end

    function InBlock(name::Symbol; outport::AbstractOutPort = OutPort())
        InBlock(inport=InPort(name), outport=outport)
    end
end

mutable struct StateIn <: AbstractInBlock
    inport::AbstractInPort
    outport::AbstractOutPort

    function StateIn(;inport::AbstractInPort, outport::AbstractOutPort)
        blk = new()
        blk.inport = inport
        blk.outport = outport
        blk.inport.parent = blk
        blk.outport.parent = blk
        blk
    end
end

mutable struct TimeIn <: AbstractInBlock
    inport::AbstractInPort
    outport::AbstractOutPort

    function TimeIn(;inport::AbstractInPort, outport::AbstractOutPort)
        blk = new()
        blk.inport = inport
        blk.outport = outport
        blk.inport.parent = blk
        blk.outport.parent = blk
        blk
    end
end

function expr(blk::AbstractInBlock)
    # i = expr_setvalue(blk.inport.var, expr_refvalue(blk.inport.line.var))
    b = expr_setvalue(blk.outport.var, expr_refvalue(blk.inport.var))
    o = [expr_setvalue(line.var, expr_refvalue(blk.outport.var)) for line = blk.outport.lines]
    Expr(:block, b, o...)
end

function next(blk::AbstractInBlock)
    [line.dest.parent for line = blk.outport.lines]
end

function Base.show(io::IO, x::InBlock)
    Base.show(io, "In()")
end

function Base.show(io::IO, x::StateIn)
    Base.show(io, "StateIn()")
end

function defaultInPort(blk::AbstractInBlock)
    nothing
end

function defaultOutPort(blk::AbstractInBlock)
    blk.outport
end