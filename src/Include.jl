# setup project paths -
const _PATH_TO_SRC = dirname(pathof(@__MODULE__))
const _PATH_TO_BASE = joinpath(_PATH_TO_SRC, "base")
const _PATH_TO_EXPIRATION = joinpath(_PATH_TO_SRC, "expiration")
const _PATH_TO_LATTICE = joinpath(_PATH_TO_SRC, "lattice")
const _PATH_TO_MONTECARLO = joinpath(_PATH_TO_SRC, "montecarlo")

# import packages that we will use -
using JSON
using Dates
using DataFrames
using CSV
using Plots

# include our codes -
include(joinpath(_PATH_TO_BASE, "VLTypes.jl"))
include(joinpath(_PATH_TO_BASE, "VLBase.jl"))
include(joinpath(_PATH_TO_BASE, "VLFactory.jl"))
include(joinpath(_PATH_TO_BASE, "VLIntrinsic.jl"))
include(joinpath(_PATH_TO_EXPIRATION, "VLExpiration.jl"))
include(joinpath(_PATH_TO_LATTICE, "VLBinomialLattice.jl"))
include(joinpath(_PATH_TO_LATTICE, "VLLatticeGreeks.jl"))
include(joinpath(_PATH_TO_MONTECARLO, "VLLongstaffMC.jl"))
