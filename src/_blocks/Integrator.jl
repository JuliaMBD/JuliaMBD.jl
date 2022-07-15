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
        initialcondition::Parameter = Float64(0),
        saturationlimits::NTuple{2,Union{Parameter,Nothing}} = (nothing,nothing),
        inport::AbstractInPort = InPort(),
        outport::AbstractOutPort = OutPort())
        blk = new()
        blk.initialcondition = initialcondition
        blk.saturationlimits = saturationlimits
        blk.inblk = StateOut(inport=inport, outport=stateout)
        blk.outblk = StateIn(inport=statein, outport=outport)
        blk.inport = inport
        blk.outport = outport
        blk
    end

    function Integrator(state::Symbol;
        initialcondition::Parameter = Float64(0),
        saturationlimits::NTuple{2,Union{Parameter,Nothing}} = (nothing,nothing),
        inport::AbstractInPort = InPort(),
        outport::AbstractOutPort = OutPort())
        Integrator(statein = InPort(Symbol(state, :in)), stateout = OutPort(Symbol(state, :out)),
            initialcondition = initialcondition,
            saturationlimits = saturationlimits,
            inport = inport,
            outport = outport)
    end
end

get_default_inport(blk::Integrator) = blk.inport
get_default_outport(blk::Integrator) = blk.outport
# get_inports(blk::Integrator) = [blk.inport]
# get_outports(blk::Integrator) = [blk.outport]