function Divide(;
    name::Symbol = gensym(),
    left::AbstractInPort = InPort(),
    right::AbstractInPort = InPort(),
    outport::AbstractOutPort = OutPort())
    BinaryOperator(:/, name = name, left = left, right = right, outport = outport)
end
    
