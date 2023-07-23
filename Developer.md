## Types

- `Auto`: A type determined automatically from the code.
- `SymbolicValue{Tv}`: A label of variable. This is convered to a variable in the program with type Tv.
- `Parameter`: This type is Any

## Line

Line is a type meaning a data flow between blocks. This is a directed line connecting two blocks.

- Elements
    - `var::SymbolicValue{Auto}`: A label of line
    - `source::AbstractOutPort`: An instance of port which is a source of data flow. An outport of block.
    - `dest::AbstractInPort`: An instance of port which is a destination of data flow. An inport of block.

- Constructor
    - Line is created by the operator `=>`.

An example:

```
a => b
```

In the above example, `a` and `b` are blocks or ports. The line connecting from `a` to `b` is created.

## Ports

Ports consists of inport and outport.
The inport is a point for a block to get data from other blocks.
The outport is a point for a block to send data to other blocks.

### InPort

- Elements
    - `var::SymbolicValue`: A label of inport.
    - `parent::Union{AbstractBlock,Nothing}`: The block involving this inport.
    - `line::Union{AbstractLine,Nothing}`: The line connected to this inport

- Note
    - The inport has only one line.
    - The label of inport basically becomes a label of argument of function corresponding to the block.

- Constructor
    - InPort(name, ::Type{Tv}) where Tv
    - InPort(name)
    - InPort(::Type{Tv}) where Tv
    - InPort()

### OutPort

- Elements
    - `var::SymbolicValue`: A label of outport.
    - `parent::Union{AbstractBlock,Nothing}`: The block involving this outport.
    - `lines::Vector{AbstractLine}`: The lines connected to this outport.

- Note
    - The outport may have multiple lines.
    - The label of outport basically becomes a label of returned values of function corresponding to the block.

- Constructor
    - OutPort(name, ::Type{Tv}) where Tv
    - OutPort(name)
    - OutPort(::Type{Tv}) where Tv
    - OutPort()

## Block

### BlockDefinition

```julia
mutable struct BlockDefinition
    name::Symbol
    parameters::Vector{Tuple{SymbolicValue,Any}}
    inports::Vector{InPort} # TODO: check whether the vector has the ports with same name
    outports::Vector{OutPort} # TODO: check whether the vector has the ports with same name
    stateinports::Vector{InPort} # TODO: check whether the vector has the ports with same name
    stateoutports::Vector{OutPort} # TODO: check whether the vector has the ports with same name
    scopeoutports::Vector{OutPort} # TODO: check whether the vector has the ports with same name
    timeblk::AbstractInBlock
    blks::Vector{AbstractBlock}
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

