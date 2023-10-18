export Integrator

"""
initialcondition::Parameter,
saturationlimits::NTuple{2,Union{Parameter,Nothing}},
inport::AbstractInPort = InPort(),
outport::AbstractOutPort = OutPort())
"""
function IntegratorInner(;
        initialcondition = ParameterPort(:initialcondition),
        saturationlimits = ParameterPort(:saturationlimits, NTuple{2,Auto}),
        in = InPort(),
        out = OutPort())
    b = SimpleBlock(:IntegratorInner)
    set!(b, :sin, in)
    set!(b, :sout, out)
    set!(b, :initialcondition, initialcondition)
    set!(b, :saturationlimits, saturationlimits)
    b
end

function expr(b::SimpleBlock, ::Val{:IntegratorInner})
    Expr(:(=), b.outports[1].name, b.inports[1].name)
end

function Integrator(;
        initialcondition = ParameterPort(:initialcondition),
        saturationlimits = ParameterPort(:saturationlimits, NTuple{2,Auto}),
        in = :in, out = :out)
    b = SubSystemBlock(:Integrator)
    in1 = Inport(in)
    out1 = Outport(out)
    inner = IntegratorInner(initialcondition = initialcondition, saturationlimits = saturationlimits)
    LineSignal(in1.outports[1], inner.inports[1], "sout")
    add!(b, in1)
    add!(b, inner)
    add!(b, out1)
    push!(b.stateoutports, inner.outports[1])
    push!(b.stateinports, out1.outports[1])
    b
end
