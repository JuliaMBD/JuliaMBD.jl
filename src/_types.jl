export Auto

abstract type AbstractComponent end
abstract type AbstractBlock <: AbstractComponent end
abstract type AbstractCompositeBlock <: AbstractBlock end
abstract type AbstractSimpleBlock <: AbstractBlock end

abstract type AbstractPortBlock <: AbstractComponent end
abstract type AbstractInPortBlock <: AbstractPortBlock end
abstract type AbstractOutPortBlock <: AbstractPortBlock end
abstract type AbstractParameterPortBlock <: AbstractInPortBlock end

abstract type AbstractSignal <: AbstractComponent end
abstract type AbstractLineSignal <: AbstractSignal end
abstract type AbstractConstSignal <: AbstractSignal end
abstract type AbstractJumpSignal <: AbstractLineSignal end

const Auto = Any

struct UndefBlock <: AbstractBlock end
struct UndefPort <: AbstractPortBlock end
struct UndefSignal <: AbstractSignal end

const undefset = Set([UndefBlock(), UndefPort(), UndefSignal()])
