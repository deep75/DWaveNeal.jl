# DWaveNeal.jl
[D-Wave Neal](https://docs.ocean.dwavesys.com/projects/neal/en/latest/) Simulated Annealing Interface for JuMP via [Anneal.jl](https://github.com/psrenergy/Anneal.jl).

## Installation
```julia
julia> import Pkg; Pkg.add("DWaveNeal")

julia> using DWaveNeal
```

## Getting started
```julia
using JuMP
using DWaveNeal

model = Model(DWaveNeal.Optimizer)

n = 3
Q = [ -1  2  2
       2 -1  2
       2  2 -1 ]

@variable(model, x[1:n], Bin)
@objective(model, Min, x' * Q * x)

optimize!(model)

for i = 1:result_count(model)
    x_i = value.(model[:x]; result = i)
    y_i = objective_value(model; result = i)

    println("[$i] f($(x_i)) = $(y_i)")
end
```

**Note**: _The D-Wave Neal wrapper for Julia is not officially supported by D-Wave Systems. If you are a commercial customer interested in official support for Julia from DWave, let them know!_

**Note**: _If you are using `DWaveNeal.jl` in your project, we recommend you to include the `.CondaPkg` entry in your `.gitignore` file. The `PythonCall` module will place a lot of files in this folder when building its Python environment._