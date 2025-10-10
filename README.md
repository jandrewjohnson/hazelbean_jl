# hazelbean_jl

A lightweight Julia project for geospatial workflows. Currently includes a utility to download a geographic subset (bounding box) from a Cloud-Optimized GeoTIFF (COG) using ArchGDAL/GDAL.

- Language: Julia
- Entry code: `src/cog_bbox_download.jl`
- Environment: Julia project with dependencies in `Project.toml` and `Manifest.toml`

## Quick Start

1) Open a shell in the project root.
2) Instantiate the environment (first run may download binaries):

```bash
julia --project=. -e "using Pkg; Pkg.instantiate()"
```

3) Run the example script (replace the URL/bbox to your needs):

```bash
julia --project=. src/cog_bbox_download.jl
```

This script will:
- Read a remote COG via GDAL's virtual filesystem (`/vsicurl`)
- Clip it to the provided bounding box `[min_x, min_y, max_x, max_y]`
- Save a tiled, LZW-compressed GeoTIFF locally

## Programmatic Usage

You can also call the function from the Julia REPL or another script:

```julia
julia> using Pkg; Pkg.activate("."); Pkg.instantiate()

julia> include("src/cog_bbox_download.jl")

julia> url = "https://example.com/path/to/global.tif";

julia> bbox = [-10.0, 40.0, 5.0, 50.0];  # [min_x, min_y, max_x, max_y]

julia> out = download_cog_bbox(url, bbox, "subset_output.tif")
"subset_output.tif"
```

### Function Signature

```julia
 download_cog_bbox(url::String, bbox::Vector{Float64}, output_path::String)
```

- `url`: HTTP(S) URL to a Cloud-Optimized GeoTIFF
- `bbox`: Bounding box `[min_x, min_y, max_x, max_y]` in the dataset CRS
- `output_path`: Output path for the cropped GeoTIFF

## Notes

- ArchGDAL bundles platform binaries for GDAL via Julia's artifact system; the first `instantiate` can take a few minutes.
- The script currently runs `Pkg.instantiate()` on startup as a convenience; for production workflows you may prefer managing the environment explicitly.
- Ensure the bbox coordinates match the source raster CRS.
- Remote access requires the server to support HTTP range requests (typical for COG hosting).

## Development

- Add dependencies in `Project.toml` and keep code under `src/`.
- Prefer clear, minimal functions with docstrings and examples.
- Consider adding tests (e.g., `test/`) as functionality grows.

## Status

Early-stage. Focused on a single COG subset utility; intended to expand as geospatial needs evolve.

