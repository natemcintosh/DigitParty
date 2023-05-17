function optimal_solution(numbers; max_number = 9)
    I, J = isqrt(length(numbers)), isqrt(length(numbers))
    grid = GridGraph(ones(Int, I, J); directions = GridGraphs.QUEEN_DIRECTIONS)

    V = 1:I*J
    E = [(src(e), dst(e)) for e in edges(grid)]
    K = 1:max_number

    numbers_count = [count(==(k), numbers) for k in K]

    model = Model(HiGHS.Optimizer)
    @variable(model, x[V, K], Bin)
    @variable(model, 0 .<= y[E, K] .<= 1)

    for v in V
        @constraint(model, sum(view(x, v, :)) == 1)
    end

    for k in K
        @constraint(model, sum(view(x, :, k)) == numbers_count[k])
    end

    for (u, v) in E, k in K
        @constraint(model, y[(u, v), k] <= x[u, k])
        @constraint(model, y[(u, v), k] <= x[v, k])
        @constraint(model, y[(u, v), k] >= x[u, k] + x[v, k] - 1)
    end

    @objective(model, Max, sum(k * y[(u, v), k] for (u, v) in E for k in K))

    set_attribute(model, "mip_abs_gap", 0.5)

    optimize!(model)

    x_sol = round.(Int, value.(x))
    solution = zeros(Int, I, J)
    for v in vertices(grid)
        (i, j) = GridGraphs.index_to_coord(grid, v)
        solution[i, j] = argmax(view(x_sol, v, :))
    end
    return solution
end
