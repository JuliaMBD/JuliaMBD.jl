using JuliaMBD.Continuous
using JuliaMBD.MathOperations

@subsystem M1 begin
    @parameters begin
        a::Float64
        b::Int
    end

    @blocks begin
        b1 = Divide(inport::Float64 = :x, outport = :y)
        b2 = Ramp(start=a, slope=b, outport = :z)
        b3 = Scope()
    end

    @connections begin
        b2.z => b1.x
    end
end

@subsystem Divide begin
    @parameters begin
        de::InPort{Auto}
        nu::InPort{Auto}
        out::OutPort{Auto}
    end

    @initialize begin
    end

    @execute begin
        out = de / nu
    end

    @finalize begin
    end
end

###

struct Divide <: AbstractBlock
    de::InPort{Auto}
    nu::InPort{Auto}
    out::OutPort{Auto}
end

function _execute_expr(b::Divide)
    quote
        let de
            out = de / nu
        end
    end
end

@subsystem Gain begin
    @parameters begin
        in::InPort{Auto}
        out::OutPort{Auto}
        K::Parameter{Auto}
    end

    @execute begin
        out = K * in
    end
end

struct Gain <: AbstractBlock
    in::Inport{Auto}
    out::OutPort{Auto}
    K::Parameter{Auto}
end

function Gain(;K::Parameter{Auto})
    b = Gain()
    b.K = K
    b
end

function _expr(b::Gain)
    quote
        out = K * in
    end
end

b1 = Divide()
b2 = Gain(K = 1.0)

b2.out => d.de

@subsystem LookUpTable begin
    @parameters begin
        in::InPort{Auto}
        out::OutPort{Auto}
        breaks::Parameter{Array{Float64}}
        x::Parameter{Array{Float64}}
    end

    @initialize begin
        quote
            tab = LookUpTable.Lookuptable(breaks, x)
        end
    end

    @execute begin
        quote
            out = tab.get(in)
        end
    end
end

a = Lookup()

compile(a) # return Expr

function compile(b::AbstractBlock)::Expr
end

struct SubSystem
    # inout, parameter など
    init::Graph{Expr} # 先行関係を表すグラフ
    exec::Graph{Expr} # 先行関係を表すグラフ
    final::Graph{Expr} # 先行関係を表すグラフ
end

"""
function compile(b::AbstractBlock)::Expr
end
=>
以下を定義するExpr
xxxx_init()
xxxx_exec() <= 引数は適宜？
xxxx_final()
"""
