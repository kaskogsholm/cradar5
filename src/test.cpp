#include "DelayDifferentialSystem.h"
#include <Eigen/Eigen>
class systemEx : public DelayDifferentialSystem<systemEx> {
public:
  Eigen::Vector3d derivative(double t) {
    Eigen::Array3<int> res;
    res << 1, 2, 3;
    return res;
  }
};
int main() { DelayDifferentialSystem<systemEx> mysys; }
