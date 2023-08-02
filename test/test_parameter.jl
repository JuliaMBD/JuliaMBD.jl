
module TestParameter

using Test
import JuliaMBD: SymbolicValue, Auto

@testset "symbolic" begin
    x = SymbolicValue(:a)
    @test typeof(x) == SymbolicValue{Auto}
end

end
