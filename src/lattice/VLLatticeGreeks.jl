# --- PRIVATE METHODS BELOW HERE ----------------------------------------------------------------- #
# --- PRIVATE METHODS ABOVE HERE ----------------------------------------------------------------- #

# --- PUBLIC METHODS BELOW HERE ------------------------------------------------------------------ #
"""
    𝝙(contractSet::Set{VLAbstractAsset}, latticeModel::VLBinomialLattice, underlyingPrice::Float64; 
        decisionLogic::Function=_american_decision_logic) -> VLResult

Magical description goes here!
"""
function 𝝙(contractSet::Set{VLAbstractAsset}, latticeModel::VLBinomialLattice, underlyingPrice::Float64; 
    decisionLogic::Function=_american_decision_logic)::VLResult

    try

        # initialize -
        baseUnderlyingPrice = underlyingPrice
        𝛅 = 0.01 * baseUnderlyingPrice
        downPrice = (baseUnderlyingPrice - 𝛅)
        upPrice = (baseUnderlyingPrice + 𝛅)

        # compute the price for the base underlying value -
        up_price_tree = binomial_price(contractSet, latticeModel, upPrice; decisionLogic=decisionLogic) |> check
        down_price_tree = binomial_price(contractSet, latticeModel, downPrice; decisionLogic=decisionLogic) |> check

        # compute delta -
        delta_value = (up_price_tree[1,3] - down_price_tree[1,3]) / (2 * 𝛅)

        # return -
        return VLResult(delta_value)
    catch error
        return VLResult(error)
    end
end

"""
    ϴ(contractSet::Set{VLAbstractAsset}, latticeModel::VLBinomialLattice, underlyingPrice::Float64, eps::Float64; 
        decisionLogic::Function=_american_decision_logic) -> VLResult

Magical description goes here!
"""
function ϴ(contractSet::Set{VLAbstractAsset}, latticeModel::VLBinomialLattice, underlyingPrice::Float64, eps::Float64; 
    decisionLogic::Function=_american_decision_logic)::VLResult

    try

        baseUnderlyingPrice = underlyingPrice
        number_of_levels = latticeModel.numberOfLevels
        current_delta_T = latticeModel.𝝙t
        𝛅 = eps * current_delta_T
        
        # compute up and down price -
        theta_value = 0.0
        base_price_tree = binomial_price(contractSet, latticeModel, baseUnderlyingPrice; decisionLogic=decisionLogic) |> check
        latticeModel.𝝙t = 𝛅
        down_price_tree = binomial_price(contractSet, latticeModel, baseUnderlyingPrice; decisionLogic=decisionLogic) |> check

        # compute theta -
        theta_value = (down_price_tree[1,3] - base_price_tree[1,3])

        # return -
        return VLResult(theta_value)
    catch error
        return VLResult(error)
    end
end
# --- PUBLIC METHODS ABOVE HERE ------------------------------------------------------------------ #