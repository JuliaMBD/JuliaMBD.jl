export OutBlock, StateOut, Scope

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

    function OutBlock(name::Symbol; inport::AbstractInPort = InPort())
        OutBlock(inport = inport, outport = OutPort(name))
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

mutable struct Scope <: AbstractOutBlock
    inport::AbstractInPort
    outport::AbstractOutPort

    function Scope(;inport::AbstractInPort, outport::AbstractOutPort)
        blk = new()
        blk.inport = inport
        blk.outport = outport
        blk.inport.parent = blk
        blk.outport.parent = blk
        blk
    end

    function Scope(name::Symbol; inport::AbstractInPort = InPort())
        Scope(inport=inport, outport=OutPort(name))
    end

    function Scope(target::AbstractOutPort)
        s = Scope(inport=InPort(), outport=OutPort(Symbol(:scope_, target.var.name)))
        Line(target, s.inport)
        s
    end

    function Scope(target::AbstractBlock)
        Scope(get_default_outport(target))
    end

    function Scope(target::AbstractInPort)
        Scope(target.line.source)
    end
end

function expr(blk::AbstractOutBlock)
    i = expr_set_inports(blk.inport)
    b = expr_setvalue(blk.outport.var, expr_refvalue(blk.inport.var))
    Expr(:block, i, b)
end

get_default_inport(blk::AbstractOutBlock) = blk.inport
get_default_outport(blk::AbstractOutBlock) = nothing
get_inports(blk::AbstractOutBlock) = [blk.inport]
get_outports(blk::AbstractOutBlock) = []