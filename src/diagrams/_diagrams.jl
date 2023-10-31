module Diagram

using EzXML
using JSON

import ..JuliaMBD

include("_model2xml.jl")
include("_xml2model.jl")

end