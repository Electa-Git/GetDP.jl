using Test
using ReferenceTests
using GetDP

include("../test/normalized.jl")


@testset "Function Generation" begin

    # Add the second Function definition
    func = GetDP.Function() # Use qualified name as established previously

    # Define constants
    add!(func, "mu0", expression="4.e-7 * Pi")
    add!(func, "eps0", expression="8.854187818e-12")
    add_space!(func)

    # Define properties for general regions
    add!(func, "nu", expression="1./mu0", region=["Air"])
    add!(func, "nu", expression="1./(mu0*soil_mu1)", region=["Soil_Layer1"])
    add!(func, "sigma", expression="0.", region=["Air"]) # Using region kwarg based on pattern
    add!(func, "sigma", expression="soil_sigma1", region=["Soil_Layer1"]) # Using region kwarg based on pattern
    add!(func, "epsilon", expression="eps0", region=["Air"])
    add!(func, "epsilon", expression="eps0*soil_eps1", region=["Soil_Layer1"])
    add!(func, "nu", expression="1./mu0", region=["AirInCable"])
    add!(func, "sigma", expression="0.", region=["AirInCable"]) # Using region kwarg based on pattern
    add!(func, "epsilon", expression="eps0", region=["AirInCable"]) # Using region kwarg based on pattern
    add_space!(func)

    # --- Define properties for Conductor 1 components ---
    add!(func, "nu", expression="1. / (mu0 * Cond1_core_wirearray15_mu_r)", region=["Cond1_core_wirearray15"])
    add!(func, "sigma", expression="1. / Cond1_core_wirearray15_rho", region=["Cond1_core_wirearray15"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond1_core_wirearray15_eps_r * eps0", region=["Cond1_core_wirearray15"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond1_core_semicon2_mu_r)", region=["Cond1_core_semicon2"])
    add!(func, "sigma", expression="1. / Cond1_core_semicon2_rho", region=["Cond1_core_semicon2"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond1_core_semicon2_eps_r * eps0", region=["Cond1_core_semicon2"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond1_core_insulator3_mu_r)", region=["Cond1_core_insulator3"])
    add!(func, "sigma", expression="1. / Cond1_core_insulator3_rho", region=["Cond1_core_insulator3"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond1_core_insulator3_eps_r * eps0", region=["Cond1_core_insulator3"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond1_core_semicon4_mu_r)", region=["Cond1_core_semicon4"])
    add!(func, "sigma", expression="1. / Cond1_core_semicon4_rho", region=["Cond1_core_semicon4"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond1_core_semicon4_eps_r * eps0", region=["Cond1_core_semicon4"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond1_core_semicon5_mu_r)", region=["Cond1_core_semicon5"])
    add!(func, "sigma", expression="1. / Cond1_core_semicon5_rho", region=["Cond1_core_semicon5"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond1_core_semicon5_eps_r * eps0", region=["Cond1_core_semicon5"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond1_sheath_wirearray11_mu_r)", region=["Cond1_sheath_wirearray11"])
    add!(func, "sigma", expression="1. / Cond1_sheath_wirearray11_rho", region=["Cond1_sheath_wirearray11"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond1_sheath_wirearray11_eps_r * eps0", region=["Cond1_sheath_wirearray11"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond1_sheath_strip12_mu_r)", region=["Cond1_sheath_strip12"])
    add!(func, "sigma", expression="1. / Cond1_sheath_strip12_rho", region=["Cond1_sheath_strip12"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond1_sheath_strip12_eps_r * eps0", region=["Cond1_sheath_strip12"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond1_sheath_semicon2_mu_r)", region=["Cond1_sheath_semicon2"])
    add!(func, "sigma", expression="1. / Cond1_sheath_semicon2_rho", region=["Cond1_sheath_semicon2"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond1_sheath_semicon2_eps_r * eps0", region=["Cond1_sheath_semicon2"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond1_jacket_tubular11_mu_r)", region=["Cond1_jacket_tubular11"])
    add!(func, "sigma", expression="1. / Cond1_jacket_tubular11_rho", region=["Cond1_jacket_tubular11"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond1_jacket_tubular11_eps_r * eps0", region=["Cond1_jacket_tubular11"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond1_jacket_insulator2_mu_r)", region=["Cond1_jacket_insulator2"])
    add!(func, "sigma", expression="1. / Cond1_jacket_insulator2_rho", region=["Cond1_jacket_insulator2"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond1_jacket_insulator2_eps_r * eps0", region=["Cond1_jacket_insulator2"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond1_jacket_insulator3_mu_r)", region=["Cond1_jacket_insulator3"])
    add!(func, "sigma", expression="1. / Cond1_jacket_insulator3_rho", region=["Cond1_jacket_insulator3"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond1_jacket_insulator3_eps_r * eps0", region=["Cond1_jacket_insulator3"])
    add_space!(func)

    # --- Define properties for Conductor 2 components ---
    add!(func, "nu", expression="1. / (mu0 * Cond2_core_wirearray15_mu_r)", region=["Cond2_core_wirearray15"])
    add!(func, "sigma", expression="1. / Cond2_core_wirearray15_rho", region=["Cond2_core_wirearray15"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond2_core_wirearray15_eps_r * eps0", region=["Cond2_core_wirearray15"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond2_core_semicon2_mu_r)", region=["Cond2_core_semicon2"])
    add!(func, "sigma", expression="1. / Cond2_core_semicon2_rho", region=["Cond2_core_semicon2"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond2_core_semicon2_eps_r * eps0", region=["Cond2_core_semicon2"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond2_core_insulator3_mu_r)", region=["Cond2_core_insulator3"])
    add!(func, "sigma", expression="1. / Cond2_core_insulator3_rho", region=["Cond2_core_insulator3"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond2_core_insulator3_eps_r * eps0", region=["Cond2_core_insulator3"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond2_core_semicon4_mu_r)", region=["Cond2_core_semicon4"])
    add!(func, "sigma", expression="1. / Cond2_core_semicon4_rho", region=["Cond2_core_semicon4"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond2_core_semicon4_eps_r * eps0", region=["Cond2_core_semicon4"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond2_core_semicon5_mu_r)", region=["Cond2_core_semicon5"])
    add!(func, "sigma", expression="1. / Cond2_core_semicon5_rho", region=["Cond2_core_semicon5"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond2_core_semicon5_eps_r * eps0", region=["Cond2_core_semicon5"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond2_sheath_wirearray11_mu_r)", region=["Cond2_sheath_wirearray11"])
    add!(func, "sigma", expression="1. / Cond2_sheath_wirearray11_rho", region=["Cond2_sheath_wirearray11"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond2_sheath_wirearray11_eps_r * eps0", region=["Cond2_sheath_wirearray11"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond2_sheath_strip12_mu_r)", region=["Cond2_sheath_strip12"])
    add!(func, "sigma", expression="1. / Cond2_sheath_strip12_rho", region=["Cond2_sheath_strip12"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond2_sheath_strip12_eps_r * eps0", region=["Cond2_sheath_strip12"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond2_sheath_semicon2_mu_r)", region=["Cond2_sheath_semicon2"])
    add!(func, "sigma", expression="1. / Cond2_sheath_semicon2_rho", region=["Cond2_sheath_semicon2"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond2_sheath_semicon2_eps_r * eps0", region=["Cond2_sheath_semicon2"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond2_jacket_tubular11_mu_r)", region=["Cond2_jacket_tubular11"])
    add!(func, "sigma", expression="1. / Cond2_jacket_tubular11_rho", region=["Cond2_jacket_tubular11"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond2_jacket_tubular11_eps_r * eps0", region=["Cond2_jacket_tubular11"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond2_jacket_insulator2_mu_r)", region=["Cond2_jacket_insulator2"])
    add!(func, "sigma", expression="1. / Cond2_jacket_insulator2_rho", region=["Cond2_jacket_insulator2"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond2_jacket_insulator2_eps_r * eps0", region=["Cond2_jacket_insulator2"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond2_jacket_insulator3_mu_r)", region=["Cond2_jacket_insulator3"])
    add!(func, "sigma", expression="1. / Cond2_jacket_insulator3_rho", region=["Cond2_jacket_insulator3"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond2_jacket_insulator3_eps_r * eps0", region=["Cond2_jacket_insulator3"])
    add_space!(func)

    # --- Define properties for Conductor 3 components ---
    add!(func, "nu", expression="1. / (mu0 * Cond3_core_wirearray15_mu_r)", region=["Cond3_core_wirearray15"])
    add!(func, "sigma", expression="1. / Cond3_core_wirearray15_rho", region=["Cond3_core_wirearray15"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond3_core_wirearray15_eps_r * eps0", region=["Cond3_core_wirearray15"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond3_core_semicon2_mu_r)", region=["Cond3_core_semicon2"])
    add!(func, "sigma", expression="1. / Cond3_core_semicon2_rho", region=["Cond3_core_semicon2"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond3_core_semicon2_eps_r * eps0", region=["Cond3_core_semicon2"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond3_core_insulator3_mu_r)", region=["Cond3_core_insulator3"])
    add!(func, "sigma", expression="1. / Cond3_core_insulator3_rho", region=["Cond3_core_insulator3"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond3_core_insulator3_eps_r * eps0", region=["Cond3_core_insulator3"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond3_core_semicon4_mu_r)", region=["Cond3_core_semicon4"])
    add!(func, "sigma", expression="1. / Cond3_core_semicon4_rho", region=["Cond3_core_semicon4"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond3_core_semicon4_eps_r * eps0", region=["Cond3_core_semicon4"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond3_core_semicon5_mu_r)", region=["Cond3_core_semicon5"])
    add!(func, "sigma", expression="1. / Cond3_core_semicon5_rho", region=["Cond3_core_semicon5"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond3_core_semicon5_eps_r * eps0", region=["Cond3_core_semicon5"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond3_sheath_wirearray11_mu_r)", region=["Cond3_sheath_wirearray11"])
    add!(func, "sigma", expression="1. / Cond3_sheath_wirearray11_rho", region=["Cond3_sheath_wirearray11"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond3_sheath_wirearray11_eps_r * eps0", region=["Cond3_sheath_wirearray11"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond3_sheath_strip12_mu_r)", region=["Cond3_sheath_strip12"])
    add!(func, "sigma", expression="1. / Cond3_sheath_strip12_rho", region=["Cond3_sheath_strip12"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond3_sheath_strip12_eps_r * eps0", region=["Cond3_sheath_strip12"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond3_sheath_semicon2_mu_r)", region=["Cond3_sheath_semicon2"])
    add!(func, "sigma", expression="1. / Cond3_sheath_semicon2_rho", region=["Cond3_sheath_semicon2"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond3_sheath_semicon2_eps_r * eps0", region=["Cond3_sheath_semicon2"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond3_jacket_tubular11_mu_r)", region=["Cond3_jacket_tubular11"])
    add!(func, "sigma", expression="1. / Cond3_jacket_tubular11_rho", region=["Cond3_jacket_tubular11"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond3_jacket_tubular11_eps_r * eps0", region=["Cond3_jacket_tubular11"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond3_jacket_insulator2_mu_r)", region=["Cond3_jacket_insulator2"])
    add!(func, "sigma", expression="1. / Cond3_jacket_insulator2_rho", region=["Cond3_jacket_insulator2"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond3_jacket_insulator2_eps_r * eps0", region=["Cond3_jacket_insulator2"])
    add_space!(func)

    add!(func, "nu", expression="1. / (mu0 * Cond3_jacket_insulator3_mu_r)", region=["Cond3_jacket_insulator3"])
    add!(func, "sigma", expression="1. / Cond3_jacket_insulator3_rho", region=["Cond3_jacket_insulator3"]) # Using region kwarg
    add!(func, "epsilon", expression="Cond3_jacket_insulator3_eps_r * eps0", region=["Cond3_jacket_insulator3"])
    add_space!(func)

    # --- Energization parameters ---
    add_constant!(func, "Pa", 0.)
    add_constant!(func, "Pb", "-120./180.*Pi")
    add_constant!(func, "Pc", "-240./180.*Pi")

    add_constant!(func, "I", 1.0)
    add_constant!(func, "V", 1.0)
    add_space!(func)

    # Other parameters
    add!(func, "Ns", expression="1")
    add!(func, "Sc", expression="SurfaceArea[]") # Assuming SurfaceArea[] helper exists or is defined elsewhere
    add_space!(func)

    # Flags for basis function degrees
    add_constant!(func, "Flag_Degree_a", "1")
    add_constant!(func, "Flag_Degree_v", "1")

    generated_code = code(func)
    # Test against reference file
    @test_reference "references/function.txt" generated_code by=normalize_exact
end