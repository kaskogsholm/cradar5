#include "Eigen/Core"
#include <Eigen/Eigen>
#pragma once

template <typename System>
concept hasDerivative = requires(System sys, double time) {
  {
    sys.derivative(time)
  } -> std::convertible_to<Eigen::Ref<const Eigen::VectorX<double>>>;
  { sys.derivative(time).cols() } -> std::convertible_to<int>;
  { sys.derivative(time).rows() } -> std::convertible_to<int>;
};

template <typename ChildSystem> class DelayDifferentialSystem {
public:
  DelayDifferentialSystem() {
    static_assert(hasDerivative<ChildSystem> &&
                  std::derived_from<ChildSystem, DelayDifferentialSystem>);
  }
};
