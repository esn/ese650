MEX = mex
CXX ?= g++
CC ?= gcc
CFLAGS =  -fPIC
CXXFLAGS =  -fPIC
MEX_OPTION = CC="$(CC)" CFLAGS="$(CFLAGS)" \
 						 CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" -Wl,--as-needed
MEX_EXT = $(shell mexext)

all: binary

binary: map_correlation getMapCellsFromRay GetUnixTime djpeg

map_correlation: map_correlation.cpp
	$(MEX) $(MEX_OPTION) $^

getMapCellsFromRay: getMapCellsFromRay.cpp
	$(MEX) $(MEX_OPTION) $^

GetUnixTime: GetUnixTime.cc
	$(MEX) $(MEX_OPTION) $^

djpeg: djpeg.cpp
	$(MEX) $(MEX_OPTION) $^ -ljpeg

clean:
	rm -f *.$(MEX_EXT)
