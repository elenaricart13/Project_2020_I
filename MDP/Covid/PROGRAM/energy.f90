! Modul del cutoff
MODULE Interaction_Cutoff_Modul
use READ_DATA
use Lennard_Jones
use PBC
use parallel_routines
implicit none
contains

SUBROUTINE INTERACTION_CUTOFF(r,F,cutoff)
! Calcul de l'energia d'interaccio total donades una subrutina externa pel potencial
! Lennard-Jones i per les condicions periodiques de contorn. Tambe calculem la pressio
    IMPLICIT NONE
    INTEGER :: i,j
    REAL*8 :: cutoff,pot
    REAL*8 :: dx,dy,dz,d,ff
    REAL*8, DIMENSION(:,:) :: r, F
    F=0d0
    potential=0d0
    pressure=0.0
    DO i=index_matrix(taskid+1,1), index_matrix(taskid+1,2)
        DO j=i,n_particles
          IF(j.ne.i) then
            dx=PBC1(r(i,1)-r(j,1),L)
            dy=PBC1(r(i,2)-r(j,2),L)
            dz=PBC1(r(i,3)-r(j,3),L)
            d=(dx**2d0+dy**2d0+dz**2d0)**0.5
            CALL L_J(d,ff,pot,cutoff)
            F(i,1)=F(i,1)+ff*dx
            F(i,2)=F(i,2)+ff*dy
            F(i,3)=F(i,3)+ff*dz
            F(j,1)=F(j,1)-ff*dx
            F(j,2)=F(j,2)-ff*dy
            F(j,3)=F(j,3)-ff*dz
            potential=potential+pot
            pressure=pressure+(ff*dx**2d0+ff*dy**2d0+ff*dz**2d0)
          END IF
        END DO
    END DO
    call MPI_REDUCE( potential, potential,1,MPI_DOUBLE_PRECISION,MPI_SUM,0,MPI_COMM_WORLD,ierror)
    call MPI_REDUCE(pressure,pressure,1,MPI_DOUBLE_PRECISION,MPI_SUM,0,MPI_COMM_WORLD,ierror)
    if (taskid==0) then
      pressure  =  pressure/2.d0
      potential = potential/2.d0*n_particles
    endif
    return
END SUBROUTINE INTERACTION_CUTOFF

END MODULE Interaction_Cutoff_Modul
