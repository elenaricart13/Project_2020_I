MODULE ALLOCATE_VARS
    USE READ_DATA
    IMPLICIT NONE
    INTEGER seed,n_verlet
    REAL*8 energy_re,dist_re,temp_re,press_re,n_mols,total_mass,rho_re
    REAL*8,DIMENSION(:,:),ALLOCATABLE :: positions, velocities, force
    REAL*8,DIMENSION(:),ALLOCATABLE :: g_r

    CONTAINS
    SUBROUTINE INITIALIZE_VARS()
        IMPLICIT NONE

        ALLOCATE(r(n_particles,3),v(n_particles,3),F(n_particles,3),g_r(0:n_radial+1))
        seed=1996

        
        !dimensional factors
        temp_re=epsilon/k_B   !Kelvin
        energy_re=epsilon     !kJ/mol
        dist_re=sigma         !Angstroms
        time_re=1d-13*sqrt(mass*sigma**2d0/epsilon)  !Seconds
        press_re=1d27*epsilon/(n_avog*sigma**3d0)          !Pascals
        n_mols=n_particles/n_avog
        total_mass=n_mols*mass
        rho_re=mass*1d24/(sigma**3d0*n_avog)

        !verlet integration vars
        n_verlet=int(t_b-t_a)/h  !number of time inegration steps
        t=t_a
        g_r=0d0
        n_gr_meas=0

    END SUBROUTINE
END MODULE