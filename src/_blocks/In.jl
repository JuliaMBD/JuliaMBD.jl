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
    b = expr_setvalue(blk.outport.var, expr_refvalue(blk.inport.var))
    o = expr_set_outports(blk.outport)
    Expr(:block, b, o)
end

function next(blk::AbstractInBlock)
    [line.dest.parent for line = blk.outport.lines]
end

get_default_inport(blk::AbstractInBlock) = nothing
get_default_outport(blk::AbstractInBlock) = blk.outport
get_inports(blk::AbstractInBlock) = []
get_outports(blk::AbstractInBlock) = [blk.outport]
