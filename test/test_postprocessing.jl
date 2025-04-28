using Test
using ReferenceTests
using GetDP

include("../test/normalized.jl")


@testset "PostProcessing Generation" begin

    postprocessing = PostProcessing()

    pp = add!(postprocessing, "Darwin_a_2D", "Darwin_a_2D")
    q = add!(pp, "a")
    add!(q, "Term", "{a}"; In="Domain_Mag", Jacobian="Vol")
    q = add!(pp, "az")
    add!(q, "Term", "CompZ[{a}]"; In="Domain_Mag", Jacobian="Vol")
    q = add!(pp, "b")
    add!(q, "Term", "{d a}"; In="Domain_Mag", Jacobian="Vol")
    q = add!(pp, "bm")
    add!(q, "Term", "Norm[{d a}]"; In="Domain_Mag", Jacobian="Vol")

    # Multi-term entries
    q = add!(pp, "j")
    add!(q, "Term", "-sigma[]*(Dt[{a}]+{ur})"; In="DomainC_Mag", Jacobian="Vol")
    add!(q, "Term", "js0[]"; In="DomainS0_Mag", Jacobian="Vol")
    add!(q, "Term", "Ns[]/Sc[]*{ir}"; In="DomainS_Mag", Jacobian="Vol")

    q = add!(pp, "jz")
    add!(q, "Term", "CompZ[-sigma[]*(Dt[{a}]+{ur})]"; In="DomainC_Mag", Jacobian="Vol")
    add!(q, "Term", "CompZ[js0[]]"; In="DomainS0_Mag", Jacobian="Vol")
    add!(q, "Term", "CompZ[Ns[]/Sc[]*{ir}]"; In="DomainS_Mag", Jacobian="Vol")

    q = add!(pp, "jm")
    add!(q, "Term", "Norm[-sigma[]*(Dt[{a}]+{ur})]"; In="DomainC_Mag", Jacobian="Vol")
    add!(q, "Term", "Norm[js0[]]"; In="DomainS0_Mag", Jacobian="Vol")
    add!(q, "Term", "Norm[Ns[]/Sc[]*{ir}]"; In="DomainS_Mag", Jacobian="Vol")

    q = add!(pp, "d")
    add!(q, "Term", "epsilon[] * Dt[Dt[{a}]+{ur}]"; In="DomainC_Mag", Jacobian="Vol")
    q = add!(pp, "dz")
    add!(q, "Term", "CompZ[epsilon[] * Dt[Dt[{a}]+{ur}]]"; In="DomainC_Mag", Jacobian="Vol")
    q = add!(pp, "dm")
    add!(q, "Term", "Norm[epsilon[] * Dt[Dt[{a}]+{ur}]]"; In="DomainC_Mag", Jacobian="Vol")

    q = add!(pp, "rhoj2")
    add!(q, "Term", "0.5*sigma[]*SquNorm[Dt[{a}]+{ur}]"; In="DomainC_Mag", Jacobian="Vol")
    add!(q, "Term", "0.5/sigma[]*SquNorm[js0[]]"; In="DomainS0_Mag", Jacobian="Vol")
    add!(q, "Term", "0.5/sigma[]*SquNorm[Ns[]/Sc[]*{ir}]"; In="DomainS_Mag", Jacobian="Vol")

    q = add!(pp, "JouleLosses")
    add!(q, "Integral", "0.5*sigma[]*SquNorm[Dt[{a}]]"; In="DomainC_Mag", Jacobian="Vol", Integration="I1")
    add!(q, "Integral", "0.5/sigma[]*SquNorm[js0[]]"; In="DomainS0_Mag", Jacobian="Vol", Integration="I1")
    add!(q, "Integral", "0.5/sigma[]*SquNorm[Ns[]/Sc[]*{ir}]"; In="DomainS_Mag", Jacobian="Vol", Integration="I1")

    q = add!(pp, "U")
    add!(q, "Term", "{U}"; In="DomainC_Mag")
    add!(q, "Term", "{Us}"; In="DomainS_Mag")

    q = add!(pp, "I")
    add!(q, "Term", "{I}"; In="DomainC_Mag")
    add!(q, "Term", "{Is}"; In="DomainS_Mag")

    q = add!(pp, "S")
    add!(q, "Term", "{U}*Conj[{I}]"; In="DomainC_Mag")
    add!(q, "Term", "{Us}*Conj[{Is}]"; In="DomainS_Mag")

    q = add!(pp, "R")
    add!(q, "Term", "-Re[{U}/{I}]"; In="DomainC_Mag")
    add!(q, "Term", "-Re[{Us}/{Is}]"; In="DomainS_Mag")

    q = add!(pp, "L")
    add!(q, "Term", "-Im[{U}/{I}]/(2*Pi*Freq)"; In="DomainC_Mag")
    add!(q, "Term", "-Im[{Us}/{Is}]/(2*Pi*Freq)"; In="DomainS_Mag")

    q = add!(pp, "R_per_km"; comment=" For convenience... possible scaling")
    add!(q, "Term", "-Re[{U}/{I}]*1e3"; In="DomainC_Mag")
    add!(q, "Term", "-Re[{Us}/{Is}]*1e3"; In="DomainS_Mag")

    q = add!(pp, "mL_per_km")
    add!(q, "Term", "-1e6*Im[{U}/{I}]/(2*Pi*Freq)"; In="DomainC_Mag")
    add!(q, "Term", "-1e6*Im[{Us}/{Is}]/(2*Pi*Freq)"; In="DomainS_Mag")

    q = add!(pp, "Zs")
    add!(q, "Term", "-{U}/{I}"; In="DomainC_Mag")
    add!(q, "Term", "-{Us}/{Is}"; In="DomainS_Mag")

    generated_code = code(postprocessing)
    # Test against reference file
    @test_reference "references/postprocessing.txt" generated_code by=normalize_exact
end