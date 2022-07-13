mutable struct SystemBlockDefinition
    name::Symbol
    parameters::Vector{SymbolicValue}
    inports::Vector{InPort}
    outports::Vector{OutPort}
    stateinports::Vector{InPort}
    stateoutports::Vector{OutPort}
    scopeoutports::Vector{OutPort}
    blks::Vector{AbstractBlock}
    
    function SystemBlockDefinition(name::Symbol)
        new(name, SymbolicValue[],
            InPort[], OutPort[],
            InPort[], OutPort[],
            OutPort[], AbstractBlock[])
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

function addBlock!(blk::SystemBlockDefinition, x::AbstractSystemBlock)
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
end

function addBlock!(blk::SystemBlockDefinition, x::InBlock)
    push!(blk.blks, x)
    push!(blk.inports, x.inport)
end

function addBlock!(blk::SystemBlockDefinition, x::OutBlock)
    push!(blk.blks, x)
    push!(blk.outports, x.outport)
end

function addBlock!(blk::SystemBlockDefinition, x::StateIn)
    push!(blk.blks, x)
    push!(blk.stateinports, x.inport)
end

function addBlock!(blk::SystemBlockDefinition, x::StateOut)
    push!(blk.blks, x)
    push!(blk.stateoutports, x.outport)
end

function addBlock!(blk::SystemBlockDefinition, x::Scope)
    push!(blk.blks, x)
    push!(blk.scopeoutports, x.outport)
end

# function define(blk::SystemBlockDefinition)
#     quote
#         import JuliaMBD: next, expr
#         $(expr_define_function(blk))
#         $(expr_define_structure(blk))
#         $(expr_define_next(blk))
#         $(expr_define_expr(blk))
#     end
# end

# macro define(x)
#     esc(:(eval(define($x))))
# end

function expr_define_function(blk::SystemBlockDefinition)
    params = [expr_defvalue(x) for x = blk.parameters]
    args = [expr_defvalue(p.var) for p = blk.inports]
    sargs = [expr_defvalue(p.var) for p = blk.stateinports]
    outs = [:($(p.var.name) = $(expr_refvalue(p.var))) for p = blk.outports]
    souts = [:($(p.var.name) = $(expr_refvalue(p.var))) for p = blk.stateoutports]
    scopes = [:($(p.var.name) = $(expr_refvalue(p.var))) for p = blk.scopeoutports]
    body = [expr(b) for b = tsort(blk.blks)]
    Expr(:function, Expr(:call, Symbol(blk.name, "Func"),
            Expr(:parameters, args..., params..., sargs...)),
        Expr(:block, body..., Expr(:tuple, outs..., souts..., scopes...)))
end

function expr_define_structure(blk::SystemBlockDefinition)
    params = [x.name for x = blk.parameters]
    ins = [p.var.name for p = blk.inports]
    outs = [p.var.name for p = blk.outports]
    sins = [p.var.name for p = blk.stateinports]
    souts = [p.var.name for p = blk.stateoutports]
    scopes = [p.var.name for p = blk.scopeoutports]

    paramdef = [:($x::Parameter) for x = params]
    indef = [:($x::AbstractInPort) for x = ins]
    outdef = [:($x::AbstractOutPort) for x = outs]
    sindef = [:($x::AbstractInPort) for x = sins]
    soutdef = [:($x::AbstractOutPort) for x = souts]
    scopesdef = [:($x::AbstractOutPort) for x = scopes]

    quote
        mutable struct $(blk.name) <: AbstractSystemBlock
            $(paramdef...)
            $(indef...)
            $(outdef...)
            $(sindef...)
            $(soutdef...)
            $(scopesdef...)
            inblk::Vector{StateOut}
            outblk::Vector{StateIn}
            scopes::Vector{Scope}

            function $(blk.name)(; $(paramdef...), $(indef...), $(outdef...))
                b = new()
                $([:(b.$x = $x) for x = params]...)
                $([:(b.$x = $x) for x = ins]...)
                $([:(b.$x.parent = b) for x = ins]...)
                $([:(b.$x = $x) for x = outs]...)
                $([:(b.$x.parent = b) for x = outs]...)

                b.outblk = StateIn[]
                $([quote
                    b.$x = InPort()
                    b.$x.parent = b
                    tmp = StateIn(inport=InPort($(Expr(:quote, x))), outport=OutPort())
                    Line(tmp.outport, b.$x)
                    push!(b.outblk, tmp)
                end for x = sins]...)
                b.inblk = StateOut[]
                $([quote
                    b.$x = OutPort()
                    b.$x.parent = b
                    tmp = StateOut(inport=InPort(), outport=OutPort($(Expr(:quote, x))))
                    Line(b.$x, tmp.inport)
                    push!(b.inblk, tmp)
                end for x = souts]...)
                b.scopes = Scope[]
                $([quote
                    b.$x = OutPort()
                    b.$x.parent = b
                    tmp = Scope(inport=InPort(), outport=OutPort($(Expr(:quote, x))))
                    Line(b.$x, tmp.inport)
                    push!(b.scopes, tmp)
                end for x = scopes]...)
                b
            end    
        end
    end
end

function expr_define_next(blk::SystemBlockDefinition)
    outs = [p.var.name for p = blk.outports]
    souts = [p.var.name for p = blk.stateoutports]
    scopes = [p.var.name for p = blk.scopeoutports]

    body = [quote
        for line = b.$x.lines
            push!(s, line.dest.parent)
        end
    end for x = outs]

    sbody = [quote
        for line = b.$x.lines
            push!(s, line.dest.parent)
        end
    end for x = souts]

    scbody = [quote
        for line = b.$x.lines
            push!(s, line.dest.parent)
        end
    end for x = scopes]

    quote
        function next(b::$(blk.name))
            s = AbstractBlock[]
            $(body...)
            $(sbody...)
            $(scbody...)
            s
        end
    end
end

function expr_define_expr(blk::SystemBlockDefinition)
    params = [:(b.$(x.name)) for x = blk.parameters]
    ins = [:(b.$(p.var.name)) for p = blk.inports]
    outs = [:(b.$(p.var.name)) for p = blk.outports]
    sins = [:(b.$(p.var.name)) for p = blk.stateinports]
    souts = [:(b.$(p.var.name)) for p = blk.stateoutports]
    scopes = [:(b.$(p.var.name)) for p = blk.scopeoutports]

    bodyin = [:(push!(i, expr_setvalue($x.var, expr_refvalue($x.line.var)))) for x = ins]
    sbodyin = [:(push!(i, expr_setvalue($x.var, expr_refvalue($x.line.var)))) for x = sins]

    bodyout = [quote
        for line = $x.lines
            push!(o, expr_setvalue(line.var, expr_refvalue($x.var)))
        end
    end for x = outs]
    sbodyout = [quote
        for line = $x.lines
            push!(o, expr_setvalue(line.var, expr_refvalue($x.var)))
        end
    end for x = souts]
    scbodyout = [quote
        for line = $x.lines
            push!(o, expr_setvalue(line.var, expr_refvalue($x.var)))
        end
    end for x = scopes]
    
    ps = [expr_kwvalue(p, :(expr_refvalue($x))) for (p,x) = zip(blk.parameters, params)]
    args = [expr_kwvalue(p.var, :(expr_refvalue($x.var))) for (p,x) = zip(blk.inports, ins)]
    sargs = [expr_kwvalue(p.var, :(expr_refvalue($x.var))) for (p,x) = zip(blk.stateinports, sins)]
    oos = [:(expr_refvalue($x.var)) for x = outs]
    soos = [:(expr_refvalue($x.var)) for x = souts]
    scoos = [:(expr_refvalue($x.var)) for x = scopes]

    quote
        function expr(b::$(blk.name))
            i = Expr[]
            $(bodyin...)
            $(sbodyin...)
            f = Expr(:(=), Expr(:tuple, $(oos...), $(soos...), $(scoos...)),
                Expr(:call, Symbol($(blk.name), :Func), $(args...), $(ps...), $(sargs...)))
            o = Expr[]
            $(bodyout...)
            $(sbodyout...)
            $(scbodyout...)
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