module NAVCal

    import DelimitedFiles

    export annum, varve_year, KelseyFerguson, MillBrook, RiverRoad, WellsRiver

    """

        annum(x)

    Convert NAVC varve year to age in annum. 

    """
    annum(x::Integer) = 20770 - x

    """

        varve_year(x)

    Convert age in annum to NAVC varve year.
    
    """
    varve_year(x::Number) = 20770. - float(x)


    """

        RiverRoad()

    Varve thickness and NAVC calibration data from the River Road site, as measured by Levy (1998). 

    key | description
    :-- | :--
    :sequence | NAVC sequence name
    :a | NAVC varve year
    :z | varve thickness (cm)
    :notes | Associated notes

    """
    function RiverRoad()
        x = DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/MASSRR/RRLevy98-AM.TXT"))
        (sequence="RRLevy98-AM", a= Int.(x[:,1]), z = float.(x[:,2]), notes=string.(x[:,3],x[:,3]))
    end

    """

        KelseyFerguson()

    Varve thickness and NAVC calibration data for the Kelsey Ferguson Brickyard site in South Windsor, CT. 

    key | description
    :-- | :--
    :sequence | NAVC sequence name
    :a | NAVC varve year
    :z | varve (couplet) thickness (cm)
    :summer | summer layer thickness (cm)
    :winter | winter layer thickness (cm)
    :transect | Outcrop transit number
    :notes | Associated notes

    """
    function KelseyFerguson()
        x = DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/KF-ABCD09-AM.txt"))
        ( sequence="KF-ABCD09", a= Int.(x[:,1]), z = float.(x[:,4]), summer = float.(x[:,2]), winter = float.(x[:,3]), transect=Int.(x[:,5]), notes=string.(x[:,6]))
    end


    """

        MillBrook()

    Varve thickness and NAVC calibration data from the Mill Brook site near Putney, Vt. 

    key | description
    :-- | :--
    :sequence | NAVC sequence name
    :a | NAVC varve year
    :z | varve thickness (cm)

    """
    function MillBrook()
        x = DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/MILLBK-AM.txt"))
        (; sequence="MILLBK", a= Int.(x[:,1]), z = float.(x[:,2]))
    end

    """

        WellsRiver(n)

    Varve thickness and NAVC calibration data from the Wells River Valley, near Wells River, VT.


    You must provide an `Int` 1-5, corresponding to the files below:

    ID | description | NAVC age range
    --: | :-- | :--
    1 | Sequence 1A | 6772-7022
    2 | Sequence 1B | 7024-7046
    3 | Sequence 1C | 7049-7138
    4 | Sequence 1D | 7157-7289
    5 | Sequence 2A | 6772-7022

    key | description
    :-- | :--
    :sequence | NAVC sequence name
    :a | NAVC varve year
    :z | varve (couplet) thickness (cm)
    :summer | summer layer thickness (cm)
    :winter | winter layer thickness (cm)
    :core | Core identifier
    :meas | ? (unclear data heading "Meas")
    :notes | Associated notes

    """
    function WellsRiver(n::Int=0)

        x = if n==1
            sequence = "WR1AswT"
            DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/VTWellsR/WR1AswT.TXT"), skipstart=2)
        elseif n==2
            sequence = "WR1BswT"
            DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/VTWellsR/WR1BswT.TXT"), skipstart=2)
        elseif n==3
            sequence = "WR1CswT"
            DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/VTWellsR/WR1CswT.TXT"), skipstart=2)
        elseif n==4
            sequence = "WR1DswT"
            DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/VTWellsR/WR1DswT.TXT"), skipstart=2)
        elseif n==5
            sequence = "WR2AswT"
            DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/VTWellsR/WR2AswT.TXT"), skipstart=2)
        else
            return "Must input an integer between 1 and 5. See docs for details."
        end 

        xrows,xcols = axes(x)

        w = "..."
        core = Vector{String}(undef,xrows.stop)
        notes = similar(core)

        @inbounds for i = xrows
            w = ifelse(x[i,6]=="...", w, x[i,6])
            core[i] = w
            notes[i] = string([ifelse(isempty(x[i,j]), "", x[i,j]*" ") for j=7:xcols.stop]...,)
        end

        return (; sequence, a= Int.(x[:,1]), z = float.(x[:,4]), summer = float.(x[:,2]), winter = float.(x[:,3]), meas=Int.(x[:,5]), core, notes)
    end

    function __init__()
        printstyled("\n\n\nWelcome to NAVCal.jl!", bold=true, color=:light_yellow, blink=true)
        print("\n\nYou probably loaded this package to correlate a varve section from\nglacial Lake Hitchcock with the North American Varve Chronology (NAVC) record.\nHere's how to do that:\n\n1. Download ")
        printstyled("core-match.jl",  color=:magenta)
        print(" from: ...\n\n2. In the REPL (here), execute ")
        printstyled("import Pluto; Pluto.run()", color=:cyan)
        print("\n     → you may need to install it first: ")
        printstyled("]add Pluto", color=:cyan)
        print("\n\n3. Open the ")
        printstyled("core-match.jl", color=:magenta)
        println(" notebook within Pluto and away you go!\n\n")
    end
end

