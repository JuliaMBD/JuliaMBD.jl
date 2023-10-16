mutable struct Add <: AbstractBasicBlock
    name::Symbol
    parameters::Vector{AbstractSymbolicValue}
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}
    env::Dict{Symbol,Any}
    
    function Add(;signs::Vector{Symbol}, out::AbstractOutPort = OutPort(:out))
        b = new(:Plus, AbstractSymbolicValue[], AbstractInPort[], AbstractOutPort[], Dict{Symbol,Any}())
        for (i,s) = enumerate(signs)
            set_inport!(b, InPort(Symbol(:in, i)))
        end
        b.env[:signs] = signs
        set_outport!(b, out)
        b
    end
end

function expr_body(blk::Add)
    signs = blk[:signs]
    expr = 0
    for (i,s) = enumerate(signs)
        expr = Expr(:call, s, expr, Symbol(:in, i))
    end
    println(expr)
    Expr(:(=), :out, expr...)
end
