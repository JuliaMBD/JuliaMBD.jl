module TestMathBlocks

using Test
import JuliaMBD:
    Plus,
    Line,
    InPort,
    OutPort,
    Add,
    Gain,
    Product,
    Divide,
    Mod,
    expr

@testset "add" begin
    b = Plus(left=InPort(), right=InPort(), outport=OutPort(Float64))
    println(b)
    Line(OutPort(), b.left)
    Line(OutPort(), b.right)
    Line(b.outport, InPort())
    println(expr(b))
end

@testset "prod" begin
    b = Product(left=InPort(), right=InPort(), outport=OutPort(Float64))
    println(b)
    Line(OutPort(), b.left)
    Line(OutPort(), b.right)
    Line(b.outport, InPort())
    println(expr(b))
end

@testset "divide" begin
    b = Divide(left=InPort(), right=InPort(), outport=OutPort(Float64))
    println(b)
    Line(OutPort(), b.left)
    Line(OutPort(), b.right)
    Line(b.outport, InPort())
    println(expr(b))
end

@testset "mod" begin
    b = Mod(left=InPort(), right=InPort(), outport=OutPort(Float64))
    println(b)
    Line(OutPort(), b.left)
    Line(OutPort(), b.right)
    Line(b.outport, InPort())
    println(expr(b))
end

@testset "add2" begin
    b = Add(inports=[InPort(), InPort(), InPort()], signs=[:+, :-, :+], outport=OutPort(Float64))
    println(b)
    for p = b.inports
        Line(OutPort(), p)
    end
    Line(b.outport, InPort())
    println(expr(b))
end

@testset "gain" begin
    b = Gain(K=10.0, inport=InPort(), outport=OutPort(Float64))
    println(b)
    Line(OutPort(), b.inport)
    Line(b.outport, InPort())
    println(expr(b))
end

end
