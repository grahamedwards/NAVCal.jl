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
	using NAVCal, PlutoUI;
catch 
	import Pkg
	Pkg.add(url="https://github.com/grahamedwards/NAVCal.jl")
	Pkg.add("CairoMakie")
	Pkg.add("PlutoUI")
	import CairoMakie as Makie
	using NAVCal, PlutoUI;
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

## Instructions
Follow the steps below to match your core with a calibrated NAVC sequence. 

### 1. Upload your core data
"

# ╔═╡ 7005783b-9dd7-429f-bcc0-7123858ca9a7
@bind coredata_read FilePicker()

# ╔═╡ c36e247d-6e07-4859-90f5-b6e21533d2d7
md"
#### No data just yet?
No worries! Use the `Download...` button below to download some example data to your machine that you can then upload. This data is pulled from the Mill Brook core. See if you can match it to that!
"

# ╔═╡ 6b77d944-1f30-4a54-9d98-d5346a7d4286
DownloadButton("1, 1.9\n2, 1.0\n3, 1.2\n4, 4.4\n5, 2.8\n6, 2.5\n7, 2.9\n8, 3.2\n9, 1.2\n10, 1.3\n11, 1.5\n12, 2.5\n13, 5.0\n14, 10.2\n15, 2.8\n16, 2.1\n17, 1.7\n18, 0.0\n19, 0.0\n20, 2.3\n21, 1.2","example-data.csv")

# ╔═╡ 897b063e-85f2-4d75-8d9d-10f8601b80c0
coredata = if isnothing(coredata_read)
	(; x=collect(1:5), y=[3.5,4.2, 2.8, 3.3, 3.6])
else
	cda = NAVCal.DelimitedFiles.readdlm(IOBuffer(coredata_read["data"]), ',', Float64)
	(x=cda[:,1], y=cda[:,2])
end

# ╔═╡ 06c4c3fc-68e5-4f00-b950-2f5acc8942c9
md"### 2. Select an NAVC sequence from the dropdown below:"

# ╔═╡ 5afcd016-1108-47c0-b1cd-7fd83bc33d9d
@bind navcdata Select([KelseyFerguson() => "Kelsey Ferguson", MillBrook() => "Mill Brook", RiverRoad() => "River Road", WellsRiver(1) => "Wells River 1A", WellsRiver(5) => "Wells River 2A", WellsRiver(2) => "Wells River 1B", WellsRiver(3) => "Wells River 1C", WellsRiver(4) => "Wells River 1D"])

# ╔═╡ abda8bf4-359d-4e1e-b0a7-9caee1e366b0
md"

### 3. Match your core data with the NAVC record

...using the controls and sliders. You can click and drag the slider nodes for big changes OR use your keyboard arrow keys for fine adjustments.

##### Normalize varve thicknesses (recommended)
"

# ╔═╡ bf494615-3298-4526-8437-806593d1be61
@bind normalized CheckBox(default=true)

# ╔═╡ b8b29e9f-04f0-4ea6-b2e6-992929978087
md"#### Amplitude (core data)
Adjust the apparent amplitude of core data varve thicknesses to more easily compare variations.
"

# ╔═╡ 59b373d2-439e-4dbd-b9c5-0c0c4383c74f
@bind coreamp Slider(LinRange(0,4,41), default=1, show_value=x-> "$coreamp x" )

# ╔═╡ 58da7af4-e9d2-4c66-b002-e16c8b93ea8b
md"#### Zoom: NAVC record 

Zoom in/out across the *time*-axis of the NAVC record.

###### Out $\longleftrightarrow$ In"

# ╔═╡ 102e94ba-b0b5-4f67-b3ea-a28d173d6115
@bind yrscale Slider(LinRange(1,ifelse(isnothing(coredata), 2, length(coredata.x))/length(navcdata.a), length(navcdata.a)), default=1, show_value=false)

# ╔═╡ 130a7390-f571-4ca6-aa89-5ccbbcaa6cd0
md"
#### Timeseries start 
Adjust the start date (in NAVC year) of the timeseries above."

# ╔═╡ 708ac696-eeda-4750-a5f0-69fedc1af32e
@bind yrstart Slider(firstindex(navcdata.a):lastindex(navcdata.a), default=firstindex(navcdata.a), show_value=x -> navcdata.a[yrstart])

# ╔═╡ 08a885cb-4812-4443-afe7-88f8dbdd0086
md"
#### Core basal age
Adjust the basal age (in NAVC year) of the core.
"

# ╔═╡ 9bc5168f-b477-45a7-9131-c41f1820ed82
@bind corestart Slider(first(navcdata.a):last(navcdata.a), default = 0, show_value=true)

# ╔═╡ 458fc2d9-b072-416e-8114-03d98e368f16
md"Core name"

# ╔═╡ 0f8f50c8-aa11-4509-a49e-8242fb8cb63d
@bind corelabel  TextField(default="my-core-name")

# ╔═╡ dbff7a09-8636-4642-a921-a230b28f4e60
md"NAVC sequence name"

# ╔═╡ 5e07fbb4-d678-4e7f-8e97-5695bda02618
@bind navclabel  TextField(default=navcdata.sequence)

# ╔═╡ 83e88f1c-7f53-4f95-bfe5-530fa1c45b80
corematchfig=let
	
	ycore, ynavc = if normalized
		copy(coredata.y) .- (sum(coredata.y)/length(coredata.y)), copy(navcdata.z) .- (sum(navcdata.z)/length(navcdata.z))
	else
		coredata.y, navcdata.z
	end

	yrstop = round(Int, (lastindex(navcdata.a)-firstindex(navcdata.a))*yrscale)-1 + yrstart
	yrstop = ifelse(yrstop>lastindex(navcdata.a), lastindex(navcdata.a), yrstop)

	xnavc, ynavc = navcdata.a[yrstart:yrstop], ynavc[yrstart:yrstop]
	f= Makie.Figure(size=(1000,400), fontsize=16)
	ax = Makie.Axis(f[1,1], xlabel="NAVC year", ylabel=ifelse(normalized,"normalized ", "")*"varve thickness (cm)")
	Makie.lines!(ax, xnavc, ynavc, label=navclabel, color=:dodgerblue4)

	if !isnothing(coredata)
		xcore = coredata.x .+ (corestart-1)
		Makie.lines!(ax, xcore , coreamp .* ycore, color=:goldenrod, label=corelabel)
	end
	Makie.axislegend(ax)
	Makie.Label(f[0,1], "Basal core age: $(xcore[1]) (NAVC year)  =  $(annum(xcore[1])) a", tellheight=true, tellwidth=false, font=:bold)
	f
end |> WideCell

# ╔═╡ 7120c46e-b195-41d3-841d-0b7240106e95
md"""
--- 
---
## Like what you see?
Right-click the image and select "Save Image As..." to download the image to your machine. 

---

I am working on a ~prettier~ workflow using a Pluto `DownloadButton`, [likely using an IOBuffer](https://discourse.julialang.org/t/correct-way-to-save-makie-plot-to-iobuffer/87793). Standby for updates! 

"""

# ╔═╡ Cell order:
# ╟─3efb1c2d-caab-437a-a3e8-8a73dbb6e0ec
# ╟─dd39968d-ede0-40a3-a384-89cd5fe9e1f2
# ╟─21c6d1ae-1f2e-4da1-b3fa-4153d3cf7749
# ╟─7005783b-9dd7-429f-bcc0-7123858ca9a7
# ╟─c36e247d-6e07-4859-90f5-b6e21533d2d7
# ╟─6b77d944-1f30-4a54-9d98-d5346a7d4286
# ╟─897b063e-85f2-4d75-8d9d-10f8601b80c0
# ╟─06c4c3fc-68e5-4f00-b950-2f5acc8942c9
# ╟─5afcd016-1108-47c0-b1cd-7fd83bc33d9d
# ╟─abda8bf4-359d-4e1e-b0a7-9caee1e366b0
# ╟─bf494615-3298-4526-8437-806593d1be61
# ╟─b8b29e9f-04f0-4ea6-b2e6-992929978087
# ╟─59b373d2-439e-4dbd-b9c5-0c0c4383c74f
# ╟─58da7af4-e9d2-4c66-b002-e16c8b93ea8b
# ╟─102e94ba-b0b5-4f67-b3ea-a28d173d6115
# ╟─83e88f1c-7f53-4f95-bfe5-530fa1c45b80
# ╟─130a7390-f571-4ca6-aa89-5ccbbcaa6cd0
# ╟─708ac696-eeda-4750-a5f0-69fedc1af32e
# ╟─08a885cb-4812-4443-afe7-88f8dbdd0086
# ╟─9bc5168f-b477-45a7-9131-c41f1820ed82
# ╟─458fc2d9-b072-416e-8114-03d98e368f16
# ╟─0f8f50c8-aa11-4509-a49e-8242fb8cb63d
# ╟─dbff7a09-8636-4642-a921-a230b28f4e60
# ╟─5e07fbb4-d678-4e7f-8e97-5695bda02618
# ╟─7120c46e-b195-41d3-841d-0b7240106e95
