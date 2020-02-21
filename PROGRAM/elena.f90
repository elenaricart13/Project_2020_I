!!Creem els m�duls de les subrutines, posicions i velocitats inicials, Andersen i funcions de distribuci� radial:

call READ_DATA

module FCC_Initialize

IMPLICIT NONE
    INTEGER :: n_particles,M,n,i,j,k
    REAL*8 :: density,L,a
    REAL*8 :: positions(n_particles,3)
    COMMON/PARAMETERS/n_particles,M,density,L,a
    n=1
    !print*,n
    DO i=0,M-1
        DO j=0,M-1
            DO k=0,M-1
                !print*,size(positions)
                positions(n,:)=a*(/i,j,k/)
                !print*,positions(n,:)
                positions(n+1,:)=positions(n,:)+a*(/0.5,0.5,0.0/)
                positions(n+2,:)=positions(n,:)+a*(/0.5,0.0,0.5/)
                positions(n+3,:)=positions(n,:)+a*(/0.0,0.5,0.5/)
                n=n+4
            END DO
        END DO
    END DO
    PRINT*, 'particles positioned', n-1, 'of a total imput', n_particles
    RETURN

end module FCC_Initialize

module Uniform_velo

IMPLICIT NONE
    REAL*8 :: density,L,a
    INTEGER :: n_particles,M,i,j,seed
    REAL*8 :: velocity(n_particles,3),vi,vtot,T
    COMMON/PARAMETERS/n_particles,M,density,L,a
    seed=13
    CALL SRAND(seed)
    DO i=1,3
        vtot=0
        DO j=1,n_particles-1
            vi=2*RAND()-1
            velocity(j,i)=vi
            vtot=vtot+vi
        END DO
        velocity(n_particles,i)=-vtot
    END DO
    !Resacling the velocities to the temperature
    CALL VELO_RESCALING(velocity,T)
    RETURN

end module Uniform_velo

module Andersen

    IMPLICIT NONE
    INTEGER n_particles,i
    REAL*8 temp,dt,nu,sigma,n1,n2,n3,n4,n5,n6
    REAL*8, DIMENSION(n_particles,3) :: v
    nu=0.1/dt
    sigma=sqrt(temp)
    DO i=1,n_particles
        IF(RAND().lt.nu*dt)THEN
            n1=RAND();n2=RAND()
            n3=RAND();n4=RAND()
            n5=RAND();n6=RAND()
            v(n_particles,:)=(/sigma*sqrt(-2d0*log10(n1))*cos(2d0*3.1415*n2),sigma*sqrt(-2d0*log10(n1))*sin(2d0*3.1415*n2),&
                &sigma*sqrt(-2d0*log10(n3))*cos(2d0*3.1415*n4)/)
        END IF
    END DO
    RETURN

end module Andersen

module Rad_Dist_Inter

    IMPLICIT NONE
    INTEGER n_radial,n_particles,i,coef,j
    REAL*8 dx_radial,dist,vec(0:n_radial+1), r(n_particles,3),dx,dy,dz,PBC1,L
    DO i=1,n_particles
        DO j=1,n_particles
            IF (i.ne.j) THEN
                dx=PBC1(r(j,1)-r(i,1),L)
                dy=PBC1(r(j,2)-r(i,2),L)
                dz=PBC1(r(j,3)-r(i,3),L)
                dist=(dx**2d0+dy**2d0+dz**2d0)**0.5
                coef=int(0.5+dist/dx_radial)
                IF ((coef.gt.0).and.(coef.le.n_radial)) THEN
                    vec(coef)=vec(coef)+1.0
                END IF
            END IF
        END DO
    END DO
    RETURN

end module Ras_Dist_Inter

module Rad_Dist_Final

    IMPLICIT NONE
    INTEGER n_radial,i,n_gr_meas
    REAL*8 dx_radial,rho,vec(0:n_radial+1),result(0:n_radial+1),aux
    vec=vec/(1d0*n_gr_meas)
    DO i=2,n_radial
        aux=(rho*4d0*3.1415*((((i)*dx_radial)**3d0)-(((i-1)*dx_radial)**3d0)))/3d0
        result(i)=vec(i)/aux
    END DO
    vec=result 
    RETURN

end module Rad_Dist_Final 