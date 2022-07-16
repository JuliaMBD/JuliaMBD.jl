@testset "integrator5" begin
# module MyModule

b = @model DCMotorDisk false begin
    ## モータ特性
    @parameter begin
        R::Float64     # 電機抵抗
        L::Float64     # インダクタンス
        K_e::Float64   # 逆起電力定数
        K_tau::Float64 # トルク定数
        J_M::Float64   # 慣性モーメント
    end
        
    ## ディスク特性
    @parameter begin
        J_I::Float64 # 慣性モーメント
        D::Float64   # 粘性減衰係数
    end
    
    @block begin
        in1 = InBlock(:v_M) # 印加電圧
        int = Integrator(:s1, outport=OutPort(:i_M))
        int1 = Integrator(:s2, outport=OutPort(:omega))
        gain = Gain(:(1/L))
        gain1 = Gain(:K_tau)
        gain2 = Gain(:(1/(J_M+J_I)))
        gain3 = Gain(:D)
        gain4 = Gain(:K_e)
        gain5 = Gain(:R)
        out1 = OutBlock(:out1)
        out2 = OutBlock(:out2)
        sum1 = Add(inports=[InPort(), InPort(), InPort()], signs=[:+, :-, :-])
        sub = Add(inports=[InPort(), InPort()], signs=[:+, :-])
    end
    
    # @scope begin
    #     int
    #     int1
    # end

    in1 => sum1.inports[1]
    gain4 => sum1.inports[2]
    gain5 => sum1.inports[3]
    sum1 => gain => int => [gain1, gain5, out2]
    gain1 => sub.inports[1]
    gain3 => sub.inports[2]
    sub => gain2 => int1 => [gain3, gain4, out1]
end

eval(expr_define_function(b))
eval(expr_define_structure(b))
eval(expr_define_next(b))
eval(expr_define_expr(b))

println(expr_define_expr(b))

x = DCMotorDisk()
println(x)
Line(OutPort(), x.v_M)
Line(OutPort(), x.time)
println(expr(x))

# b = @model TestDCMotorDisk false begin
#     @parameter begin
#         R::Float64 = 5.7
#         L::Float64 = 0.2
#         K_e::Float64 = 7.16e-2
#         K_tau::Float64 = 7.2e-2
#         J_M::Float64 = 0.11e-3
#         J_I::Float64 = 1.3e-3
#         D::Float64 = 6.0e-5
#         v0::Float64 = 24.0
#     end

#     @block begin
#         motor_and_disk = DCMotorDisk()
#         step = Step(steptime = 1, finalvalue = :v0)
#     end
    
#     @scope step 
    
#     step => motor_and_disk.v_M
# end

# println(b.name)
# println(expr_define_function(b))

# eval(expr_define_function(b))
# eval(expr_define_structure(b))
# eval(expr_define_next(b))
# eval(expr_define_expr(b))

# println(TestDCMotorDiskFunc(time=1.0, s1in=0.0, s2in=0.0))

# end
end
