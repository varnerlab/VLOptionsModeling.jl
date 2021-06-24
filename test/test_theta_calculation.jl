using VLOptionsModeling
using Plots

# create an emprt contract set for now -
contract_set = Set{VLAbstractAsset}()
assetSymbol = "XYZ"
strikePrice = 50.0
underlyingPrice = 50.0
expirationDate = nothing
premimumValue = 0.0
numberOfContracts = 1
sense = :buy
contractMultiplier = 1.0
put_contract = VLPutOptionContract(assetSymbol, strikePrice, premimumValue; sense=sense, contractMultiplier=contractMultiplier)
push!(contract_set, put_contract)

# setup the lattice (Example 19.1/Fig. 19.3 Hull)
𝝙t = 30.42 / (365.0) # years
μ = log(1.0084) * (1 / 𝝙t)
σ = (1 / √𝝙t) * log(1.1224)
numberOfLevels = 6

# what is eps -
eps = (29.42 / 30.42)

# Create the lattice model -
latticeModel = VLBinomialLattice(μ, σ, 𝝙t, numberOfLevels)

# compute delta -
theta_value = ϴ(contract_set, latticeModel, underlyingPrice, eps) |> check