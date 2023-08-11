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
    next

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
    for x = prev(b2)
        println(x)
    end
    for x = next(b1)
        println(x)
    end
end

end
