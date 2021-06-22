# --- PRIVATE METHODS --------------------------------------------------------------------------------------- #
function _build_call_contract_object(data::Dict{String,Any})

    # grab stuff from data -
    # "symbol":"AMD",
    # "type":"call",
    # "sense":"sell",
    # "strike_price":60.0,
    # "premium_value":1.50,
    # "number_of_contracts":1,
    # "expiration":"2020-08-07"

    symbol = data["ticker_symbol"]
    sense = data["sense"]
    strike_price = data["strike_price"]
    premium_value = data["premium_value"]
    number_of_contracts = data["number_of_contracts"]
    expiration_date_string = data["expiration"]
    contract_multuplier = data["contract_multiplier"]

    # TODO - check sense, is this legit?
    # TODO - check is date string formatting correct?

    # build -
    callOptionContract = PSCallOptionContract(symbol, Date(expiration_date_string), strike_price, premium_value, number_of_contracts; 
        sense=Symbol(sense), contractMultiplier=contract_multuplier)

    # return -
    return VLResult(callOptionContract)
end

function _build_put_contract_object(data::Dict{String,Any})

    symbol = data["ticker_symbol"]
    sense = data["sense"]
    strike_price = data["strike_price"]
    premium_value = data["premium_value"]
    number_of_contracts = data["number_of_contracts"]
    expiration_date_string = data["expiration"]
    contract_multiplier = data["contract_multiplier"]

    # TODO - check sense, is this legit?
    # TODO - check is date string formatting correct?

    # build -
    putOptionContract = PSPutOptionContract(symbol, Date(expiration_date_string), strike_price, premium_value, number_of_contracts; 
        sense=Symbol(sense),contractMultiplier=contract_multiplier)

    # return -
    return VLResult(putOptionContract)
end

function _build_equity_object(data::Dict{String,Any})

    try

        # get stuff from dictionary -
        ticker_symbol = data["ticker_symbol"]
        purchase_price = data["purchase_price_per_share"]
        number_of_shares = data["number_of_shares"]
        purchase_date_string = data["purchase_date"]

        # build -
        equityObject = PSEquityAsset(ticker_symbol, purchase_price, number_of_shares, Date(purchase_date_string))

        # return -
        return VLResult(equityObject)
    catch error
        return VLResult(error)
    end
end
# ----------------------------------------------------------------------------------------------------------- #

# --- PUBLIC METHODS ---------------------------------------------------------------------------------------- #
function build_simulation_contract_set(simulation_dictionary::Dict{String,Any})::VLResult

    try

        # initialize -
        asset_set = Set{PSAbstractAsset}()

        # TODO: check - do we have the correct keys?

        # grab the list of asset dictionaries -
        asset_dictionary_array = simulation_dictionary["contract_set_parameters"]
        for (_, asset_dictionary) in enumerate(asset_dictionary_array)
            
            # initialize -
            local result = nothing

            # ok, so lets grab data from the asset_dictionary, and build each asset type -
            type_string = asset_dictionary["type"]
            type_symbol = Symbol(type_string)
            if (type_symbol == :call)
                result = _build_call_contract_object(asset_dictionary) |> check
            elseif (type_symbol == :put)
                result = _build_put_contract_object(asset_dictionary) |> check
            elseif (type_symbol == :equity)
                result = _build_equity_object(asset_dictionary) |> check
            end

            # grab -
            push!(asset_set, result)
        end

        # return -
        return VLResult(asset_set)

    catch error
        return VLResult(error)
    end
end

function build_simulation_contract_set(pathToSimulationFile::String)::VLResult

    try

        # load the experimet file -
        simulation_dictionary = JSON.parsefile(pathToSimulationFile)

        # build the contract set -
        return build_simulation_contract_set(simulation_dictionary)

    catch error
        return VLResult(error)
    end
end
# ----------------------------------------------------------------------------------------------------------- #