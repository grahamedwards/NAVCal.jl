using NAVCal
using Test

@testset "NAVCal.jl" begin
    @test annum(8500) === 12270
    @test varve_year(2500) ≈ 18270.0

    x, i = KelseyFerguson(), 8
    @test (x.a[i], x.summer[i], x.winter[i], x.z[i], x.transect[i], x.notes[i]) ==  (3304, 0.805, 0.942, 1.746, 1, "...")

    x, i = MillBrook(), 8
    @test (x.a[i], x.z[i]) === (5774, 10.7)
    @test x[1] isa String

    x, i = RiverRoad(), 8
    @test (x.a[i], x.z[i]) === (5029, 1.7)
    @test x[1] isa String
    
    x, i = WellsRiver(1), 8
    @test (x.a[i], x.summer[i], x.winter[i], x.z[i], x.meas[i], x.core[i], x.notes[i]) === (362, 0.000, 0.000, 0.000, 0, "WR1-16", "deformed layer, gap with match to WR2 ")
    @test x[1] isa String
    
    x = WellsRiver(2)
    @test (x.a[i], x.summer[i], x.winter[i], x.z[i], x.meas[i], x.core[i], x.notes[i]) === (8, 0.181, 0.433, 0.613, 2, "WR1-12", "")
    @test x[1] isa String

    x = WellsRiver(3)
    @test (x.a[i], x.summer[i], x.winter[i], x.z[i], x.meas[i], x.core[i], x.notes[i]) ===  (8, 0.167, 0.350, 0.518,   2, "WR1-11,WR1-12C", "")
    @test x[1] isa String

    x = WellsRiver(4)
    @test (x.a[i], x.summer[i], x.winter[i], x.z[i], x.meas[i], x.core[i], x.notes[i]) ===  (8, 0.276, 0.201, 0.477, 2, "WR1-7", "")
    @test x[1] isa String

    x = WellsRiver(5)
    @test (x.a[i], x.summer[i], x.winter[i], x.z[i], x.meas[i], x.core[i], x.notes[i]) === (208, 0.191, 0.815, 1.006, 1,  "WS2-1", "")
    @test x[1] isa String

    @test WellsRiver() === "Must input an integer between 1 and 5. See docs for details."

end



