export Integrator

mutable struct Integrator <: AbstractIntegratorBlock
    initialcondition::Parameter
    saturationlimits::NTuple{2,Union{Parameter,Nothing}}
    inport::AbstractInPort
    outport::AbstractOutPort
    inblk::StateOut
    outblk::StateIn

    function Integrator(;
        statein::AbstractInPort,
        stateout::AbstractOutPort,
        initialcondition::Parameter = Value{Float64}(0),
        saturationlimits::NTuple{2,Union{Parameter,Nothing}} = (nothing,nothing),
        inport::AbstractInPort,
        outport::AbstractOutPort)
        blk = new()
        blk.initialcondition = initialcondition
        blk.saturationlimits = saturationlimits
        blk.inblk = StateOut(inport=inport, outport=stateout)
        blk.outblk = StateIn(inport=statein, outport=outport)
        blk.inport = inport
        blk.outport = outport
        blk
    end
end

function Base.show(io::IO, x::Integrator)
    Base.show(io, "Integrator($([x.inblk, x.outblk]))")
end
