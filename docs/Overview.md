## The Problem ?!

First, from manrad5, here's the problem we're trying to solve:

![image](https://github.com/user-attachments/assets/ffb1a7a4-4842-4b39-8132-6cb6d81123d1)

Less formally, we're interested in finding functions which satisfy a delay differential equation where the delay(s) depend on the state of the system.  [Here's](https://fse.studenttheses.ub.rug.nl/14274/1/Delay_Differential_Equations.pdf) a good primer on the subject. $\alpha_1$, $\alpha_2$, etc. are functions that return a time less than $t$. The key conceptual difference between delay differential equations and ordinary differential equations is that DDEs are _global_ in that the local of the system depends on information that is non-local in time (i.e. the state of the system at some point in the past). 

Since DDEs have a concept of a delay, we will generally refer to the independent variable as time, or $t$, but that is a just a convention adopted to save typing.

## Inputs and Outputs

Although RADAR5 has many virtues, this project will not attempt to mimic its API. Here's the function signature in the fortran source code: 


```
      SUBROUTINE RADAR5(N,FCN,PHI,ARGLAG,X,Y,XEND,H, 
     &                  RTOL,ATOL,ITOL, 
     &                  JAC,IJAC,MLJAC,MUJAC, 
     &                  JACLAG,NLAGS,NJACL, 
     &                  MAS,IMAS,MLMAS,MUMAS,SOLOUT,IOUT, 
     &                  WORK,LWORK,IWORK,LIWORK,RPAR,IPAR,IDID, 
     &                  GRID,LGRID,IPAST,NRDENS) 
```
All these arguments are documented in radar5.f, although some familiarity with the problem domain is assumed. Here's a diagram of what's going on, split into logical chunks. 

![image](https://github.com/user-attachments/assets/c0374e5b-3ece-4ddd-9c1d-0aec9d5b55ad)

The initial design of cradar5's API will encode this mental model of the problem with the following classes, rendered in rough pseudo-code. 


### DifferentialSystem

An instance of this class will be provided by code calling cradar5, or cradar5 will construct such an instance before proceeding with the integration. It encapsulates all the information which is specific to a given DDE.

#### Methods

history(time, parameters)
- computes the trajectory of the state vector for $t<t_0$


derivative(time, parameters, state_vector, delayed_state_vector_1, delayed_state_vector_2 ...)
- computes the right hand side of the problem (the function $f(t)$ in above)
- this is function is certainly required
- time is a scalar, while the other args are vectors
- the length of the state_vector and the vector returned by this function will be referred to as $n$ going forward.

jacobian(same args as derivative)
- computes the jacobian of the derivative function w.r.t to the state_vector, which is an $n \times n$ matrix.
- for optimal performance, the user should supply this function after calculating it analytically. 
- as a convenience feature, we will either try to approximate the function via finite differences or automatic differentiation

delayed_jacobian(same args as derivative)
- computes the derivative of the function w.r.t to the delayed_state_vectors. It might be better to think of this as a tensor, 
with a matrix for each delay.


 
