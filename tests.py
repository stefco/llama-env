#!/usr/bin/env python

# print("Checking ligo.skymap version...")
# import ligo.skymap
# print(f"ligo.skymap.__version__: {ligo.skymap.__version__}")
# print("Importing read_sky_map...")
# from ligo.skymap.io.fits import read_sky_map
# print("Importing LVAlertClient...")
# from ligo.lvalert import LVAlertClient
# print("Importing fits...")
# from ligo.skymap.io import fits
print("Importing GraceDb...")
from ligo.gracedb.rest import GraceDb as LigoGraceDb, HTTPError
print("Importing astropy_healpix...")
import astropy_healpix
print("Importing astropy.io....")
import astropy.io
print("Importing astropy.table...")
import astropy.table
