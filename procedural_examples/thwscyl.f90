!
!     file thwscyl.f90
!
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!     *                                                               *
!     *                  copyright (c) 2005 by UCAR                   *
!     *                                                               *
!     *       University Corporation for Atmospheric Research         *
!     *                                                               *
!     *                      all rights reserved                      *
!     *                                                               *
!     *                    FISHPACK90  Version 1.1                    *
!     *                                                               *
!     *                      A Package of Fortran                     *
!     *                                                               *
!     *                Subroutines and Example Programs               *
!     *                                                               *
!     *               for Modeling Geophysical Processes              *
!     *                                                               *
!     *                             by                                *
!     *                                                               *
!     *        John Adams, Paul Swarztrauber and Roland Sweet         *
!     *                                                               *
!     *                             of                                *
!     *                                                               *
!     *         the National Center for Atmospheric Research          *
!     *                                                               *
!     *                Boulder, Colorado  (80307)  U.S.A.             *
!     *                                                               *
!     *                   which is sponsored by                       *
!     *                                                               *
!     *              the National Science Foundation                  *
!     *                                                               *
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!
program thwscyl

    use, intrinsic :: ISO_Fortran_env, only: &
        stdout => OUTPUT_UNIT

    use fishpack_library, only: &
        ip, wp, hwscyl

    ! Explicit typing only
    implicit none

    !-----------------------------------------------
    ! Dictionary
    !-----------------------------------------------
    integer(ip), parameter   :: M = 50, N = 100
    integer(ip), parameter   :: IDIMF = M + 25
    integer(ip), parameter   :: MP1 = M + 1, NP1 = N + 1
    integer(ip)              :: mbdcnd, nbdcnd, i, j, ierror
    real(wp)                 :: f(IDIMF, NP1)
    real(wp), dimension(MP1) :: bdc, bdd, r
    real(wp), dimension(NP1) :: bda, bdb, z
    real(wp)                 :: a, b, c, d, elmbda, pertrb
    real(wp), parameter      :: ZERO = 0.0_wp, ONE = 1.0_wp, FOUR = 4.0_wp
    !-----------------------------------------------

    ! Set domain and boundary conditions in r
    a = ZERO
    b = ONE
    mbdcnd = 6

    ! Set domain and boundary conditions in z
    c = ZERO
    d = ONE
    nbdcnd = 3

    ! Set helmholtz constant
    elmbda = ZERO

    ! Generate and store grid points for the purpose of computing
    ! boundary data and the right side of the poisson equation
    do i = 1, MP1
        r(i) = real(i - 1, kind=wp)/M
    end do

    do j = 1, NP1
        z(j) = real(j - 1, kind=wp)/N
    end do

    ! Generate boundary data in z. bda is a dummy variable
    bdb = FOUR * (z**4)

    ! Generate boundary data in r
    bdc = ZERO
    bdd = FOUR * (r**4)

    ! Generate right hand side of equation.
    block
        real(wp), parameter :: THREE = 3.0_wp

        do i = 1, MP1
            f(i,:NP1) = FOUR * (r(i)**2) * (z(:NP1)**2) &
                * (FOUR * (z(:NP1)**2) + THREE * (r(i)**2))
        end do
    end block

    ! Solve 2D Helmholtz in cylindrical coordiantes on centered grid
    call hwscyl(a, b, M, mbdcnd, bda, bdb, c, d, N, nbdcnd, bdc, bdd, &
        elmbda, f, IDIMF, pertrb, ierror)

    ! Compute discretization error by minimizing over all a the function
    ! norm(f(i, j) - a*1 - u(r(i), z(j))).  The exact solution is
    !
    ! u(r, z) = (r*z)**4 + arbitrary constant.
    !
    block
        real(wp) :: x, discretization_error
        real(wp) :: exact_solution(MP1, NP1)

        ! Adjust solution
        x = ZERO
        do i = 1, MP1
            x = x + sum(f(i,:NP1)-(r(i)*z(:NP1))**4)
        end do
        x = x/(NP1*MP1)
        f(:MP1,:NP1) = f(:MP1,:NP1) - x

        do j = 1, NP1
            do i = 1, MP1
                exact_solution(i,j) = (r(i)*z(j))**4
            end do
        end do

        ! Set discretization error
        discretization_error = maxval(abs(exact_solution - f(:MP1,:NP1)))

        ! Print earlier output from platforms with 64-bit floating point
        ! arithmetic followed by the output from this computer
        !
        write( stdout, '(/a)') '     hwscyl *** TEST RUN *** '
        write( stdout, '(a)') '     Previous 64 bit floating point arithmetic result '
        write( stdout, '(a)') '     ierror = 0,  pertrb = 2.2674e-4'
        write( stdout, '(a)') '     discretization error = 3.7367e-4'
        write( stdout, '(a)') '     The output from your computer is: '
        write( stdout, '(a,i3,a,1pe15.6)') &
            '     ierror =', ierror, ' pertrb = ', pertrb
        write( stdout, '(a,1pe15.6/)') '     discretization error = ', discretization_error
    end block

end program thwscyl
