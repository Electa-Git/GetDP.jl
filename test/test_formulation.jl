using Test
using ReferenceTests
using GetDP

include("../test/normalized.jl")




@testset "Formulation Generation" begin
    
    formulation = GetDP.Formulation()

    form = add!(formulation, "Darwin_a_2D", "FemEquation"; comment=" Magnetodynamics + displacement current, no coupling")
    add_quantity!(form, "a", Type="Local", NameOfSpace="Hcurl_a_Mag_2D")
    add_quantity!(form, "ur", Type="Local", NameOfSpace="Hregion_u_Mag_2D", comment=" massive conductors (source or not)")
    add_quantity!(form, "I", Type="Global", NameOfSpace="Hregion_u_Mag_2D [I]")
    add_quantity!(form, "U", Type="Global", NameOfSpace="Hregion_u_Mag_2D [U]")
    add_quantity!(form, "ir", Type="Local", NameOfSpace="Hregion_i_2D", comment=" stranded conductors (source)")
    add_quantity!(form, "Us", Type="Global", NameOfSpace="Hregion_i_2D[Us]")
    add_quantity!(form, "Is", Type="Global", NameOfSpace="Hregion_i_2D[Is]")

    eq = add_equation!(form)

    add!(eq, "Galerkin", "[ nu[] * Dof{d a} , {d a} ]", In="Domain_Mag", Jacobian="Vol", Integration="I1")
    add!(eq, "Galerkin", "DtDof [ sigma[] * Dof{a} , {a} ]", In="DomainC_Mag", Jacobian="Vol", Integration="I1")
    add!(eq, "Galerkin", "[ sigma[] * Dof{ur}, {a} ]", In="DomainC_Mag", Jacobian="Vol", Integration="I1")
    add!(eq, "Galerkin", "DtDof [ sigma[] * Dof{a} , {ur} ]", In="DomainC_Mag", Jacobian="Vol", Integration="I1")
    add!(eq, "Galerkin", "[ sigma[] * Dof{ur}, {ur}]", In="DomainC_Mag", Jacobian="Vol", Integration="I1")
    add!(eq, "Galerkin", "DtDtDof [ epsilon[] * Dof{a} , {a}]", In="DomainC_Mag", Jacobian="Vol", Integration="I1", comment=" Added term => Darwin approximation")
    add!(eq, "Galerkin", "DtDof[ epsilon[] * Dof{ur}, {a} ]", In="DomainC_Mag", Jacobian="Vol", Integration="I1")
    add!(eq, "Galerkin", "DtDtDof [ epsilon[] * Dof{a} , {ur}]", In="DomainC_Mag", Jacobian="Vol", Integration="I1")
    add!(eq, "Galerkin", "DtDof[ epsilon[] * Dof{ur}, {ur} ]", In="DomainC_Mag", Jacobian="Vol", Integration="I1")
    add!(eq, "GlobalTerm", "[ Dof{I} , {U} ]", In="DomainCWithI_Mag")
    add!(eq, "Galerkin", "[ -js0[] , {a} ]", In="DomainS0_Mag", Jacobian="Vol", Integration="I1", comment=" Either you impose directly the function js0[]")
    add!(eq, "Galerkin", "[ -Ns[]/Sc[] * Dof{ir}, {a} ]", In="DomainS_Mag", Jacobian="Vol", Integration="I1", comment=" or you use the constraints => allows accounting for sigma[]")
    add!(eq, "Galerkin", "DtDof [ Ns[]/Sc[] * Dof{a}, {ir} ]", In="DomainS_Mag", Jacobian="Vol", Integration="I1")
    add!(eq, "Galerkin", "[ Ns[]/Sc[] / sigma[] * Ns[]/Sc[]* Dof{ir} , {ir}]", In="DomainS_Mag", Jacobian="Vol", Integration="I1", comment=" resistance term")
    add!(eq, "GlobalTerm", "[ Dof{Us}, {Is} ]", In="DomainS_Mag")
        
    generated_code = code(formulation)
    # Test against reference file
    @test_reference "references/formulation.txt" generated_code by=normalize_exact
end