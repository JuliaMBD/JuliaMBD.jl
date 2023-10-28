export Auto

abstract type AbstractComponent end
abstract type AbstractBlock <: AbstractComponent end
abstract type AbstractCompositeBlock <: AbstractBlock end
abstract type AbstractSimpleBlock <: AbstractBlock end

abstract type AbstractPort <: AbstractComponent end
abstract type AbstractInPort <: AbstractPort end
abstract type AbstractOutPort <: AbstractPort end
abstract type AbstractParameterPort <: AbstractInPort end

abstract type AbstractSignal <: AbstractComponent end
abstract type AbstractLineSignal <: AbstractSignal end
abstract type AbstractConstSignal <: AbstractSignal end
abstract type AbstractJumpSignal <: AbstractLineSignal end

const Auto = Any

struct UndefBlock <: AbstractBlock end
struct UndefPort <: AbstractPort end
struct UndefSignal <: AbstractSignal end

const undefset = Set([UndefBlock(), UndefPort(), UndefSignal()])
