### A Pluto.jl notebook ###
# v0.19.29

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ f751c23b-42db-4d18-a4a4-5fe3845824bc
using Pkg

# ╔═╡ 6a802234-83d2-47a3-b731-eae0a9ffcd87
Pkg.add("PlutoUI")

# ╔═╡ 4dd766c6-8e94-41b4-b3bc-158308fb9cd6
Pkg.add(url="https://github.com/JuliaMBD/JuliaMBD.git")

# ╔═╡ 960c0c2c-7059-11ee-3dd3-635406458bb4
using DifferentialEquations

# ╔═╡ 4b4e3932-5328-4450-a126-890b5e146fe8
using Plots

# ╔═╡ 51d67969-096c-4adb-a93d-7572c8606f27
using PlutoUI

# ╔═╡ 706cbed4-c33b-4d51-a25e-96a90be31dc2
using JuliaMBD

# ╔═╡ 56c88157-09ac-4cba-832f-54a657d47e6e
@model RLC begin
    @parameter begin
        R
        L
        C
    end

    @block begin
        int1 = Integrator()
        int2 = Integrator()
        in1 = Inport(:in)
        out1 = Outport(:out)
        gain1 = Gain(K = R)
        gain2 = Gain(K = 1/C)
        gain3 = Gain(K = 1/L)
        sum1 = Add(signs=[:+, :-, :-])
    end

    @connect begin
        in1.out => sum1.in1
        gain1.out => sum1.in2
        int1.out => sum1.in3
        sum1.out => gain3.in
        gain3.out => int2.in
        int2.out => out1.in
        int2.out => gain1.in
        int2.out => gain2.in
        gain2.out => int1.in
    end
end

# ╔═╡ bd082037-6f7d-4cc8-94b1-a8c2586d78b8
@model Test begin
    @parameter begin
        R
        L
        C
        voltage
    end

    @block begin
        system = RLC(R=R, L=L, C=C)
        source = Step(steptime=0.1, finalvalue=voltage)
    end

    @connect begin
        source.out => system.in
    end

    @scope begin
        source.out => v
        system.out => i
    end
end

# ╔═╡ 45e85dd2-52b6-469a-ac46-c55fbf05b0ce
begin
	t_slider = @bind t Slider(1:0.1:10)
	md"t: ($t_slider) <- touch me"
end

# ╔═╡ e879aaf8-3826-4ad5-86d2-b7fa26f0de3a
begin
	m = @compile Test(R=t, L=100e-3, C=10e-6, voltage=5);
	result = JuliaMBD.simulate(m, tspan=(0,0.5), alg=DifferentialEquations.Tsit5());
	plot(result)
end

# ╔═╡ Cell order:
# ╠═960c0c2c-7059-11ee-3dd3-635406458bb4
# ╠═4b4e3932-5328-4450-a126-890b5e146fe8
# ╠═f751c23b-42db-4d18-a4a4-5fe3845824bc
# ╠═6a802234-83d2-47a3-b731-eae0a9ffcd87
# ╠═4dd766c6-8e94-41b4-b3bc-158308fb9cd6
# ╠═51d67969-096c-4adb-a93d-7572c8606f27
# ╠═706cbed4-c33b-4d51-a25e-96a90be31dc2
# ╠═56c88157-09ac-4cba-832f-54a657d47e6e
# ╠═bd082037-6f7d-4cc8-94b1-a8c2586d78b8
# ╠═45e85dd2-52b6-469a-ac46-c55fbf05b0ce
# ╠═e879aaf8-3826-4ad5-86d2-b7fa26f0de3a
