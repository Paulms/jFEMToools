abstract type Shape{dim} end

getdim(::Shape{dim}) where {dim} = dim

#########################
# Triangles   #
#########################
struct Simplex{dim} <: Shape{dim} end
const Triangle = Simplex{2}
@inline get_num_faces(::Type{Triangle}) = 3
@inline get_num_vertices(::Type{Triangle}) = 3

function reference_coordinates(::Type{Triangle})
    [Tensors.Vec{2, Float64}((0.0, 0.0)),
    Tensors.Vec{2, Float64}((1.0, 0.0)),
    Tensors.Vec{2, Float64}((0.0, 1.0))]
end
function reference_edges(::Type{Triangle})
    [[Tensors.Vec{2, Float64}((1.0, 0.0)),Tensors.Vec{2, Float64}((0.0, 1.0))],
     [Tensors.Vec{2, Float64}((0.0, 1.0)),Tensors.Vec{2, Float64}((0.0, 0.0))],
     [Tensors.Vec{2, Float64}((0.0, 0.0)),Tensors.Vec{2, Float64}((1.0, 0.0))]]
end
@inline reference_edge_nodes(::Type{Triangle}) = ((1,2),(2,3),(3,1))

function gettopology(::Type{Triangle})
    return Dict(0=>3,1=>3,2=>1)
end

##########################
# Tetrahedron
######################

const Tetrahedron = Simplex{3}

get_num_faces(::Type{Tetrahedron}) = 3
get_num_vertices(::Type{Tetrahedron}) = 3

function reference_coordinates(::Type{Tetrahedron})
    [Tensors.Vec{3, Float64}((0.0, 0.0,0.0)),
     Tensors.Vec{3, Float64}((1.0, 0.0,0.0)),
     Tensors.Vec{3, Float64}((0.0,1.0, 0.0)),
     Tensors.Vec{3, Float64}((0.0,0.0, 1.0))]
end
function reference_edges(::Type{Tetrahedron})
    coords = reference_coordinates(Tetrahedron)
    [[coords[i[1]], coords[i[2]]] for i in reference_edge_nodes(Tetrahedron)]
end
reference_edge_nodes(::Type{Tetrahedron}) = ((1,2),(2,3),(3,4),(4,1))

function gettopology(::Type{Tetrahedron})
    return Dict(0=>4,1=>6,2=>4,3=>1)
end

"""
get points for a nodal basis of order `order` on a `dim`
    dimensional simplex
"""
function get_nodal_points(::Type{Simplex{dim}}, order) where {dim}
    points = Vector{Tensors.Vec{dim,Float64}}()
    vertices = reference_coordinates(Simplex{dim})
    topology = Dict{Int, Int}()
    append!(points, vertices)
    push!(topology, 0=>length(points))
    [append!(points, _interior_points(verts, order)) for verts in reference_edges(Simplex{dim})]
    push!(topology, 1=>length(points)-topology[0])
    append!(points, _interior_points(vertices, order))
    push!(topology, 2=>length(points)-topology[0]-topology[1])
    points, topology
end

function _interior_points(verts, order)
    n = length(verts)
    ls = [(verts[i] - verts[1])/order for i in 2:n]
    m = length(ls)
    grid_indices =  []
    if m == 1
        grid_indices = [[i] for i in 1:order-1]
    elseif m == 2 && order > 2
        grid_indices = [[i,j] for i in 1:order-1 for j in 1:order-i-1]
    end
    pts = Vector{typeof(verts[1])}()
    for indices in grid_indices
        res = verts[1]
        for (i,ii) in enumerate(indices)
            res += (ii) * ls[m - i+1]
        end
        push!(pts,res)
    end
    pts
end

#########################
# Rectangles  #
#########################
struct HyperCube{dim} <: Shape{dim} end
const Rectangle = HyperCube{2}
@inline get_num_faces(::Type{Rectangle}) = 4
@inline get_num_vertices(::Type{Rectangle}) = 4

function reference_coordinates(::Type{Rectangle})
    [Tensors.Vec{2, Float64}((0.0, 0.0)),
    Tensors.Vec{2, Float64}((1.0, 0.0)),
    Tensors.Vec{2, Float64}((0.0, 1.0)),
    Tensors.Vec{2, Float64}((1.0, 1.0))]
end
function reference_edges(::Type{Rectangle})
    [[Tensors.Vec{2, Float64}((1.0, 0.0)),Tensors.Vec{2, Float64}((1.0, 1.0))],
     [Tensors.Vec{2, Float64}((1.0, 1.0)),Tensors.Vec{2, Float64}((0.0, 1.0))],
     [Tensors.Vec{2, Float64}((0.0, 1.0)),Tensors.Vec{2, Float64}((0.0, 0.0))],
     [Tensors.Vec{2, Float64}((0.0, 0.0)),Tensors.Vec{2, Float64}((1.0, 0.0))]]
end
@inline reference_edge_nodes(::Type{Rectangle}) = ((1,2),(2,3),(3,4),(4,1))

function gettopology(::Type{Rectangle})
    return Dict(0=>4,1=>4,2=>1)
end

##########################
# Hexahedron
######################

const Hexahedron = HyperCube{3}

get_num_faces(::Type{Hexahedron}) = 6
get_num_vertices(::Type{Hexahedron}) = 8

function reference_coordinates(::Type{Hexahedron})
    [Tensors.Vec{3, Float64}((0.0, 0.0,0.0)),
     Tensors.Vec{3, Float64}((1.0, 0.0,0.0)),
     Tensors.Vec{3, Float64}((1.0,0.0, 1.0)),
     Tensors.Vec{3, Float64}((0.0,0.0, 1.0)),
     Tensors.Vec{3, Float64}((0.0,1.0, 0.0)),
     Tensors.Vec{3, Float64}((1.0,1.0, 0.0)),
     Tensors.Vec{3, Float64}((1.0,1.0, 1.0)),
     Tensors.Vec{3, Float64}((0.0,1.0, 1.0))]
end
function reference_edges(::Type{Hexahedron})
    [[Tensors.Vec{3, Float64}((1.0, 0.0,0.0)),Tensors.Vec{3, Float64}((1.0, 0.0,1.0))],
    [Tensors.Vec{3, Float64}((1.0, 0.0,1.0)),Tensors.Vec{3, Float64}((0.0, 0.0,1.0))],
    [Tensors.Vec{3, Float64}((0.0, 0.0,1.0)),Tensors.Vec{3, Float64}((0.0, 0.0,0.0))],
    [Tensors.Vec{3, Float64}((0.0, 0.0,0.0)),Tensors.Vec{3, Float64}((1.0, 0.0,0.0))],
    [Tensors.Vec{3, Float64}((1.0, 0.0,0.0)),Tensors.Vec{3, Float64}((1.0, 1.0,1.0))],
    [Tensors.Vec{3, Float64}((1.0, 0.0,1.0)),Tensors.Vec{3, Float64}((0.0, 1.0,1.0))],
    [Tensors.Vec{3, Float64}((0.0, 0.0,1.0)),Tensors.Vec{3, Float64}((0.0, 1.0,0.0))],
    [Tensors.Vec{3, Float64}((0.0, 0.0,0.0)),Tensors.Vec{3, Float64}((1.0, 1.0,0.0))],
    [Tensors.Vec{3, Float64}((0.0, 0.0,0.0)),Tensors.Vec{3, Float64}((0.0, 1.0,0.0))],
    [Tensors.Vec{3, Float64}((1.0, 0.0,0.0)),Tensors.Vec{3, Float64}((1.0, 1.0,0.0))],
    [Tensors.Vec{3, Float64}((1.0, 0.0,1.0)),Tensors.Vec{3, Float64}((1.0, 1.0,1.0))],
    [Tensors.Vec{3, Float64}((0.0, 0.0,1.0)),Tensors.Vec{3, Float64}((0.0, 1.0,1.0))]]
end
reference_edge_nodes(::Type{Hexahedron}) = ((1,2),(2,3),(3,4),(4,1),(5,6),(6,7),(7,8),(8,5),(1,5),(2,6),(3,7),(4,8))

function gettopology(::Type{Hexahedron})
    return Dict(0=>8,1=>12,2=>6,3=>1)
end

"""
get points for a nodal basis of order `order` on a `dim`
    dimensional hypercube
"""
function get_nodal_points(::Type{HyperCube{dim}}, order) where {dim}
    points = Vector{Tensors.Vec{dim,Float64}}()
    vertices = reference_coordinates(HyperCube{dim})
    topology = Dict{Int, Int}()
    append!(points, vertices)
    push!(topology, 0=>length(points))
    [append!(points, _interior_points(verts, order)) for verts in reference_edges(HyperCube{dim})]
    push!(topology, 1=>length(points)-topology[0])
    append!(points, _cube_interior_points(vertices, order, dim))
    push!(topology, 2=>length(points)-topology[0]-topology[1])
    points, topology
end

function _cube_interior_points(verts, order, dim)
    n = length(verts)
    ls = [(verts[i] - verts[1])/order for i in 2:n]
    lx = ls[1]
    for point in ls
        any([x ≈ 0 for x in point]) 
        if !any([x ≈ 0 for x in point])
            lx = point
        end
    end
    
    if dim == 2
        return [eltype(verts)((verts[1][1]+i*lx[1],verts[1][2]+j*lx[2])) for i in 1:order-1 for j in 1:order-1]
    elseif dim == 3
        return [eltype(verts)((verts[1][1]+i*lx[1],verts[1][2]+j*lx[2], verts[1][3]+k*lx[3])) for i in 1:order-1 for j in 1:order-1 for k in 1:order-1]
    else
        error("interior nodes for hypercube of dimension $dim not supported")
    end
end

############
# Segment
###########
const Segment = Simplex{1}
@inline get_num_faces(::Type{Segment}) = 1
@inline get_num_vertices(::Type{Segment}) = 2

function reference_coordinates(::Type{Segment})
    return [Tensors.Vec{1, Float64}((0.0,)),Tensors.Vec{1, Float64}((1.0,))]
end

function get_nodal_points(::Type{Segment}, order)
    points = Vector{Tensors.Vec{1,Float64}}()
    vertices = reference_coordinates(Segment)
    topology = Dict{Int, Int}()
    append!(points, vertices)
    push!(topology, 0=>length(points))
    append!(points, _interior_points(vertices, order))
    push!(topology, 1=>length(points)-topology[0])
    points, topology
end


### Utils
function map_shape_symbols(symbol)
    if symbol == :Triangle
        Triangle()
    elseif symbol == :Segment
        Segment()
    else
        error("Shape not available")
    end
end