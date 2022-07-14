module JuliaMBD

export AbstractBlock, AbstractSystemBlock
export AbstractInPort, AbstractOutPort
export Auto, SymbolicValue, Parameter
export InPort, OutPort, Line
export expr_refvalue, expr_setvalue
export expr, next, defaultInPort, defaultOutPort
export SystemBlockDefinition, addBlock!, addParameter!
export expr_define_function, expr_define_structure, expr_define_next, expr_define_expr
export @parameter, @block, @model, @scope

import Base
# import DifferentialEquations

abstract type AbstractLine end

abstract type AbstractComponent end

abstract type AbstractPort <: AbstractComponent end
abstract type AbstractInPort <: AbstractPort end
abstract type AbstractOutPort <: AbstractPort end

abstract type AbstractBlock <: AbstractComponent end
abstract type AbstractIntegratorBlock <: AbstractBlock end
abstract type AbstractSystemBlock <: AbstractBlock end
abstract type AbstractTimeBlock <: AbstractBlock end
abstract type AbstractInBlock <: AbstractBlock end
abstract type AbstractOutBlock <: AbstractBlock end

"""
Note:
- AbstractTimeBlock has a property `timeport`
- AbstractIntegratorBlock has `inblk`, `outblk` that are the vectors to store StateIn, StateOut blocks.
"""

include("_parameter.jl")
include("_ports_and_line.jl")

include("_blocks/In.jl")
include("_blocks/Out.jl")
include("_blocks/Constant.jl")
include("_blocks/Gain.jl")
include("_blocks/Add.jl")
include("_blocks/BinaryOperator.jl")
include("_blocks/MathFunction.jl")
include("_blocks/Integrator.jl")
include("_blocks/PulseGenerator.jl")
include("_blocks/Ramp.jl")
include("_blocks/Step.jl")
include("_blocks/Quantizer.jl")
include("_blocks/Saturation.jl")

include("_system.jl")
include("_macro.jl")

end
