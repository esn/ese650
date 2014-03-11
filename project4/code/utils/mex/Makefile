MEX = mex
CXX ?= g++
CC ?= gcc
CFLAGS = -Wall -Wconversion -O3 -fPIC -Wl,--as-needed
CXXFLAGS = -Wall -Wconversion -O3 -fPIC -Wl,--as-needed
MEX_OPTION = -largeArrayDims CC\#$(CC) CFLAGS\#"$(CFLAGS)" \
						 CXX\#$(CXX) CXXFLAGS\#"$(CXXFLAGS)"
MEX_EXT = $(shell mexext)

all: binary

binary: map_correlation.$(MEX_EXT) getMapCellsFromRay.$(MEX_EXT)

map_correlation.$(MEX_EXT): map_correlation.cpp
	$(MEX) $(MEX_OPTION) $^

getMapCellsFromRay.$(MEX_EXT): getMapCellsFromRay.cpp
	$(MEX) $(MEX_OPTION) $^

clean:
	rm -f *.$(MEX_EXT)
