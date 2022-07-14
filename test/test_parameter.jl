
import JuliaMBD

@testset "symbolic" begin
    x = SymbolicValue(:a)
    @test typeof(x) == SymbolicValue{Auto}
end
