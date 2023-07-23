
@testset "scope1" begin
    int1 = Integrator(statein=InPort(:sin1), stateout=OutPort(:sout1), inport=InPort(), outport=OutPort())
    int2 = Integrator(statein=InPort(:sin2), stateout=OutPort(:sout2), inport=InPort(), outport=OutPort())
    in1 = InBlock(inport=InPort(:vin), outport=OutPort())
    gain1 = Gain(K=:R, inport=InPort(:g1in), outport=OutPort(:g1out))
    gain2 = Gain(K=:(1/C), inport=InPort(:g2in), outport=OutPort(:g2out))
    gain3 = Gain(K=:(1/L), inport=InPort(:g3in), outport=OutPort(:g3out))
    add = Add(inports=[InPort(:a), InPort(:b), InPort(:c)], signs=[:+, :-, :-], outport=OutPort())
    scope1 = Scope(inport=InPort(), outport=OutPort(:scope1))
    Line(in1.outport, add.inports[1])
    Line(gain1.outport, add.inports[2])
    Line(int1.outport, add.inports[3])
    Line(add.outport, gain3.inport)
    Line(gain3.outport, int2.inport)
    Line(int2.outport, gain1.inport)
    Line(int2.outport, gain2.inport)
    Line(gain2.outport, int1.inport)
    Line(gain3.outport, scope1.inport)

    b = BlockDefinition(:RLCBlock2)
    addParameter!(b, SymbolicValue{Float64}(:R), 100.0)
    addParameter!(b, SymbolicValue{Float64}(:C))
    addParameter!(b, SymbolicValue{Float64}(:L))
    addBlock!(b, int1)
    addBlock!(b, int2)
    addBlock!(b, in1)
    addBlock!(b, gain1)
    addBlock!(b, gain2)
    addBlock!(b, gain3)
    addBlock!(b, add)
    addBlock!(b, scope1)

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
    s2 = RLCBlock2(vin=InPort(), R=1.0, C=1.0, L=1.0)
    # Line(time.outport, s1.timeport)
    Line(s1.outport, s2.vin)

    bt = BlockDefinition(:TestBlock2)
    # addBlock!(bt, time)
    addBlock!(bt, s1)
    addBlock!(bt, s2)

    eval(expr_define_function(bt))
    eval(expr_define_structure(bt))
    eval(expr_define_next(bt))
    eval(expr_define_expr(bt))

    println(expr_define_function(bt))
    println(TestBlock2Function(; time=1.0, sin1=1.0, sin2=1.0))
end

@testset "scope2" begin
    int1 = Integrator(statein=InPort(:sin1), stateout=OutPort(:sout1), inport=InPort(), outport=OutPort())
    int2 = Integrator(statein=InPort(:sin2), stateout=OutPort(:sout2), inport=InPort(), outport=OutPort())
    in1 = InBlock(inport=InPort(:vin), outport=OutPort())
    gain1 = Gain(K=:R, inport=InPort(:g1in), outport=OutPort(:g1out))
    gain2 = Gain(K=:(1/C), inport=InPort(:g2in), outport=OutPort(:g2out))
    gain3 = Gain(K=:(1/L), inport=InPort(:g3in), outport=OutPort(:g3out))
    add = Add(inports=[InPort(:a), InPort(:b), InPort(:c)], signs=[:+, :-, :-], outport=OutPort())
    scope1 = Scope(inport=InPort(), outport=OutPort(:scope1))
    in1 => add.inports[1]
    gain1 => add.inports[2]
    gain2 => int1 => add.inports[3]
    add => gain3 => [int2, scope1]
    int2 => [gain1, gain2]

    b = BlockDefinition(:RLCBlock2)
    addParameter!(b, SymbolicValue{Float64}(:R), 100.0)
    addParameter!(b, SymbolicValue{Float64}(:C))
    addParameter!(b, SymbolicValue{Float64}(:L))
    addBlock!(b, int1)
    addBlock!(b, int2)
    addBlock!(b, in1)
    addBlock!(b, gain1)
    addBlock!(b, gain2)
    addBlock!(b, gain3)
    addBlock!(b, add)
    addBlock!(b, scope1)

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
    s2 = RLCBlock2(vin=InPort(), R=1.0, C=1.0, L=1.0)
    # Line(time.outport, s1.timeport)
    Line(s1.outport, s2.vin)

    bt = BlockDefinition(:TestBlock3)
    # addBlock!(bt, time)
    addBlock!(bt, s1)
    addBlock!(bt, s2)

    eval(expr_define_function(bt))
    eval(expr_define_structure(bt))
    eval(expr_define_next(bt))
    eval(expr_define_expr(bt))

    println(TestBlock3Function(; time=1.0, sin1=1.0, sin2=1.0))
end

@testset "scope3" begin
    int1 = Integrator(statein=InPort(:sin1), stateout=OutPort(:sout1), inport=InPort(), outport=OutPort())
    int2 = Integrator(statein=InPort(:sin2), stateout=OutPort(:sout2), inport=InPort(), outport=OutPort())
    in1 = InBlock(inport=InPort(:vin), outport=OutPort())
    gain1 = Gain(K=:R, inport=InPort(:g1in), outport=OutPort(:g1out))
    gain2 = Gain(K=:(1/C), inport=InPort(:g2in), outport=OutPort(:g2out))
    gain3 = Gain(K=:(1/L), inport=InPort(:g3in), outport=OutPort(:g3out))
    add = Add(inports=[InPort(:a), InPort(:b), InPort(:c)], signs=[:+, :-, :-], outport=OutPort())
    out1 = Scope(inport=InPort(), outport=OutPort(:out1))
    in1 => add.inports[1]
    gain1 => add.inports[2]
    gain2 => int1 => add.inports[3]
    add => gain3 => [int2, out1]
    int2 => [gain1, gain2]

    b = BlockDefinition(:RLCBlock4566)
    addParameter!(b, SymbolicValue{Float64}(:R), 100.0)
    addParameter!(b, SymbolicValue{Float64}(:C))
    addParameter!(b, SymbolicValue{Float64}(:L))
    addBlock!(b, int1)
    addBlock!(b, int2)
    addBlock!(b, in1)
    addBlock!(b, gain1)
    addBlock!(b, gain2)
    addBlock!(b, gain3)
    addBlock!(b, add)
    addBlock!(b, out1)

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
    s2 = RLCBlock4566(vin=InPort(), R=1.0, C=1.0, L=1.0)
    # Line(time.outport, s1.timeport)
    Line(s1.outport, s2.vin)

    sc = Scope(s2.out1, :scope_test)

    bt = BlockDefinition(:TestBlock543)
    # addBlock!(bt, time)
    addBlock!(bt, s1)
    addBlock!(bt, s2)
    addBlock!(bt, sc)

    eval(expr_define_function(bt))
    eval(expr_define_structure(bt))
    eval(expr_define_next(bt))
    eval(expr_define_expr(bt))

    println(expr_define_function(bt))
end
