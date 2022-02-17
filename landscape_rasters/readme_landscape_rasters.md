# Landscape rasters

*Author use only: v6 of landscape rasters uploaded 2022/02/16.*

The ```landscape_rasters``` directory contains rasters (GeoTIFF format) of the dynamic landscapes used to represent different hypotheses in the iDDC models. These rasters were generated from modified species distribution models projected to different time periods. Raster cell values represent habitat suitability, which has been rescaled, standardized to a single scale across all rasters, and grouped into eleven bins from 0 to 10, where 10 is the maximum habitat suitability and 0 indicates no habitat suitability. Different combinations of rasters are selected to represent each model, and used to generate the ```oriworld[...].txt``` and corresponding ```veg2K[...].txt``` simulation input files.

There are seven different time periods (indicated in the filename):

```LIG``` – Last Interglacial<br/>
```post-LIG``` - transitional environment after the Last Interglacial<br/>
```pre-LGM``` - transitional environment before the Last Glacial Maximum<br/>
```LGM``` - Last Glacial Maximum<br/>
```earlyHolo``` - transitional environment between the Last Glacial Maximum and the mid-Holocene<br/>
```midHolo``` - mid-Holocene<br/>
```current``` - current climate

There are four additional rasters that are modifications of the seven time periods:

```oruanui``` - modification of the LGM environment immediately after the Oruanui eruption<br/>
```hatepe``` - modification of the current environment immediately after the Hatepe eruption<br/>
```maori``` - modification of the current environment after Maori colonization of New Zealand<br/>
```euro``` - modification of the current environment after European colonization of New Zealand

Each of the above rasters also has an alternative version labelled ```fourLineages``` which is used for iDDC models requiring barriers between the four genetic clusters for a given time period.

See the publication text for further details.
