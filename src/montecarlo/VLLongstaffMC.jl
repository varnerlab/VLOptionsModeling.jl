# --- PRIVATE METHODS BELOW HERE ----------------------------------------------------------------- #
# --- PRIVATE METHODS ABOVE HERE ----------------------------------------------------------------- #

# --- PUBLIC METHODS BELOW HERE ------------------------------------------------------------------ #
function lsm_price(contractSet::Set{VLAbstractAsset}, underlyingPriceTable::Array{Float64,2}; 
    riskFreeRate::Float64 = 0.015, decisionLogic::Function=_american_decision_logic)::VLResult

    # main -
    try

        # what is the size of the price table?
        (number_of_rows, number_of_cols) = size(underlyingPriceTable)


    catch error
        return VLResult(error)
    end
end
# --- PUBLIC METHODS ABOVE HERE ------------------------------------------------------------------ #