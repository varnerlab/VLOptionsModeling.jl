# --- PRIVATE METHODS BELOW HERE ----------------------------------------------------------------- #
# --- PRIVATE METHODS ABOVE HERE ----------------------------------------------------------------- #

# --- PUBLIC METHODS BELOW HERE ------------------------------------------------------------------ #
function 𝝙(contractSet::Set{VLAbstractAsset}, latticeModel::VLBinomialLattice, underlyingPrice::Float64; 
    decisionLogic::Function=_american_decision_logic)::VLResult

    try

        # initialize -
        baseUnderlyingPrice = underlyingPrice
        𝛅 = 1.0
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

function ϴ()::VLResult

    try
    catch error
        return VLresult(error)
    end
end
# --- PUBLIC METHODS ABOVE HERE ------------------------------------------------------------------ #