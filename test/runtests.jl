using JuliaMBD
using Test

@testset "JuliaMBDTest01" begin
    b = GainBlock(:Gain, :K)
    println(generate_instance(b))
end

@testset "JuliaMBDTest02" begin
    b = GainBlock(:Gain, :K)
    l = ContinuousSignal(:x)
    connect(l, b.inport)
    println(generate_instance(b))
end

@testset "JuliaMBDTest03" begin
    b0 = SystemBlock(:System)
    b1 = InBlock(:In)
    b2 = GainBlock(:Gain, :K)
    b3 = OutBlock(:Out1)
    l1 = ContinuousSignal(:x1)
    l2 = ContinuousSignal(:x2)
    connect(l1, b1.outport, b2.inport)
    connect(l2, b2.outport, b3.inport)
    add_block(b0, b1)
    add_block(b0, b2)
    add_block(b0, b3)
    expr = generate_definition(b0)
    println(expr)
    eval(expr)
end

# @testset "JuliaMBDTest02" begin
#     blk1 = SystemBlock(:main)
#     l1 = Line(:x, Int)
#     l2 = Line(:y, Int)
#     push!(blk1.in, InPort(blk1, :in))
#     push!(blk1.out, OutPort(blk1, :out))
#     connect(nothing, blk1.in[1], l1)
#     connect(blk1.out[1], nothing, l2)
#     println(_toexpr(blk1))
# end
