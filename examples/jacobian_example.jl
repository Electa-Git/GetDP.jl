# This file contains the Jacobian definition originally implemented in Onelab by prof. Ruth Sabariego (ruth.sabariego@kuleuven.be)

push!(LOAD_PATH, joinpath(@__DIR__, "..", "src")) # hide
using GetDP

# Create a Problem object
problem = Problem()

# Initialize Jacobian
jac = Jacobian()

# Add Vol Jacobian
vol = add!(jac, "Vol")
add!(vol; Region="DomainInf", Jacobian=VolSphShell(Rint="Val_Rint", Rext="Val_Rext", center_X="Xcenter", center_Y="Ycenter", center_Z="Zcenter"))
add!(vol; Region="All", Jacobian="Vol")

# Add Sur Jacobian
sur = add!(jac, "Sur")
add!(sur; Region="All", Jacobian="Sur", comment="Attention: there is no spherical shell for lines in a surface domain")

# Add Jacobian to problem
problem.jacobian = jac

# Initialize Integration
integ = Integration()
i1 = add!(integ, "I1")
case = add!(i1)
gauss_case = add!(case; Type="Gauss")
geo_case = add_nested_case!(gauss_case)
add!(geo_case; GeoElement="Point", NumberOfPoints=1)
add!(geo_case; GeoElement="Line", NumberOfPoints=4)
add!(geo_case; GeoElement="Triangle", NumberOfPoints=4)
add!(geo_case; GeoElement="Quadrangle", NumberOfPoints=4)
add!(geo_case; GeoElement="Triangle2", NumberOfPoints=7)
problem.integration = integ

# Generate and write the .pro file
make_file!(problem)
# Generate and write the .pro file
problem.filename = "jacobian_by_jlgetdp.pro"
write_file(problem)