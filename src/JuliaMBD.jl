module JuliaMBD

# export AbstractBlock, AbstractSystemBlock, AbstractFunctionBlock
# export AbstractInPort, AbstractOutPort
# export Auto, SymbolicValue, Parameter
# export InPort, OutPort, Line
# export expr_refvalue, expr_setvalue
# export expr, expr_initial
# export next, prev
# export BlockDefinition, addBlock!, addParameter!
# export get_default_inport, get_default_outport
# export expr_define_structure, expr_define_next, expr_define_expr
# export expr_define_function, expr_define_initialfunction, expr_define_sfunction
# export expr_set_inports, expr_set_outports
# export get_inports, get_outports
# export @parameter, @block, @model, @scope
# export get_parameters, simulate, odesolve

# import Base
# import DifferentialEquations
# import Plots

# abstract type AbstractSymbolicValue{Tv} end
# abstract type AbstractPort{Tv} <: AbstractSymbolicValue{Tv} end
# abstract type AbstractLine{Tv} <: AbstractSymbolicValue{Tv} end
# abstract type AbstractInPort{Tv} <: AbstractPort{Tv} end
# abstract type AbstractOutPort{Tv} <: AbstractPort{Tv} end

# abstract type AbstractBlock end
# abstract type AbstractBasicBlock <: AbstractBlock end
# abstract type AbstractSystemBlockInstance <: AbstractBlock end
# abstract type AbstractSystemBlockDefinition end

# abstract type AbstractIntegratorBlock <: AbstractBlock end
# abstract type AbstractFunctionBlock <: AbstractSystemBlock end
# abstract type AbstractTimeBlock <: AbstractBlock end
# abstract type AbstractInBlock <: AbstractBlock end
# abstract type AbstractOutBlock <: AbstractBlock end

"""
Note:
- AbstractTimeBlock has a property `timeport`
- AbstractIntegratorBlock has `inblk`, `outblk` that are the vectors to store StateIn, StateOut blocks.
"""

# include("_parameter.jl")
# include("_ports_and_line.jl")

# include("blocks/MathOperations/include.jl")
# include("blocks/PortSubsystem/include.jl")

# include("_block.jl")
# include("_tsort.jl")

# include("_system.jl")

# include("_common.jl")

# include("_blocks/In.jl")
# include("_blocks/Out.jl")
# include("blocks/Constant.jl")
# include("_blocks/Gain.jl")
# include("_blocks/Add.jl")
# include("_blocks/BinaryOperator.jl")
# include("_blocks/MathFunction.jl")
# include("_blocks/Integrator.jl")
# include("_blocks/PulseGenerator.jl")
# include("_blocks/Ramp.jl")
# include("_blocks/Step.jl")
# include("_blocks/Quantizer.jl")
# include("_blocks/Saturation.jl")

# include("_tsort.jl")
# include("_system.jl")
# include("_ode.jl")
# include("_macro.jl")

end
