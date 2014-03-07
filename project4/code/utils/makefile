MEX=mex
CXX?=g++
CC?=gcc
CFLAGS=-Wall -Wconversion -O3 -fPIC
MEX_OPTION=-largeArrayDims CXX\#$(CXX) CXXFLAGS\#"$(CFLAGS)"
MEX_EXT=$(shell mexext)

all: binary

binary: map_correlation.$(MEX_EXT) getMapCellsFromRay.$(MEX_EXT)

map_correlation.$(MEX_EXT): map_correlation.cpp
	$(MEX) $(MEX_OPTION) $^

getMapCellsFromRay.$(MEX_EXT): getMapCellsFromRay.cpp
	$(MEX) $(MEX_OPTION) $^

clean:
	rm -f *.$(MEX_EXT)
