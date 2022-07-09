
import JuliaMBD

@testset "value" begin
    x = Value(1.0)
    @test typeof(x) == Value{Float64}
    x = Value(1)
    @test typeof(x) == Value{Int64}
    x = Value{Float64}(1)
    @test typeof(x) == Value{Float64}
end

@testset "symbolic" begin
    x = SymbolicValue(:a)
    @test typeof(x) == SymbolicValue{Auto}
end
