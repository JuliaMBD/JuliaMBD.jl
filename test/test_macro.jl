
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

@testset "macro05" begin
    y = @macroexpand @parameter b x = 9.8
    println(y)
end

@testset "macro06" begin
    y = @macroexpand @parameter b begin
            x = 9.8
            z
    end
    println(y)
end

@testset "macro07" begin
    y = @macroexpand @parameter b begin
            x::Float64 = 9.8
            z::Int
    end
    println(y)
end

@testset "macro08" begin
    y = @macroexpand @model MSD begin
        @parameter begin
            M::Float64
            g = 9.8
        end
        @block begin
            a = InBlock(inport=InPort(:x), outport=OutPort())
        end
        @connection begin
            a.outport => b.inport
        end
    end
    println(y)
end