module JuliaMBD

export AbstractBlock, AbstractSystemBlock
export AbstractInPort, AbstractOutPort
export Auto, SymbolicValue, Parameter
export InPort, OutPort, Line
export expr_refvalue, expr_setvalue
export expr, expr_initial
export next, prev
export SystemBlockDefinition, addBlock!, addParameter!
export get_default_inport, get_default_outport
export expr_define_structure, expr_define_next, expr_define_expr
export expr_define_function, expr_define_initialfunction, expr_define_sfunction
export expr_set_inports, expr_set_outports
export get_inports, get_outports
export @parameter, @block, @model, @scope
export get_parameters, simulate

import Base
import DifferentialEquations
import Plots

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
include("_common.jl")

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

include("_tsort.jl")
include("_system.jl")
include("_ode.jl")
include("_macro.jl")

Base.show(io::IO, x::Constant) = Base.show(io, "Constant()")
Base.show(io::IO, x::InBlock) = Base.show(io, "In()")
Base.show(io::IO, x::StateIn) = Base.show(io, "StateIn()")
Base.show(io::IO, x::Integrator) = Base.show(io, "Integrator()")
Base.show(io::IO, x::OutBlock) = Base.show(io, "Out()")
Base.show(io::IO, x::StateOut) = Base.show(io, "StateOut()")
Base.show(io::IO, x::Scope) = Base.show(io, "Scope()")
Base.show(io::IO, x::AbstractLine) = Base.show(io, x.var)
Base.show(io::IO, x::AbstractPort) = Base.show(io, x.var)
Base.show(io::IO, x::SymbolicValue{Tv}) where Tv = Base.show(io, Expr(:(::), x.name, Tv))
Base.show(io::IO, x::SymbolicValue{Auto}) = Base.show(io, x.name)

Base.show(io::IO, b::SystemBlockDefinition) = Base.show(io, "SystemBlock($(b.name))")

end
