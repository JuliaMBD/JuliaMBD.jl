
function simulate(blk::AbstractSystemBlock, tspan; n = 1000, alg=DifferentialEquations.Tsit5(), kwargs...)
    params = (;get_parameters(blk)...)
    iv = blk.ifunc(params)
    p = DifferentialEquations.ODEProblem(blk.sfunc, iv, tspan, params)
    sol = DifferentialEquations.solve(p, alg; kwargs...)
    ts = LinRange(tspan[1], tspan[2], n)
    results = blk.ofunc(sol, params, ts)
    graph = Plots.plot(ts, [x for (_,x) = results], layout=(length(results),1),
        title=reshape([x for (x,_) = results], 1, length(results)), leg=false)
    (params=params, solution=sol, ts=ts, outputs=results, graph=graph)
end

function simulate(blk::AbstractFunctionBlock, tspan; n = 1000, alg=DifferentialEquations.Tsit5(), kwargs...)
    params = (;get_parameters(blk)...)
    ts = LinRange(tspan[1], tspan[2], n)
    results = blk.ofunc(0, params, ts)
    graph = Plots.plot(ts, [x for (_,x) = results], layout=(length(results),1),
        title=reshape([x for (x,_) = results], 1, length(results)), leg=false)
    (params=params, ts=ts, outputs=results, graph=graph)
end
