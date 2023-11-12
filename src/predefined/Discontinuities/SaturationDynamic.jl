export SaturationDynamic

function SaturationDynamic(;
    u = InPort(),
    up = InPort(),
    lo = InPort(),
    y = OutPort())
    b = SimpleBlock(:SaturationDynamic)
    setport!(b, :in, u)
    setport!(b, :up, up)
    setport!(b, :lo, lo)
    setport!(b, :out, y)
    b
end

function expr(b::SimpleBlock, ::Val{:SaturationDynamic})
    u = b.env[:in].name
    y = b.env[:out].name
    up = b.env[:up].name
    lo = b.env[:lo].name
    quote
        $y = if $u <= $lo
            $lo
        elseif $u >= $up
            $up
        else
            $u
        end
    end
end
