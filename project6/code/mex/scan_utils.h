#ifndef SCAN_UTILS_H
#define SCAN_UTILS_H

#include <iostream>
#include <string.h>
#include <math.h>
#include <vector>
#include <algorithm>
#include "pose_utils.h"
#include "sensor_msgs/LaserScan.h"

// Cut the 'mirror' part of laser scan, downsample to meet resolution, project to common ground frame, also return the cutted and downsampled scan for republish
mat preprocess_scan(const sensor_msgs::LaserScan& scan, double resolution, colvec ypr, sensor_msgs::LaserScan& lscan);

// Compute scan covariance based on fisher's imformation matrix
mat cov_fisher(const mat& scan, bool& isCovValid);

#endif
