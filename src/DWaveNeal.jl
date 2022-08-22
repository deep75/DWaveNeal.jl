module DWaveNeal

import Anneal
using PythonCall
using MathOptInterface
const MOI = MathOptInterface

# -*- :: Python D-Wave Simulated Annealing :: -*- #
const neal = PythonCall.pynew() # initially NULL

function __init__()
    PythonCall.pycopy!(neal, pyimport("neal"))
end

Anneal.@anew Optimizer begin
    name = "D-Wave Neal Simulated Annealing Sampler"
    version = v"0.5.8"
    attributes = begin
        "num_reads"::Integer = 1_000
        "num_sweeps"::Integer = 1_000
        "num_sweeps_per_beta"::Integer = 1
        "beta_range"::Union{Tuple{Float64,Float64},Nothing} = nothing
        "beta_schedule"::Union{Vector,Nothing} = nothing
        "beta_schedule_type"::Union{String,Nothing} = nothing
        "seed"::Union{Integer,Nothing} = nothing
        "initial_states_generator"::Union{String,Nothing} = nothing
        "interrupt_function"::Union{Function,Nothing} = nothing
    end
end

function Anneal.sample(sampler::Optimizer{T}) where {T}
    # ~ Retrieve Ising Model ~ #
    _, α, h, J, β = Anneal.ising(sampler)

    # ~ Instantiate Sampler (Python) ~ #
    neal_sampler = neal.SimulatedAnnealingSampler()

    # ~ Retrieve Optimizer Attributes ~ #
    params = Dict{Symbol,Any}(
        :num_reads => MOI.get(sampler, MOI.RawOptimizerAttribute("num_reads")),
        :num_sweeps => MOI.get(sampler, MOI.RawOptimizerAttribute("num_sweeps")),
        :num_sweeps_per_beta => MOI.get(sampler, MOI.RawOptimizerAttribute("num_sweeps_per_beta")),
        :beta_range => MOI.get(sampler, MOI.RawOptimizerAttribute("beta_range")),
        :beta_schedule => MOI.get(sampler, MOI.RawOptimizerAttribute("beta_schedule")),
        :beta_schedule_type => MOI.get(sampler, MOI.RawOptimizerAttribute("beta_schedule_type")),
        :seed => MOI.get(sampler, MOI.RawOptimizerAttribute("seed")),
        :initial_states_generator => MOI.get(sampler, MOI.RawOptimizerAttribute("initial_states_generator")),
        :interrupt_function => MOI.get(sampler, MOI.RawOptimizerAttribute("interrupt_function")),
    )

    # ~ Sample! ~ #
    results = @timed neal_sampler.sample_ising(h, J; params...)
    
    # ~ Basic Data Formatting ~ #
    records = results.value.record
    samples = Anneal.Sample{Int,T}[
        Anneal.Sample{Int,T}(
            pyconvert.(Int, ψ),        # state
            pyconvert(Int, n),         # reads
            α * (pyconvert(T, e) + β), # value
        )
        for (ψ, e, n) in records
    ]

    # ~ Write metadata ~ #
    metadata = Dict{String,Any}(
        "time" => Dict{String,Any}(
            "sample" => results.time
        )
    )

    # ~ Build SampleSet ~ #
    return Anneal.SampleSet{Int,T}(samples, metadata)
end

end # module
