# concrete result type -
struct VLResult{T}
    value::T
end

abstract type VLAbstractAsset end

struct VLEquityAsset <: VLAbstractAsset

    # data -
    assetSymbol::String
    purchasePricePerShare::Float64
    numberOfShares::Int64
    purchaseDate::Date
    
    function VLEquityAsset(assetSymbol::String, purchasePricePerShare::Float64, numberOfShares::Int64, purchaseDate::Date)
        this = new(assetSymbol, purchasePricePerShare, numberOfShares, purchaseDate)
    end
end

struct VLCallOptionContract <: VLAbstractAsset

    # data -
    assetSymbol::String
    strikePrice::Float64
    expirationDate::Date
    premimumValue::Float64
    numberOfContracts::Int64
    sense::Symbol
    contractMultiplier::Float64

    function VLCallOptionContract(assetSymbol::String, expirationDate::Union{Nothing,Date}, strikePrice::Float64, premimumValue::Float64, 
        numberOfContracts::Int64; sense::Symbol=:buy, contractMultiplier::Float64=100.0)
        
        this = new(assetSymbol, strikePrice, expirationDate, premimumValue, numberOfContracts, sense, contractMultiplier)
    end
end

struct VLPutOptionContract <: VLAbstractAsset

    # data -
    assetSymbol::String
    strikePrice::Float64
    expirationDate::Date
    premimumValue::Float64
    numberOfContracts::Int64
    sense::Symbol
    contractMultiplier::Float64

    function VLPutOptionContract(assetSymbol::String, expirationDate::Union{Nothing,Date}, strikePrice::Float64, premimumValue::Float64, 
        numberOfContracts::Int64; sense::Symbol=:buy, contractMultiplier::Float64=100.0)

        this = new(assetSymbol, strikePrice, expirationDate, premimumValue, numberOfContracts, sense, contractMultiplier)
    end
end
