"""
Block
"""

"""
systemequation

Generate function
"""

# function systemequation(system::SystemBlock, label::Symbol = :model)
#     u = gensym()
#     du = Symbol("d", u)
#     states = sort(collect(keys(system.states)))
#     n = length(states)
#     dict = Dict(zip(states, [:($u[$i]) for i = 1:n]))
#     expr = [Expr(:(=), :($(du)[$i]), _replace(dict, _tosystemexpr(system.states[states[i]]))) for i = 1:n]
#     initvec = [_toexpr(system.states[x].initialcondition) for x = states]
#     init = Symbol(label, "init")
#     func = Symbol(label, "!")
#     quote
#         $init = $initvec
#         function $func($(du), $(u), p, t)
#             $(Expr(:block, expr...))
#         end
#     end
# end

# function _systemequation_func(system::SystemBlock)
#     u = gensym()
#     du = Symbol("d", u)
#     states = sort(collect(keys(system.states)))
#     n = length(states)
#     dict = Dict(zip(states, [:($u[$i]) for i = 1:n]))
#     expr = [Expr(:(=), :($(du)[$i]), _replace(dict, _tosystemexpr(system.states[states[i]]))) for i = 1:n]
#     func = quote
#         ($(du), $(u), p, t) -> begin
#             $(Expr(:block, expr...))
#         end
#     end
#     eval(func)
# end

# function _tosystemexpr(blk)
#     s = Set{AbstractBlock}()
#     _toexpr(s, blk.inport)
#     saturationlimits = [_toexpr(x) for x = blk.saturationlimits]
#     if length(saturationlimits) == 0
#         _toexpr(blk.inport[1])
#     else
#         lower, upper = saturationlimits
#         Expr(:if, Expr(:comparison, lower, :<=, blk.state, :<=, uupper), _toexpr(blk.inport[1]), 0)
#     end

# end

"""
AbstractBlock

An abstract object of block.
"""

abstract type AbstractBlock end

"""
Var

A struct of symbol and datatype
"""

struct Var
    label::Symbol
    datatype::DataType
end


"""
Line

An object of line with one symbol
"""

const Line = Var

"""
InPort
"""

mutable struct InPort
    line::Union{Line,Nothing}
    parent::AbstractBlock
    label::Symbol

    InPort(blk, label) = new(nothing, blk, label)
end

"""
OutPort
"""

mutable struct OutPort
    lines::Vector{Line}
    parent::AbstractBlock
    label::Symbol

    OutPort(blk, label) = new(Vector{Line}(), blk, label)
end

"""
connect

A function to connect OutPort and InPort with a line
"""

function connect(source::OutPort, target::InPort, line::Line)
    push!(source.lines, line)
    target.line = line
end

function connect(source::Nothing, target::InPort, line::Line)
    target.line = line
end

function connect(source::AbstractBlock, target::Nothing, line::Line)
    push!(source.lines, line)
end

"""
toexpr
"""

_toexpr(v::Number) = v
_toexpr(v::Symbol) = v
_toexpr(v::Var) = v.label

"""
ConstantBlock
"""

mutable struct ConstantBlock <: AbstractBlock
    out::OutPort
    value
    
    function ConstantBlock(value)
        blk = new()
        blk.out = OutPort(blk, :out)
        blk.value = value
        blk
    end
end

function _toexpr(blk::ConstantBlock)
    Expr(:block, [Expr(:(=), x.label, _toexpr(blk.value)) for x = blk.out.lines]...)
end

"""
GainBlock
"""

mutable struct GainBlock <: AbstractBlock
    in::InPort
    out::OutPort
    K
    
    function GainBlock(K)
        blk = new()
        blk.in = InPort(blk, :in)
        blk.out = OutPort(blk, :out)
        blk.K = K
        blk
    end
end

function _toexpr(blk::GainBlock)
    tmp = gensym()
    Expr(:block, Expr(:(=), tmp, Expr(:call, :*, _toexpr(blk.K), blk.in.line.label)), [Expr(:(=), x.label, tmp) for x = blk.out.lines]...)
end

"""
InBlock
"""

mutable struct InBlock <: AbstractBlock
    out::OutPort
    label::Symbol
    
    function InBlock(label)
        blk = new()
        blk.out = OutPort(blk, :out)
        blk.label = label
        blk
    end
end

function _toexpr(blk::InBlock)
    Expr(:block, [Expr(:(=), x.label, blk.label) for x = blk.out.lines]...)
end

"""
SystemBlock

The structure to represent a system block.
"""

mutable struct SystemBlock <: AbstractBlock
    name::Symbol
    in::Vector{InPort}
    out::Vector{OutPort}
    blocks::Vector{AbstractBlock}

    SystemBlock(name::Symbol) = new(name, Vector{InPort}(), Vector{OutPort}())
end

function _toexpr(blk::SystemBlock)
    tmp = [gensym() for x = blk.out]
    invars = [p.line.label for p = blk.in]
    outvars = [[x.label for x = p.lines] for p = blk.out]
    body = [Expr(:(=), Expr(:tuple, tmp...), Expr(:call, blk.name, invars...))]
    for (i,x) = enumerate(outvars)
        for v = x
            push!(body, Expr(:(=), v, tmp[i]))
        end
    end
    Expr(:block, body...)
end

function _tofunc(blk::SystemBlock)
    invars = [x.label for x = blk.in]
    l = []
    s = [x for x = blk.in]
    while length(s) != 0
        m = pop!(s)
        push!(l, _toexpr(m))
        for m
    end
    
    # tmp = [gensym() for x = blk.outport]
    # invars = [_toexpr(p) for p = blk.inport]
    # outvars = [_toexpr(p) for p = blk.outport]
    # body = [Expr(:(=), Expr(:tuple, tmp...), Expr(:call, blk.name, invars...))]
    # for (i,x) = enumerate(outvars)
    #     for v = x
    #         push!(body, Expr(:(=), v, tmp[i]))
    #     end
    # end
    # Expr(:block, body...)
end

function tsort(prior::Dict{Symbol,Tuple{Set{Symbol},Set{Symbol}}})
    l = []
    s = [k for (k,(v1,v2)) = prior if length(v1) == 0]
    while length(s) != 0
        n = pop!(s)
        (v1, v2) = prior[n]
        for x = v2
        end
    end
end


# L ← トポロジカルソートした結果を蓄積する空リスト
# S ← 入力辺を持たないすべてのノードの集合

# while S が空ではない do
#     S からノード n を削除する
#     L に n を追加する
#     for each n の出力辺 e とその先のノード m do
#         辺 e をグラフから削除する
#         if m がその他の入力辺を持っていなければ then
#             m を S に追加する

# if グラフに辺が残っている then
#     閉路があり DAG でないので中断

# ---

# L ← トポロジカルソートされた結果の入る空の連結リスト

# for each ノード n do
#     visit(n)

# function visit(Node n)
#     if n をまだ訪れていなければ then
#         n を訪問済みとして印を付ける
#         for each n の出力辺 e とその先のノード m do
#             visit(m)
#         n を L の先頭に追加