export Derivative

"""
initialcondition::Parameter,
inport::AbstractInPort = InPort(),
outport::AbstractOutPort = OutPort())

line => in => block => dout
[din, out] => line
"""
function Derivative(;
    initialcondition = Float64(0),
    in = InPort(),
    din = OutPort(),
    dout = OutPort())
    b = SimpleBlock(:Derivative)
    setport!(b, :in, in)
    setport!(b, :dout, dout)
    b.env[:din] = din
    b.env[:out] = din
    setparameter!(b, :initialcondition, initialcondition)
    b
end

function expr(b::SimpleBlock, ::Val{:Derivative})
    Expr(:(=), b.outports[1].name, b.inports[1].name)
end

function expr_initial(b::SimpleBlock, ::Val{:Derivative})
    Expr(:(=), b.outports[1].name, b.env[:initialcondition].name)
end

function _add!(b::AbstractCompositeBlock, x::SimpleBlock, ::Val{:Derivative})
    push!(b.dstateinports, x.env[:din])
    push!(b.dstateoutports, x.env[:dout])
end
