module JuliaMBD

export AbstractBlock
export Auto, Value, SymbolicValue
export InPort, OutPort, Line
export expr_refvalue, expr_setvalue, expr, next, tsort
export SystemBlockDefinition, addBlock!, addParameter!
export expr_define_function, expr_define_structure, expr_define_next, expr_define_expr

export @define

import Base

abstract type AbstractLine end
abstract type AbstractPort end
abstract type AbstractBlock end
abstract type AbstractFunctionBlock <: AbstractBlock end

include("_parameter.jl")
include("_ports_and_line.jl")

include("_blocks/In.jl")
include("_blocks/Out.jl")
include("_blocks/Constant.jl")
include("_blocks/Gain.jl")
include("_blocks/Add.jl")
include("_blocks/PulseGenerator.jl")

include("_system.jl")
include("_macro.jl")

end
