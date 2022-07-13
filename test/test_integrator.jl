
import JuliaMBD: expr, next

@testset "integrator" begin
    b = Integrator(statein=InPort(:sin), stateout=OutPort(:sout), inport=InPort(), outport=OutPort(Float64))
    println(b)
end

@testset "integrator2" begin
    b0 = Constant(value=Float64(1), outport=OutPort(Float64))
    b1 = Integrator(statein=InPort(:sin), stateout=OutPort(:sout), inport=InPort(), outport=OutPort())
    b3 = OutBlock(inport=InPort(), outport=OutPort())
    Line(b0.outport, b1.inport)
    Line(b1.outport, b3.inport)
    println(b1)
    [println(expr(b)) for b = JuliaMBD.tsort([b1.inblk,b1.outblk,b3,b0])]
end

@testset "integrator3" begin
    b0 = Constant(value=Float64(1), outport=OutPort(Float64))
    b1 = Integrator(statein=InPort(:sin), stateout=OutPort(:sout), inport=InPort(), outport=OutPort())
    b3 = OutBlock(inport=InPort(), outport=OutPort())
    Line(b0.outport, b1.inport)
    Line(b1.outport, b3.inport)

    b = SystemBlockDefinition(:TestBlock)
    addBlock!(b, b0)
    addBlock!(b, b1)
    addBlock!(b, b3)

    # println(expr_define_systemfunction(b))
end

@testset "integrator4" begin
    int1 = Integrator(statein=InPort(:sin1), stateout=OutPort(:sout1), inport=InPort(), outport=OutPort())
    int2 = Integrator(statein=InPort(:sin2), stateout=OutPort(:sout2), inport=InPort(), outport=OutPort())
    in1 = InBlock(inport=InPort(:vin), outport=OutPort())
    gain1 = Gain(K=:R, inport=InPort(:g1in), outport=OutPort(:g1out))
    gain2 = Gain(K=:(1/C), inport=InPort(:g2in), outport=OutPort(:g2out))
    gain3 = Gain(K=:(1/L), inport=InPort(:g3in), outport=OutPort(:g3out))
    add = Add(inports=[InPort(:a), InPort(:b), InPort(:c)], signs=[:+, :-, :-], outport=OutPort())
    Line(in1.outport, add.inports[1])
    Line(gain1.outport, add.inports[2])
    Line(int1.outport, add.inports[3])
    Line(add.outport, gain3.inport)
    Line(gain3.outport, int2.inport)
    Line(int2.outport, gain1.inport)
    Line(int2.outport, gain2.inport)
    Line(gain2.outport, int1.inport)

    b = SystemBlockDefinition(:RLCBlock)
    addParameter!(b, SymbolicValue{Float64}(:R))
    addParameter!(b, SymbolicValue{Float64}(:C))
    addParameter!(b, SymbolicValue{Float64}(:L))
    addBlock!(b, int1)
    addBlock!(b, int2)
    addBlock!(b, in1)
    addBlock!(b, gain1)
    addBlock!(b, gain2)
    addBlock!(b, gain3)
    addBlock!(b, add)

    println(expr_define_function(b))
    println(expr_define_structure(b))
    println(expr_define_next(b))
    println(expr_define_expr(b))

    eval(expr_define_function(b))
    eval(expr_define_structure(b))
    eval(expr_define_next(b))
    eval(expr_define_expr(b))

    # time = InBlock(inport=InPort(:time), outport=OutPort())
    s1 = PulseGenerator(timeport=InPort(), outport=OutPort())
    s2 = RLCBlock(vin=InPort(), R=1.0, C=1.0, L=1.0)
    # Line(time.outport, s1.timeport)
    Line(s1.outport, s2.vin)

    bt = SystemBlockDefinition(:TestBlock)
    # addBlock!(bt, time)
    addBlock!(bt, s1)
    addBlock!(bt, s2)

    println(expr_define_function(bt))
    println(expr_define_structure(bt))
    println(expr_define_next(bt))
    println(expr_define_expr(bt))

    eval(expr_define_function(bt))
    eval(expr_define_structure(bt))
    eval(expr_define_next(bt))
    eval(expr_define_expr(bt))

    println(TestBlockFunc(; time=1.0, sin1=1.0, sin2=1.0))
end

@testset "integrator5" begin
    int1 = Integrator(statein=InPort(:sin1), stateout=OutPort(:sout1), inport=InPort(), outport=OutPort())
    int2 = Integrator(statein=InPort(:sin2), stateout=OutPort(:sout2), inport=InPort(), outport=OutPort())
    in1 = InBlock(inport=InPort(:vin), outport=OutPort())
    gain1 = Gain(K=:R, inport=InPort(:g1in), outport=OutPort(:g1out))
    gain2 = Gain(K=:(1/C), inport=InPort(:g2in), outport=OutPort(:g2out))
    gain3 = Gain(K=:(1/L), inport=InPort(:g3in), outport=OutPort(:g3out))
    add = Add(inports=[InPort(:a), InPort(:b), InPort(:c)], signs=[:+, :-, :-], outport=OutPort())
    Line(in1.outport, add.inports[1])
    Line(gain1.outport, add.inports[2])
    Line(int1.outport, add.inports[3])
    Line(add.outport, gain3.inport)
    Line(gain3.outport, int2.inport)
    Line(int2.outport, gain1.inport)
    Line(int2.outport, gain2.inport)
    Line(gain2.outport, int1.inport)

    b = SystemBlockDefinition(:RLCBlock)
    addParameter!(b, SymbolicValue{Float64}(:R))
    addParameter!(b, SymbolicValue{Float64}(:C))
    addParameter!(b, SymbolicValue{Float64}(:L))
    addBlock!(b, int1)
    addBlock!(b, int2)
    addBlock!(b, in1)
    addBlock!(b, gain1)
    addBlock!(b, gain2)
    addBlock!(b, gain3)
    addBlock!(b, add)

    eval(expr_define_function(b))
    eval(expr_define_structure(b))
    eval(expr_define_next(b))
    eval(expr_define_expr(b))

    # time = InBlock(inport=InPort(:time), outport=OutPort())
    s1 = PulseGenerator(timeport=InPort(), outport=OutPort())
    s2 = RLCBlock(vin=InPort(), R=1.0, C=1.0, L=1.0)
    # Line(time.outport, s1.timeport)
    Line(s1.outport, s2.vin)

    bt = SystemBlockDefinition(:TestBlock)
    # addBlock!(bt, time)
    addBlock!(bt, s1)
    addBlock!(bt, s2)

    println(expr_define_function(bt))
    println(expr_define_structure(bt))
    println(expr_define_next(bt))
    println(expr_define_expr(bt))

    eval(expr_define_function(bt))
    eval(expr_define_structure(bt))
    eval(expr_define_next(bt))
    eval(expr_define_expr(bt))

    println(TestBlockFunc(; time=1.0, sin1=1.0, sin2=1.0))
end
