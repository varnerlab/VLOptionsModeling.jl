module VLOptionsModeling

    # include my codes -
    include("Include.jl")

    # export -
    export check
    export binomial_price
    export expiration

    # export types -
    export VLAbstractAsset
    export VLAbstractLattice
    export VLBinomialLattice
    export VLEquityAsset
    export VLCallOptionContract
    export VLPutOptionContract

end # module
