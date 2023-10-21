# JuliaMBD

[![Build Status](https://travis-ci.com/okamumu/JuliaMBD.jl.svg?branch=master)](https://travis-ci.com/okamumu/JuliaMBD.jl)
[![Coverage](https://codecov.io/gh/okamumu/JuliaMBD.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/okamumu/JuliaMBD.jl)
[![Coverage](https://coveralls.io/repos/github/okamumu/JuliaMBD.jl/badge.svg?branch=master)](https://coveralls.io/github/okamumu/JuliaMBD.jl?branch=master)

A block-based modeling tool for MBD (model-based development)

## Introduction

MBD (Model-Based Development) is one of the most powerful approaches to develop embedded systems. By creating a simulation model, we can verify the system requreiments via computer-aided simulation before the implentation of physical systems. Most popular MBD tool is Matlab/Simulink. In the simulink, we make the simulation model by building simple blocks.

JuliaMBD is a similar tool of Simulink, and provides the approach to develop the simulation model by building blocks. Main funcitonatity of this tool is to compile a block to Expr to bulid the system function representing dynamic behavior of system states.

## Installation

The package has not been an official. Thus it is installed from GitHub

```julia
using Pkg
Pkg.add(url="https://github.com/JuliaReliab/LookupTable.jl.git") # this is also required for the lookuptable
Pkg.add(url="https://github.com/JuliaMBD/JuliaMBD.git")
```

The package requires `DifferentialEquations` and `Plots`, and execute
```julia
using DifferentialEquations
using Plots
using JuliaMBD
```



## Example

Consider an RLC circuit. An example of model description is

```julia
## RLC circuit
@model RLC begin
    # define model parameters
    @parameter begin
        R # a parameter of resistor
        L # a parameter of inductor
        C # a parameter of capacitor
    end
    # define blocks
    @block begin
        in1 = Inport(:in)
        out1 = Outport(:out)
        int1 = Integrator()
        int2 = Integrator()
        gain1 = Gain(K = R)
        gain2 = Gain(K = 1/C)
        gain3 = Gain(K = 1/L)
        sum1 = Add(signs=[:+, :-, :-])
    end
    # define the connections between blocks
    @connect begin
        in1.out => sum1.in1 # this means the outport of block `in1` is connected to the inport of `sum1.in1`
        gain1.out => sum1.in2
        int1.out => sum1.in3
        sum1.out => gain3.in
        gain3.out => int2.in
        int2.out => out1.in
        int2.out => gain1.in
        int2.out => gain2.in
        gain2.out => int1.in
    end
end

# test model for RLC
@model Test begin
    @parameter begin
        R
        L
        C
        voltage
    end
    @block begin
        # create the user-defined model
        # This example passes the parameters of this model to RLC model by expressing `R=R, L=L, C=C`
        system = RLC(R=R, L=L, C=C)
        source = Step(steptime=0.1, finalvalue=voltage)
    end
    @connect begin
        source.out => system.in
    end
    @scope begin
        system.in => v
        system.out => i
    end
end
```

### Parameter section

In this section, we define model parameters. `@parameter` indicates the start of parameter section. There are two ways to write the section:

```julia
@parameter a
@parameter b
```

```julia
@parameter begin
    a
    b
end
```

Also we can set the type and the default value of the parameter:

```julia
@parameter a = 0
@parameter begin
    b::Float64 = 1.0
end
```

### Block section

In this section, we define all the blocks that are used to build the system. `@block` indicates the beginning of section. Similar to parameter section, there are two types to write the section.

```julia
@block a = Gain(K=10)
@block begin
    b = Integrator()
    c = Add(sigins=[:+, :+])
end
```

We find the following expressions in this section, and regard it as the creation (constructor) of block.
```
symbol = (function call)
```
```julia
Expr(:(=), Symbol, Expr(:call, :functionname, args...))
```
Other expressions are regarded as common statements of Julia.

The arguments of constructor depends on the block and are pre-defined. See the document of each block in detail.

### Connection section

In the connection section, we represent the connections between ports of blocks. The format for a connection uses the operation `=>` as follows.
```
(outport) => (inport)
```
The ports of blocks are expressed by properties of blocks;
```
gain.in # this is the inport of gain block
```
The label of port is pre-defined. See the document of each block in detail.

### Scope section

This section indicates Scope to monitor the dynamic behavior of signals on in/out ports. The format to indicate a scope is
```
(port) => (label)
```
The label means the title of plotting graph of dynamic behavior of signals.

## Compile and Run

The constructor gives us an instance of block. To run the simulation, we should compile an instance of block. The compilation is done by
```julia
m = @compile Test(R=10, L=100e-3, C=10e-6, voltage=5)
```
`m` is an instance having the functions that are for simulation run. To obtain the result, we execute
```julia
result = simulate(m, tspan=(0, 1))
```
where `tspan` means the time intaval in which the simulation runs. `result` is the instance to store the simulation result.

Finally, to draw the graph, we also run
```julia
plot(result)
```
The layout can be changed with `layout`
```julia
plot(result, layout=(1,2))
```

## Pre-defined blocks

### Available block

- Continuous
    - Integrator
- Discontinuities
    - Quantizer
    - Saturation
- LookupTables
    - OneDLookupTable (experimental)
- MathOperations
    - Abs
    - Add
    - Divide
    - Gain
    - Mod
    - Product
- PortSubsystem
    - Inport
    - Outport
    - (SubSystem is implemented as user-defined block)
- Sources
    - Constant
    - PulseGenerator
    - Ramp
    - Step

### Documents for blocks

To be written

## For Developers

To be written


