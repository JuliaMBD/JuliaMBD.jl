module JuliaMBD

import Base
import Plots
import DifferentialEquations
import LookupTable

include("_types.jl")

## global vars
const gotoports = Dict{Symbol,Vector{AbstractPort}}()
const fromports = Dict{Symbol,AbstractPort}()

include("_vars.jl")
include("_ports.jl")
include("_signals.jl")
include("_simpleblock.jl")
include("_compositeblock.jl")

include("_show.jl")
include("_compile.jl")
include("_expr.jl")
include("_expr_func.jl")
include("_expr_func_derivative.jl")
include("_ode.jl")

include("_macro.jl")

include("diagrams/_diagrams.jl")

include("predefined/PortSubsystem/_blocks.jl")
include("predefined/MathOperations/_blocks.jl")
include("predefined/Continuous/_blocks.jl")
include("predefined/Sources/_blocks.jl")
include("predefined/Discontinuities/_blocks.jl")
include("predefined/LookupTables/_blocks.jl")
include("predefined/SignalRouting/_blocks.jl")

end
