# --- PRIVATE METHODS BELOW HERE ----------------------------------------------------------------- #
# --- PRIVATE METHODS ABOVE HERE ----------------------------------------------------------------- #

# --- PUBLIC METHODS BELOW HERE ------------------------------------------------------------------ #
function 𝝙(contractSet::Set{VLAbstractAsset}, latticeModel::VLBinomialLattice, underlyingPrice::Float64; 
    decisionLogic::Function=_american_decision_logic)::VLResult

    try

        # initialize -
        baseUnderlyingPrice = underlyingPrice
        perturbedUnderlyingPrice = (baseUnderlyingPrice + 1.0)

        # compute the price for the base underlying value -
        base_price_tree = binomial_price(contractSet, latticeModel, baseUnderlyingPrice) |> check
        perturbed_price_tree = binomial_price(contractSet, latticeModel, perturbedUnderlyingPrice; decisionLogic=decisionLogic) |> check

        # compute delta -
        delta_value = perturbed_price_tree[1,3] - base_price_tree[1,3]

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