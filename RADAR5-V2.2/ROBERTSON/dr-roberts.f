C * * * * * * * * * * * * * * * 
C --- DRIVER FOR RADAR5 
C * * * * * * * * * * * * * * *
        include '../radar5.f'
        include '../decsol.f'
        include '../dc_decdel.f'

        IMPLICIT REAL*8 (A-H,O-Z)

        REAL*4 start,finish
        INTEGER, PARAMETER :: DP=kind(1D0)
C --->  PARAMETERS FOR RADAR5 (FULL JACOBIAN) <---
        INTEGER, PARAMETER :: ND=3
        INTEGER, PARAMETER :: NRDENS=1
        INTEGER, PARAMETER :: NGRID=1
        INTEGER, PARAMETER :: NLAGS=1
        INTEGER, PARAMETER :: NJACL=2
        INTEGER, PARAMETER :: MXST=10000
        INTEGER, PARAMETER :: LWORK=30
        INTEGER, PARAMETER :: LIWORK=30
        REAL(kind=DP), dimension(ND) :: Y
        REAL(kind=DP), dimension(NGRID+1) :: GRID
        REAL(kind=DP), dimension(LWORK) :: WORK
        INTEGER, dimension(LIWORK) :: IWORK
        INTEGER, dimension(NRDENS+2*ND) :: IPAST
        DIMENSION ATOL(1),RTOL(1)
        DIMENSION IPAR(1),RPAR(4)
        EXTERNAL  FCN,PHI,ARGLAG,JFCN,JACLAG,SOLOUT

c ------ FILE TO OPEN ----------
        OPEN(9,FILE='sol.out')
        REWIND 9

C       PARAMETERS IN THE DIFFERENTIAL EQUATION
        RPAR(1)=4.0D-2
        RPAR(2)=1.0D+4
        RPAR(3)=3.0D+7
        RPAR(4)=0.1D-2
C       RPAR(4)=1.0D-2

C -----------------------------------------------------------------------
C                            
C --- DIMENSION OF THE SYSTEM
        N=ND
C --- COMPUTE THE JACOBIAN ANALYTICALLY
        IJAC=1
C --- JACOBIAN IS A FULL MATRIX
        MLJAC=N
C --- DIFFERENTIAL EQUATION IS IN EXPLICIT FORM
      IMAS=0
      MLMAS=N

C --- OUTPUT ROUTINE IS USED DURING INTEGRATION
        IOUT=1
C --- INITIAL VALUES 
        X=0.0D0
        Y(1)= 1.0D0
        Y(2)= 0.0D0 
        Y(3)= 0.0D0 
C       Consistent with initial function
C --- ENDPOINT OF INTEGRATION
        XEND=1.0D+11
C --- REQUIRED (RELATIVE AND ABSOLUTE) TOLERANCE
        ITOL=0
        RTOL=1.D-9
        ATOL=RTOL*1.D-5
C --- INITIAL STEP SIZE
        H=1.0D-6
C --- DEFAULT VALUES FOR PARAMETERS
        IWORK=0
        WORK=0.0D0  
C --- MAX NUMBER OF STEPS
        IWORK(2)=1000000
C --- WORKSPACE FOR PAST 
        IWORK(12)=MXST
C --- THE SECOND COMPONENT USES RETARDED ARGUMENT
        IWORK(15)=NRDENS
        IPAST(1)=2
C --- SET THE PRESCRIBED GRID-POINTS
       DO I=1,NGRID
         GRID(I)=RPAR(4)*I
       END DO
       LGRID = NGRID+1
C --- WORKSPACE FOR GRID
       IWORK(13)=NGRID
C --- SIMPLIFIED NEWTON
       IWORK(14)=1

C _____________________________________________________________________
C --- CALL OF THE SUBROUTINE RADAR5   
        CALL cpu_time(start)
        CALL RADAR5(N,FCN,PHI,ARGLAG,X,Y,XEND,H,
     &                  RTOL,ATOL,ITOL,
     &                  JFCN,IJAC,MLJAC,MUJAC,
     &                  JACLAG,NLAGS,NJACL,
     &                  FCN,IMAS,MLMAS,MUMAS,SOLOUT,IOUT,
     &                  WORK,LWORK,IWORK,LIWORK,RPAR,IPAR,IDID,
     &                  GRID,LGRID,IPAST,NRDENS)   
        CALL cpu_time(finish)
C --- PRINT FINAL SOLUTION SOLUTION
        WRITE (6,90) X,Y(1),Y(2),Y(3)
C --- PRINT STATISTICS
        WRITE(6,*)' *** TOL=',RTOL,' ***','   Time = ',finish-start
        WRITE (6,91) (IWORK(J),J=14,20),IWORK(13)
 90     FORMAT(1X,'X =',F8.2,'    Y =',4E18.10)
 91     FORMAT(' fcn=',I7,' jac=',I6,' step=',I6,
     &        ' accpt=',I6,' rejct=',I6,' dec=',I6,
     &        ' sol=',I7,' fullits =',I7)
        WRITE(6,*) 'SOLUTION IS TABULATED IN FILES: sol.out & cont.out'
        STOP
        END
C
C
        SUBROUTINE SOLOUT (NR,XOLD,X,HSOL,Y,CONT,LRC,N,
     &                     RPAR,IPAR,IRTRN)
C ----- PRINTS THE DISCRETE OUTPUT AND THE CONTINUOUS OUTPUT
C       AT EQUIDISTANT OUTPUT-POINTS
        IMPLICIT REAL*8 (A-H,O-Z)
        INTEGER, PARAMETER :: DP=kind(1D0)
        REAL(kind=DP), dimension(N) :: Y
        REAL(kind=DP), dimension(LRC) :: CONT
        DIMENSION IPAR(1),RPAR(4)

        WRITE (9,99) X,Y(1),Y(2),Y(3)
C
 99     FORMAT(1X,'X =',E15.10,'    Y =',3E18.10)
        RETURN
        END

C
        FUNCTION ARGLAG(IL,X,N,Y,RPAR,IPAR,PHI,PAST,IPAST,NRDS)
        IMPLICIT REAL*8 (A-H,O-Z)
        INTEGER, PARAMETER :: DP=kind(1D0)
        REAL(kind=DP), dimension(N) :: Y
        REAL(kind=DP), dimension(1) :: PAST
        INTEGER, dimension(NRDS+2*N) :: IPAST
        DIMENSION IPAR(1),RPAR(4)

        ARGLAG=X-RPAR(4)
        RETURN
        END
C
        SUBROUTINE FCN(N,X,Y,F,ARGLAG,PHI,RPAR,IPAR,
     &                  PAST,IPAST,NRDS)
        IMPLICIT REAL*8 (A-H,K,O-Z)
        INTEGER, PARAMETER :: DP=kind(1D0)
        REAL(kind=DP), dimension(N) :: Y
        REAL(kind=DP), dimension(N) :: F
        REAL(kind=DP), dimension(1) :: PAST
        INTEGER, dimension(NRDS+2*N) :: IPAST
        DIMENSION IPAR(1),RPAR(4)
        EXTERNAL PHI,ARGLAG

        CALL LAGR5(1,X,N,Y,ARGLAG,PAST,THETA1,IPOS1,RPAR,IPAR,
     &	         PHI,IPAST,NRDS)
        Y2L1=YLAGR5(2,THETA1,IPOS1,PHI,RPAR,IPAR,
     &              PAST,IPAST,NRDS)
        P=RPAR(3)


        F(1)=-RPAR(1)*Y(1)+RPAR(2)*Y2L1*Y(3) 
        F(2)= RPAR(1)*Y(1)-RPAR(2)*Y2L1*Y(3)-P*Y(2)**2         
        F(3)= P*Y(2)**2         

        RETURN
        END
C
        SUBROUTINE JFCN(N,X,Y,DFY,LDFY,ARGLAG,PHI,RPAR,IPAR,
     &                  PAST,IPAST,NRDS)
C ----- STANDARD JACOBIAN OF THE EQUATION
        IMPLICIT REAL*8 (A-H,K,O-Z)
        INTEGER, PARAMETER :: DP=kind(1D0)
        REAL(kind=DP), dimension(N) :: Y
        REAL(kind=DP), dimension(LDFY,N) :: DFY
        REAL(kind=DP), dimension(1) :: PAST
        INTEGER, dimension(NRDS+2*N) :: IPAST
        DIMENSION IPAR(1),RPAR(4)
        EXTERNAL PHI,ARGLAG

        CALL LAGR5(1,X,N,Y,ARGLAG,PAST,THETA1,IPOS1,RPAR,IPAR,
     &             PHI,IPAST,NRDS)
        Y2L1=YLAGR5(2,THETA1,IPOS1,PHI,RPAR,IPAR,
     &              PAST,IPAST,NRDS)
        P=RPAR(3)
C       Matrix J(3,3)

        DFY(1,1)=-RPAR(1)   
        DFY(1,2)= 0.D0        
        DFY(1,3)= RPAR(2)*Y2L1
        DFY(2,1)= RPAR(1)   
        DFY(2,2)= -2*P*Y(2)            
        DFY(2,3)=-RPAR(2)*Y2L1
        DFY(3,1)= 0.D0
        DFY(3,2)= 2*P*Y(2)
        DFY(3,3)= 0.D0
        RETURN
        END
C
        SUBROUTINE JACLAG(N,X,Y,DFYL,ARGLAG,PHI,IVE,IVC,IVL,
     &                    RPAR,IPAR,PAST,IPAST,NRDS)
C ----- JACOBIAN OF DELAY TERMS IN THE EQUATION
        IMPLICIT REAL*8 (A-H,O-Z)
        INTEGER, PARAMETER :: DP=kind(1D0)
        REAL(kind=DP), dimension(N) :: Y
        REAL(kind=DP), dimension(2) :: DFYL
        REAL(kind=DP), dimension(1) :: PAST
        INTEGER, dimension(NRDS+2*N) :: IPAST
        DIMENSION IPAR(1),RPAR(4)
        INTEGER, dimension(2) :: IVE,IVC,IVL
        EXTERNAL PHI,ARGLAG
        
        IVL(1)=1
        IVE(1)=1
        IVC(1)=2
        IVL(2)=1
        IVE(2)=2
        IVC(2)=2
        DFYL(1)= RPAR(2)*Y(3)
        DFYL(2)=-RPAR(2)*Y(3)

        RETURN
        END

C
        FUNCTION PHI(I,X,RPAR,IPAR)
        IMPLICIT REAL*8 (A-H,O-Z)
        INTEGER, PARAMETER :: DP=kind(1D0)
        DIMENSION IPAR(1),RPAR(4)
        PHI=0.0D0 
        RETURN
        END
