using Test
using ReferenceTests
using GetDP

include("../test/normalized.jl")


@testset "Constraint Generation" begin

   # Add the Constraint definition
    constraint = GetDP.Constraint()

    # Electrical constraints
    add_comment!(constraint, "Electrical constraints")

    # ElectricScalarPotential
    esp = assign!(constraint, "ElectricScalarPotential")
    case!(esp, "Ind_1", value="V0", time_function="F_Cos_wt_p[]{2*Pi*Freq, Pa}")
    case!(esp, "Ind_2", value="V0", time_function="F_Cos_wt_p[]{2*Pi*Freq, Pb}")
    case!(esp, "Ind_3", value="V0", time_function="F_Cos_wt_p[]{2*Pi*Freq, Pc}")
    case!(esp, "Sur_Dirichlet_Ele", value="0")

    # ZeroElectricScalarPotential
    zesp = assign!(constraint, "ZeroElectricScalarPotential", comment="Only if second order basis functions")
    for_loop!(zesp, "k", "1:3")
    case!(zesp, "Ind~{k}", value="0")
    case!(zesp, "Sur_Dirichlet_Ele", value="0")

    # Magnetic constraints
    add_comment!(constraint, "Magnetic constraints")

    # MagneticVectorPotential_2D
    mvp = assign!(constraint, "MagneticVectorPotential_2D")
    case!(mvp, "Sur_Dirichlet_Mag", value="0.")

    # Voltage_2D
    voltage = assign!(constraint, "Voltage_2D")
    case!(voltage, "", comment="UNUSED")

    # Current_2D
    current = assign!(constraint, "Current_2D", comment="constraint used if Inds in DomainS_Mag example for a three-phase cable")
    case!(current, "Ind_1", value="I", time_function="F_Cos_wt_p[]{2*Pi*Freq, Pa}")
    case!(current, "Ind_2", value="I", time_function="F_Cos_wt_p[]{2*Pi*Freq, Pb}")
    case!(current, "Ind_3", value="I", time_function="F_Cos_wt_p[]{2*Pi*Freq, Pc}")


    generated_code = code(constraint)
    # Test against reference file
    @test_reference "references/constraint.txt" generated_code by=normalize_exact
end