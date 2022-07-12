module JuliaMBD

export AbstractBlock, AbstractSystemBlock
export AbstractInPort, AbstractOutPort
export Auto, Value, SymbolicValue, Parameter
export InPort, OutPort, Line
export expr_refvalue, expr_setvalue, expr, next, tsort
export SystemBlockDefinition, addBlock!, addParameter!
export expr_define_function, expr_define_structure, expr_define_next, expr_define_expr
export @define, define

import Base
# import DifferentialEquations

abstract type AbstractLine end

abstract type AbstractPort end
abstract type AbstractInPort <: AbstractPort end
abstract type AbstractOutPort <: AbstractPort end

abstract type AbstractBlock end
abstract type AbstractIntegratorBlock <: AbstractBlock end
abstract type AbstractSystemBlock <: AbstractBlock end
abstract type AbstractInBlock <: AbstractBlock end
abstract type AbstractOutBlock <: AbstractBlock end

include("_parameter.jl")
include("_ports_and_line.jl")

include("_blocks/In.jl")
include("_blocks/Out.jl")
include("_blocks/Constant.jl")
include("_blocks/Gain.jl")
include("_blocks/Add.jl")
include("_blocks/PulseGenerator.jl")
include("_blocks/Integrator.jl")

include("_system.jl")
include("_macro.jl")

end
