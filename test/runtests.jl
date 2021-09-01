using JuliaMBD
using Test

@testset "JuliaMBD.jl" begin
    blk1 = ConstantBlock(5)
    blk2 = GainBlock(Var(:K, Float64))
    l1 = Line(:x, Int)
    connect(blk1.outport, blk2.inport, l1)
    println(_toexpr(blk1.outport))
    println(_toexpr(blk2.outport))
end
