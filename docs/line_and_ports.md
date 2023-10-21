## Types

```julia
abstract type AbstractLine end
abstract type AbstractPort <: AbstractComponent end
abstract type AbstractInPort <: AbstractPort end
abstract type AbstractOutPort <: AbstractPort end
```

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

