export Saturation

function Saturation(;
    in = InPort(),
    out = OutPort(),
    upperlimit = ParameterPort(),
    lowerlimit = ParameterPort())
    b = SimpleBlock(:Saturation)
    set!(b, :in, in)
    set!(b, :out, out)
    set!(b, :upperlimit, upperlimit)
    set!(b, :lowerlimit, lowerlimit)
    b
end

function expr(b::SimpleBlock, ::Val{:Saturation})
    in = b.inports[1].name
    out = b.outports[1].name
    upperlimit = b.env[:upperlimit].name
    lowerlimit = b.env[:lowerlimit].name
    quote
        $out = if $in <= $lowerlimit
            $lowerlimit
        elseif $in >= $upperlimit
            $upperlimit
        else
            $in
        end
    end
end
