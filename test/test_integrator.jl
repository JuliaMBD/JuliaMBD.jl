
import JuliaMBD

@testset "integrator" begin
    b = Integrator(statein=InPort(:sin), stateout=OutPort(:sout), inport=InPort(), outport=OutPort(Float64))
    println(b)
end

@testset "integrator2" begin
    b0 = Constant(value=Value(1), outport=OutPort(Float64))
    b1 = Integrator(statein=InPort(:sin), stateout=OutPort(:sout), inport=InPort(), outport=OutPort())
    b3 = Out(inport=InPort(), outport=OutPort())
    Line(b0.outport, b1.inport)
    Line(b1.outport, b3.inport)
    println(b1)
    [println(expr(b)) for b = JuliaMBD.tsort([b1.inblk,b1.outblk,b3,b0])]
end

@testset "integrator3" begin
    b0 = Constant(value=Value(1), outport=OutPort(Float64))
    b1 = Integrator(statein=InPort(:sin), stateout=OutPort(:sout), inport=InPort(), outport=OutPort())
    b3 = Out(inport=InPort(), outport=OutPort())
    Line(b0.outport, b1.inport)
    Line(b1.outport, b3.inport)

    b = SystemBlockDefinition(:TestBlock)
    addBlock!(b, b0)
    addBlock!(b, b1)
    addBlock!(b, b3)

    println(expr_define_function(b))
end
