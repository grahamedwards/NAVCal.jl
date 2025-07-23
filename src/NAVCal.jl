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
    :a | NAVC varve year
    :z | varve thickness (cm)
    :notes | Associated notes

    """
    function RiverRoad()
        x = DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/MASSRR/RRLevy98-AM.TXT"))
        (a= Int.(x[:,1]), z = float.(x[:,2]), notes=string.(x[:,3],x[:,3]))
    end

    """

        KelseyFerguson()

    Varve thickness and NAVC calibration data for the Kelsey Ferguson Brickyard site in South Windsor, CT. 

    key | description
    :-- | :--
    :a | NAVC varve year
    :z | varve (couplet) thickness (cm)
    :summer | summer layer thickness (cm)
    :winter | winter layer thickness (cm)
    :transect | Outcrop transit number
    :notes | Associated notes

    """
    function KelseyFerguson()
        x = DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/KF-ABCD09-AM.txt"))
        (a= Int.(x[:,1]), z = float.(x[:,4]), summer = float.(x[:,2]), winter = float.(x[:,3]), transect=Int.(x[:,5]), notes=string.(x[:,6]))
    end


    """

        MillBrook()

    Varve thickness and NAVC calibration data from the Mill Brook site near Putney, Vt. 

    key | description
    :-- | :--
    :a | NAVC varve year
    :z | varve thickness (cm)

    """
    function MillBrook()
        x = DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/MILLBK-AM.txt"))
        (a= Int.(x[:,1]), z = float.(x[:,2]))
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
            DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/VTWellsR/WR1AswT.TXT"), skipstart=2)
        elseif n==2
            DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/VTWellsR/WR1BswT.TXT"), skipstart=2)
        elseif n==3
            DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/VTWellsR/WR1CswT.TXT"), skipstart=2)
        elseif n==4
            DelimitedFiles.readdlm(joinpath(@__DIR__,"../navc-data/VTWellsR/WR1DswT.TXT"), skipstart=2)
        elseif n==5
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

        return (a= Int.(x[:,1]), z = float.(x[:,4]), summer = float.(x[:,2]), winter = float.(x[:,3]), meas=Int.(x[:,5]), core, notes)
    end
end


