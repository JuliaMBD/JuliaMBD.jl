module TestBlock

using Test
import JuliaMBD:
    AbstractBlock,
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
    Add,
    prev,
    next,
    allblocks,
    alllines,
    tsort

@testset "block01" begin
    b1 = Plus()
    b2 = Mod()
    i = InPort()
    o = OutPort()
    Line(o, b1[:in1])
    Line(o, b1[:in2])
    Line(b1[:out], b2[:in1])
    Line(o, b2[:in2])
    Line(b2[:out], i)
    println(expr(b1))
    println(expr(b2))
end

@testset "block02" begin
    b1 = Plus()
    b2 = Mod()
    i = InPort()
    o = OutPort()
    Line(o, b1[:in1])
    Line(o, b1[:in2])
    Line(b1[:out], b2[:in1])
    Line(o, b2[:in2])
    Line(b2[:out], i)
    println("Prev blocks")
    for x = prev(b2)
        println(x)
    end
    println("Next blocks")
    for x = next(b1)
        println(x)
    end
end

@testset "block03" begin
    b1 = Plus()
    b2 = Mod()
    i = InPort()
    o = OutPort()
    Line(o, b1[:in1])
    Line(o, b1[:in2])
    l = Line(b1[:out], b2[:in1])
    Line(o, b2[:in2])
    Line(b2[:out], i)
    println("Prev lines")
    for x = prev(l)
        println(x)
    end
    println("Next lines")
    for x = next(l)
        println(x)
    end
end

@testset "block04" begin
    b1 = Plus()
    b2 = Mod()
    i = InPort()
    o = OutPort()
    Line(o, b1[:in1])
    Line(o, b1[:in2])
    Line(b1[:out], b2[:in1])
    Line(o, b2[:in2])
    Line(b2[:out], i)
    println("all blocks")
    for x = allblocks(b1)
        println(x)
    end
end

@testset "block05" begin
    b1 = Plus()
    b2 = Mod()
    i = InPort()
    o = OutPort()
    Line(o, b1[:in1])
    Line(o, b1[:in2])
    l = Line(b1[:out], b2[:in1])
    Line(o, b2[:in2])
    Line(b2[:out], i)
    println("all lines")
    for x = alllines(l)
        println(x)
    end
end

@testset "block06" begin
    b1 = Plus()
    b2 = Mod()
    i = InPort()
    o = OutPort()
    Line(o, b1[:in1])
    Line(o, b1[:in2])
    Line(b1[:out], b2[:in1])
    Line(o, b2[:in2])
    Line(b2[:out], i)
    println("all blocks")
    blks = [x for x = allblocks(b2)]
    println(tsort(blks))
end

@testset "block07" begin
    b1 = Plus()
    b2 = Mod()
    i = InPort()
    o = OutPort()
    Line(o, b1[:in1])
    Line(o, b1[:in2])
    l = Line(b1[:out], b2[:in1])
    Line(o, b2[:in2])
    Line(b2[:out], i)
    println("all lines")
    blks = [x for x = alllines(l)]
    println(tsort(blks))
end

end
