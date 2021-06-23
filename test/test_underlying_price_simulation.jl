using VLOptionsModeling
using Plots

# create an emprt contract set for now -
assetSymbol = "XYZ"
strikePrice = 50.0
expirationDate = nothing
premimumValue = 0.0
numberOfContracts = 1
sense = :buy
contractMultiplier = 1.0
put_contract = VLPutOptionContract(assetSymbol, strikePrice, premimumValue; sense=sense, contractMultiplier=contractMultiplier)

# setup the lattice (Example 19.1/Fig. 19.3 Hull)
𝝙t = 30.42 / (365.0) # years
μ = log(1.0084) * (1 / 𝝙t)
σ = (1 / √𝝙t) * log(1.1224)
numberOfLevels = 36

# Create the lattice model -
latticeModel_1 = VLBinomialLattice(μ, σ, 𝝙t, numberOfLevels)
latticeModel_2 = VLBinomialLattice(μ, σ, 0.5 * 𝝙t, numberOfLevels)
latticeModel_3 = VLBinomialLattice(μ, σ, 0.25 * 𝝙t, numberOfLevels)
latticeModel_4 = VLBinomialLattice(μ, σ, 0.125 * 𝝙t, numberOfLevels)
latticeModel_5 = VLBinomialLattice(μ, σ, 0.0625 * 𝝙t, numberOfLevels)

# setup strike array -
underlying_price_array = range(35.0, stop=65.0, step=0.1) |> collect

# sim -
sim_array_1 = binomial_price(put_contract, latticeModel_1, underlying_price_array) |> check
sim_array_2 = binomial_price(put_contract, latticeModel_2, underlying_price_array) |> check
sim_array_3 = binomial_price(put_contract, latticeModel_3, underlying_price_array) |> check
sim_array_4 = binomial_price(put_contract, latticeModel_4, underlying_price_array) |> check
sim_array_5 = binomial_price(put_contract, latticeModel_5, underlying_price_array) |> check

# compute expiration -
contract_set = Set{VLAbstractAsset}()
push!(contract_set, put_contract)
expiration_array = expiration(contract_set, underlying_price_array) |> check

# plots -
plot(sim_array_1[:,1],sim_array_1[:,2])
plot!(sim_array_2[:,1],sim_array_2[:,2])
plot!(sim_array_3[:,1],sim_array_3[:,2])
plot!(sim_array_4[:,1],sim_array_4[:,2])
plot!(sim_array_5[:,1],sim_array_5[:,2])
plot!(expiration_array[:,1],expiration_array[:,2])