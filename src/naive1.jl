
export Naive1, pick_next_spot

mutable struct Naive1 <: AbstractEngine
    spot_ranks::Vector{CartesianIndex{2}}
end

"""
rank spots by how many empty spots it has around it
for each new number {
pick spot that has same rank as number
re-rank spots
}
"""
function pick_next_spot(g::Game, e::Naive1)::CartesianIndex{2}
    # Rank spots by how many empty spots it has around it
    sort!(e.spot_ranks; by = idx -> how_many_empties(g, idx))

    next_number_rank = g.up_next[1] / 9
    idx_of_picked_spot = round(Int, (1 - next_number_rank) * length(e.spot_ranks))
    popat!(e.spot_ranks, idx_of_picked_spot)
end

