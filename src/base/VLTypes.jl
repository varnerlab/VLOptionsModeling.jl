using Base:Float64
# concrete result type -
struct VLResult{T}
    value::T
end

abstract type VLAbstractAsset end
abstract type VLAbstractLattice end

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
    expirationDate::Union{Nothing,Date}
    premimumValue::Float64
    numberOfContracts::Int64
    sense::Symbol
    contractMultiplier::Float64

    function VLPutOptionContract(assetSymbol::String, strikePrice::Float64, premimumValue::Float64; 
        expirationDate::Union{Nothing,Date}=nothing, numberOfContracts::Int64=1, sense::Symbol=:buy, contractMultiplier::Float64=100.0)

        _ = new(assetSymbol, strikePrice, expirationDate, premimumValue, numberOfContracts, sense, contractMultiplier)
    end
end

struct VLBinomialLattice <: VLAbstractLattice

    # data -
    μ::Float64
    σ::Float64
    𝝙t::Float64
    numberOfLevels::Int64

    function VLBinomialLattice(μ::Float64, σ::Float64, 𝝙t::Float64, numberOfLevels::Int64)
        _ = new(μ, σ, 𝝙t, numberOfLevels)
    end
end

