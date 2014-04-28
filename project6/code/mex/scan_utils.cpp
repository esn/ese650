#include "scan_utils.h"

mat preprocess_scan(const sensor_msgs::LaserScan &scan, double resolution, colvec ypr, sensor_msgs::LaserScan &lscan) {
  // Cut laser scan
  lscan = scan;
  lscan.angle_min = -1.58;
  lscan.angle_max =  1.58;
  lscan.range_max =  20;
  lscan.ranges.clear();
  int curr_idx = -round((scan.angle_min - lscan.angle_min) / scan.angle_increment);
  double curr_angle = scan.angle_min + curr_idx * scan.angle_increment;
  while (curr_angle <= lscan.angle_max) {
    lscan.ranges.push_back((scan.ranges[curr_idx] < lscan.range_max) ? scan.ranges[curr_idx] : lscan.range_max);
    curr_idx++;
    curr_angle = scan.angle_min + curr_idx * scan.angle_increment;
  }
  // Transform 45 degree, to IMU frame
  lscan.angle_min += 45 * PI / 180;
  lscan.angle_max += 45 * PI / 180;
  // Downsample
  mat lscan_mat = zeros<mat>(2, lscan.ranges.size());
  int cnt = 0;
  double prevx = NUM_INF;
  double prevy = NUM_INF;
  for (int k = 0; k < lscan.ranges.size(); k++) {
    if (lscan.ranges[k] < lscan.range_max) {
      double theta = lscan.angle_min + k * lscan.angle_increment;
      double x = lscan.ranges[k] * cos(theta);
      double y = lscan.ranges[k] * sin(theta);
      double dist = (x - prevx) * (x - prevx) + (y - prevy) * (y - prevy);
      if (dist > resolution * resolution) {
        lscan_mat(0, cnt) = x;
        lscan_mat(1, cnt) = y;
        prevx = x;
        prevy = y;
        cnt++;
      } else
        lscan.ranges[k] = lscan.range_max;
    }
  }
  if (cnt > 0)
    lscan_mat = lscan_mat.cols(0, cnt - 1);
  else
    lscan_mat = zeros<mat>(2, cnt);
  // Projection
  ypr(0) = 0;
  mat Rpr = ypr_to_R(ypr);
  Rpr = Rpr.submat(0, 0, 1, 1);
  mat lscan_mat_proj = Rpr * lscan_mat;

  return lscan_mat_proj;
}

// For compute fisher matrix
struct scanData {
  double r;
  double theta;
  double alpha;
  double beta;
  double x;
  double y;
};

mat cov_fisher(const mat &scan, bool &isCovValid) {
  static bool isCovValidPrev = false;

  double minDist = 0.10;

  // Convert data format
  vector<scanData> data;
  data.clear();
  data.reserve(scan.n_cols);
  for (int k = 0; k < scan.n_cols; k++) {
    double x = scan(0, k);
    double y = scan(1, k);
    scanData _data;
    _data.x = x;
    _data.y = y;
    _data.r = hypot(x, y);
    _data.theta = atan2(y, x);
    _data.alpha = 100;
    _data.beta = 0;
    data.push_back(_data);
  }

  //Subsample
  int i = 0;
  while (i < (int)(data.size()) - 1) {
    double d = hypot(data[i].x - data[i + 1].x, data[i].y - data[i + 1].y);
    if (d >= minDist)
      i++;
    else
      data.erase(data.begin() + i + 1);
  }

  //Calculate normal orientation
  for (int k = 0; k < data.size(); k++) {
    if (k - 1 >= 0 && k + 1 < data.size()) {
      double tx = 0;
      double ty = 0;
      bool invalid_flag = false;
      double d1 = hypot(data[k - 1].x - data[k].x, data[k - 1].y - data[k].y);
      double d2 = hypot(data[k].x - data[k + 1].x, data[k].y - data[k + 1].y);
      if (d1 <= minDist * 2) {
        tx += (data[k - 1].x - data[k].x) / d1;
        ty += (data[k - 1].y - data[k].y) / d1;
      } else
        invalid_flag = true;
      if (d2 <= minDist * 2) {
        tx += (data[k].x - data[k + 1].x) / d2;
        ty += (data[k].y - data[k + 1].y) / d2;
      } else
        invalid_flag = true;
      if (!invalid_flag) {
        double nx = -ty;
        double ny =  tx;
        data[k].alpha = atan2(ny, nx);
        data[k].beta = data[k].alpha - data[k].theta;
      }
    }
  }
  //Remove points that do not have normal orientation
  int j = 0;
  while (j < data.size()) {
    if (data[j].alpha != 100)
      j++;
    else
      data.erase(data.begin() + j);
  }
  // Compute FIM based on normal
  mat FIM(3, 3);
  FIM.zeros();
  mat f(3, 3);
  f.zeros();
  for (int k = 0; k < data.size(); k++) {
    f.zeros();
    double r = data[k].r;
    double c = cos(data[k].alpha);
    double s = sin(data[k].alpha);
    double b = cos(data[k].beta);
    double t = tan(data[k].beta);
    // Upper left 2*2 block
    f(0, 0) = c * c / (b * b);
    f(1, 0) = c * s / (b * b);
    f(0, 1) = c * s / (b * b);
    f(1, 1) = s * s / (b * b);
    // Two symmetric block
    f(0, 2) = r * t * c / b;
    f(1, 2) = r * t * s / b;
    f(2, 0) = r * t * c / b;
    f(2, 1) = r * t * s / b;
    // Lower right
    f(2, 2) = (r * t) * (r * t);
    // Add
    FIM = FIM + f;
  }
  // Ray-tracing range measurement covariance
  double sigma = 0.1;
  FIM = FIM / (sigma * sigma);
  // Deal with singular/non-positive-definite case
  colvec eigFIM = eig_sym(FIM);
  mat C = eye<mat>(3, 3);

  if (eigFIM(0) > 200 && !isCovValidPrev)
    isCovValid = true;
  else if (eigFIM(0) < 10e-10 && isCovValidPrev)
    isCovValid = false;
  else
    isCovValid = isCovValidPrev;
  isCovValidPrev = isCovValid;

  if (isCovValid) {
    C = inv(FIM);
  } else {
    C(0, 0) = 2 * 2;
    C(1, 1) = 2 * 2;
    C(2, 2) = 45 * PI / 180 * 45 * PI / 180;
  }

  return C;
}

