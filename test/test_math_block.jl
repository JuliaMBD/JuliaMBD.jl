module TestMathBlock

using Test
import JuliaMBD:
    AbstractBlock,
    AbstractBasicBlock,
    AbstractInPort,
    AbstractOutPort,
    AbstractSymbolicValue,
    get_inports,
    get_outports,
    set_inport!,
    set_outport!,
    expr,
    expr_body,
    InPort,
    OutPort,
    Line,
    Gain,
    Abs,
    Plus,
    Mod,
    Product,
    Divide,
    Add

mutable struct TestGain <: AbstractBasicBlock
    name::Symbol
    parameters::Vector{AbstractSymbolicValue}
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}
    env::Dict{Symbol,Any}
    
    function TestGain(; in::AbstractInPort = InPort(:in), out::AbstractOutPort = OutPort(:out))
        b = new(:TestGain, AbstractSymbolicValue[], AbstractInPort[], AbstractOutPort[], Dict{Symbol,Any}())
        set_inport!(b, in)
        set_outport!(b, out)
        b
    end
end

function expr_body(blk::TestGain)
    :(out = in)
end

@testset "block01" begin
    b = TestGain()
    i = InPort()
    o = OutPort()
    Line(o, get_inports(b)[1])
    Line(get_outports(b)[1], i)
    println(expr(b))
end

@testset "block02" begin
    b = TestGain()
    i = InPort()
    o = OutPort()
    Line(o, b[:in])
    Line(b[:out], i)
    println(expr(b))
end

@testset "block03" begin
    b = Gain(K=1)
    i = InPort()
    o = OutPort()
    Line(o, b[:in])
    Line(b[:out], i)
    println(expr(b))
end

@testset "block04" begin
    b = Abs()
    i = InPort()
    o = OutPort()
    Line(o, b[:in])
    Line(b[:out], i)
    println(expr(b))
end

@testset "block05" begin
    b = Plus()
    i = InPort()
    o = OutPort()
    Line(o, b[:in1])
    Line(o, b[:in2])
    Line(b[:out], i)
    println(expr(b))
end

@testset "block06" begin
    b = Mod()
    i = InPort()
    o = OutPort()
    Line(o, b[:in1])
    Line(o, b[:in2])
    Line(b[:out], i)
    println(expr(b))
end

@testset "block07" begin
    b = Product()
    i = InPort()
    o = OutPort()
    Line(o, b[:in1])
    Line(o, b[:in2])
    Line(b[:out], i)
    println(expr(b))
end

@testset "block08" begin
    b = Divide()
    i = InPort()
    o = OutPort()
    Line(o, b[:in1])
    Line(o, b[:in2])
    Line(b[:out], i)
    println(expr(b))
end

@testset "block09" begin
    b = Add(signs=[:-, :+, :-])
    i = InPort()
    o = OutPort()
    Line(o, b[:in1])
    Line(o, b[:in2])
    Line(o, b[:in3])
    Line(b[:out], i)
    println(expr(b))
end

end
