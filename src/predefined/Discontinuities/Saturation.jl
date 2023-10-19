export Saturation

function Saturation(;
    in = InPort(),
    out = OutPort(),
    upperlimit = Float64(0),
    lowerlimit = Float64(0))
    b = SimpleBlock(:Saturation)
    setport!(b, :in, in)
    setport!(b, :out, out)
    setparameter!(b, :upperlimit, upperlimit)
    setparameter!(b, :lowerlimit, lowerlimit)
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
