function Mod(;
    name::Symbol = gensym(),
    left::AbstractInPort = InPort(),
    right::AbstractInPort = InPort(),
    outport::AbstractOutPort = OutPort())
    BinaryOperator(:mod, name = name, left = left, right = right, outport = outport)
end
