push!(LOAD_PATH, joinpath(@__DIR__, "..", "src")) # hide
using GetDP
# using GetDP: Resolution

# Create a Problem object
problem = Problem()

# Create a new Problem instance
functionspace = FunctionSpace()

# FunctionSpace section
fs1 = add!(functionspace, "Hcurl_a_Mag_2D", nothing, nothing, Type = "Form1P")
add_basis_function!(
    functionspace,
    "se",
    "ae",
    "BF_PerpendicularEdge";
    Support = "Domain_Mag",
    Entity = "NodesOf[ All ]",
)

add_constraint!(functionspace, "ae", "NodesOf", "MagneticVectorPotential_2D")

fs1 = add!(functionspace, "Hregion_i_2D", nothing, nothing, Type = "Vector")
add_basis_function!(
    functionspace,
    "sr",
    "ir",
    "BF_RegionZ";
    Support = "DomainS_Mag",
    Entity = "DomainS_Mag",
)
add_global_quantity!(functionspace, "Is", "AliasOf"; NameOfCoef = "ir")
add_global_quantity!(functionspace, "Us", "AssociatedWith"; NameOfCoef = "ir")
add_constraint!(functionspace, "Us", "Region", "Voltage_2D")
add_constraint!(functionspace, "Is", "Region", "Current_2D")


fs3 = add!(functionspace, "Hregion_u_Mag_2D", nothing, nothing, Type = "Form1P")
add_basis_function!(
    functionspace,
    "sr",
    "ur",
    "BF_RegionZ";
    Support = "DomainC_Mag",
    Entity = "DomainC_Mag",
)
add_global_quantity!(functionspace, "U", "AliasOf"; NameOfCoef = "ur")
add_global_quantity!(functionspace, "I", "AssociatedWith"; NameOfCoef = "ur")
add_constraint!(functionspace, "U", "Region", "Voltage_2D")
add_constraint!(functionspace, "I", "Region", "Current_2D")

fs1 = add!(functionspace, "Hgrad_Thermal", nothing, nothing, Type = "Form0")
add_basis_function!(
    functionspace,
    "sn",
    "t",
    "BF_Node";
    Support = "Domain_Thermal",
    Entity = "NodesOf[ All ]",
)

add_constraint!(functionspace, "t", "NodesOf", "DirichletTemp")

problem.functionspace = functionspace

# Define Formulation
formulation = GetDP.Formulation()

form = add!(formulation, "Darwin_a_2D", "FemEquation")
add_quantity!(form, "a", Type = "Local", NameOfSpace = "Hcurl_a_Mag_2D")

add_quantity!(form, "ur", Type = "Local", NameOfSpace = "Hregion_u_Mag_2D")
add_quantity!(form, "I", Type = "Global", NameOfSpace = "Hregion_u_Mag_2D [I]")
add_quantity!(form, "U", Type = "Global", NameOfSpace = "Hregion_u_Mag_2D [U]")

add_quantity!(form, "ir", Type = "Local", NameOfSpace = "Hregion_i_2D")
add_quantity!(form, "Us", Type = "Global", NameOfSpace = "Hregion_i_2D[Us]")
add_quantity!(form, "Is", Type = "Global", NameOfSpace = "Hregion_i_2D[Is]")

add_quantity!(form, "T", Type = "Local", NameOfSpace = "Hgrad_Thermal")

eq = add_equation!(form)

add!(
    eq,
    "Galerkin",
    "[ nu[] * Dof{d a} , {d a} ]",
    In = "Domain_Mag",
    Jacobian = "Vol",
    Integration = "I1",
)
add!(
    eq,
    "Galerkin",
    "DtDof [ sigma[{T}] * Dof{a} , {a} ]",
    In = "DomainC_Mag",
    Jacobian = "Vol",
    Integration = "I1",
)
add!(
    eq,
    "Galerkin",
    "[ sigma[{T}] * Dof{ur}, {a} ]",
    In = "DomainC_Mag",
    Jacobian = "Vol",
    Integration = "I1",
)
add!(
    eq,
    "Galerkin",
    "DtDof [ sigma[{T}] * Dof{a} , {ur} ]",
    In = "DomainC_Mag",
    Jacobian = "Vol",
    Integration = "I1",
)
add!(
    eq,
    "Galerkin",
    "[ sigma[{T}] * Dof{ur}, {ur}]",
    In = "DomainC_Mag",
    Jacobian = "Vol",
    Integration = "I1",
)
add!(
    eq,
    "Galerkin",
    "DtDtDof [ epsilon[] * Dof{a} , {a}]",
    In = "DomainC_Mag",
    Jacobian = "Vol",
    Integration = "I1",
    comment = " Darwin approximation term",
)
add!(
    eq,
    "Galerkin",
    "DtDof[ epsilon[] * Dof{ur}, {a} ]",
    In = "DomainC_Mag",
    Jacobian = "Vol",
    Integration = "I1",
)
add!(
    eq,
    "Galerkin",
    "DtDtDof [ epsilon[] * Dof{a} , {ur}]",
    In = "DomainC_Mag",
    Jacobian = "Vol",
    Integration = "I1",
)
add!(
    eq,
    "Galerkin",
    "DtDof[ epsilon[] * Dof{ur}, {ur} ]",
    In = "DomainC_Mag",
    Jacobian = "Vol",
    Integration = "I1",
)
add!(eq, "GlobalTerm", "[ Dof{I} , {U} ]", In = "DomainCWithI_Mag") #DomainActive

add!(
    eq,
    "Galerkin",
    "[ -js0[] , {a} ]",
    In = "DomainS0_Mag",
    Jacobian = "Vol",
    Integration = "I1",
    )
    
    add!(
        eq,
        "Galerkin",
        "[ -Ns[]/Sc[] * Dof{ir}, {a} ]",
        In = "DomainS_Mag",
        Jacobian = "Vol",
        Integration = "I1",
        )
add!(
    eq,
    "Galerkin",
    "DtDof [ Ns[]/Sc[] * Dof{a}, {ir} ]",
    In = "DomainS_Mag",
    Jacobian = "Vol",
    Integration = "I1",
    )
add!(
    eq,
    "Galerkin",
    "[ Ns[]/Sc[] / sigma[{T}] * Ns[]/Sc[]* Dof{ir} , {ir} ]",
    In = "DomainS_Mag",
    Jacobian = "Vol",
    Integration = "I1",
)
add!(eq, "GlobalTerm", "[ Dof{Us} , {Is} ]", In = "DomainS_Mag") #DomainActive


form = add!(formulation, "ThermalSta", "FemEquation")
add_quantity!(form, "T", Type = "Local", NameOfSpace = "Hgrad_Thermal")
add_quantity!(form, "a", Type = "Local", NameOfSpace = "Hcurl_a_Mag_2D")
add_quantity!(form, "ir", Type = "Local", NameOfSpace = "Hregion_i_2D")
add_quantity!(form, "ur", Type = "Local", NameOfSpace = "Hregion_u_Mag_2D")

eq = add_equation!(form)

add!(
    eq,
    "Galerkin",
    "[ k[] * Dof{d T} , {d T} ]",
    In = "Vol_Thermal",
    Jacobian = "Vol",
    Integration = "I1",
)

add!(
    eq,
    "Galerkin",
    "[ -0.5*sigma[{T}] * <a>[ SquNorm[Dt[{a}]+{ur}] ], {T} ]",
    In = "Vol_QSource_Thermal",
    Jacobian = "Vol",
    Integration = "I1",
)
add!(
    eq,
    "Galerkin",
    "[ -0.5/sigma[{T}] * <a>[ SquNorm[js0[]] ], {T} ]",
    In = "Vol_QSource0_Thermal",
    Jacobian = "Vol",
    Integration = "I1",
)
add!(
    eq,
    "Galerkin",
    "[ -0.5/sigma[{T}] * <ir>[ SquNorm[Ns[]/Sc[]*{ir}] ], {T} ]",
    In = "Vol_QSourceB_Thermal",
    Jacobian = "Vol",
    Integration = "I1",
)

add!(
    eq,
    "Galerkin",
    "[ h[] * Dof{T} , {T} ]",
    In = "Sur_Convection_Thermal",
    Jacobian = "Sur",
    Integration = "I1",
)
add!(
    eq,
    "Galerkin",
    "[-h[] * Tambient[] , {T} ]",
    In = "Sur_Convection_Thermal",
    Jacobian = "Sur",
    Integration = "I1",
)
problem.formulation = formulation

# Define Resolution
resolution = Resolution()

# Manually add multiple systems
sys_mag = SystemItem("Sys_Mag", "Darwin_a_2D"; 
    Type="Complex", 
    Frequency="Freq"
)

sys_the = SystemItem("Sys_The", "ThermalSta")

add!(resolution, "Magneto_thermal", [sys_mag, sys_the],
    Operation=[
    "CreateDir[\"res\"]",
    "InitSolution[Sys_Mag]",
    "InitSolution[Sys_The]",
    "Generate[Sys_Mag]",
    "Solve[Sys_Mag]",
    "Generate[Sys_The]",
    "Solve[Sys_The]",
    "SaveSolution[Sys_Mag]",
    "SaveSolution[Sys_The]",
    # "PostOperation[Mag_Maps]",
    "PostOperation[Mag_Global]",
    "PostOperation[The_Maps]",
])

# Add the resolution to the problem
problem.resolution = resolution

# PostProcessing section
postprocessing = PostProcessing()

# --- Darwin_a_2D ---
pp_darwin = add!(postprocessing, "Darwin_a_2D", "Darwin_a_2D")

q = add!(pp_darwin, "a")
add!(q, "Term", "{a}"; In="Domain_Mag", Jacobian="Vol")

q = add!(pp_darwin, "az")
add!(q, "Term", "CompZ[{a}]"; In="Domain_Mag", Jacobian="Vol")

q = add!(pp_darwin, "b")
add!(q, "Term", "{d a}"; In="Domain_Mag", Jacobian="Vol")

q = add!(pp_darwin, "bm")
add!(q, "Term", "Norm[{d a}]"; In="Domain_Mag", Jacobian="Vol")

q = add!(pp_darwin, "j")
add!(q, "Term", "-sigma[{T}]*(Dt[{a}]+{ur})"; In="DomainC_Mag", Jacobian="Vol")
add!(q, "Term", "js0[]"; In="DomainS0_Mag", Jacobian="Vol")
add!(q, "Term", "Ns[]/Sc[]*{ir}"; In="DomainS_Mag", Jacobian="Vol")

q = add!(pp_darwin, "jz")
add!(q, "Term", "CompZ[-sigma[{T}]*(Dt[{a}]+{ur})]"; In="DomainC_Mag", Jacobian="Vol")
add!(q, "Term", "CompZ[js0[]]"; In="DomainS0_Mag", Jacobian="Vol")
add!(q, "Term", "CompZ[Ns[]/Sc[]*{ir}]"; In="DomainS_Mag", Jacobian="Vol")

q = add!(pp_darwin, "jm")
add!(q, "Term", "Norm[-sigma[{T}]*(Dt[{a}]+{ur})]"; In="DomainC_Mag", Jacobian="Vol")
add!(q, "Term", "Norm[js0[]]"; In="DomainS0_Mag", Jacobian="Vol")
add!(q, "Term", "Norm[Ns[]/Sc[]*{ir}]"; In="DomainS_Mag", Jacobian="Vol")

q = add!(pp_darwin, "d")
add!(q, "Term", "epsilon[] * Dt[Dt[{a}]+{ur}]"; In="DomainC_Mag", Jacobian="Vol")

q = add!(pp_darwin, "dz")
add!(q, "Term", "CompZ[epsilon[] * Dt[Dt[{a}]+{ur}]]"; In="DomainC_Mag", Jacobian="Vol")

q = add!(pp_darwin, "dm")
add!(q, "Term", "Norm[epsilon[] * Dt[Dt[{a}]+{ur}]]"; In="DomainC_Mag", Jacobian="Vol")

q = add!(pp_darwin, "rhoj2"; comment=" local losses")
add!(q, "Term", "0.5*sigma[{T}]*SquNorm[Dt[{a}]+{ur}]"; In="DomainC_Mag", Jacobian="Vol")
add!(q, "Term", "0.5/sigma[{T}]*SquNorm[js0[]]"; In="DomainS0_Mag", Jacobian="Vol")
add!(q, "Term", "0.5/sigma[{T}]*SquNorm[Ns[]/Sc[]*{ir}]"; In="DomainS_Mag", Jacobian="Vol")

q = add!(pp_darwin, "JouleLosses"; comment=" global losses")
add!(q, "Integral", "0.5*sigma[{T}]*SquNorm[Dt[{a}]+{ur}]"; In="DomainC_Mag", Jacobian="Vol", Integration="I1")
add!(q, "Integral", "0.5/sigma[{T}]*SquNorm[js0[]]"; In="DomainS0_Mag", Jacobian="Vol", Integration="I1")
add!(q, "Integral", "0.5/sigma[{T}]*SquNorm[Ns[]/Sc[]*{ir}]"; In="DomainS_Mag", Jacobian="Vol", Integration="I1")

q = add!(pp_darwin, "U")
add!(q, "Term", "{U}"; In="DomainC_Mag")
add!(q, "Term", "{Us}"; In="DomainS_Mag")

q = add!(pp_darwin, "I")
add!(q, "Term", "{I}"; In="DomainC_Mag")
add!(q, "Term", "{Is}"; In="DomainS_Mag")

q = add!(pp_darwin, "S")
add!(q, "Term", "{U}*Conj[{I}]"; In="DomainC_Mag")
add!(q, "Term", "{Us}*Conj[{Is}]"; In="DomainS_Mag")

q = add!(pp_darwin, "R")
add!(q, "Term", "-Re[{U}/{I}]"; In="DomainC_Mag")
add!(q, "Term", "-Re[{Us}/{Is}]"; In="DomainS_Mag")

q = add!(pp_darwin, "L")
add!(q, "Term", "-Im[{U}/{I}]/(2*Pi*Freq)"; In="DomainC_Mag")
add!(q, "Term", "-Im[{Us}/{Is}]/(2*Pi*Freq)"; In="DomainS_Mag")

q = add!(pp_darwin, "R_per_km"; comment=" For convenience... possible scaling")
add!(q, "Term", "-Re[{U}/{I}]*1e3"; In="DomainC_Mag")
add!(q, "Term", "-Re[{Us}/{Is}]*1e3"; In="DomainS_Mag")

q = add!(pp_darwin, "mL_per_km")
add!(q, "Term", "-1e6*Im[{U}/{I}]/(2*Pi*Freq)"; In="DomainC_Mag")
add!(q, "Term", "-1e6*Im[{Us}/{Is}]/(2*Pi*Freq)"; In="DomainS_Mag")


# --- ThermalSta ---
pp_the = add!(postprocessing, "ThermalSta", "ThermalSta")

q = add!(pp_the, "T")
add!(q, "Term", "{T}"; In = "Domain_Mag", Jacobian = "Vol")

q = add!(pp_the, "TinC")
add!(q, "Term", "{T}-273.15"; In = "Domain_Mag", Jacobian = "Vol")

q = add!(pp_the, "q")
add!(q, "Term", "-k[]*{d T}"; In = "Domain_Mag", Jacobian = "Vol")

# --- Assign to problem ---
problem.postprocessing = postprocessing

# PostOperation section
postoperation = PostOperation()

# Add post-operation items
po1 = add!(postoperation, "Mag_Maps", "Darwin_a_2D")
po2 = add!(postoperation, "Mag_Global", "Darwin_a_2D")
po3 = add!(postoperation, "The_Maps", "ThermalSta")

# Add operations for maps
op1 = add_operation!(po1)  # Creates a POBase_ for po1

add_operation!(op1, "Print[ az, OnElementsOf Domain_Mag, //Smoothing 1\n        Name \"flux lines: Az [T m]\", File \"res/az.pos\" ];")
add_operation!(op1, "Echo[Str[\"View[PostProcessing.NbViews-1].RangeType = 3;\", // per timestep\n    \"View[PostProcessing.NbViews-1].NbIso = 25;\",\n    \"View[PostProcessing.NbViews-1].IntervalsType = 1;\" // isolines\n    ], File \"res/maps.opt\"];")
add_operation!(op1, "Print[ b, OnElementsOf Domain_Mag, //Smoothing 1,\n        Name \"B [T]\", File \"res/b.pos\" ];")
add_operation!(op1, "Echo[Str[\"View[PostProcessing.NbViews-1].RangeType = 3;\", // per timestep\n    \"View[PostProcessing.NbViews-1].IntervalsType = 2;\"\n    ], File \"res/maps.opt\"];")
add_operation!(op1, "Print[ bm, OnElementsOf Domain_Mag,\n        Name \"|B| [T]\", File \"res/bm.pos\" ];")
add_operation!(op1, "Echo[Str[\"View[PostProcessing.NbViews-1].RangeType = 3;\", // per timestep\n    \"View[PostProcessing.NbViews-1].ShowTime = 0;\",\n    \"View[PostProcessing.NbViews-1].IntervalsType = 2;\"\n    ], File \"res/maps.opt\"];")
add_operation!(op1, "Print[ jz, OnElementsOf Region[{DomainC_Mag, DomainS_Mag}],\n        Name \"jz [A/m^2] Conducting domain\", File \"res/jz_inds.pos\" ];")
add_operation!(op1, "Echo[Str[\"View[PostProcessing.NbViews-1].RangeType = 3;\", // per timestep\n    \"View[PostProcessing.NbViews-1].IntervalsType = 2;\"\n    ], File \"res/maps.opt\"];")
add_operation!(op1, "Print[ rhoj2, OnElementsOf Region[{DomainC_Mag, DomainS_Mag}],\n        Name \"Power density\", File \"res/rhoj2.pos\" ];")
add_operation!(op1, "Echo[Str[\"View[PostProcessing.NbViews-1].RangeType = 3;\", // per timestep\n    \"View[PostProcessing.NbViews-1].ShowTime = 0;\",\n    \"View[PostProcessing.NbViews-1].IntervalsType = 2;\"\n    ], File \"res/maps.opt\"];")
add_operation!(op1, "Print[ jm, OnElementsOf DomainC_Mag,\n        Name \"|j| [A/m^2] Conducting domain\", File \"res/jm.pos\" ];")
add_operation!(op1, "Echo[Str[\"View[PostProcessing.NbViews-1].RangeType = 3;\", // per timestep\n    \"View[PostProcessing.NbViews-1].ShowTime = 0;\",\n    \"View[PostProcessing.NbViews-1].IntervalsType = 2;\"\n    ], File \"res/maps.opt\"];")
add_operation!(op1, "Print[ dm, OnElementsOf DomainC_Mag,\n        Name \"|D| [A/m²]\", File \"res/dm.pos\" ];")
add_operation!(op1, "Echo[Str[\"View[PostProcessing.NbViews-1].RangeType = 3;\", // per timestep\n    \"View[PostProcessing.NbViews-1].ShowTime = 0;\",\n    \"View[PostProcessing.NbViews-1].IntervalsType = 2;\"\n    ], File \"res/maps.opt\"];")

add_raw_code!(po1, "po = \"{01Losses/\";")
add_raw_code!(po1, "po2 = \"{02PU-parameters/\";")

op2 = add_operation!(po2)  # Creates a POBase_ for po2
add_operation!(op2, "Print[ JouleLosses[DomainC_Mag], OnGlobal, Format Table,\n    SendToServer StrCat[po,\"0Total conducting domain\"],\n    Units \"W/m\", File \"res/losses_total.dat\" ];", comment=" You may restrict DomainC_Mag to part of it")
add_operation!(op2, "Print[ JouleLosses[Inds], OnGlobal, Format Table,\n    SendToServer StrCat[po,\"3Source (stranded OR massive)\"],\n    Units \"W/m\", File \"res/losses_inds.dat\" ];")
add_operation!(op2, "Print[ R, OnRegion Ind_1, Format Table,\n    SendToServer StrCat[po2,\"0R\"],\n    Units \"Ω\", File \"res/Rinds.dat\" ];", comment=" Region to adapt according to your cable")
add_operation!(op2, "Print[ L, OnRegion Ind_1, Format Table,\n    SendToServer StrCat[po2,\"1L\"],\n    Units \"H\", File \"res/Linds.dat\" ];")
add_operation!(op2, "Print[ Zs[DomainC_Mag], OnRegion Inds, Format Table,\n    SendToServer StrCat[po2,\"2re(Zs)\"] {0},\n    Units \"Ω\", File \"res/Zsinds_C_Mag.dat\" ];")

# Add thermal post-operations
op3 = add_operation!(po3)

# All the thermal domain but the cable
add_operation!(op3, "Print[ TinC, OnElementsOf Region[{Vol_Thermal,-Cable}], Smoothing 1, Name \"T [°C] araound cable\",  File \"T.pos\" ];")
add_operation!(op3, "Print[ TinC , OnElementsOf Cable,  Name \"T [°C] Cable\", File \"T_cable.pos\" ];")
add_operation!(op3, "Print[ q , OnElementsOf Region[{Vol_Thermal,-Cable}], Name \"heat flux [W/m²] around cable\",  File \"q.pos\" ];")
add_operation!(op3, "Print[ q , OnElementsOf Cable, Name \"heat flux [W/m²] cable\",  File \"q_cable.pos\" ];")


# Add the post-operation to the problem
problem.postoperation = postoperation

# Generate and write the .pro file
make_problem!(problem)

# Write the code to a file
problem.filename = "Magneto_thermal.pro"
write_file(problem)
