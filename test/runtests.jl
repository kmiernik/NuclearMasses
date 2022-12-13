using NuclearMasses
using Test


@testset "NuclearMasses.jl" begin
    he4 = Nuclide(4, 2)
    c12 = he4 + he4 + he4

    @test c12.A == 12
    @test c12.Z == 6
    @test c12.delta == 0.0

    @test Nuclide("He-4") == he4
    @test Nuclide("HE-4") == he4
    @test Nuclide("he-4") == he4

    @test Nuclide(12, 6) == c12
    @test Nuclide(12, "C") == c12
    @test Nuclide(12, "C", 0.0, experimental=true) == c12
    @test Nuclide(12, 6, 0.0, experimental=true) == c12
    @test Nuclide("C-12") == c12
    @test Nuclide("C-12", 0.0, experimental=true) == c12

    pb208 = Nuclide(208, 82, model=NuclearMasses.hfb24)
    @test Nuclide("Pb-208", model=NuclearMasses.hfb24) == pb208
    @test pb208.delta == -21940.0

    sn132 = Nuclide(132, 50)
    sn132h = Nuclide(132, 50, model=NuclearMasses.hfb24)

    sn132f = Nuclide(132, 50, model=NuclearMasses.frdm12)
    @test Nuclide("Sn-132", model=NuclearMasses.frdm12) == sn132f
    @test sn132f.delta == -75940.0

    @test (sn132.delta - sn132f.delta) < 1000.0
    @test (sn132.delta - sn132h.delta) < 1000.0

    cn = sn132 + he4
    @test cn.A == 136
    @test cn.Z == 52

    x = Nuclide(300, 120)
    @test x.delta == Inf

    try
        x = Nuclide(1, 2)
        @test false
    catch err
        @test isa(err, AssertionError)
    end
end
