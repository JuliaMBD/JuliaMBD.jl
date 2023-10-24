export simulate
export @compile

macro compile(x)
    b = gensym()
    expr = quote
        $b = $x
        eval(JuliaMBD.expr_sfunc($b))
        eval(JuliaMBD.expr_ofunc($b))
        eval(JuliaMBD.expr_ifunc($b))
        eval(JuliaMBD.expr_pfunc($b))
        JuliaMBD.ODEModel(
            $b,
            eval(JuliaMBD.expr_odemodel_pfunc($b)),
            eval(JuliaMBD.expr_odemodel_ifunc($b)),
            eval(JuliaMBD.expr_odemodel_sfunc($b)),
            eval(JuliaMBD.expr_odemodel_ofunc($b))
        )
    end
    esc(expr)
end

struct ODEModel
    blk
    pfunc # the function to obtain the values of parameters
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

function simulate(blk::ODEModel; tspan = (0, 1), parameters = (), n = 1000, alg=DifferentialEquations.Tsit5(), kwargs...)
    # making a function to get parameters without default values; ex) params = blk.pfunc(M=10, R=1)
    args = [Expr(:kw, k, parameters[k]) for k = keys(parameters)]
    params = eval(Expr(:call, Expr(:., blk, Expr(:quote, :pfunc)), args...))

    if length(blk.blk.stateinports) != 0
        u = odesolve(blk, params, tspan; alg=alg, kwargs...)
    else
        u = (t) -> 0.0
    end
    ts = LinRange(tspan[1], tspan[2], n)
    results = blk.ofunc(u, params, ts)
    SimulationResult(params, ts, results, u)
end

function Plots.plot(x::SimulationResult; vars=keys(x.outputs), layout=(length(vars), 1), kwargs...)
    Plots.plot(x.ts, [x.outputs[k] for k = vars], layout=layout, title=reshape([k for k = vars], 1, length(vars)), leg=false, kwargs...)
end

