export Integrator

mutable struct IntegratorInner <: AbstractBlock
    initialcondition::Parameter
    saturationlimits::NTuple{2,Union{Parameter,Nothing}}
    inport::AbstractInPort
    outport::AbstractOutPort

    function IntegratorInner(;
        initialcondition::Parameter,
        saturationlimits::NTuple{2,Union{Parameter,Nothing}},
        inport::AbstractInPort = InPort(),
        outport::AbstractOutPort = OutPort())
        blk = new()
        blk.initialcondition = initialcondition
        blk.saturationlimits = saturationlimits
        blk.inport = inport
        blk.outport = outport
        blk.inport.parent = blk
        blk.outport.parent = blk
        blk
    end
end

mutable struct Integrator <: AbstractIntegratorBlock
    innerblk::IntegratorInner
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
        blk.innerblk = IntegratorInner(
            initialcondition = initialcondition,
            saturationlimits = saturationlimits,
            inport = inport,
            outport = OutPort())
        blk.inblk = StateOut(
            inport=InPort(),
            outport=stateout)
        blk.outblk = StateIn(
            inport=statein,
            outport=outport)
        Line(blk.innerblk.outport, blk.inblk.inport)
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

function expr(blk::IntegratorInner)
    i = expr_set_inports(blk.inport)
    b = expr_setvalue(blk.outport.var, expr_refvalue(blk.inport.var))
    o = expr_set_outports(blk.outport)
    Expr(:block, i, b, o)
end

function expr_initial(blk::IntegratorInner)
    i = expr_set_inports(blk.inport)
    b = expr_setvalue(blk.outport.var, expr_refvalue(blk.initialcondition))
    o = expr_set_outports(blk.outport)
    Expr(:block, i, b, o)
end

get_default_inport(blk::Integrator) = blk.inport
get_default_outport(blk::Integrator) = blk.outport
get_inports(blk::IntegratorInner) = [blk.inport]
get_outports(blk::IntegratorInner) = [blk.outport]
