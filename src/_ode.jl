
function simulate(blk::AbstractBlock, tspan; n = 1000, alg=DifferentialEquations.Tsit5(), kwargs...)
    params = (;get_parameters(blk)...)
    iv = blk.ifunc(params)
    p = DifferentialEquations.ODEProblem(blk.sfunc, iv, tspan, params)
    sol = DifferentialEquations.solve(p, alg; kwargs...)
    ts = LinRange(tspan[1], tspan[2], n)
    results = blk.ofunc(sol, params, ts)
    graph = Plots.plot(ts, [x for (_,x) = results], layout=(length(results),1), leg=false)
    (params=params, solution=sol, ts=ts, outputs=results, graph=graph)
end
