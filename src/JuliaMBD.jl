module JuliaMBD

export ContinuousSignal
export GainBlock, SystemBlock, InBlock, OutBlock
export connect
export InPort, OutPort
export generate_instance, generate_definition
export add_block

include("_blocknew.jl")

end
