module TestBlock

using Test
import JuliaMBD:
    AbstractBlock,
    AbstractInPort,
    AbstractOutPort,
    get_inports,
    get_outports,
    set_inport!,
    set_outport!,
    expr,
    expr_body,
    InPort,
    OutPort,
    Line

mutable struct Gain <: AbstractBlock
    name::Symbol
    inports::Vector{AbstractInPort}
    outports::Vector{AbstractOutPort}
    env::Dict{Symbol,Any}
    
    function Gain(; in::AbstractInPort = InPort(:in), out::AbstractOutPort = OutPort(:out))
        b = new(:Gain, AbstractInPort[], AbstractOutPort[], Dict{Symbol,Any}())
        set_inport!(b, in)
        set_outport!(b, out)
        b
    end
end

function expr_body(blk::Gain)
    :(out = in)
end

@testset "block01" begin
    b = Gain()
    i = InPort()
    o = OutPort()
    Line(o, get_inports(b)[1])
    Line(get_outports(b)[1], i)
    println(expr(b))
end

@testset "block02" begin
    b = Gain()
    i = InPort()
    o = OutPort()
    Line(o, b[:in])
    Line(b[:out], i)
    println(expr(b))
end

end
