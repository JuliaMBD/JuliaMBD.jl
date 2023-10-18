export SaturationDynamic

function SaturationDynamic(;
    u = InPort(),
    up = InPort(),
    lo = InPort(),
    y = OutPort())
    b = SimpleBlock(:SaturationDynamic)
    set!(b, :u, u)
    set!(b, :up, up)
    set!(b, :lo, lo)
    set!(b, :y, y)
    b
end

function expr(b::SimpleBlock, ::Val{:SaturationDynamic})
    u = b.env[:u].name
    y = b.env[:y].name
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
