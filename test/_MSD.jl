module MSDtest

using JuliaMBD
using Test

@testset "MSD1" begin
    @time begin
        @model MSD begin
            @parameter begin
                M
                D
                k
                g = 9.8
            end
            @block begin
                in1 = Inport(:in1)
                out1 = Outport(:out1)
                constant1 = Constant(value = M*g)
                gain1 = Gain(K = D)
                gain2 = Gain(K = k)
                gain3 = Gain(K = 1/M)
                int1 = Integrator()
                int2 = Integrator()
                constant2 = Constant(value = M*g/k)
                sum1 = Add(signs=[:+, :+, :-, :-])
            end
            @connect begin
                in1.out => sum1.in1
                constant1.out => sum1.in2
                gain1.out => sum1.in3
                gain2.out => sum1.in4
                sum1.out => gain3.in
                gain3.out => int1.in
                int1.out => int2.in
                constant2.out => int2.initialcondition
                int1.out => gain1.in
                int2.out => gain2.in
                int2.out => out1.in
            end
        end
        @model Test begin
            @parameter begin
                M
                D
                k
                f
                p_cycle
                p_width
            end
            @block begin
                msd = MSD(M=M, D=D, k=k)
                pulse = JuliaMBD.PulseGenerator(amplitude=f, period=p_cycle, pulsewidth=p_width, phasedelay=10.0)
            end
            @connect begin
                pulse.out => msd.in1
            end
            @scope begin
                pulse.out => F
                msd.out1 => x
            end
        end

        @compile Test(M=10, D=10, k=10, f=10, p_cycle=20, p_width=50)
    end
end

end