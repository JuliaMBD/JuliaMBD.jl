
import JuliaMBD

@testset "add" begin
    b = Add(left=InPort(), right=InPort(), outport=OutPort(Float64))
    println(b)
    Line(OutPort(), b.left)
    Line(OutPort(), b.right)
    Line(b.outport, InPort())
    println(expr(b))
end

@testset "gain" begin
    b = Gain(K=Value(10.0), inport=InPort(), outport=OutPort(Float64))
    println(b)
    Line(OutPort(), b.inport)
    Line(b.outport, InPort())
    println(expr(b))
end

@testset "constant" begin
    b = Constant(value=Value(10.0), outport=OutPort(Float64))
    println(b)
    Line(b.outport, InPort())
    println(expr(b))
end

@testset "pulsegenerator" begin
    b = PulseGenerator(timeport=InPort(), outport=OutPort(Float64))
    println(b)
    Line(b.outport, InPort())
    Line(OutPort(), b.timeport)
    println(expr(b))
end

