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



    function RiverRoad()
        x = DelimitedFiles.readdlm("../navc-data/MASSRR/RRLevy98-AM.TXT")
        (a= Int.(x[:,1]), z = float.(x[:,2]), notes=string.(x[:,3],x[:,3]))
    end

    function KelseyFerguson()
        x = DelimitedFiles.readdlm("../navc-data/KF-ABCD09-AM.txt")
        (a= Int.(x[:,1]), z = float.(x[:,4]), summer = float.(x[:,2]), winter = float.(x[:,3]), transect=Int.(x[:,5]), notes=string.(x[:,6]))
    end

    function MillBrook()
        x = DelimitedFiles.readdlm("../navc-data/MILLBK-AM.txt")
        (a= Int.(x[:,1]), z = float.(x[:,2]))
    end

    function WellsRiver(n::Int=0)

        x = if n==1
            DelimitedFiles.readdlm("../navc-data/VTWellsR/WR1AswT.TXT", skipstart=2)
        elseif n==2
            DelimitedFiles.readdlm("../navc-data/VTWellsR/WR1BswT.TXT", skipstart=2)
        elseif n==3
            DelimitedFiles.readdlm("../navc-data/VTWellsR/WR1CswT.TXT", skipstart=2)
        elseif n==4
            DelimitedFiles.readdlm("../navc-data/VTWellsR/WR1DswT.TXT", skipstart=2)
        elseif n==5
            DelimitedFiles.readdlm("../navc-data/VTWellsR/WR2AswT.TXT", skipstart=2)
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


