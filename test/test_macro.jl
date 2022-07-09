
import JuliaMBD

@testset "macro01" begin
    x = @macroexpand JuliaMBD.@model test begin
    end
    println(x)
end

@testset "macro02" begin
    x = @macroexpand JuliaMBD.@parameters x a, b
    println(x)
end