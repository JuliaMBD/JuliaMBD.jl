module TestSystemBlock

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
    Inport,
    Outport,
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
    SubSystem,
    set_block!,
    next

@testset "block01" begin
    b1 = Plus()
    b2 = Product()
    ib = Inport()
    ob = Outport()
    Line(ib[:out], b1[:in1])
    Line(ib[:out], b1[:in2])
    Line(b1[:out], b2[:in1])
    Line(ib[:out], b2[:in2])
    Line(b2[:out], ob[:in])

    b = SubSystem()
    set_block!(b, :a, b1)
    set_block!(b, :b, b2)
    set_block!(b, :c, ib)
    set_block!(b, :d, ob)

    i = InPort()
    o = OutPort()
    Line(o, b[:c])
    Line(b[:d], i, :tttt)
    println(expr(b))
end

@testset "block02" begin
    b1 = Plus()
    b2 = Product()
    ib = Inport()
    ob = Outport()
    Line(ib[:out], b1[:in1])
    Line(ib[:out], b1[:in2])
    Line(b1[:out], b2[:in1])
    Line(ib[:out], b2[:in2])
    Line(b2[:out], ob[:in])

    b = SubSystem()
    set_block!(b, :a, b1)
    set_block!(b, :b, b2)
    set_block!(b, :c, ib)
    set_block!(b, :d, ob)
    println(expr(b))
end

@testset "block03" begin
    b1 = Plus()
    b2 = Product()
    ib = Inport()
    ob = Outport()
    Line(ib[:out], b1[:in1])
    Line(ib[:out], b1[:in2])
    Line(b1[:out], b2[:in1])
    Line(ib[:out], b2[:in2])
    Line(b2[:out], ob[:in])

    b = SubSystem()
    set_block!(b, :a, b1)
    set_block!(b, :b, b2)
    set_block!(b, :c, ib)
    set_block!(b, :d, ob)
    println(expr(b))

    bb = SubSystem()
    set_block!(bb, :ss, b)
    ib = Inport()
    ob = Outport()
    set_block!(bb, :a, ib)
    set_block!(bb, :b, ob)
    Line(ib[:out], b[:c])
    # Line(b[:d], ob[:in])
    println(expr(bb))
end

end
