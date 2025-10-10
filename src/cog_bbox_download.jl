using Pkg
using HTTP
using ArchGDAL
using Printf

Pkg.instantiate()

"""
    download_cog_bbox(url::String, bbox::Vector{Float64}, output_path::String)

Download a bounding box from a Cloud Optimized GeoTIFF.

# Arguments
- `url::String`: URL to the COG file
- `bbox::Vector{Float64}`: Bounding box as [min_x, min_y, max_x, max_y]
- `output_path::String`: Path where the cropped GeoTIFF will be saved

# Example
```julia
url = "https://example.com/global_data.tif"
bbox = [-180.0, -90.0, 180.0, 90.0]  # Global extent
download_cog_bbox(url, bbox, "subset.tif")
```
"""
function download_cog_bbox(url::String, bbox::Vector{Float64}, output_path::String)
    @assert length(bbox) == 4 "Bounding box must have 4 values: [min_x, min_y, max_x, max_y]"
    
    min_x, min_y, max_x, max_y = bbox
    
    println("Downloading bounding box from COG...")
    println("URL: $url")
    println("Bbox: [$min_x, $min_y, $max_x, $max_y]")
    
    # Use GDAL's virtual file system to read the COG via HTTP
    vsi_url = "/vsicurl/$url"
    
    # Open the dataset
    dataset = ArchGDAL.read(vsi_url) do ds
        # Get the geotransform to convert bbox to pixel coordinates
        gt = ArchGDAL.getgeotransform(ds)
        
        # Calculate pixel coordinates from geographic coordinates
        # gt[1] = top left x, gt[2] = pixel width, gt[3] = rotation (usually 0)
        # gt[4] = top left y, gt[5] = rotation (usually 0), gt[6] = pixel height (negative)
        
        pixel_x_min = floor(Int, (min_x - gt[1]) / gt[2])
        pixel_x_max = ceil(Int, (max_x - gt[1]) / gt[2])
        pixel_y_min = floor(Int, (min_y - gt[4]) / gt[6])
        pixel_y_max = ceil(Int, (max_y - gt[4]) / gt[6])
        
        # Ensure pixels are within bounds
        width = ArchGDAL.width(ds)
        height = ArchGDAL.height(ds)
        
        pixel_x_min = max(0, pixel_x_min)
        pixel_x_max = min(width, pixel_x_max)
        pixel_y_min = max(0, pixel_y_min)
        pixel_y_max = min(height, pixel_y_max)
        
        # Calculate window size
        win_width = pixel_x_max - pixel_x_min
        win_height = pixel_y_max - pixel_y_min
        
        println("Reading window: x=$pixel_x_min, y=$pixel_y_min, width=$win_width, height=$win_height")
        
        # Read the subset using GDAL's windowed reading
        # This triggers range requests for only the needed tiles
        ArchGDAL.gdalwarp([vsi_url], [
            "-te", string(min_x), string(min_y), string(max_x), string(max_y),
            "-of", "GTiff",
            "-co", "COMPRESS=LZW",
            "-co", "TILED=YES"
        ], dest=output_path)
    end
    
    println("Successfully saved subset to: $output_path")
    return output_path
end

# Example usage
if abspath(PROGRAM_FILE) == @__FILE__
    # Example: Download a subset from a global COG
    url = "https://example.com/path/to/global.tif"
    bbox = [-10.0, 40.0, 5.0, 50.0]  # Example: Western Europe
    output_path = "subset_output.tif"
    
    download_cog_bbox(url, bbox, output_path)
end
