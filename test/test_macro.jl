
import JuliaMBD

@testset "macro01" begin
    y = (@macroexpand @block b x = InBlock(inport=InPort(:x), outport=OutPort()))
    println(y)
end

@testset "macro02" begin
    y = (@macroexpand @block b begin
            x = InBlock(inport=InPort(:x), outport=OutPort())
            z = OutBlock(inport=InPort(), outport=OutPort(:y))
    end)
    println(y)
end

@testset "macro03" begin
    y = @macroexpand @connection b.a => b.b
    println(y)
end

@testset "macro04" begin
    y = @macroexpand @connection begin
        b.a => b.b
        b.y => t.t
    end
    println(y)
end