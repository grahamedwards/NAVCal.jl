### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ dd39968d-ede0-40a3-a384-89cd5fe9e1f2
try
	import CairoMakie as Makie 
	using NAVCal, PlutoUI
catch 
	import Pkg
	Pkg.add(url="https://github.com/grahamedwards/NAVCal.jl")
	Pkg.add("CairoMakie")
	Pkg.add("PlutoUI")
	import CairoMakie as Makie
	using NAVCal, PlutoUI
end

# ╔═╡ 3efb1c2d-caab-437a-a3e8-8a73dbb6e0ec
html"""
<style>
input[type*="range"] {
	width: 90%;
}
</style>
"""

# ╔═╡ 21c6d1ae-1f2e-4da1-b3fa-4153d3cf7749
md"
# NAVC core matching


"

# ╔═╡ 6b77d944-1f30-4a54-9d98-d5346a7d4286
DownloadButton("1, 1.9\n2, 1.0\n3, 1.2\n4, 4.4\n5, 2.8\n6, 2.5\n7, 2.9\n8, 3.2\n9, 1.2\n10, 1.3\n11, 1.5\n12, 2.5\n13, 5.0\n14, 10.2\n15, 2.8\n16, 2.1\n17, 1.7\n18, 0.0\n19, 0.0\n20, 2.3\n21, 1.2","example-data.csv")

# ╔═╡ 7005783b-9dd7-429f-bcc0-7123858ca9a7
@bind coredata_read FilePicker()

# ╔═╡ 897b063e-85f2-4d75-8d9d-10f8601b80c0
coredata = if isnothing(coredata_read)
	(; x=1:5, y=[3.5,4.2, 2.8, 3.3, 3.6])
else
	cda = NAVCal.DelimitedFiles.readdlm(IOBuffer(coredata_read["data"]), ',', Float64)
	(x=cda[:,1], y=cda[:,2])
end

# ╔═╡ 5afcd016-1108-47c0-b1cd-7fd83bc33d9d
@bind navcdata Select([KelseyFerguson() => "Kelsey Ferguson", MillBrook() => "Mill Brook", RiverRoad() => "River Road", WellsRiver(1) => "Wells River 1A", WellsRiver(5) => "Wells River 2A", WellsRiver(2) => "Wells River 1B", WellsRiver(3) => "Wells River 1C", WellsRiver(4) => "Wells River 1D"])

# ╔═╡ 214a6a5d-850f-4a7d-bdf0-e610f027e2d2
x["Kelsey Ferguson"]

# ╔═╡ 39eef177-61dc-4b62-a053-4e9b16f0dcd8
md"Normalize varve thickness (recommended)"

# ╔═╡ bf494615-3298-4526-8437-806593d1be61
@bind normalized CheckBox(default=true)

# ╔═╡ b8b29e9f-04f0-4ea6-b2e6-992929978087
md"Amplitude core data"

# ╔═╡ 59b373d2-439e-4dbd-b9c5-0c0c4383c74f
@bind coreamp Slider(LinRange(0,2,21), default=1, show_value=false)

# ╔═╡ 58da7af4-e9d2-4c66-b002-e16c8b93ea8b
md"Zoom (NAVC record): In $\longleftrightarrow$ Out"

# ╔═╡ 102e94ba-b0b5-4f67-b3ea-a28d173d6115
@bind yrscale Slider(LinRange(ifelse(isnothing(coredata), 2, length(coredata.x))/length(navcdata.a),1,length(navcdata.a)), default=1, show_value=false)

# ╔═╡ 130a7390-f571-4ca6-aa89-5ccbbcaa6cd0
md"Timeseries start (NAVC varve year)"

# ╔═╡ 708ac696-eeda-4750-a5f0-69fedc1af32e
@bind yrstart Slider(firstindex(navcdata.a):lastindex(navcdata.a), default=firstindex(navcdata.a), show_value=false)

# ╔═╡ 08a885cb-4812-4443-afe7-88f8dbdd0086
md"Core basal age (NAVC varve year)"

# ╔═╡ 9bc5168f-b477-45a7-9131-c41f1820ed82
@bind corestart Slider(first(navcdata.a):last(navcdata.a), default = 0, show_value=true)

# ╔═╡ 5e07fbb4-d678-4e7f-8e97-5695bda02618
corelabel= "

# ╔═╡ 6c42d1b7-0008-413a-a31a-803fd3cdbec7
navclabel="NAVC record name"

# ╔═╡ 83e88f1c-7f53-4f95-bfe5-530fa1c45b80
let

	ycore, ynavc = if normalized
		copy(coredata.y) .- (sum(coredata.y)/length(coredata.y)), copy(navcdata.z) .- (sum(navcdata.z)/length(navcdata.z))
	else
		coredata.y, navcdata.z
	end

	yrstop = round(Int, (lastindex(navcdata.a)-firstindex(navcdata.a))*yrscale)-1 + yrstart
	yrstop = ifelse(yrstop>lastindex(navcdata.a), lastindex(navcdata.a), yrstop)

	xnavc, ynavc = navcdata.a[yrstart:yrstop], ynavc[yrstart:yrstop]
	
	f= Makie.Figure(size=(1200,400))
	ax = Makie.Axis(f[1,1], xlabel="NAVC year", ylabel=ifelse(normalized,"normalized ", "")*"varve thickness (cm)")
	Makie.lines!(ax, xnavc, ynavc, label=navclabel, color=:dodgerblue4)

	if !isnothing(coredata)
		Makie.lines!(ax, coredata.x .+ (corestart-1), coreamp .* ycore, color=:goldenrod)
	end
	Makie.axislegend(ax)
	f
end |> WideCell

# ╔═╡ Cell order:
# ╟─3efb1c2d-caab-437a-a3e8-8a73dbb6e0ec
# ╠═21c6d1ae-1f2e-4da1-b3fa-4153d3cf7749
# ╠═dd39968d-ede0-40a3-a384-89cd5fe9e1f2
# ╟─6b77d944-1f30-4a54-9d98-d5346a7d4286
# ╟─7005783b-9dd7-429f-bcc0-7123858ca9a7
# ╠═897b063e-85f2-4d75-8d9d-10f8601b80c0
# ╠═5afcd016-1108-47c0-b1cd-7fd83bc33d9d
# ╠═214a6a5d-850f-4a7d-bdf0-e610f027e2d2
# ╟─39eef177-61dc-4b62-a053-4e9b16f0dcd8
# ╟─bf494615-3298-4526-8437-806593d1be61
# ╟─b8b29e9f-04f0-4ea6-b2e6-992929978087
# ╟─59b373d2-439e-4dbd-b9c5-0c0c4383c74f
# ╟─58da7af4-e9d2-4c66-b002-e16c8b93ea8b
# ╟─102e94ba-b0b5-4f67-b3ea-a28d173d6115
# ╠═83e88f1c-7f53-4f95-bfe5-530fa1c45b80
# ╟─130a7390-f571-4ca6-aa89-5ccbbcaa6cd0
# ╟─708ac696-eeda-4750-a5f0-69fedc1af32e
# ╟─08a885cb-4812-4443-afe7-88f8dbdd0086
# ╟─9bc5168f-b477-45a7-9131-c41f1820ed82
# ╠═5e07fbb4-d678-4e7f-8e97-5695bda02618
# ╟─6c42d1b7-0008-413a-a31a-803fd3cdbec7
