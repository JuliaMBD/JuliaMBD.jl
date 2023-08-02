get_default_inport(p::AbstractInPort) = p
get_default_inport(p::AbstractOutPort) = get_default_inport(p.parent)
get_default_outport(p::AbstractOutPort) = p
get_default_outport(p::AbstractInPort) = get_default_outport(p.parent)
get_default_inport(blk::AbstractBlock) = blk.inports[1]
get_default_outport(blk::AbstractBlock) = blk.outports[1]
get_default_inport(blk::Nothing) = Nothing
get_default_outport(blk::Nothing) = Nothing

get_inports(blk::AbstractBlock) = blk.inports
get_outports(blk::AbstractBlock) = blk.outports
