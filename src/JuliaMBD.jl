module JuliaMBD

import Base
import Plots
import DifferentialEquations
import LookupTable

include("_types.jl")
include("_vars.jl")
include("_ports.jl")
include("_signals.jl")
include("_block.jl")

include("predefined/PortSubsystem/_blocks.jl")
include("predefined/MathOperations/_blocks.jl")
include("predefined/Continuous/_blocks.jl")
include("predefined/Sources/_blocks.jl")
include("predefined/Discontinuities/_blocks.jl")
include("predefined/LookupTables/_blocks.jl")

include("_show.jl")
include("_tsort.jl")
include("_expr.jl")
include("_ode.jl")

include("_macro.jl")

include("diagrams/_diagrams.jl")

end
