module DoublePendulum

using NeuralOperators
using Flux
using CUDA
using JLD2

include("data.jl")

__init__() = register_double_pendulum_chaotic()

function update_model!(model_file_path, model)
    model = cpu(model)
    jldsave(model_file_path; model)
    @warn "model updated!"
end

function train(; Δt=2)
    if has_cuda()
        @info "CUDA is on"
        device = gpu
        CUDA.allowscalar(false)
    else
        device = cpu
    end

    m = Chain(
        Dense(1, 350), # (1, 2, 6, :) -> (350, 2, 6, :)
        x -> reshape(x, 1, 60, 70, :), # (350, 2, 6, :) -> (1, 60, 70, :)
        MarkovNeuralOperator(),
        x -> reshape(x, 350, 2, 6, :), # (1, 60, 70, :) -> (350, 2, 6, :)
        Dense(350, 1), # (350, 2, 6, :) -> (1, 2, 6, :)
    ) |> device

    loss(𝐱, 𝐲) = sum(abs2, 𝐲 .- m(𝐱)) / size(𝐱)[end]

    opt = Flux.Optimiser(WeightDecay(1f-4), Flux.ADAM(1f-3))

    loader_train, loader_test = get_dataloader(Δt=Δt)

    losses = Float32[]
    function validate()
        validation_loss = sum(loss(device(𝐱), device(𝐲)) for (𝐱, 𝐲) in loader_test)/length(loader_test)
        @info "loss: $validation_loss"

        push!(losses, validation_loss)
        (losses[end] == minimum(losses)) && update_model!(joinpath(@__DIR__, "../model/model.jld2"), m)
    end
    call_back = Flux.throttle(validate, 10, leading=false, trailing=true)

    data = [(𝐱, 𝐲) for (𝐱, 𝐲) in loader_train] |> device
    Flux.@epochs 50 @time(Flux.train!(loss, params(m), data, opt, cb=call_back))
end

function get_model()
    f = jldopen(joinpath(@__DIR__, "../model/model.jld2"))
    model = f["model"]
    close(f)

    return model
end

end
