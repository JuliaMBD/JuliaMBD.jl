import Base

Base.show(io::IO, x::AbstractBlock) = Base.show(io, "Block($(x.name))")
Base.show(io::IO, x::AbstractInPort) = Base.show(io, "InPort($(x.name))")
Base.show(io::IO, x::AbstractOutPort) = Base.show(io, "OutPort($(x.name))")
Base.show(io::IO, x::AbstractParameterPort) = Base.show(io, "Parameter($(x.name))")
Base.show(io::IO, x::AbstractLineSignal) = Base.show(io, "Line($(x.name))")

