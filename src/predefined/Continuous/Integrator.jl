export Integrator

"""
initialcondition::Parameter,
saturationlimits::NTuple{2,Union{Parameter,Nothing}},
inport::AbstractInPort = InPort(),
outport::AbstractOutPort = OutPort())

line => in => block => sout
[sin, out] => line
"""
function Integrator(;
    initialcondition = Float64(0),
    saturationlimits = (nothing,nothing),
    in = InPort(),
    sin = OutPort(),
    sout = OutPort())
    b = SimpleBlock(:Integrator)
    setport!(b, :in, in)
    setport!(b, :sout, sout)
    b.env[:sin] = sin
    b.env[:out] = sin
    setparameter!(b, :initialcondition, initialcondition)
    setparameter!(b, :saturationlimits, saturationlimits)
    b
end

function expr(b::SimpleBlock, ::Val{:Integrator})
    Expr(:(=), b.outports[1].name, b.inports[1].name)
end

function expr_initial(b::SimpleBlock, ::Val{:Integrator})
    Expr(:(=), b.outports[1].name, b.env[:initialcondition].name)
end

function _add!(b::AbstractCompositeBlock, x::SimpleBlock, ::Val{:Integrator})
    push!(b.stateinports, x.env[:sin])
    push!(b.stateoutports, x.env[:sout])
end

# function Integrator(;
#         initialcondition = ParameterPort(:initialcondition),
#         saturationlimits = ParameterPort(:saturationlimits, NTuple{2,Auto}),
#         in = :in, out = :out)
#     b = SubSystemBlock(:Integrator)
#     in1 = Inport(in)
#     out1 = Outport(out)
#     inner = IntegratorInner(initialcondition = initialcondition, saturationlimits = saturationlimits)
#     LineSignal(in1.outports[1], inner.inports[1], "sout")
#     add!(b, in1)
#     add!(b, inner)
#     add!(b, out1)
#     push!(b.stateoutports, inner.outports[1])
#     push!(b.stateinports, out1.outports[1])
#     b
# end
