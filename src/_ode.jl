mutable struct MBDProblem
    name
    parameters
    sfunc
    ifunc
    ofunc
end

"""
Expr to define the systemfunction of SystemBlock
The toporogical sort `tsort` is used.
"""

macro modelbuild(m)
    esc(:(expr_define_sfunction($m)))
end

function expr_setpair(x::SymbolicValue{Tv}, expr) where Tv
    Expr(:call, :(=>), @q(x.name), Expr(:call, Symbol(Tv), expr))
end

function expr_setpair(x::SymbolicValue{Auto}, expr)
    Expr(:call, :(=>), @q(x.name), expr)
end

function expr_define_sfunction(blk::SystemBlockDefinition)
    if !(length(blk.inports) == 1 && name(blk.inports[1]) == :time)
        error("Model $(blk.name) has undermined inports $(name(blk.inports)). Please connect inputs to inports.")
    end

    params = [Expr(:kw, name(x[1]), :(p.$(name(x[1])))) for x = blk.parameters]
    params_init = [(if typeof(x[2]) <: Number expr_setpair(x[1], x[2]) else expr_setpair(x[1], 0) end) for x = blk.parameters]

    sins = [Expr(:kw, name(p), :(u[$i])) for (i,p) = enumerate(blk.stateinports)]
    sins0 = [Expr(:kw, name(p), 0) for (i,p) = enumerate(blk.stateinports)]
    sins1 = [Expr(:kw, name(p), :(u(t)[$i])) for (i,p) = enumerate(blk.stateinports)]
    souts = [:(result.$(name(p))) for p = blk.stateoutports]
    dus = [:(du[$i]) for (i,_) = enumerate(blk.stateoutports)]

    scopes = [Expr(:call, :(=>), @q(name(p)), :([x.$(name(p)) for x = result])) for p = blk.scopeoutports]

    expr = Expr(:call,
        :MBDProblem,
        @q(blk.name),
        Expr(:call, :Dict, params_init...),
        Expr(:->, Expr(:tuple, :du, :u, :p, :t),
            Expr(:block,
                Expr(:(=), :result, Expr(:call, Symbol(blk.name, "Function"),
                    Expr(:kw, :time, :t),
                    params...,
                    sins...
                )),
                Expr(:(=), Expr(:tuple, dus...), Expr(:tuple, souts...))
            )
        ),
        Expr(:->, Expr(:tuple, :p),
            Expr(:block,
                Expr(:(=), :result, Expr(:call, Symbol(blk.name, "InitialFunction"),
                    Expr(:kw, :time, 0),
                    params...,
                    sins0...
                )),
                Expr(:vect, souts...)
            )
        ),
        Expr(:->, Expr(:tuple, :u, :p, :ts),
            Expr(:block,
                :(result = [$(Expr(:call, Symbol(blk.name, "Function"), Expr(:kw, :time, :t), params..., sins1...)) for t = ts]),
                Expr(:call, :Dict, scopes...)
            )
        )
    )
end

function simulate(prob::MBDProblem, tspan; n = 1000, alg=DifferentialEquations.Tsit5(), kwargs...)
    params = (;prob.parameters...)
    iv = prob.ifunc(params)
    p = DifferentialEquations.ODEProblem(prob.sfunc, iv, tspan, params)
    sol = DifferentialEquations.solve(p, alg; kwargs...)
    ts = LinRange(tspan[1], tspan[2], n)
    results = prob.ofunc(sol, params, ts)
    Plots.plot(ts, [x for (_,x) = results], layout=(length(results),1), leg=false)
end

function simulate(blk::AbstractBlock, pdict, tspan; n = 1000, alg=DifferentialEquations.Tsit5(), kwargs...)
    params = get_parameters(blk)
    iv = blk.ifunc(params)
    p = DifferentialEquations.ODEProblem(blk.sfunc, iv, tspan, params)
    sol = DifferentialEquations.solve(p, alg; kwargs...)
    ts = LinRange(tspan[1], tspan[2], n)
    results = blk.ofunc(sol, params, ts)
    graph = Plots.plot(ts, [x for (_,x) = results], layout=(length(results),1), leg=false)
    (params=params, solution=sol, ts=ts, outputs=results, graph=graph)
end
