struct ODEModel
    blk
    ifunc # the function to obtain the state vector from a given model parameters
    sfunc # the function to obtain the next state vector. This is an argument for ODEProblem
    ofunc # the function to obtain the outputs
end

struct SimulationResult
    parameters
    ts
    outputs
    solution
end

function odesolve(blk::ODEModel, params, tspan; alg=DifferentialEquations.Tsit5(), kwargs...)
    iv = blk.ifunc(params)
    p = DifferentialEquations.ODEProblem(blk.sfunc, iv, tspan, params)
    DifferentialEquations.solve(p, alg; kwargs...)
end

# function odesolve(blk::AbstractFunctionBlock, params, tspan; alg=DifferentialEquations.Tsit5(), kwargs...)
#     (t) -> 0.0
# end

function simulate(blk::ODEModel, tspan; n = 1000, alg=DifferentialEquations.Tsit5(), kwargs...)
    params = [x[2] for x = blk.blk.parameters]
    if length(blk.blk.stateinports) != 0
        u = odesolve(blk, params, tspan; alg=alg, kwargs...)
    else
        u = (t) -> 0.0
    end
    ts = LinRange(tspan[1], tspan[2], n)
    results = blk.ofunc(u, params, ts)
    SimulationResult(params, ts, results, u)
end

function Plots.plot(x::SimulationResult, layout=(length(x.outputs), 1))
    n = length(x.outputs)
    Plots.plot(x.ts, [x for (_,x) = x.outputs], layout=layout, title=reshape([x for (x,_) = x.outputs], 1, n), leg=false)
end

