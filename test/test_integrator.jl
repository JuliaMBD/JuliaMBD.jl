
import JuliaMBD

@testset "integrator" begin
    b = Integrator(statein=InPort(:sin), stateout=OutPort(:sout), inport=InPort(), outport=OutPort(Float64))
    println(b)
end

@testset "integrator2" begin
    b0 = Constant(value=Value(1), outport=OutPort(Float64))
    b1 = Integrator(statein=InPort(:sin), stateout=OutPort(:sout), inport=InPort(), outport=OutPort())
    b3 = Out(inport=InPort(), outport=OutPort())
    Line(b0.outport, b1.inport)
    Line(b1.outport, b3.inport)
    println(b1)
    [println(expr(b)) for b = JuliaMBD.tsort([b1.inblk,b1.outblk,b3,b0])]
end

@testset "integrator3" begin
    b0 = Constant(value=Value(1), outport=OutPort(Float64))
    b1 = Integrator(statein=InPort(:sin), stateout=OutPort(:sout), inport=InPort(), outport=OutPort())
    b3 = Out(inport=InPort(), outport=OutPort())
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
    in1 = In(inport=InPort(:vin), outport=OutPort())
    # out1 = Out(inport=InPort(), outport=OutPort(:vout))
    gain1 = Gain(K=SymbolicValue{Float64}(:R), inport=InPort(:g1in), outport=OutPort(:g1out))
    gain2 = Gain(K=SymbolicValue{Float64}(:C), inport=InPort(:g2in), outport=OutPort(:g2out)) # 1/C を入れたい
    gain3 = Gain(K=SymbolicValue{Float64}(:L), inport=InPort(:g3in), outport=OutPort(:g3out)) # 1/L を入れたい
    add = Add2(inports=[InPort(:a), InPort(:b), InPort(:c)], signs=[:+, :-, :-], outport=OutPort())
    Line(in1.outport, add.inports[1])
    Line(gain1.outport, add.inports[2])
    Line(int1.outport, add.inports[3])
    Line(add.outport, gain3.inport)
    Line(gain3.outport, int2.inport)
    # Line(int2.outport, out1.inport)
    Line(int2.outport, gain1.inport)
    Line(int2.outport, gain2.inport)
    Line(gain2.outport, int1.inport)

    b = SystemBlockDefinition(:RLCBlock)
    addParameter!(b, SymbolicValue{Float64}(:R))
    addParameter!(b, SymbolicValue{Float64}(:C))
    addParameter!(b, SymbolicValue{Float64}(:L))
    # addBlock!(b, time)
    addBlock!(b, int1)
    addBlock!(b, int2)
    addBlock!(b, in1)
    # addBlock!(b, out1)
    addBlock!(b, gain1)
    addBlock!(b, gain2)
    addBlock!(b, gain3)
    addBlock!(b, add)

    import JuliaMBD: expr, next

    println(expr_define_function(b))
    eval(expr_define_function(b))
    println(expr_define_structure(b))
    eval(expr_define_structure(b))
    eval(expr_define_next(b))
    println(expr_define_expr(b))
    eval(expr_define_expr(b))

    time = In(inport=InPort(:time), outport=OutPort())
    s1 = PulseGenerator(timeport=InPort(), outport=OutPort())
    # s2 = RLCBlock(vin=InPort(), sin1=InPort(), sin2=InPort(), sout1=OutPort(), sout2=OutPort(), R=Value(1.0), C=Value(1.0), L=Value(1.0))
    s2 = RLCBlock(vin=InPort(), sin1=InPort(), sin2=InPort(), sout1=OutPort(), sout2=OutPort(), R=Value(1.0), C=Value(1.0), L=Value(1.0))
    sin1 = In(inport=InPort(:sin1), outport=OutPort())
    sin2 = In(inport=InPort(:sin2), outport=OutPort())
    sout1 = Out(inport=InPort(), outport=OutPort(:sout1))
    sout2 = Out(inport=InPort(), outport=OutPort(:sout2))
    Line(time.outport, s1.timeport)
    Line(s1.outport, s2.vin)
    Line(sin1.outport, s2.sin1)
    Line(sin2.outport, s2.sin2)
    Line(s2.sout1, sout1.inport)
    Line(s2.sout2, sout2.inport)

    bt = SystemBlockDefinition(:TestBlock)
    addBlock!(bt, time)
    addBlock!(bt, s1)
    addBlock!(bt, s2)
    addBlock!(bt, sin1)
    addBlock!(bt, sin2)
    addBlock!(bt, sout1)
    addBlock!(bt, sout2)

    println(expr_define_function(bt))
    eval(expr_define_function(bt))
    println(expr_define_structure(bt))
    eval(expr_define_structure(bt))
    eval(expr_define_next(bt))
    eval(expr_define_expr(bt))

    # println(TestBlockFunc(; time=1.0, sin1=1.0, sin2=1.0, R=1.0, C=1.0, L=1.0))
end
