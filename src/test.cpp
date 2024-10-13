#include "DelayDifferentialSystem.h"
#include <Eigen/Eigen>
class Paul : public DelayDifferentialSystem<Paul, 1> {
public:
  using Vector = Eigen::Vector<double, 1>;
  Eigen::Vector<double, 1> derivative(
      double t, const Eigen::Ref<const Vector> &parameters,
      const Eigen::Ref<const Vector> &state_vector,
      const Eigen::Ref<const Eigen::Vector<double, 1>> &delayed_state_vector) {
    Eigen::Vector<double, 1> res;
    res = delayed_state_vector;
    return res;
  }

  double delay(double t,
               const Eigen::Ref<const Eigen::Vector<double, 2>> &parameters,
               const Eigen::Ref<const Eigen::Vector<double, 1>> &state_vector) {
    return state_vector(0);
  }

  // Need Jacobian
  // Need delayed Jac
  // Need Phi, history func
};
int main() {
  Paul paul_system;
  /*paul_system.solve(init, start_time, [0.1])*/
}
