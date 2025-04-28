using Test
using ReferenceTests
using GetDP

include("../test/normalized.jl")




@testset "Jacobian Generation" begin
    # Initialize Jacobian
    jac = Jacobian()

    # Add Vol Jacobian
    vol = add!(jac, "Vol")
    add!(vol; Region="DomainInf", Jacobian=VolSphShell(Rint="Val_Rint", Rext="Val_Rext", center_X="Xcenter", center_Y="Ycenter", center_Z="Zcenter"))
    add!(vol; Region="All", Jacobian="Vol")

    # Add Sur Jacobian
    sur = add!(jac, "Sur")
    add!(sur; Region="All", Jacobian="Sur", comment="Attention: there is no spherical shell for lines in a surface domain")

    # Generate code
    generated_code = code(jac)
    
    # Test against reference file
    @test_reference "references/jacobian.txt" generated_code by=normalize_exact
end