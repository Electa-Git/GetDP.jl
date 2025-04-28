using Test
using ReferenceTests
using GetDP

include("../test/normalized.jl")


@testset "Group Generation" begin

    # Add the Group definition
    group = GetDP.Group()

    # Individual regions
    add!(group, "Air", ["AIR_ABOVE_SOIL"], "Region")
    add!(group, "AirInCable", ["AIR_IN_CABLE"], "Region")
    add!(group, "Soil_Layer1", ["LAYER1"], "Region")
    add_space!(group)  # Space after initial regions

    # Conductor 1 regions
    add!(group, "Cond1_core_wirearray15", [1115], "Region")
    add!(group, "Cond1_core_semicon2", [1120], "Region")
    add!(group, "Cond1_core_insulator3", [1130], "Region")
    add!(group, "Cond1_core_semicon4", [1140], "Region")
    add!(group, "Cond1_core_semicon5", [1150], "Region")
    add!(group, "Cond1_sheath_wirearray11", [1211], "Region")
    add!(group, "Cond1_sheath_strip12", [1212], "Region")
    add!(group, "Cond1_sheath_semicon2", [1220], "Region")
    add!(group, "Cond1_jacket_tubular11", [1311], "Region")
    add!(group, "Cond1_jacket_insulator2", [1320], "Region")
    add!(group, "Cond1_jacket_insulator3", [1330], "Region")
    add_space!(group)  # Space after Cond1 regions

    # Conductor 2 regions
    add!(group, "Cond2_core_wirearray15", [2115], "Region")
    add!(group, "Cond2_core_semicon2", [2120], "Region")
    add!(group, "Cond2_core_insulator3", [2130], "Region")
    add!(group, "Cond2_core_semicon4", [2140], "Region")
    add!(group, "Cond2_core_semicon5", [2150], "Region")
    add!(group, "Cond2_sheath_wirearray11", [2211], "Region")
    add!(group, "Cond2_sheath_strip12", [2212], "Region")
    add!(group, "Cond2_sheath_semicon2", [2220], "Region")
    add!(group, "Cond2_jacket_tubular11", [2311], "Region")
    add!(group, "Cond2_jacket_insulator2", [2320], "Region")
    add!(group, "Cond2_jacket_insulator3", [2330], "Region")
    add_space!(group)  # Space after Cond2 regions

    # Conductor 3 regions
    add!(group, "Cond3_core_wirearray15", [3115], "Region")
    add!(group, "Cond3_core_semicon2", [3120], "Region")
    add!(group, "Cond3_core_insulator3", [3130], "Region")
    add!(group, "Cond3_core_semicon4", [3140], "Region")
    add!(group, "Cond3_core_semicon5", [3150], "Region")
    add!(group, "Cond3_sheath_wirearray11", [3211], "Region")
    add!(group, "Cond3_sheath_strip12", [3212], "Region")
    add!(group, "Cond3_sheath_semicon2", [3220], "Region")
    add!(group, "Cond3_jacket_tubular11", [3311], "Region")
    add!(group, "Cond3_jacket_insulator2", [3320], "Region")
    add!(group, "Cond3_jacket_insulator3", [3330], "Region")
    add_space!(group)  # Space after Cond3 regions

    # Combined conductor regions
    add!(group, "Cond1_sheath_C", ["Cond1_sheath_wirearray11", "Cond1_sheath_strip12"], "Region")
    add!(group, "Cond1_jacket_C", ["Cond1_jacket_tubular11"], "Region")
    add!(group, "Cond1_C", ["Cond1_sheath_C", "Cond1_jacket_C"], "Region")

    add!(group, "Cond2_sheath_C", ["Cond2_sheath_wirearray11", "Cond2_sheath_strip12"], "Region")
    add!(group, "Cond2_jacket_C", ["Cond2_jacket_tubular11"], "Region")
    add!(group, "Cond2_C", ["Cond2_sheath_C", "Cond2_jacket_C"], "Region")

    add!(group, "Cond3_sheath_C", ["Cond3_sheath_wirearray11", "Cond3_sheath_strip12"], "Region")
    add!(group, "Cond3_jacket_C", ["Cond3_jacket_tubular11"], "Region")
    add!(group, "Cond3_C", ["Cond3_sheath_C", "Cond3_jacket_C"], "Region")
    add_space!(group)
    add_space!(group)

    add!(group, "Cond1_core_CC", ["Cond1_core_semicon2", "Cond1_core_insulator3", "Cond1_core_semicon4", "Cond1_core_semicon5"], "Region")
    add!(group, "Cond1_sheath_CC", ["Cond1_sheath_semicon2"], "Region")
    add!(group, "Cond1_jacket_CC", ["Cond1_jacket_insulator2", "Cond1_jacket_insulator3"], "Region")
    add!(group, "Cond1_CC", ["Cond1_core_CC", "Cond1_sheath_CC", "Cond1_jacket_CC"], "Region")

    add!(group, "Cond2_core_CC", ["Cond2_core_semicon2", "Cond2_core_insulator3", "Cond2_core_semicon4", "Cond2_core_semicon5"], "Region")
    add!(group, "Cond2_sheath_CC", ["Cond2_sheath_semicon2"], "Region")
    add!(group, "Cond2_jacket_CC", ["Cond2_jacket_insulator2", "Cond2_jacket_insulator3"], "Region")
    add!(group, "Cond2_CC", ["Cond2_core_CC", "Cond2_sheath_CC", "Cond2_jacket_CC"], "Region")

    add!(group, "Cond3_core_CC", ["Cond3_core_semicon2", "Cond3_core_insulator3", "Cond3_core_semicon4", "Cond3_core_semicon5"], "Region")
    add!(group, "Cond3_sheath_CC", ["Cond3_sheath_semicon2"], "Region")
    add!(group, "Cond3_jacket_CC", ["Cond3_jacket_insulator2", "Cond3_jacket_insulator3"], "Region")
    add!(group, "Cond3_CC", ["Cond3_core_CC", "Cond3_sheath_CC", "Cond3_jacket_CC"], "Region")
    add_space!(group)  # Space after combined conductor regions

    # Dirichlet and Magnetodynamics regions
    add!(group, "Sur_Dirichlet_Ele", [], "Region")
    add_space!(group)
    add!(group, "Sur_Dirichlet_Mag", ["OUTBND_EM1"], "Region"; comment="n.b=0 on this boundary")
    add_space!(group)  # Space before Magnetodynamics comment

    # Magnetodynamics domains
    add!(group, "DomainS0_Mag", [], "Region"; comment="UNUSED")
    add!(group, "DomainS_Mag", [], "Region"; comment="UNUSED")
    add!(group, "DomainCWithI_Mag", [], "Region"; comment="If source massive")
    add_space!(group)

    # Inductor and cable regions
    add!(group, "Ind_1", [1115], "Region")
    add!(group, "Ind_2", [2115], "Region")
    add!(group, "Ind_3", [3115], "Region")
    add!(group, "Inds", [1115, 2115, 3115], "Region")
    add!(group, "Cable", ["Inds", "Cond1_CC", "Cond2_CC", "Cond3_CC", "Cond1_C", "Cond2_C", "Cond3_C"], "Region")
    add_space!(group)
    add!(group, "Cable_1", ["Ind_1", "Cond1_CC", "Cond1_C"], "Region")
    add!(group, "Cable_2", ["Ind_2", "Cond2_CC", "Cond2_C"], "Region")
    add!(group, "Cable_3", ["Ind_3", "Cond3_CC", "Cond3_C"], "Region")
    add!(group, "DomainCWithI_Mag", ["Inds"], "Region"; operation="+=", comment="If source massive")
    add_space!(group)

    # Soil and infinity regions
    add!(group, "Soil_Layer1", ["INFINITY_GROUND"], "Region"; operation="+=")
    add!(group, "DomainInf", ["INFINITY_GROUND"], "Region")
    add_space!(group)

    # Combined magnetodynamics domains
    add!(group, "DomainCC_Mag", ["DomainS_Mag"], "Region")
    add!(group, "DomainCC_Mag", ["Air", "AirInCable", "Soil_Layer1", "Cond1_CC", "Cond2_CC", "Cond3_CC"], "Region"; operation="+=")
    add_space!(group)
    add!(group, "DomainC_Mag", ["DomainCWithI_Mag", "Cond1_C", "Cond2_C", "Cond3_C"], "Region")
    add_space!(group)
    add!(group, "Domain_Mag", ["DomainCC_Mag", "DomainC_Mag"], "Region")
    add_space!(group)

    # Electrodynamics domain
    add!(group, "Domain_Ele", ["Cable"], "Region"; comment="Just the cable or the same domain as magnetodynamics")
    add_space!(group)

    # Dummy domain
    add!(group, "DomainDummy", [12345], "Region")

    generated_code = code(group)
    # Test against reference file
    @test_reference "references/group.txt" generated_code by=normalize_exact
end