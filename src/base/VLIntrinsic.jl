function intrinsic_value(contract::VLCallOptionContract, currentPriceValue::Float64)::VLResult

    # initialize -
    payoffValue = 0.0
    profitLossValue = 0.0
    
    # get data from the contract object -
    sense = contract.sense
    strikePrice = contract.strikePrice
    premiumValue = contract.premimumValue
    number_of_contracts = contract.numberOfContracts
    contract_multiplier = contract.contractMultiplier

    # compute the iv -
    if (sense == :buy)

        # compute the P/L -
        payoffValue = max(0.0, (currentPriceValue - strikePrice))
        profitLossValue = (payoffValue - premiumValue) 
        
    elseif (sense == :sell)
        
        # compute the P/L -
        payoffValue = min(0.0, -1.0 * (currentPriceValue - strikePrice))
        profitLossValue = (payoffValue + premiumValue) 
    end

    # compute the intrinsic value -
    iv = (contract_multiplier) * (number_of_contracts) * payoffValue
    pl = (contract_multiplier) * (number_of_contracts) * profitLossValue

    # make a named tuple -
    named_tuple = (intrinsic_value = iv, pl_value = pl)

    # return -
    return VLResult(named_tuple)
end

function intrinsic_value(contract::VLPutOptionContract, currentPriceValue::Float64)::VLResult

    # initialize -
    payoffValue = 0.0
    profitLossValue = 0.0
    
    # get data from the contract object -
    sense = contract.sense
    strikePrice = contract.strikePrice
    premiumValue = contract.premimumValue
    number_of_contracts = contract.numberOfContracts
    contract_multiplier = contract.contractMultiplier

    # compute the iv -
    if (sense == :buy)

        # compute the P/L -
        payoffValue = max(0.0, (strikePrice - currentPriceValue))
        profitLossValue = (payoffValue - premiumValue) 
        
    elseif (sense == :sell)

        # compute the P/L -
        payoffValue = min(0.0, -1.0 * (strikePrice - currentPriceValue))
        profitLossValue = (payoffValue + premiumValue)
    end

    # compute the intrinsic value -
    pl = (contract_multiplier) * (number_of_contracts) * profitLossValue
    iv = (contract_multiplier) * (number_of_contracts) * payoffValue

    # make a named tuple -
    named_tuple = (intrinsic_value = iv, pl_value = pl)

    # return -
    return VLResult(named_tuple)
end

function intrinsic_value(equityObject::VLEquityAsset, currentPriceValue::Float64)::VLResult

    # initialize -
    iv = 0.0
    
    # get data from equityObject -
    purchasePricePerShare = equityObject.purchasePricePerShare
    numberOfShares = equityObject.numberOfShares

    # compute the intrinsic value -
    iv = numberOfShares * (currentPriceValue - purchasePricePerShare)

    # make a named tuple -
    named_tuple = (intrinsic_value = iv, pl_value = iv)

    # return -
    return VLResult(named_tuple)
end

function intrinsic_value(contractSet::Set{VLAbstractAsset}, underlyingPriceValue::Float64)::VLResult

    # initialize -
    tmp_iv_array = Float64[]

    # go through each contract, compute the iv, store -
    for (_, contract) in enumerate(contractSet)

        # compute -
        result = intrinsic_value(contract, underlyingPriceValue)
        if (isa(result.value, Exception) == true)
            return result
        end
        iv_value = result.value.intrinsic_value

        # store -
        push!(tmp_iv_array, iv_value)
    end

    # sum -
    total_iv_value = sum(tmp_iv_array)

    # return -
    return VLResult{Float64}(total_iv_value)
end

function compute_profit_loss_value(contractSet::Set{VLAbstractAsset}, underlyingPriceValue::Float64)::VLResult
    
    # initialize -
    tmp_pl_array = Float64[]

    # go through each contract, compute the iv, store -
    for (index, contract) in enumerate(contractSet)

        # compute -
        result = intrinsic_value(contract, underlyingPriceValue)
        if (isa(result.value, Exception) == true)
            return result
        end
        pl_value = result.value.pl_value

        # store -
        push!(tmp_pl_array, pl_value)
    end

    # sum -
    total_pl_value = sum(tmp_pl_array)

    # return -
    return VLResult{Float64}(total_pl_value)
end