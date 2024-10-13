#include "Eigen/Core"
#include <Eigen/Eigen>
#pragma once

template <typename System, int dimension>
concept hasDerivative = requires(System sys, double time) {
  {
    sys.derivative(time)
  } -> std::convertible_to<Eigen::Ref<const Eigen::Vector<double, dimension>>>;
  /*{ sys.derivative(time).cols() } -> std::convertible_to<int>;*/
  /*{ sys.derivative(time).rows() } -> std::convertible_to<int>;*/
};

template <typename ChildSystem, int dimension> class DelayDifferentialSystem {
public:
  DelayDifferentialSystem() {
    static_assert(hasDerivative<ChildSystem, dimension> &&
                      std::derived_from<ChildSystem, DelayDifferentialSystem>,
                  "Delay differential equation did not satisfy the "
                  "'hasDerivative' concept.");
  }
};
