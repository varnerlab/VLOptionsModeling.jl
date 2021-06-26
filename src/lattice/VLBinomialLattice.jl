# --- PRIVATE METHODS BELOW HERE ----------------------------------------------------------------- #
function _compute_crr_index_array(numberOfLevels::Int64)
    
    # ok, so lets build an index array -
    number_items_per_level = [i for i = 1:numberOfLevels]
    tmp_array = Array{Int64,1}()
    theta = 0
    for value in number_items_per_level
        for index = 1:value
            push!(tmp_array, theta)
        end
        theta = theta + 1
    end

    N = sum(number_items_per_level[1:(numberOfLevels - 1)])
    index_array = Array{Int64,2}(undef, N, 3)
    for row_index = 1:N
    
        # index_array[row_index,1] = tmp_array[row_index]
        index_array[row_index,1] = row_index
        index_array[row_index,2] = row_index + 1 + tmp_array[row_index]
        index_array[row_index,3] = row_index + 2 + tmp_array[row_index]
    end

    return index_array
end

function _american_decision_logic(currentValue::Float64, futureValue::Float64)::Float64
    return max(currentValue, futureValue)
end

function _crr_movement_logic(latticeModel::VLBinomialLattice)::NamedTuple

    # initialize - get stuff from the lattice model -
    µ = latticeModel.µ
    σ = latticeModel.σ
    𝝙t = latticeModel.𝝙t

    # compute the movement up, down and probability -
    u = exp(σ * √𝝙t)
    d = exp(-σ * √𝝙t)
    p = (exp(µ * 𝝙t) - d) / (u - d)
    dfactor = exp(-µ * 𝝙t)

    # setup the tuple -
    movement_tuple = (up=u, down=d, probability=p, discount=dfactor)

    # return -
    return movement_tuple
end


# --- PRIVATE METHODS ABOVE HERE ----------------------------------------------------------------- #

# --- PUBLIC METHODS BELOW HERE ------------------------------------------------------------------ #
"""
    binomial_price(contractSet::Set{VLAbstractAsset}, latticeModel::VLBinomialLattice, underlyingPrice::Float64; 
        decisionLogic::Function = _american_decision_logic, movementLogic::Function = _crr_movement_logic) -> VLResult

Magical description goes here!
"""
function binomial_price(contractSet::Set{VLAbstractAsset}, latticeModel::VLBinomialLattice, underlyingPrice::Float64; 
    decisionLogic::Function=_american_decision_logic, movementLogic::Function = _crr_movement_logic)::VLResult

    try

        # initialize -
        numberOfLevels = latticeModel.numberOfLevels
        crr_index_array = _compute_crr_index_array(numberOfLevels)
        total_number_of_lattice_nodes = crr_index_array[end,end]    # the number of nodes will be the end, end element of the index array -
        number_of_nodes_to_evaluate = crr_index_array[end,1]        # the number of nodes that we need to evaluate is goven by the end x 1 element 
        
        # compute the movement using the movement function -
        movement_tuple = movementLogic(latticeModel)
        u = movement_tuple.up
        d = movement_tuple.down
        p = movement_tuple.probability
        dfactor = movement_tuple.discount
        
        # init the tree -
        tree_value_array = Array{Float64,2}(undef, total_number_of_lattice_nodes, 3) # nodes x 3 = col1: underlying price, col2: intrinsic value, col3: option price

        # First: let's compute the underlying price on the lattice -
        tree_value_array[1,1] = underlyingPrice
        for node_index = 1:number_of_nodes_to_evaluate
            
            # get index -
            parent_node_index = crr_index_array[node_index,1]
            up_node_index = crr_index_array[node_index,2]
            down_node_index = crr_index_array[node_index,3]
            
            # compute prices -
            parent_price = tree_value_array[parent_node_index,1]
            up_price = parent_price * u
            down_price = parent_price * d

            # store prices -
            tree_value_array[up_node_index,1] = up_price
            tree_value_array[down_node_index,1] = down_price
        end

        # Next: compute the intrinsice value for each node -
        for node_index = 1:total_number_of_lattice_nodes
            
             # ok, get the underlying price -
            underlying_price_value = tree_value_array[node_index,1]

            # compute the intrinsic value -
            iv_value = intrinsic_value(contractSet, underlying_price_value) |> check

            # capture - 
            tree_value_array[node_index,2] = iv_value
            tree_value_array[node_index,3] = iv_value
        end

        # Last: compute the option price -
        reverse_node_index_array = range(number_of_nodes_to_evaluate, stop=1, step=-1) |> collect
        for (_, parent_node_index) in enumerate(reverse_node_index_array)
            
            # ok, get the connected node indexes -
            up_node_index = crr_index_array[parent_node_index,2]
            down_node_index = crr_index_array[parent_node_index,3]

            # ok, let's compute the payback *if* we continue -
            future_payback = dfactor * (p * tree_value_array[up_node_index,3] + (1 - p) * tree_value_array[down_node_index,3])
            current_payback = tree_value_array[parent_node_index,2]
        
            # use the decision logic to compute price -
            node_price = decisionLogic(current_payback, future_payback)

            # capture -
            tree_value_array[parent_node_index,3] = node_price
        end

        # return -
        return VLResult(tree_value_array)
    catch error
        return VLResult(error)
    end
end

"""
    binomial_price(contractSet::Set{VLAbstractAsset}, latticeModel::VLBinomialLattice, underlyingPriceArray::Array{Float64,1};
        decisionLogic::Function = _american_decision_logic, movementLogic::Function = _crr_movement_logic) -> VLResult

Magical description goes here!
"""
function binomial_price(contractSet::Set{VLAbstractAsset}, latticeModel::VLBinomialLattice, underlyingPriceArray::Array{Float64,1};
    decisionLogic::Function=_american_decision_logic, movementLogic::Function = _crr_movement_logic)::VLResult

    try

        # initialize -
        number_of_underlying_prices = length(underlyingPriceArray)
        contract_price_array = Array{Float64,2}(undef, number_of_underlying_prices, 2)

        # ok, so let's simulate updating the strike price -
        for (index, underlying_price) in enumerate(underlyingPriceArray)

            # compute -
            price_tree = binomial_price(contractSet, latticeModel, underlying_price; decisionLogic=decisionLogic, movementLogic=movementLogic) |> check
            price_value = price_tree[1,3]   # the value of the contract is *always* the 1,3 element -

            # grab -
            contract_price_array[index,1] = underlying_price
            contract_price_array[index,2] = price_value
        end

        # return -
        return VLResult(contract_price_array)
    catch error
        return VLResult(error)
    end
end

"""
    binomial_price(contract::Union{VLCallOptionContract,VLPutOptionContract}, latticeModel::VLBinomialLattice, 
        underlyingPrice::Float64, strikPriceArray::Array{Float64,1}; 
            decisionLogic::Function = _american_decision_logic, movementLogic::Function = _crr_movement_logic) -> VLResult

Magical description goes here!
"""
function binomial_price(contract::Union{VLCallOptionContract,VLPutOptionContract}, latticeModel::VLBinomialLattice, 
    underlyingPrice::Float64, strikPriceArray::Array{Float64,1}; 
        decisionLogic::Function=_american_decision_logic, movementLogic::Function = _crr_movement_logic)::VLResult

    try

        # initialize -
        number_of_strike_prices = length(strikPriceArray)
        contract_price_array = Array{Float64,2}(undef, number_of_strike_prices, 2)

        # ok, so lets set the strike price and process the contract =
        for (index, strike_price) in enumerate(strikPriceArray)
            
            # set the price - 
            contract.strikePrice = strike_price

            # package -
            contract_set = Set{VLAbstractAsset}()
            push!(contract_set, contract)
        
            # calculate the contract price -
            price_tree = binomial_price(contract_set, latticeModel, underlyingPrice; decisionLogic=decisionLogic, movementLogic=movementLogic) |> check
            price_value = price_tree[1,3]   # the value of the contract is *always* the 1,3 element -

            # grab -
            contract_price_array[index,1] = strike_price
            contract_price_array[index,2] = price_value
        end

        # return -
        return VLResult(contract_price_array)
    catch error
        return VLResult(error)
    end
end

# --- PUBLIC METHODS ABOVE HERE ------------------------------------------------------------------ #
