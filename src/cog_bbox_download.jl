
using ArchGDAL
using Rasters # Often used for a more convenient array-like interface

# Define the URL to your COG. This is an example from Amazon S3.
cog_url = "/vsicurl/http://landsat-pds.s3.amazonaws.com/c1/L8/037/034/LC08_L1TP_037034_20160712_20170221_01_T1/LC08_L1TP_037034_20160712_20170221_01_T1_B4.TIF"

# Define the bounding box for the region of interest in world coordinates.
# For this example Landsat image, the CRS is UTM.
# The `read` parameter takes a tuple of tuples: ((min_y, max_y), (min_x, max_x)).
bbox = ((200000.0, 300000.0), (300000.0, 400000.0))

# Read the subset of the COG using ArchGDAL.
# The `read` parameter is a tuple of tuples that specifies the spatial extent.
dataset = ArchGDAL.readraster(cog_url, read=bbox)
# dataset = ArchGDAL.readraster(cog_url, read=bbox)

# You can now work with the `dataset` object, which contains only your subset.
# For example, to convert it to a plain array:
subset_array = ArchGDAL.read(dataset)

# Optional: If you use the Rasters.jl package, you can also open it more abstractly
# and then slice it like a regular array, which is very user-friendly.
# This approach also leverages ArchGDAL under the hood.
using Rasters
raster_data = Raster(cog_url)
subset_raster = raster_data[X(Between(200000, 300000)), Y(Between(300000, 400000))]

# You can then save your subset to a new file on your local machine
ArchGDAL.write("subset_output.tif", dataset)

# Be sure to close the dataset when you are finished
ArchGDAL.destroy(dataset)

