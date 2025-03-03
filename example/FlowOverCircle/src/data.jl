using WaterLily
using LinearAlgebra: norm2

"""
    circle(n, m; Re=250)

This function is copy from [WaterLily](https://github.com/weymouth/WaterLily.jl)
"""
function circle(n, m; Re=250)
    # Set physical parameters
    U, R, center = 1., m/8., [m/2, m/2]
    ν = U * R / Re

    body = AutoBody((x,t) -> norm2(x .- center) - R)
    Simulation((n+2, m+2), [U, 0.], R; ν, body)
end

function gen_data(ts::AbstractRange)
    n, m = 3(2^5), 2^6
    circ = circle(n, m)

    𝐩s = Array{Float32}(undef, 1, n, m, length(ts))
    for (i, t) in enumerate(ts)
        sim_step!(circ, t)
        𝐩s[1, :, :, i] .= Float32.(circ.flow.p)[2:end-1, 2:end-1]
    end

    return 𝐩s
end

function get_dataloader(; ts::AbstractRange=LinRange(100, 11000, 10000), ratio::Float64=0.95, batchsize=100)
    data = gen_data(ts)

    n_train, n_test = floor(Int, length(ts)*ratio), floor(Int, length(ts)*(1-ratio))

    𝐱_train, 𝐲_train = data[:, :, :, 1:(n_train-1)], data[:, :, :, 2:n_train]
    loader_train = Flux.DataLoader((𝐱_train, 𝐲_train), batchsize=batchsize, shuffle=true)

    𝐱_test, 𝐲_test = data[:, :, :, (end-n_test+1):(end-1)], data[:, :, :, (end-n_test+2):end]
    loader_test = Flux.DataLoader((𝐱_test, 𝐲_test), batchsize=batchsize, shuffle=false)

    return loader_train, loader_test
end
