using Test
using ReferenceTests
using GetDP

include("../test/normalized.jl")




@testset "FunctionSpace Generation" begin
    # Setup
    functionspace = FunctionSpace()
    
    # Build the function space structure
    fs1 = add!(functionspace, "Hcurl_a_Mag_2D", nothing, nothing, Type="Form1P")
    add_basis_function!(functionspace, "se", "ae", "BF_PerpendicularEdge"; 
        Support="Domain_Mag", Entity="NodesOf[ All ]")
    add_basis_function!(functionspace, "se2", "ae2", "BF_PerpendicularEdge_2E";
        Support="Domain_Mag",
        Entity="EdgesOf[ All ]",
        condition="If (Flag_Degree_a == 2)",
        endCondition="EndIf")

    add_constraint!(functionspace, "ae", "NodesOf", "MagneticVectorPotential_2D")
    add_constraint!(functionspace, "ae2", "EdgesOf", "MagneticVectorPotential_2D";
        comment=" Only OK if homogeneous BC, otherwise specify zero-BC",
        condition="If (Flag_Degree_a == 2)",
        endCondition="EndIf")

    fs2 = add!(functionspace, "Hregion_i_2D", nothing, nothing, Type="Vector")
    add_basis_function!(functionspace, "sr", "ir", "BF_RegionZ"; 
        Support="DomainS_Mag", Entity="DomainS_Mag")
    add_global_quantity!(functionspace, "Is", "AliasOf"; NameOfCoef="ir")
    add_global_quantity!(functionspace, "Us", "AssociatedWith"; NameOfCoef="ir")
    add_constraint!(functionspace, "Us", "Region", "Voltage_2D")
    add_constraint!(functionspace, "Is", "Region", "Current_2D")

    fs3 = add!(functionspace, "Hregion_u_Mag_2D", nothing, nothing, Type="Form1P", 
        comment=" Gradient of Electric scalar potential (2D)")
    add_basis_function!(functionspace, "sr", "ur", "BF_RegionZ"; 
        Support="DomainC_Mag", Entity="DomainC_Mag")
    add_global_quantity!(functionspace, "U", "AliasOf"; NameOfCoef="ur")
    add_global_quantity!(functionspace, "I", "AssociatedWith"; NameOfCoef="ur")
    add_constraint!(functionspace, "U", "Region", "Voltage_2D")
    add_constraint!(functionspace, "I", "Region", "Current_2D")

    # Generate code
    generated_code = code(functionspace)
    
    # Test against reference file
    @test_reference "references/function_space.txt" generated_code by=normalize_exact
end