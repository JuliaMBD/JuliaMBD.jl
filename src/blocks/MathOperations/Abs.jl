function Abs(;
    name::Symbol = gensym(),
    inport::AbstractInPort = InPort(),
    outport::AbstractOutPort = OutPort())
    UnaryOperator(:abs, name=name, inport=inport, outport=outport)
end

