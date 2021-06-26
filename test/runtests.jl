using VLOptionsModeling
using Test

# -- Model creation tests ------------------------------------------------------ #
function run_default_test() 
    return true
end
# ------------------------------------------------------------------------------- #


@testset "default_test_set" begin
    @test run_default_test() == true
end