@testset "func1" begin
    b = @model Example begin
        @parameter K
        @block begin
            in = InBlock(:in)
            gain = Gain(:K)
            out = OutBlock(:out)
        end
        
        in => gain => out
    end

    println(expr_define_structure(b))

    @model ExampleTest begin
        @parameter begin
            K
            v
        end
    
        @block begin
            c = Constant(:v)
            test = Example()
        end
        
        @scope begin
            c
            test.out
        end
        
        c => test.in
    end

    m = ExampleTest(K=2.0, v=10.0)
    println(simulate(m, (0.0, 1.0)))
end
