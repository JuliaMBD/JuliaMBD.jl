struct SimulationResult
    parameters
    ts
    outputs
    solution
end

function odesolve(blk::AbstractSystemBlock, params, tspan; alg=DifferentialEquations.Tsit5(), kwargs...)
    iv = blk.ifunc(params)
    p = DifferentialEquations.ODEProblem(blk.sfunc, iv, tspan, params)
    DifferentialEquations.solve(p, alg; kwargs...)
end

function odesolve(blk::AbstractFunctionBlock, params, tspan; alg=DifferentialEquations.Tsit5(), kwargs...)
    (t) -> 0.0
end

function simulate(blk::AbstractSystemBlock, tspan; n = 1000, alg=DifferentialEquations.Tsit5(), kwargs...)
    params = (;get_parameters(blk)...)
    u = odesolve(blk, params, tspan; alg=alg, kwargs...)
    ts = LinRange(tspan[1], tspan[2], n)
    results = blk.ofunc(u, params, ts)
    SimulationResult(params, ts, results, u)
end

function Plots.plot(x::SimulationResult)
    n = length(x.outputs)
    Plots.plot(x.ts, [x for (_,x) = x.outputs], layout=(n,1), title=reshape([x for (x,_) = x.outputs], 1, n), leg=false)
end

