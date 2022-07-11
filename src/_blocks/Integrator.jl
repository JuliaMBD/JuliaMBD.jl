export Integrator

mutable struct Integrator <: AbstractIntegratorBlock
    initialcondition::Parameter
    saturationlimits::NTuple{2,Union{Parameter,Nothing}}
    inblk::AbstractBlock
    outblk::AbstractBlock
    inport::InPort
    outport::OutPort

    function Integrator(;
        statein::InPort,
        stateout::OutPort,
        initialcondition::Parameter = Value{Float64}(0),
        saturationlimits::NTuple{2,Union{Parameter,Nothing}} = (nothing,nothing),
        inport::InPort,
        outport::OutPort)
        blk = new()
        blk.initialcondition = initialcondition
        blk.saturationlimits = saturationlimits
        blk.inblk = Out(inport=inport, outport=stateout)
        blk.outblk = In(inport=statein, outport=outport)
        blk.inport = inport
        blk.outport = outport
        blk
    end
end

function Base.show(io::IO, x::Integrator)
    Base.show(io, "Integrator($([x.inblk, x.outblk]))")
end
