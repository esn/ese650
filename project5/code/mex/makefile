MEX = mex
CXX ?= g++
CC ?= gcc

CFLAGS = -fPIC
CXXFLAGS = -fPIC

MEX = mex
MEX_OPTION = CC\#$(CC) CFLAGS\#"$(CFLAGS)" \
						 CXX\#$(CXX) CXXFLAGS\#"$(CXXFLAGS)" \
					   -Wl,--as-needed -O -outdir build
MEX_EXT = $(shell mexext)

CFLAGS_OPENCV=`pkg-config opencv --cflags --libs`

all: astar_graph astar_nonholonomic16 dijkstra_graph dijkstra_matrix \
	dijkstra_nonholonomic16 subs_interp subs_interp3_circular

%.$(MEX_EXT): %.cpp
	$(MEX) $(MEX_OPTION) $< $(CFLAGS_OPENCV)

astar_graph: astar_graph.cc
	$(MEX) $(MEX_OPTION) $<

astar_nonholonomic16: astar_nonholonomic16.cc
	$(MEX) $(MEX_OPTION) $<

dijkstra_graph: dijkstra_graph.cc
	$(MEX) $(MEX_OPTION) $<

dijkstra_matrix: dijkstra_matrix.cc
	$(MEX) $(MEX_OPTION) $<

dijkstra_nonholonomic16: dijkstra_nonholonomic16.cc
	$(MEX) $(MEX_OPTION) $<

subs_interp3_circular: subs_interp3_circular.cc
	$(MEX) $(MEX_OPTION) $<

subs_interp: subs_interp.cc
	$(MEX) $(MEX_OPTION) $<

clean:
	rm -f *.$(MEX_EXT)
