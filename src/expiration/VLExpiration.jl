# --- PRIVATE METHODS --------------------------------------------------------------------------------------- #
function _compute_profit_loss_at_expiration(asset::VLAbstractAsset, assetPriceValueArray::Array{Float64,1})::Array{Float64,1}

    # initialize -
    pl_value_array = Array{Float64,1}()

    # compute the intrinsic value -
    for (index, asset_price_value) in enumerate(assetPriceValueArray)
        result = intrinsic_value(asset, asset_price_value)
        if (isa(result.value, Exception) == true)
            return result
        end
        pl_value = result.value.pl_value
        
        # grab -
        push!(pl_value_array, pl_value)
    end

    # call -
    return pl_value_array
end

function _compute_profit_loss_at_expiration(asset::VLAbstractAsset, assetPriceStart::Float64, assetPriceStop::Float64; 
    number_of_price_steps::Int64=1000)::Array{Float64,1}

    # setup price range -
    asset_price_range = collect(range(assetPriceStart, assetPriceStop, length=number_of_price_steps))

    # return -
    return _compute_profit_loss_at_expiration(asset, asset_price_range)
end
# ----------------------------------------------------------------------------------------------------------- #

function expiration(assetSet::Set{VLAbstractAsset}, assetPriceArray::Array{Float64,1})::VLResult

    try

        # get -
        number_of_price_steps = length(assetPriceArray)

        # initialize -
        number_of_assets = length(assetSet)
        assetProfitLossArray = zeros(number_of_price_steps, number_of_assets)
        tradeProfitLossArray = zeros(number_of_price_steps, 2) # firstCol: price, secondCol: PL

        # process the set of assets -
        for (assetIndex, assetObject) in enumerate(assetSet)
            
            # process each asset type -
            profit_loss_array = _compute_profit_loss_at_expiration(assetObject, assetPriceArray)

            # add the PL for this asset to the overall array -
            for index = 1:number_of_price_steps
                assetProfitLossArray[index,assetIndex] = profit_loss_array[index]
            end
        end

        # ok, so the assetProfitLossArray holds the PL for each asset type in its cols -
        # to get the PL for the entire trade at a particular stock price, then sum across the cols -
        for price_index = 1:number_of_price_steps
            
            # grab col -
            tmp_row = assetProfitLossArray[price_index,:]
        
            # add - 
            tradeProfitLossArray[price_index,1] = assetPriceArray[price_index]
            tradeProfitLossArray[price_index,2] = sum(tmp_row)
        end

        # return -
        return VLResult{Array{Float64,2}}(tradeProfitLossArray)
    catch error
        return VLResult(error)
    end
end
