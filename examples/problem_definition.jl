# This file contains a cable simulation example following the codes originally implemented in Onelab by prof. Ruth Sabariego (ruth.sabariego@kuleuven.be)

push!(LOAD_PATH, joinpath(@__DIR__, "..", "src")) # hide
using GetDP

# Create a Problem object
problem = Problem()

# Add the include statement
include!(problem, "test_case_1_data.geo")

# Add the first DefineConstant block
add_raw_code!(
  problem,
  """
DefineConstant[
  Flag_AnalysisType = {1,
      Choices{
      0="Electric",
      1="Magnetic"
      },
      Name "{00Parameters/00Type of analysis", Highlight "Blue",
      ServerAction Str["Reset","GetDP/1ResolutionChoices"]}

  nb_iter = 20, // Maximum number of nonlinear iterations (You may adapt)
  relaxation_factor = 1, // value in [0,1]; if 1, there is no relaxation; if <1, you used the solution of previous iteration for helping convergence
  stop_criterion = 1e-6, // prescribed tolerance, iterative process stops when the difference between two consecutive iterations is smaller than this value

  c_ = {"-solve -v2", Name "GetDP/9ComputeCommand", Visible 1},
  p_ = {"", Name "GetDP/2PostOperationChoices", Visible 1}
];
"""
)

# Add the Function definition
func1 = GetDP.Function()
add!(func1, "Resolution_name()", "Str['Electrodynamics', 'Darwin']")


# Add the second DefineConstant block
add_raw_code!(
  problem,
  """
DefineConstant[
  r_ = {Str[Resolution_name(Flag_AnalysisType)], Name "GetDP/1ResolutionChoices", Visible 1}
  c_ = {"-solve -v2", Name "GetDP/9ComputeCommand", Visible 1},
  p_ = {"", Name "GetDP/2PostOperationChoices", Visible 1, Closed 1}
];
"""
)

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
# add_space!(group)

# Assign Group to Problem
problem.group = group

# Add the second Function definition
func2 = GetDP.Function() # Use qualified name as established previously

# Define constants
add!(func2, "mu0", expression="4.e-7 * Pi")
add!(func2, "eps0", expression="8.854187818e-12")
add_space!(func2)

# Define properties for general regions
add!(func2, "nu", expression="1./mu0", region=["Air"])
add!(func2, "nu", expression="1./(mu0*soil_mu1)", region=["Soil_Layer1"])
add!(func2, "sigma", expression="0.", region=["Air"]) # Using region kwarg based on pattern
add!(func2, "sigma", expression="soil_sigma1", region=["Soil_Layer1"]) # Using region kwarg based on pattern
add!(func2, "epsilon", expression="eps0", region=["Air"])
add!(func2, "epsilon", expression="eps0*soil_eps1", region=["Soil_Layer1"])
add!(func2, "nu", expression="1./mu0", region=["AirInCable"])
add!(func2, "sigma", expression="0.", region=["AirInCable"]) # Using region kwarg based on pattern
add!(func2, "epsilon", expression="eps0", region=["AirInCable"]) # Using region kwarg based on pattern
add_space!(func2)

# --- Define properties for Conductor 1 components ---
add!(func2, "nu", expression="1. / (mu0 * Cond1_core_wirearray15_mu_r)", region=["Cond1_core_wirearray15"])
add!(func2, "sigma", expression="1. / Cond1_core_wirearray15_rho", region=["Cond1_core_wirearray15"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond1_core_wirearray15_eps_r * eps0", region=["Cond1_core_wirearray15"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond1_core_semicon2_mu_r)", region=["Cond1_core_semicon2"])
add!(func2, "sigma", expression="1. / Cond1_core_semicon2_rho", region=["Cond1_core_semicon2"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond1_core_semicon2_eps_r * eps0", region=["Cond1_core_semicon2"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond1_core_insulator3_mu_r)", region=["Cond1_core_insulator3"])
add!(func2, "sigma", expression="1. / Cond1_core_insulator3_rho", region=["Cond1_core_insulator3"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond1_core_insulator3_eps_r * eps0", region=["Cond1_core_insulator3"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond1_core_semicon4_mu_r)", region=["Cond1_core_semicon4"])
add!(func2, "sigma", expression="1. / Cond1_core_semicon4_rho", region=["Cond1_core_semicon4"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond1_core_semicon4_eps_r * eps0", region=["Cond1_core_semicon4"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond1_core_semicon5_mu_r)", region=["Cond1_core_semicon5"])
add!(func2, "sigma", expression="1. / Cond1_core_semicon5_rho", region=["Cond1_core_semicon5"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond1_core_semicon5_eps_r * eps0", region=["Cond1_core_semicon5"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond1_sheath_wirearray11_mu_r)", region=["Cond1_sheath_wirearray11"])
add!(func2, "sigma", expression="1. / Cond1_sheath_wirearray11_rho", region=["Cond1_sheath_wirearray11"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond1_sheath_wirearray11_eps_r * eps0", region=["Cond1_sheath_wirearray11"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond1_sheath_strip12_mu_r)", region=["Cond1_sheath_strip12"])
add!(func2, "sigma", expression="1. / Cond1_sheath_strip12_rho", region=["Cond1_sheath_strip12"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond1_sheath_strip12_eps_r * eps0", region=["Cond1_sheath_strip12"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond1_sheath_semicon2_mu_r)", region=["Cond1_sheath_semicon2"])
add!(func2, "sigma", expression="1. / Cond1_sheath_semicon2_rho", region=["Cond1_sheath_semicon2"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond1_sheath_semicon2_eps_r * eps0", region=["Cond1_sheath_semicon2"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond1_jacket_tubular11_mu_r)", region=["Cond1_jacket_tubular11"])
add!(func2, "sigma", expression="1. / Cond1_jacket_tubular11_rho", region=["Cond1_jacket_tubular11"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond1_jacket_tubular11_eps_r * eps0", region=["Cond1_jacket_tubular11"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond1_jacket_insulator2_mu_r)", region=["Cond1_jacket_insulator2"])
add!(func2, "sigma", expression="1. / Cond1_jacket_insulator2_rho", region=["Cond1_jacket_insulator2"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond1_jacket_insulator2_eps_r * eps0", region=["Cond1_jacket_insulator2"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond1_jacket_insulator3_mu_r)", region=["Cond1_jacket_insulator3"])
add!(func2, "sigma", expression="1. / Cond1_jacket_insulator3_rho", region=["Cond1_jacket_insulator3"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond1_jacket_insulator3_eps_r * eps0", region=["Cond1_jacket_insulator3"])
add_space!(func2)

# --- Define properties for Conductor 2 components ---
add!(func2, "nu", expression="1. / (mu0 * Cond2_core_wirearray15_mu_r)", region=["Cond2_core_wirearray15"])
add!(func2, "sigma", expression="1. / Cond2_core_wirearray15_rho", region=["Cond2_core_wirearray15"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond2_core_wirearray15_eps_r * eps0", region=["Cond2_core_wirearray15"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond2_core_semicon2_mu_r)", region=["Cond2_core_semicon2"])
add!(func2, "sigma", expression="1. / Cond2_core_semicon2_rho", region=["Cond2_core_semicon2"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond2_core_semicon2_eps_r * eps0", region=["Cond2_core_semicon2"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond2_core_insulator3_mu_r)", region=["Cond2_core_insulator3"])
add!(func2, "sigma", expression="1. / Cond2_core_insulator3_rho", region=["Cond2_core_insulator3"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond2_core_insulator3_eps_r * eps0", region=["Cond2_core_insulator3"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond2_core_semicon4_mu_r)", region=["Cond2_core_semicon4"])
add!(func2, "sigma", expression="1. / Cond2_core_semicon4_rho", region=["Cond2_core_semicon4"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond2_core_semicon4_eps_r * eps0", region=["Cond2_core_semicon4"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond2_core_semicon5_mu_r)", region=["Cond2_core_semicon5"])
add!(func2, "sigma", expression="1. / Cond2_core_semicon5_rho", region=["Cond2_core_semicon5"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond2_core_semicon5_eps_r * eps0", region=["Cond2_core_semicon5"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond2_sheath_wirearray11_mu_r)", region=["Cond2_sheath_wirearray11"])
add!(func2, "sigma", expression="1. / Cond2_sheath_wirearray11_rho", region=["Cond2_sheath_wirearray11"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond2_sheath_wirearray11_eps_r * eps0", region=["Cond2_sheath_wirearray11"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond2_sheath_strip12_mu_r)", region=["Cond2_sheath_strip12"])
add!(func2, "sigma", expression="1. / Cond2_sheath_strip12_rho", region=["Cond2_sheath_strip12"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond2_sheath_strip12_eps_r * eps0", region=["Cond2_sheath_strip12"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond2_sheath_semicon2_mu_r)", region=["Cond2_sheath_semicon2"])
add!(func2, "sigma", expression="1. / Cond2_sheath_semicon2_rho", region=["Cond2_sheath_semicon2"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond2_sheath_semicon2_eps_r * eps0", region=["Cond2_sheath_semicon2"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond2_jacket_tubular11_mu_r)", region=["Cond2_jacket_tubular11"])
add!(func2, "sigma", expression="1. / Cond2_jacket_tubular11_rho", region=["Cond2_jacket_tubular11"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond2_jacket_tubular11_eps_r * eps0", region=["Cond2_jacket_tubular11"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond2_jacket_insulator2_mu_r)", region=["Cond2_jacket_insulator2"])
add!(func2, "sigma", expression="1. / Cond2_jacket_insulator2_rho", region=["Cond2_jacket_insulator2"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond2_jacket_insulator2_eps_r * eps0", region=["Cond2_jacket_insulator2"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond2_jacket_insulator3_mu_r)", region=["Cond2_jacket_insulator3"])
add!(func2, "sigma", expression="1. / Cond2_jacket_insulator3_rho", region=["Cond2_jacket_insulator3"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond2_jacket_insulator3_eps_r * eps0", region=["Cond2_jacket_insulator3"])
add_space!(func2)

# --- Define properties for Conductor 3 components ---
add!(func2, "nu", expression="1. / (mu0 * Cond3_core_wirearray15_mu_r)", region=["Cond3_core_wirearray15"])
add!(func2, "sigma", expression="1. / Cond3_core_wirearray15_rho", region=["Cond3_core_wirearray15"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond3_core_wirearray15_eps_r * eps0", region=["Cond3_core_wirearray15"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond3_core_semicon2_mu_r)", region=["Cond3_core_semicon2"])
add!(func2, "sigma", expression="1. / Cond3_core_semicon2_rho", region=["Cond3_core_semicon2"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond3_core_semicon2_eps_r * eps0", region=["Cond3_core_semicon2"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond3_core_insulator3_mu_r)", region=["Cond3_core_insulator3"])
add!(func2, "sigma", expression="1. / Cond3_core_insulator3_rho", region=["Cond3_core_insulator3"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond3_core_insulator3_eps_r * eps0", region=["Cond3_core_insulator3"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond3_core_semicon4_mu_r)", region=["Cond3_core_semicon4"])
add!(func2, "sigma", expression="1. / Cond3_core_semicon4_rho", region=["Cond3_core_semicon4"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond3_core_semicon4_eps_r * eps0", region=["Cond3_core_semicon4"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond3_core_semicon5_mu_r)", region=["Cond3_core_semicon5"])
add!(func2, "sigma", expression="1. / Cond3_core_semicon5_rho", region=["Cond3_core_semicon5"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond3_core_semicon5_eps_r * eps0", region=["Cond3_core_semicon5"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond3_sheath_wirearray11_mu_r)", region=["Cond3_sheath_wirearray11"])
add!(func2, "sigma", expression="1. / Cond3_sheath_wirearray11_rho", region=["Cond3_sheath_wirearray11"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond3_sheath_wirearray11_eps_r * eps0", region=["Cond3_sheath_wirearray11"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond3_sheath_strip12_mu_r)", region=["Cond3_sheath_strip12"])
add!(func2, "sigma", expression="1. / Cond3_sheath_strip12_rho", region=["Cond3_sheath_strip12"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond3_sheath_strip12_eps_r * eps0", region=["Cond3_sheath_strip12"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond3_sheath_semicon2_mu_r)", region=["Cond3_sheath_semicon2"])
add!(func2, "sigma", expression="1. / Cond3_sheath_semicon2_rho", region=["Cond3_sheath_semicon2"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond3_sheath_semicon2_eps_r * eps0", region=["Cond3_sheath_semicon2"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond3_jacket_tubular11_mu_r)", region=["Cond3_jacket_tubular11"])
add!(func2, "sigma", expression="1. / Cond3_jacket_tubular11_rho", region=["Cond3_jacket_tubular11"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond3_jacket_tubular11_eps_r * eps0", region=["Cond3_jacket_tubular11"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond3_jacket_insulator2_mu_r)", region=["Cond3_jacket_insulator2"])
add!(func2, "sigma", expression="1. / Cond3_jacket_insulator2_rho", region=["Cond3_jacket_insulator2"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond3_jacket_insulator2_eps_r * eps0", region=["Cond3_jacket_insulator2"])
add_space!(func2)

add!(func2, "nu", expression="1. / (mu0 * Cond3_jacket_insulator3_mu_r)", region=["Cond3_jacket_insulator3"])
add!(func2, "sigma", expression="1. / Cond3_jacket_insulator3_rho", region=["Cond3_jacket_insulator3"]) # Using region kwarg
add!(func2, "epsilon", expression="Cond3_jacket_insulator3_eps_r * eps0", region=["Cond3_jacket_insulator3"])
add_space!(func2)

# --- Energization parameters ---
add_constant!(func2, "Pa", 0.0)
add_constant!(func2, "Pb", "-120./180.*Pi")
add_constant!(func2, "Pc", "-240./180.*Pi")

add_constant!(func2, "I", 1.0)
add_constant!(func2, "V", 1.0)
add_space!(func2)

# Other parameters
add!(func2, "Ns", expression="1")
add!(func2, "Sc", expression="SurfaceArea[]") # Assuming SurfaceArea[] helper exists or is defined elsewhere
add_space!(func2)

# Flags for basis function degrees
add_constant!(func2, "Flag_Degree_a", "1")
add_constant!(func2, "Flag_Degree_v", "1")

add_space!(func2)

problem.function_obj = [func1, func2]

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

# Assign Constraint to Problem
problem.constraint = constraint

# Generate and write the .pro file
make_file!(problem)

# Add Macro, Include, and conditional Include statements
add_raw_code!(
  problem,
  """
//---
Macro Change_post_options
Echo[Str[ "nv = PostProcessing.NbViews;",
    "For v In {0:nv-1}",
    "View[v].NbIso = 25;",
    "View[v].RangeType = 3;" ,// per timestep
    "View[v].ShowTime = 0;",
    "View[v].IntervalsType = 3;",
    "EndFor"
], File "res/pos.opt"];
Return

Include "jacobian_integration.pro"; // Normally no modification is needed

// The following files contain: basis functions, formulations, resolution, post-processing, post-operation
// Some adaptations may be needed
If (Flag_AnalysisType == 0)
    Include "electrodynamic_formulation.pro";
EndIf

If (Flag_AnalysisType == 1)
    Include "darwin_formulation.pro";
EndIf
"""
)


# Write the code to a file
problem.filename = "problem_definition.pro"
write_file!(problem)
