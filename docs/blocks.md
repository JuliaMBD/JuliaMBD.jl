## Types

```julia
abstract type AbstractBlock end
```

- Properties
    - name: Symbol for class name
    - inports: Dict
    - outports: Dict
- AbstractBlock can generate the julia code by `_expr` (inner function).
- AbstractBlock can be compiled by 'compile' to the ODEModel.
- This should be connected to others.


## Block

### BlockDefinition

```julia
mutable struct BlockDefinition
    name::Symbol
    parameters::Vector{Tuple{SymbolicValue,Any}}
    inports::Dict{Symbol,InPort}
    outports::Dict{Symbol,OutPort}
    blks::Dict{Symbol,AbstractBlock}
end
```

- `name::Symbol`: Block name
- `parameters::Vector{Tuple{SymbolicValue,Any}}`: Block parameters
- `inports::Vector{InPort}`: InPort of Block
- `outports::Vector{OutPort}`: OutPort of Block
- `stateinports::Vector{InPort}`: InPort for state of block
- `stateoutports::Vector{OutPort}`: OutPort for state of block
- `scopeoutports::Vector{OutPort}`: OutPort for scope
- `timeblk::AbstractInBlock`: A port for time
- `blks::Vector{AbstractBlock}`: blocks

- Notes
    - BlockDefinition makes a structure of AbstractSystemBlock

### AbstractSystemBlock

```julia
abstract type AbstractBlock <: AbstractComponent end
abstract type AbstractIntegratorBlock <: AbstractBlock end
abstract type AbstractSystemBlock <: AbstractBlock end
abstract type AbstractFunctionBlock <: AbstractSystemBlock end
abstract type AbstractTimeBlock <: AbstractBlock end
abstract type AbstractInBlock <: AbstractBlock end
abstract type AbstractOutBlock <: AbstractBlock end
```

`AbstractSystemBlock` means the block to be needed by odesolver, i.e., the integrator blocks are involved. On the other hand, `AbstractFunctionBlock` does not involve integrator blocks.

- `odesolve(blk::AbstractSystemBlock, params, tspan; alg=DifferentialEquations.Tsit5(), kwargs...)`
- `odesolve(blk::AbstractFunctionBlock, params, tspan; alg=DifferentialEquations.Tsit5(), kwargs...)`


`AbstractTimeBlock` means the block having the time block.

- `get_timeport`: A function to get the input port of time.

### Inherent

```julia
function addBlock!(blk::BlockDefinition, x::AbstractBlock)
function addBlock!(blk::BlockDefinition, x::AbstractIntegratorBlock)
function addBlock!(blk::BlockDefinition, x::AbstractTimeBlock)
function addBlock!(blk::BlockDefinition, x::AbstractSystemBlock)
function addBlock!(blk::BlockDefinition, x::InBlock)
function addBlock!(blk::BlockDefinition, x::OutBlock)
``````

Consideration

The implementation of adding a system block is below.
```julia
function addBlock!(blk::BlockDefinition, x::AbstractSystemBlock)
    push!(blk.blks, x)
    for b = x.inblk
        addBlock!(blk, b)
    end
    for b = x.outblk
        addBlock!(blk, b)
    end
    for b = x.scopes
        addBlock!(blk, b)
    end
    Line(blk.timeblk.outport, x.time)
end
```
The system block has the fields; inblk, outblk, scopes, timeblk.

Wny sin and sout are ignored? -> Ans: inblk and outblk already involve sin and sout.

