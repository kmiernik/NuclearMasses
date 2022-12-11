using NuclearMasses
using Test

@testset "NuclearMasses.jl" begin
    he4 = Nuclide(4, 2)
    c12 = he4 + he4 + he4

    @test c12.delta == 0.0

    @test Nuclide("He-4") == he4
    @test Nuclide("HE-4") == he4
    @test Nuclide("he-4") == he4

    @test Nuclide(12, 6) == c12
    @test Nuclide(12, "C") == c12
    @test Nuclide(12, "C", 0.0, true) == c12
    @test Nuclide(12, 6, 0.0, true) == c12
    @test Nuclide("C-12", 0.0, true) == c12
    @test Nuclide("C-12") == c12
end
