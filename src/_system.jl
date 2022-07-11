mutable struct SystemBlockDefinition
    name::Symbol
    parameters::Vector{SymbolicValue}
    inports::Vector{InPort}
    outports::Vector{OutPort}
    stateinports::Vector{InPort}
    stateoutports::Vector{OutPort}
    blks::Vector{AbstractBlock}
    
    function SystemBlockDefinition(name::Symbol)
        new(name, SymbolicValue[], InPort[], OutPort[], InPort[], OutPort[], AbstractBlock[])
    end
end

function addParameter!(blk::SystemBlockDefinition, x::SymbolicValue)
    push!(blk.parameters, x)
end

function addBlock!(blk::SystemBlockDefinition, x::AbstractBlock)
    push!(blk.blks, x)
end
    
function addBlock!(blk::SystemBlockDefinition, x::AbstractIntegratorBlock)
    addBlock!(blk, x.inblk)
    addBlock!(blk, x.outblk)
end

function addBlock!(blk::SystemBlockDefinition, x::In)
    push!(blk.blks, x)
    push!(blk.inports, x.inport)
end

function addBlock!(blk::SystemBlockDefinition, x::Out)
    push!(blk.blks, x)
    push!(blk.outports, x.outport)
end

function addBlock!(blk::SystemBlockDefinition, x::StateIn)
    push!(blk.blks, x)
    push!(blk.inports, x.inport)
    push!(blk.stateinports, x.inport)
end

function addBlock!(blk::SystemBlockDefinition, x::StateOut)
    push!(blk.blks, x)
    push!(blk.outports, x.outport)
    push!(blk.stateoutports, x.outport)
end

# function expr_define_systemfunction(blk::SystemBlockDefinition)
#     params = [expr_defvalue(x) for x = blk.parameters]
#     args = []
#     outs = []

#     # remove independent blocks
#     systemblks = AbstractBlock[x.parent for x = blk.stateoutports]
#     for b = reverse(tsort(blk.blks))
#         if b in systemblks || !isempty(intersect(next(b), systemblks))
#             pushfirst!(systemblks, b)
#             if typeof(b) <: AbstractInBlock
#                 pushfirst!(args, expr_defvalue(b.inport.var))
#             elseif typeof(b) <: AbstractOutBlock
#                 pushfirst!(outs, expr_refvalue(b.outport.var))
#             end
#         end
#     end
#     body = [expr(b) for b = systemblks]
#     Expr(:function, Expr(:call, Symbol(blk.name, "SystemFunc"),
#             Expr(:parameters, args..., params...)),
#         Expr(:block, body..., Expr(:tuple, outs...)))
# end

function expr_define_function(blk::SystemBlockDefinition)
    params = [expr_defvalue(x) for x = blk.parameters]
    args = [expr_defvalue(p.var) for p = blk.inports]
    outs = [expr_refvalue(p.var) for p = blk.outports]
    # sargs = [expr_defvalue(p.var) for p = blk.stateinports]
    # souts = [expr_refvalue(p.var) for p = blk.stateoutports]
    body = [expr(b) for b = tsort(blk.blks)]
    Expr(:function, Expr(:call, Symbol(blk.name, "Func"),
            Expr(:parameters, args..., params...)),
        Expr(:block, body..., Expr(:tuple, outs...)))
end

function expr_define_structure(blk::SystemBlockDefinition)
    params = [x.name for x = blk.parameters]
    ins = [p.var.name for p = blk.inports]
    outs = [p.var.name for p = blk.outports]

    paramdef = [:($x::Parameter) for x = params]
    indef = [:($x::AbstractInPort) for x = ins]
    outdef = [:($x::AbstractOutPort) for x = outs]

    quote
        mutable struct $(blk.name) <: AbstractBlock
            $(paramdef...)
            $(indef...)
            $(outdef...)

            function $(blk.name)(; $(paramdef...), $(indef...), $(outdef...))
                b = new()
                $([:(b.$x = $x) for x = params]...)
                $([:(b.$x = $x) for x = ins]...)
                $([:(b.$x = $x) for x = outs]...)
                $([:(b.$x.parent = b) for x = ins]...)
                $([:(b.$x.parent = b) for x = outs]...)
                b
            end    
        end
    end
end

function expr_define_next(blk::SystemBlockDefinition)
    outs = [p.var.name for p = blk.outports]

    # body = [Expr(:for, Expr(:(=), :line, Expr(:., Expr(:., :b, Expr(:quote, x)), Expr(:quote, :lines))),
    # Expr(:block,
    #     Expr(:call, :push!, :s, Expr(:., Expr(:., :line, Expr(:quote, :dest)), Expr(:quote, :parent)))
    #     )) for x = outs]

    # Expr(:function, Expr(:call, :next, Expr(:(::), :b, blk.name)),
    #     Expr(:block,
    #         Expr(:(=), :s, Expr(:ref, :AbstractBlock)), body..., :s))

    body = [quote
        for line = b.$x.lines
            push!(s, line.dest.parent)
        end
    end for x = outs]

    quote
        function next(b::$(blk.name))
            s = AbstractBlock[]
            $(body...)
            s
        end
    end
end

function expr_define_expr(blk::SystemBlockDefinition)
    # params = [Expr(:., :b, Expr(:quote, x.name)) for x = blk.parameters]
    # ins = [Expr(:., :b, Expr(:quote, p.var.name)) for p = blk.inports]
    # outs = [Expr(:., :b, Expr(:quote, p.var.name)) for p = blk.outports]
    
    # expr_setvalue(blk.inport.var, expr_refvalue(blk.inport.line.var))
    # bodyin = [Expr(:call, :push!, :i,
    #     Expr(:call, :expr_setvalue, Expr(:., x, Expr(:quote, :var)),
    #         Expr(:call, :expr_refvalue, Expr(:., Expr(:., x, Expr(:quote, :line)), Expr(:quote, :var))))) for x = ins]

    # for line = blk.outport.lines
    #   push!(o, expr_setvalue(line.var, expr_refvalue(blk.outport.var)))
    # end

    # bodyout = [Expr(:for, Expr(:(=), :line, Expr(:., x, Expr(:quote, :lines))),
    #         Expr(:block,
    #             Expr(:call, :push!, :o,
    #     Expr(:call, :expr_setvalue, Expr(:., :line, Expr(:quote, :var)),
    #         Expr(:call, :expr_refvalue, Expr(:., x, Expr(:quote, :var))))))) for x = outs]
    
    # args = [expr_kwvalue(p.var, Expr(:call, :expr_refvalue, Expr(:., x, Expr(:quote, :var)))) for (p,x) = zip(blk.inports, ins)]
    # ps = [expr_kwvalue(p, Expr(:call, :expr_refvalue, x)) for (p,x) = zip(blk.parameters, params)]
    # oos = [Expr(:call, :expr_refvalue, Expr(:., x, Expr(:quote, :var))) for x = outs]

    # f = Expr(:(=), Expr(:tuple, :a, :b), Expr(:call, :xxx, Expr(:kw, t, expr_refvalue(b.t))))
    # fbody = Expr(:(=), :f,
    #     Expr(:call, :Expr, Expr(:quote, :(=)),
    #         Expr(:call, :Expr, Expr(:quote, :tuple), oos...),
    #         Expr(:call, :Expr, Expr(:quote, :call),
    #     Expr(:call, :Symbol, Expr(:quote, blk.name), Expr(:quote, :Func)), args..., ps...)))

    # Expr(:function, Expr(:call, :expr, Expr(:(::), :b, blk.name)),
    # Expr(:block,
    #     Expr(:(=), :i, Expr(:ref, :Expr)),
    #     bodyin...,
    #     fbody,
    #     Expr(:(=), :o, Expr(:ref, :Expr)),
    #     bodyout...,
    #     Expr(:call, :Expr, Expr(:quote, :block), Expr(:..., :i), :f, Expr(:..., :o))
    # ))
    # Expr(:function, Expr(:call, :expr, Expr(:(::), :b, blk.name)),
    # Expr(:block,
    #     Expr(:(=), :i, Expr(:ref, :Expr)),
    #     bodyin...,
    #     fbody,
    #     Expr(:(=), :o, Expr(:ref, :Expr)),
    #     bodyout...,
    #     Expr(:call, :Expr, Expr(:quote, :block), Expr(:..., :i), :f, Expr(:..., :o))
    # ))

    params = [:(b.$(x.name)) for x = blk.parameters]
    ins = [:(b.$(p.var.name)) for p = blk.inports]
    outs = [:(b.$(p.var.name)) for p = blk.outports]

    bodyin = [:(push!(i, expr_setvalue($x.var, expr_refvalue($x.line.var)))) for x = ins]

    bodyout = [quote
        for line = $x.lines
            push!(o, expr_setvalue(line.var, expr_refvalue($x.var)))
        end
    end for x = outs]
    
    args = [expr_kwvalue(p.var, :(expr_refvalue($x.var))) for (p,x) = zip(blk.inports, ins)]
    ps = [expr_kwvalue(p, :(expr_refvalue($x))) for (p,x) = zip(blk.parameters, params)]
    oos = [:(expr_refvalue($x.var)) for x = outs]

    quote
        function expr(b::$(blk.name))
            i = Expr[]
            $(bodyin...)
            f = Expr(:(=), Expr(:tuple, $(oos...)), Expr(:call, Symbol($(blk.name), :Func), $(args...), $(ps...)))
            o = Expr[]
            $(bodyout...)
            Expr(:block, i..., f, o...)
        end
    end
end

"""
tsort

Tomprogical sort to determine the sequence of expression in SystemBlock
"""

function expr(blks::Vector{AbstractBlock})
    Expr(:block, [expr(x) for x = tsort(blks)]...)
end

function tsort(blks::Vector{AbstractBlock})
    l = []
    check = Dict([n => 0 for n = blks])
    for n = blks
        if check[n] != 2
            _visit(n, check, l)
        end
    end
    l
end

function _visit(n, check, l)
    if check[n] == 1
        throw(ErrorException("DAG has a closed path"))
    elseif check[n] == 0
        check[n] = 1
        for m = next(n)
            _visit(m, check, l)
        end
        check[n] = 2
        pushfirst!(l, n)
    end
end