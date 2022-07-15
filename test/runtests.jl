using JuliaMBD
using Test

import JuliaMBD: next, expr, get_outports

include("test_parameter.jl")
include("test_port.jl")

include("test_blocks.jl")
include("test_integrator.jl")
include("test_module.jl")
include("test_scope.jl")
include("test_macro.jl")
include("test_msd.jl")

include("test_inmodule.jl")
