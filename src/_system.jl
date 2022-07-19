mutable struct SystemBlockDefinition
    name::Symbol
    parameters::Vector{Tuple{SymbolicValue,Any}}
    inports::Vector{InPort} # TODO: check whether the vector has the ports with same name
    outports::Vector{OutPort} # TODO: check whether the vector has the ports with same name
    stateinports::Vector{InPort} # TODO: check whether the vector has the ports with same name
    stateoutports::Vector{OutPort} # TODO: check whether the vector has the ports with same name
    scopeoutports::Vector{OutPort} # TODO: check whether the vector has the ports with same name
    timeblk::AbstractInBlock
    blks::Vector{AbstractBlock}
    
    function SystemBlockDefinition(name::Symbol)
        b = new(name, Tuple{SymbolicValue,Any}[],
            InPort[], OutPort[],
            InPort[], OutPort[],
            OutPort[], InBlock(inport=InPort(:time), outport=OutPort()), AbstractBlock[])
        addBlock!(b, b.timeblk)
        b
    end
end

function addParameter!(blk::SystemBlockDefinition, x::SymbolicValue)
    push!(blk.parameters, (x, x.name))
end

function addParameter!(blk::SystemBlockDefinition, x::SymbolicValue, y)
    push!(blk.parameters, (x, y))
end

function addBlock!(blk::SystemBlockDefinition, x::AbstractBlock)
    push!(blk.blks, x)
end
    
function addBlock!(blk::SystemBlockDefinition, x::AbstractIntegratorBlock)
    addBlock!(blk, x.inblk)
    addBlock!(blk, x.outblk)
    addBlock!(blk, x.innerblk)
end

function addBlock!(blk::SystemBlockDefinition, x::AbstractTimeBlock)
    push!(blk.blks, x)
    Line(blk.timeblk.outport, get_timeport(x))
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
    Line(blk.timeblk.outport, x.time)
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

"""
Expr for creating a structure for systemblok

An example of structure is
```
mutable struct MSD <: AbstractSystemBlock
    M::Parameter
    D::Parameter
    k::Parameter
    g::Parameter
    time::AbstractInPort
    in1::AbstractInPort
    out1::AbstractOutPort
    sin1::AbstractInPort
    sin2::AbstractInPort
    sout1::AbstractOutPort
    sout2::AbstractOutPort
    inblk::Vector{StateOut}
    outblk::Vector{StateIn}
    scopes::Vector{Scope}
    ## for ode
    parafunc
    ifunc
    sfunc
    ofunc

    function MSD(; M = :M, D = :D, k = :k, g = 9.8,
        time::AbstractInPort = InPort(),
        in1::AbstractInPort = InPort(),
        out1::AbstractOutPort = OutPort(),
        sin1::AbstractInPort = InPort(:sin1),
        sin2::AbstractInPort = InPort(:sin2),
        sout1::AbstractOutPort = OutPort(:sout1),
        sout2::AbstractOutPort = OutPort(:sout2))
        b = new()
        b.M = M
        b.D = D
        b.k = k
        b.g = g
        b.time = time
        b.in1 = in1
        b.time.parent = b
        b.in1.parent = b
        b.out1 = out1
        b.out1.parent = b
        b.outblk = StateIn[]
        begin
            b.sin1 = InPort()
            b.sin1.parent = b
            tmp = StateIn(inport = sin1, outport = OutPort())
            Line(tmp.outport, b.sin1)
            push!(b.outblk, tmp)
        end
        begin
            b.sin2 = InPort()
            b.sin2.parent = b
            tmp = StateIn(inport = sin2, outport = OutPort())
            Line(tmp.outport, b.sin2)
            push!(b.outblk, tmp)
        end
        b.inblk = StateOut[]
        begin
            b.sout1 = OutPort()
            b.sout1.parent = b
            tmp = StateOut(inport = InPort(), outport = sout1)
            Line(b.sout1, tmp.inport)
            push!(b.inblk, tmp)
        end
        begin
            b.sout2 = OutPort()
            b.sout2.parent = b
            tmp = StateOut(inport = InPort(), outport = sout2)
            Line(b.sout2, tmp.inport)
            push!(b.inblk, tmp)
        end
        b.scopes = Scope[]
        b
    end
end
```
"""    

function expr_define_structure(blk::SystemBlockDefinition)
    params = [name(x[1]) for x = blk.parameters]
    ins = [name(p.var) for p = blk.inports]
    outs = [name(p.var) for p = blk.outports]
    sins = [name(p.var) for p = blk.stateinports]
    souts = [name(p.var) for p = blk.stateoutports]
    scopes = [name(p.var) for p = blk.scopeoutports]

    paramdef = [:($x::Parameter) for x = params]
    indef = [:($x::AbstractInPort) for x = ins]
    outdef = [:($x::AbstractOutPort) for x = outs]
    sindef = [:($x::AbstractInPort) for x = sins]
    soutdef = [:($x::AbstractOutPort) for x = souts]
    scopesdef = [:($x::AbstractOutPort) for x = scopes]

    paramdefin = [Expr(:kw, :($(name(x[1])))::Parameter, _toquote(x[2])) for x = blk.parameters]
    indefin = [Expr(:kw, :($x::AbstractInPort), :(InPort())) for x = ins]
    outdefin = [Expr(:kw, :($x::AbstractOutPort), :(OutPort())) for x = outs]
    sindefin = [Expr(:kw, :($x::AbstractInPort), :(InPort($(Expr(:quote, x))))) for x = sins]
    soutdefin = [Expr(:kw, :($x::AbstractOutPort), :(OutPort($(Expr(:quote, x))))) for x = souts]
    scopesdefin = [Expr(:kw, :($x::AbstractOutPort), :(OutPort($(Expr(:quote, x))))) for x = scopes]

    (pfunc, sfunc, ifunc, ofunc) = let
        xparams = [Expr(:kw, name(x[1]), :(p.$(name(x[1])))) for x = blk.parameters]
        xparams_init = [Expr(:call, :(=>), @q(name(x[1])), :(b.$(name(x[1])))) for x = blk.parameters]

        xsins = [Expr(:kw, name(p), :(u[$i])) for (i,p) = enumerate(blk.stateinports)]
        xsins0 = [Expr(:kw, name(p), 0) for (i,p) = enumerate(blk.stateinports)]
        xsins1 = [Expr(:kw, name(p), :(u(t)[$i])) for (i,p) = enumerate(blk.stateinports)]
        xsouts = [:(result.$(name(p))) for p = blk.stateoutports]
        xdus = [:(du[$i]) for (i,_) = enumerate(blk.stateoutports)]

        xscopes = [Expr(:call, :(=>), @q(name(p)), :([x.$(name(p)) for x = result])) for p = blk.scopeoutports]
        
        pfunc = Expr(:->, Expr(:tuple, :b), Expr(:call, :Dict, xparams_init...))

       sfunc = Expr(:->, Expr(:tuple, :du, :u, :p, :t),
                Expr(:block,
                    Expr(:(=), :result, Expr(:call, Symbol(blk.name, "Function"),
                    Expr(:kw, :time, :t), xparams..., xsins...)),
                    Expr(:(=), Expr(:tuple, xdus...), Expr(:tuple, xsouts...))
                )
            )
        ifunc = Expr(:->, Expr(:tuple, :p),
                Expr(:block,
                    Expr(:(=), :result, Expr(:call, Symbol(blk.name, "InitialFunction"),
                        Expr(:kw, :time, 0),
                        xparams...,
                        xsins0...
                    )),
                    Expr(:vect, xsouts...)
                )
            )
        ofunc = Expr(:->, Expr(:tuple, :u, :p, :ts),
                Expr(:block,
                    :(result = [$(Expr(:call, Symbol(blk.name, "Function"), Expr(:kw, :time, :t), xparams..., xsins1...)) for t = ts]),
                    Expr(:call, :Dict, xscopes...)
                )
            )
        (pfunc, sfunc, ifunc, ofunc)
    end

    v = quote
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
            pfunc
            ifunc
            sfunc
            ofunc

            function $(blk.name)(; $(paramdefin...), $(indefin...), $(outdefin...), $(sindefin...), $(soutdefin...), $(scopesdefin...))
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
                    tmp = StateIn(inport=$x, outport=OutPort())
                    Line(tmp.outport, b.$x)
                    push!(b.outblk, tmp)
                end for x = sins]...)
                b.inblk = StateOut[]
                $([quote
                    b.$x = OutPort()
                    b.$x.parent = b
                    tmp = StateOut(inport=InPort(), outport=$x)
                    Line(b.$x, tmp.inport)
                    push!(b.inblk, tmp)
                end for x = souts]...)
                b.scopes = Scope[]
                $([quote
                    b.$x = OutPort()
                    b.$x.parent = b
                    tmp = Scope(inport=InPort(), outport=$x)
                    Line(b.$x, tmp.inport)
                    push!(b.scopes, tmp)
                end for x = scopes]...)
                b.pfunc = $(pfunc)
                b.sfunc = $(sfunc)
                b.ifunc = $(ifunc)
                b.ofunc = $(ofunc)
                b
            end
        end
    end
end

"""
Expr to define the following generic functions for AbstractBlock.
next, should be imported as `import JuliaMBD: next`

- get_inports: Get inports
- get_outports: Get outports
"""

function expr_define_next(blk::SystemBlockDefinition)
    params = [:(b.$(name(x[1]))) for x = blk.parameters]
    ins = [:(b.$(name(p.var))) for p = blk.inports]
    outs = [:(b.$(name(p.var))) for p = blk.outports]
    sins = [:(b.$(name(p.var))) for p = blk.stateinports]
    souts = [:(b.$(name(p.var))) for p = blk.stateoutports]
    scopes = [:(b.$(name(p.var))) for p = blk.scopeoutports]

    quote
        function get_inports(b::$(blk.name))
            $(Expr(:vect, ins..., sins...))
        end

        function get_outports(b::$(blk.name))
            $(Expr(:vect, outs..., souts..., scopes...))
        end
    end
end

"""
Expr to define the generic functions `expr` for AbstractBlock.
expr should be imported as `import JuliaMBD: expr`

- expr: Generate Expr to define the call of systemfunction
"""

function expr_define_expr(blk::SystemBlockDefinition)
    params = [:(b.$(name(x[1]))) for x = blk.parameters]
    ins = [:(b.$(name(p.var))) for p = blk.inports]
    outs = [:(b.$(name(p.var))) for p = blk.outports]
    sins = [:(b.$(name(p.var))) for p = blk.stateinports]
    souts = [:(b.$(name(p.var))) for p = blk.stateoutports]
    scopes = [:(b.$(name(p.var))) for p = blk.scopeoutports]
    
    ps = [expr_kwvalue(p[1], :(expr_refvalue($x))) for (p,x) = zip(blk.parameters, params)]
    args = [expr_kwvalue(p.var, :(expr_refvalue($x.var))) for (p,x) = zip(blk.inports, ins)]
    sargs = [expr_kwvalue(p.var, :(expr_refvalue($x.var))) for (p,x) = zip(blk.stateinports, sins)]
    oos = [:(expr_refvalue($x.var)) for x = outs]
    soos = [:(expr_refvalue($x.var)) for x = souts]
    scoos = [:(expr_refvalue($x.var)) for x = scopes]

    tmp = [Expr(:quote, name(p.var)) for p = blk.stateinports]
    quote
        function expr(b::$(blk.name))
            i = $(Expr(:call, :expr_set_inports, ins..., sins...))
            f = Expr(:(=), Expr(:tuple, $(oos...), $(soos...), $(scoos...)),
                Expr(:call, Symbol($(Expr(:quote, (blk.name))), :Function), $(args...), $(ps...), $(sargs...)))
            o = $(Expr(:call, :expr_set_outports, outs..., souts..., scopes...))
            Expr(:block, i, f, o)
        end

        function expr_initial(b::$(blk.name))
            i = $(Expr(:call, :expr_set_inports, ins..., sins...))
            f = Expr(:(=), Expr(:tuple, $(oos...), $(soos...), $(scoos...)),
                Expr(:call, Symbol($(Expr(:quote, (blk.name))), :InitialFunction), $(args...), $(ps...), $(sargs...)))
            o = $(Expr(:call, :expr_set_outports, outs..., souts..., scopes...))
            Expr(:block, i, f, o)
        end
    end
end

"""
Expr to define the systemfunction of SystemBlock
The toporogical sort `tsort` is used.
"""

function expr_define_function(blk::SystemBlockDefinition)
    params = [expr_defvalue(x) for x = blk.parameters]
    args = [expr_defvalue(p.var) for p = blk.inports]
    sargs = [expr_defvalue(p.var) for p = blk.stateinports]
    outs = [:($(name(p.var)) = $(expr_refvalue(p.var))) for p = blk.outports]
    souts = [:($(name(p.var)) = $(expr_refvalue(p.var))) for p = blk.stateoutports]
    scopes = [:($(name(p.var)) = $(expr_refvalue(p.var))) for p = blk.scopeoutports]

    blks = blk.blks
    body = [expr(b) for b = tsort(blks)]
    Expr(:function, Expr(:call, Symbol(blk.name, "Function"),
            Expr(:parameters, args..., params..., sargs...)),
        Expr(:block, body..., Expr(:tuple, outs..., souts..., scopes...)))
end

"""
Expr to define the initialfunction of SystemBlock
The toporogical sort `tsort` is used.
"""

function expr_define_initialfunction(blk::SystemBlockDefinition)
    params = [expr_defvalue(x) for x = blk.parameters]
    args = [expr_defvalue(p.var) for p = blk.inports]
    sargs = [expr_defvalue(p.var) for p = blk.stateinports]
    outs = [:($(name(p.var)) = $(expr_refvalue(p.var))) for p = blk.outports]
    souts = [:($(name(p.var)) = $(expr_refvalue(p.var))) for p = blk.stateoutports]
    scopes = [:($(name(p.var)) = $(expr_refvalue(p.var))) for p = blk.scopeoutports]

    blks = blk.blks
    body = [expr_initial(b) for b = tsort(blks)]
    Expr(:function, Expr(:call, Symbol(blk.name, "InitialFunction"),
            Expr(:parameters, args..., params..., sargs...)),
        Expr(:block, body..., Expr(:tuple, outs..., souts..., scopes...)))
end

