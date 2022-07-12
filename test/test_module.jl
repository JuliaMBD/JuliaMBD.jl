import JuliaMBD

@testset "integrator5" begin
    int1 = Integrator(statein=InPort(:sin1), stateout=OutPort(:sout1), inport=InPort(), outport=OutPort())
    int2 = Integrator(statein=InPort(:sin2), stateout=OutPort(:sout2), inport=InPort(), outport=OutPort())
    in1 = In(inport=InPort(:vin), outport=OutPort())
    gain1 = Gain(K=SymbolicValue{Float64}(:R), inport=InPort(:g1in), outport=OutPort(:g1out))
    gain2 = Gain(K=SymbolicValue{Float64}(:C), inport=InPort(:g2in), outport=OutPort(:g2out)) # 1/C を入れたい
    gain3 = Gain(K=SymbolicValue{Float64}(:L), inport=InPort(:g3in), outport=OutPort(:g3out)) # 1/L を入れたい
    add = Add2(inports=[InPort(:a), InPort(:b), InPort(:c)], signs=[:+, :-, :-], outport=OutPort())
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

    @define(b)

    time = In(inport=InPort(:time), outport=OutPort())
    s1 = PulseGenerator(timeport=InPort(), outport=OutPort())
    s2 = RLCBlock(vin=InPort(), R=Value(1.0), C=Value(1.0), L=Value(1.0))
    Line(time.outport, s1.timeport)
    Line(s1.outport, s2.vin)

    bt = SystemBlockDefinition(:TestBlock)
    addBlock!(bt, time)
    addBlock!(bt, s1)
    addBlock!(bt, s2)

    @define(bt)

    println(TestBlockFunc(; time=1.0, sin1=1.0, sin2=1.0))
end