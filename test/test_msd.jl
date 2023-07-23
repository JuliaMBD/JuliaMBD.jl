@testset "integrator2" begin
    b = BlockDefinition(:MSD)
    addParameter!(b, SymbolicValue{Float64}(:M))
    addParameter!(b, SymbolicValue{Float64}(:D))
    addParameter!(b, SymbolicValue{Float64}(:k))
    addParameter!(b, SymbolicValue{Float64}(:g), 9.8)

    in1 = InBlock(inport=InPort(:in1), outport=OutPort())
    addBlock!(b, in1)
    out1 = OutBlock(inport=InPort(), outport=OutPort(:out1))
    addBlock!(b, out1)
    constant1 = Constant(value=:(M*g), outport=OutPort())
    addBlock!(b, constant1)
    gain1 = Gain(K=:D, inport=InPort(), outport=OutPort())
    addBlock!(b, gain1)
    gain2 = Gain(K=:k, inport=InPort(), outport=OutPort())
    addBlock!(b, gain2)
    gain3 = Gain(K=:(1/M), inport=InPort(), outport=OutPort())
    addBlock!(b, gain3)
    int1 = Integrator(statein=InPort(:sin1), stateout=OutPort(:sout1), inport=InPort(), outport=OutPort())
    addBlock!(b, int1)
    int2 = Integrator(statein=InPort(:sin2), stateout=OutPort(:sout2), inport=InPort(), outport=OutPort())
    addBlock!(b, int2)
    add = Add(inports=[InPort(), InPort(), InPort(), InPort()], signs=[:+, :+, :-, :-], outport=OutPort())
    addBlock!(b, add)

    Line(in1.outport, add.inports[1])
    Line(constant1.outport, add.inports[2])
    Line(gain1.outport, add.inports[3])
    Line(gain2.outport, add.inports[4])
    Line(add.outport, gain3.inport)
    Line(gain3.outport, int1.inport)
    Line(int1.outport, int2.inport)
    Line(int1.outport, gain1.inport)
    Line(int2.outport, gain2.inport)
    Line(int2.outport, out1.inport)

    eval(expr_define_function(b))
    eval(expr_define_initialfunction(b))
    eval(expr_define_structure(b))
    eval(expr_define_next(b))
    eval(expr_define_expr(b))

    b = BlockDefinition(:TestBlockMSD)
    addParameter!(b, SymbolicValue{Float64}(:M))
    addParameter!(b, SymbolicValue{Float64}(:D))
    addParameter!(b, SymbolicValue{Float64}(:k))
    addParameter!(b, SymbolicValue{Float64}(:f))
    addParameter!(b, SymbolicValue{Float64}(:p_cycle))
    addParameter!(b, SymbolicValue{Float64}(:p_width))

    msd = MSD(M=:M, D=:D, k=:k, in1=InPort(), out1=OutPort())
    addBlock!(b, msd)
    pulse = PulseGenerator(amplitude=:f, period=:p_cycle, pulsewidth=:p_width, phasedelay=10.0,
        timeport=InPort(), outport=OutPort())
    addBlock!(b, pulse)
    # time = InBlock(inport=InPort(:time), outport=OutPort())
    # addBlock!(b, time)
    scope1 = Scope(inport=InPort(), outport=OutPort(:F))
    addBlock!(b, scope1)
    scope2 = Scope(inport=InPort(), outport=OutPort(:x))
    addBlock!(b, scope2)

    # Line(time.outport, pulse.timeport)
    Line(pulse.outport, msd.in1)
    Line(pulse.outport, scope1.inport)
    Line(msd.out1, scope2.inport)

    eval(expr_define_function(b))
    eval(expr_define_initialfunction(b))
    eval(expr_define_structure(b))
    eval(expr_define_next(b))
    eval(expr_define_expr(b))
    # eval(expr_define_sfunction(b))

    println(expr_define_function(b))
    m = TestBlockMSD(M=10.0, D=10.0, k=10.0, f=1.0, p_cycle=20.0, p_width=10.0)
    params = m.pfunc(m) #Dict(:M => 10.0, :D => 10.0, :k => 18.0, :f => 1.0, :p_cycle => 20.0, :p_width => 50.0)
    println(m.ifunc((;params...)))
    println(m.sfunc([0.0, 0.0], [0.0, 9.8], (;params...), 10.0))
    println(simulate(m, (0.0, 10.0)))
end

@testset "integrator3" begin
    @model MSD begin
        @parameter begin
            M::Float64
            D::Float64
            k::Float64
            g = 9.8
        end
        @block begin
            in1 = InBlock(inport=InPort(:in1), outport=OutPort())
            out1 = OutBlock(inport=InPort(), outport=OutPort(:out1))
            constant1 = Constant(value=:(M*g), outport=OutPort())
            gain1 = Gain(K=:D, inport=InPort(), outport=OutPort())
            gain2 = Gain(K=:k, inport=InPort(), outport=OutPort())
            gain3 = Gain(K=:(1/M), inport=InPort(), outport=OutPort())
            int1 = Integrator(statein=InPort(:sin1), stateout=OutPort(:sout1), inport=InPort(), outport=OutPort())
            int2 = Integrator(statein=InPort(:sin2), stateout=OutPort(:sout2), inport=InPort(), outport=OutPort())
            add = Add(inports=[InPort(), InPort(), InPort(), InPort()], signs=[:+, :+, :-, :-], outport=OutPort())
        end
        begin
            in1.outport => add.inports[1]
            constant1.outport => add.inports[2]
            gain1.outport => add.inports[3]
            gain2.outport => add.inports[4]
            add.outport => gain3.inport
            gain3.outport => int1.inport
            int1.outport => int2.inport
            int1.outport => gain1.inport
            int2.outport => gain2.inport
            int2.outport => out1.inport
        end
    end

    b = @model TestBlock234 begin
        @parameter begin
            M::Float64
            D::Float64
            k::Float64
            f::Float64
            p_cycle::Float64
            p_width::Float64
        end
        @block begin
            msd = MSD(M=:M, D=:D, k=:k, in1=InPort(), out1=OutPort())
            pulse = PulseGenerator(amplitude=:f, period=:p_cycle, pulsewidth=:p_width, phasedelay=10.0,
                timeport=InPort(), outport=OutPort())
            # time = InBlock(inport=InPort(:time), outport=OutPort())
            scope1 = Scope(inport=InPort(), outport=OutPort(:F))
            scope2 = Scope(inport=InPort(), outport=OutPort(:x))
        end
        begin
            # time.outport => pulse.timeport
            pulse.outport => msd.in1
            pulse.outport => scope1.inport
            msd.out1 => scope2.inport
        end
    end

    println(expr_define_function(b))
end

@testset "integrator3" begin
    @model MSD22 begin
        @parameter begin
            M::Float64
            D::Float64
            k::Float64
            g = 9.8
        end
        @block begin
            in1 = InBlock(:in1)
            out1 = OutBlock(:out1)
            constant1 = Constant(value=:(M*g))
            gain1 = Gain(K=:D)
            gain2 = Gain(K=:k)
            gain3 = Gain(K=:(1/M))
            int1 = Integrator(:s1)
            int2 = Integrator(:s2)
            add = Add(inports=[InPort(), InPort(), InPort(), InPort()], signs=[:+, :+, :-, :-])
        end
        begin
            in1 => add.inports[1]
            constant1 => add.inports[2]
            gain1 => add.inports[3]
            gain2 => add.inports[4]
            add => gain3 => int1 => [int2, gain1]
            int2 => gain2
            int2 => out1
        end
    end

    b = @model TestBlock55 begin
        @parameter begin
            M::Float64
            D::Float64
            k::Float64
            f::Float64
            p_cycle::Float64
            p_width::Float64
        end
        @block begin
            msd = MSD22()
            pulse = PulseGenerator(amplitude=:f, period=:p_cycle, pulsewidth=:p_width, phasedelay=10.0)
            # time = InBlock(:time)
        end

        @scope begin
            pulse
            msd.out1
        end

        begin
            # time => pulse.timeport
            pulse => msd.in1
        end
    end

    println(expr_define_function(b))
end

