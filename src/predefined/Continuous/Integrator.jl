export Integrator

struct IntegratorInnerBlockType <: AbstractBlockType end

"""
initialcondition::Parameter,
saturationlimits::NTuple{2,Union{Parameter,Nothing}},
inport::AbstractInPort = InPort(),
outport::AbstractOutPort = OutPort())
"""
function IntegratorInner(name = :IntegratorInner;
    initialcondition = ParameterPort(:initialcondition),
    saturationlimits = ParameterPort(:saturationlimits, NTuple{2,Auto}),
    in = InPort(:sin),
    out = OutPort(:sout))
    b = SimpleBlock(name, IntegratorInnerBlockType)
    set!(b, in.name, in)
    set!(b, out.name, out)
    set!(b, initialcondition.name, initialcondition)
    set!(b, saturationlimits.name, saturationlimits)
    b
end

function expr(b::SimpleBlock, ::Type{IntegratorInnerBlockType})
    Expr(:(=), b.outports[1].name, b.inports[1].name)
end

function Integrator(name = :Integrator;
    initialcondition = ParameterPort(:initialcondition),
    saturationlimits = ParameterPort(:saturationlimits, NTuple{2,Auto}),
    in = InPort(:in),
    out = OutPort(:out))
    b = SubSystemBlock(name)
    in1 = Inport(in.name)
    set!(b, in1.name, in1)
    inner = IntegratorInner(initialcondition = initialcondition, saturationlimits = saturationlimits)
    set!(b, inner.name, inner)
    out1 = Outport(out.name)
    set!(b, out1.name, out1)
    LineSignal(in1.outports[1], inner.inports[1], "sout")
    b
end
