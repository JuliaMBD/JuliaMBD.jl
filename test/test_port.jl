
@testset "inport" begin
    x = InPort()
    println(x)
    x = InPort(:leftin, Float64)
    println(x)
end

@testset "outport" begin
    x = OutPort()
    println(x)
    x = OutPort(:leftin, Float64)
    println(x)
end
