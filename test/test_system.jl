
import JuliaMBD

@testset "inport" begin
    b1 = Constant(value=Value{Float64}(10.0), outport=OutPort(Int64))
    b2 = Gain(K=SymbolicValue{Float64}(:K), inport=InPort(Float64), outport=OutPort())
    b3 = Gain(K=SymbolicValue{Float64}(:K), inport=InPort(), outport=OutPort())
    b4 = Add(left=InPort(), right=InPort(), outport=OutPort())
    b5 = In(inport=InPort(:in, Float64), outport=OutPort())
    b6 = Out(inport=InPort(), outport=OutPort(:out))
    b7 = Out(inport=InPort(), outport=OutPort(:out2))


    Line(b1.outport, b2.inport)
    Line(b5.outport, b4.left)
    Line(b2.outport, b4.right)
    Line(b4.outport, b3.inport)
    Line(b4.outport, b6.inport)
    Line(b3.outport, b7.inport)

    b = SystemBlockDefinition(:TestBlock)
    addParameter!(b, SymbolicValue{Float64}(:K))
    addBlock!(b, b1)
    addBlock!(b, b2)
    addBlock!(b, b3)
    addBlock!(b, b4)
    addBlock!(b, b5)
    addBlock!(b, b6)
    addBlock!(b, b7)

    @define(b)

    bx = TestBlock(K=SymbolicValue{Float64}(:a), in=InPort(:x), out=OutPort(:y1), out2=OutPort(:y2))
    bx5 = In(inport=InPort(:in, Float64), outport=OutPort())
    bx6 = Out(inport=InPort(), outport=OutPort(:out1))
    bx7 = Out(inport=InPort(), outport=OutPort(:out2))

    Line(bx5.outport, bx.in)
    Line(bx.out, bx6.inport)
    Line(bx.out2, bx7.inport)
    
    println(expr(bx))
end
