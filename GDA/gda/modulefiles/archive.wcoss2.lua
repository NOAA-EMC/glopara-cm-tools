
help([[
Load environment to archive on WCOSS2
]])

load(pathJoin("PrgEnv-intel", os.getenv("PrgEnv_intel_ver")))
load(pathJoin("craype", os.getenv("craype_ver")))
load(pathJoin("intel", os.getenv("intel_ver")))
load(pathJoin("cmdaccel", os.getenv("cmdaccel_ver")))

load(pathJoin("python", os.getenv("python_ver")))
load(pathJoin("prod_envir", os.getenv("prod_envir_ver")))
load(pathJoin("libjpeg", os.getenv("libjpeg_ver")))

load(pathJoin("cdo", os.getenv("cdo_ver")))

load(pathJoin("hdf5", os.getenv("hdf5_ver")))
load(pathJoin("netcdf", os.getenv("netcdf_ver")))

load(pathJoin("udunits", os.getenv("udunits_ver")))
load(pathJoin("gsl", os.getenv("gsl_ver")))
load(pathJoin("nco", os.getenv("nco_ver")))
load(pathJoin("prod_util", os.getenv("prod_util_ver")))
load(pathJoin("grib_util", os.getenv("grib_util_ver")))
load(pathJoin("bufr_dump", os.getenv("bufr_dump_ver")))
load(pathJoin("util_shared", os.getenv("util_shared_ver")))

whatis("Description: Archive run environment")
