module module_cmgnbn

    use type_FishpackWorkspace, only: &
        FishpackWorkspace

    ! Explicit typing only
    implicit none

    ! Everything is private unless stated otherwise
    private
    public :: cmgnbn
    public :: cmgnbn_unit_test

contains

    subroutine cmgnbn_unit_test()
        !
        !     file tcmgnbn.f
        !
        !     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        !     *                                                               *
        !     *                  copyright (c) 2005 by UCAR                   *
        !     *                                                               *
        !     *       University Corporation for Atmospheric Research         *
        !     *                                                               *
        !     *                      all rights reserved                      *
        !     *                                                               *
        !     *                    FISHPACK90  version 1.1                    *
        !     *                                                               *
        !     *                 A Package of Fortran 77 and 90                *
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
        !-----------------------------------------------
        !   L o c a l   V a r i a b l e s
        !-----------------------------------------------
        integer :: idimf, m, mp1, mperod, n, nperod, i, j, ierror
        real , dimension(21) :: x
        real , dimension(41) :: y
        real :: dx, pi, dum, dy, s, t, tsq, t4, err
        complex , dimension(22, 40) :: f
        complex, dimension(20) :: a, b, c
        !-----------------------------------------------
        !
        !     PROGRAM TO ILLUSTRATE THE USE OF SUBROUTINE CMGNBN TO SOLVE
        !     THE EQUATION
        !
        !     (1+X)**2*(D/DX)(DU/DX) - 2(1+X)(DU/DX) + (D/DY)(DU/DY)
        !
        !             - SQRT(-1)*U = (3 - SQRT(-1))*(1+X)**4*SIN(Y)         (1)
        !
        !     ON THE RECTANGLE 0 .LT. X .LT. 1 AND -PI .LT. Y .LT. PI
        !     WITH THE BOUNDARY CONDITIONS
        !
        !     (DU/DX)(0, Y) = 4SIN(Y)                               (2)
        !                                -PI .LE. Y .LE. PI
        !     U(1, Y) = 16SIN(Y)                                    (3)
        !
        !     AND WITH U PERIODIC IN Y USING FINITE DIFFERENCES ON A
        !     GRID WITH DELTAX (= DX) = 1/20 AND DELTAY (= DY) = PI/20.
        !        TO SET UP THE FINITE DIFFERENCE EQUATIONS WE DEFINE
        !     THE GRID POINTS
        !
        !     X(I) = (I-1)DX            I=1, 2, ..., 21
        !
        !     Y(J) = -PI + (J-1)DY      J=1, 2, ..., 41
        !
        !     AND LET V(I, J) BE AN APPROXIMATION TO U(X(I), Y(J)).
        !     NUMBERING THE GRID POINTS IN THIS FASHION GIVES THE SET
        !     OF UNKNOWNS AS V(I, J) FOR I=1, 2, ..., 20 AND J=1, 2, ..., 40.
        !     HENCE, IN THE PROGRAM M = 20 AND N = 40.  AT THE INTERIOR
        !     GRID POINT (X(I), Y(J)), WE REPLACE ALL DERIVATIVES IN
        !     EQUATION (1) BY SECOND ORDER CENTRAL FINITE DIFFERENCES,
        !     MULTIPLY BY DY**2, AND COLLECT COEFFICIENTS OF V(I, J) TO
        !     GET THE FINITE DIFFERENCE EQUATION
        !
        !     A(I)V(I-1, J) + B(I)V(I, J) + C(I)V(I+1, J)
        !
        !     + V(I, J-1) - 2V(I, J) + V(I, J+1) = F(I, J)            (4)
        !
        !     WHERE S = (DY/DX)**2, AND FOR I=2, 3, ..., 19
        !
        !     A(I) = (1+X(I))**2*S + (1+X(I))*S*DX
        !
        !     B(I) = -2(1+X(I))**2*S - SQRT(-1)*DY**2
        !
        !     C(I) = (1+X(I))**2*S - (1+X(I))*S*DX
        !
        !     F(I, J) = (3 - SQRT(-1))*(1+X(I))**4*DY**2*SIN(Y(J))
        !              FOR J=1, 2, ..., 40.
        !
        !        TO OBTAIN EQUATIONS FOR I = 1, WE REPLACE THE
        !     DERIVATIVE IN EQUATION (2) BY A SECOND ORDER CENTRAL
        !     FINITE DIFFERENCE APPROXIMATION, USE THIS EQUATION TO
        !     ELIMINATE THE VIRTUAL UNKNOWN V(0, J) IN EQUATION (4)
        !     AND ARRIVE AT THE EQUATION
        !
        !     B(1)V(1, J) + C(1)V(2, J) + V(1, J-1) - 2V(1, J) + V(1, J+1)
        !
        !                       = F(1, J)
        !
        !     WHERE
        !
        !     B(1) = -2S - SQRT(-1)*DY**2 , C(1) = 2S
        !
        !     F(1, J) = (11-SQRT(-1)+8/DX)*DY**2*SIN(Y(J)),  J=1, 2, ..., 40.
        !
        !     FOR COMPLETENESS, WE SET A(1) = 0.
        !        TO OBTAIN EQUATIONS FOR I = 20, WE INCORPORATE
        !     EQUATION (3) INTO EQUATION (4) BY SETTING
        !
        !     V(21, J) = 16SIN(Y(J))
        !
        !     AND ARRIVE AT THE EQUATION
        !
        !     A(20)V(19, J) + B(20)V(20, J)
        !
        !     + V(20, J-1) - 2V(20, J) + V(20, J+1) = F(20, J)
        !
        !     WHERE
        !
        !     A(20) = (1+X(20))**2*S + (1+X(20))*S*DX
        !
        !     B(20) = -2*(1+X(20))**2*S - SQRT(-1)*DY**2
        !
        !     F(20, J) = ((3-SQRT(-1))*(1+X(20))**4*DY**2 - 16(1+X(20))**2*S
        !                + 16(1+X(20))*S*DX)*SIN(Y(J))
        !
        !                    FOR J=1, 2, ..., 40.
        !
        !     FOR COMPLETENESS, WE SET C(20) = 0.  HENCE, IN THE
        !     PROGRAM MPEROD = 1.
        !        THE PERIODICITY CONDITION ON U GIVES THE CONDITIONS
        !
        !     V(I, 0) = V(I, 40) AND V(I, 41) = V(I, 1) FOR I=1, 2, ..., 20.
        !
        !     HENCE, IN THE PROGRAM NPEROD = 0.
        !
        !          THE EXACT SOLUTION TO THIS PROBLEM IS
        !
        !                  U(X, Y) = (1+X)**4*SIN(Y) .
        !
        !
        !     FROM THE DIMENSION STATEMENT WE GET THAT IDIMF = 22
        !
        idimf = 22
        m = 20
        mp1 = m + 1
        mperod = 1
        dx = 0.05
        n = 40
        nperod = 0
        pi = acos( -1.0 )
        dy = pi/20.
        !
        !     GENERATE GRID POINTS FOR LATER USE.
        !
        do i = 1, mp1
            x(i) = real(i - 1)*dx
        end do
        do j = 1, n
            y(j) = (-pi) + real(j - 1)*dy
        end do
        !
        !     GENERATE COEFFICIENTS.
        !
        s = (dy/dx)**2
        do i = 2, 19
            t = 1. + X(i)
            tsq = t**2
            a(i) = CMPLX((tsq + t*dx)*s, 0.)
            b(i) = (-2.*tsq*s) - (0., 1.)*dy**2
            c(i) = CMPLX((tsq - t*dx)*s, 0.)
        end do
        a(1) = (0., 0.)
        b(1) = (-2.*s) - (0., 1.)*dy**2
        c(1) = CMPLX(2.*s, 0.)
        b(20) = (-2.*s*(1. + X(20))**2) - (0., 1.)*dy**2
        a(20) = CMPLX(s*(1. + X(20))**2+(1.+X(20))*dx*s, 0.)
        c(20) = (0., 0.)
        !
        !     GENERATE RIGHT SIDE.
        !
        do i = 2, 19
            do j = 1, n
                f(i, j) = (3., -1.)*(1. + X(i))**4*dy**2*SIN(Y(j))
            end do
        end do
        t = 1. + X(20)
        tsq = t**2
        t4 = tsq**2
        do j = 1, n
            f(1, j) = ((11., -1.) + 8./dx)*dy**2*SIN(Y(j))
            f(20, j)=((3., -1.)*t4*dy**2-16.*tsq*s+16.*t*s*dx)*SIN(Y(j))
        end do
        call CMGNBN (nperod, n, mperod, m, a, b, c, idimf, f, ierror)
        !
        !     COMPUTE DISCRETIAZATION ERROR.  THE EXACT SOLUTION IS
        !
        !            U(X, Y) = (1+X)**4*SIN(Y) .
        !
        err = 0.
        do i = 1, m
            do j = 1, n
                t = abs(F(i, j)-(1.+X(i))**4*SIN(Y(j)))
                err = max(t, err)
            end do
        end do
        !     Print earlier output from platforms with 32 and 64 bit floating point
        !     arithemtic followed by the output from this computer
        write( *, *) ''
        write( *, *) '    CMGNBN TEST RUN *** '
        write( *, *) &
            '    Previous 64 bit floating point arithmetic result '
        write( *, *) '    IERROR = 0,  Discretization Error = 9.1620E-3'

        write( *, *) '    The output from your computer is: '
        write( *, *) '    IERROR =', ierror, ' Discretization Error = ', &
            err

    end subroutine cmgnbn_unit_test

    subroutine CMGNBN(nperod, n, mperod, m, a, b, c, idimy, y, ierror)
        !
        !     file cmgnbn.f
        !
        !     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        !     *                                                               *
        !     *                  copyright (c) 2005 by UCAR                   *
        !     *                                                               *
        !     *       University Corporation for Atmospheric Research         *
        !     *                                                               *
        !     *                      all rights reserved                      *
        !     *                                                               *
        !     *                    FISHPACK90  version 1.1                    *
        !     *                                                               *
        !     *                 A Package of Fortran 77 and 90                *
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
        !     SUBROUTINE CMGNBN (NPEROD, N, MPEROD, M, A, B, C, IDIMY, Y, IERROR)
        !
        !
        ! DIMENSION OF           A(M), B(M), C(M), Y(IDIMY, N)
        ! ARGUMENTS
        !
        ! LATEST REVISION        NOVEMBER 2004
        !
        ! PURPOSE                THE NAME OF THIS PACKAGE IS A MNEMONIC FOR THE
        !                        COMPLEX GENERALIZED BUNEMAN ALGORITHM.
        !                        IT SOLVES THE COMPLEX LINEAR SYSTEM OF EQUATION
        !
        !                        A(I)*X(I-1, J) + B(I)*X(I, J) + C(I)*X(I+1, J)
        !                        + X(I, J-1) - 2.*X(I, J) + X(I, J+1) = Y(I, J)
        !
        !                        FOR I = 1, 2, ..., M  AND  J = 1, 2, ..., N.
        !
        !                        INDICES I+1 AND I-1 ARE EVALUATED MODULO M,
        !                        I.E., X(0, J) = X(M, J) AND X(M+1, J) = X(1, J),
        !                        AND X(I, 0) MAY EQUAL 0, X(I, 2), OR X(I, N),
        !                        AND X(I, N+1) MAY EQUAL 0, X(I, N-1), OR X(I, 1)
        !                        DEPENDING ON AN INPUT PARAMETER.
        !
        ! USAGE                  CALL CMGNBN (NPEROD, N, MPEROD, M, A, B, C, IDIMY, Y,
        !                                     IERROR)
        !
        ! ARGUMENTS
        !
        ! ON INPUT               NPEROD
        !
        !                          INDICATES THE VALUES THAT X(I, 0) AND
        !                          X(I, N+1) ARE ASSUMED TO HAVE.
        !
        !                          = 0  IF X(I, 0) = X(I, N) AND X(I, N+1) =
        !                               X(I, 1).
        !                          = 1  IF X(I, 0) = X(I, N+1) = 0  .
        !                          = 2  IF X(I, 0) = 0 AND X(I, N+1) = X(I, N-1).
        !                          = 3  IF X(I, 0) = X(I, 2) AND X(I, N+1) =
        !                               X(I, N-1).
        !                          = 4  IF X(I, 0) = X(I, 2) AND X(I, N+1) = 0.
        !
        !                        N
        !                          THE NUMBER OF UNKNOWNS IN THE J-DIRECTION.
        !                          N MUST BE GREATER THAN 2.
        !
        !                        MPEROD
        !                          = 0 IF A(1) AND C(M) ARE NOT ZERO
        !                          = 1 IF A(1) = C(M) = 0
        !
        !                        M
        !                          THE NUMBER OF UNKNOWNS IN THE I-DIRECTION.
        !                          N MUST BE GREATER THAN 2.
        !
        !                        A, B, C
        !                          ONE-DIMENSIONAL COMPLEX ARRAYS OF LENGTH M
        !                          THAT SPECIFY THE COEFFICIENTS IN THE LINEAR
        !                          EQUATIONS GIVEN ABOVE.  IF MPEROD = 0
        !                          THE ARRAY ELEMENTS MUST NOT DEPEND UPON
        !                          THE INDEX I, BUT MUST BE CONSTANT.
        !                          SPECIFICALLY, THE SUBROUTINE CHECKS THE
        !                          FOLLOWING CONDITION .
        !
        !                            A(I) = C(1)
        !                            C(I) = C(1)
        !                            B(I) = B(1)
        !
        !                          FOR I=1, 2, ..., M.
        !
        !                        IDIMY
        !                          THE ROW (OR FIRST) DIMENSION OF THE
        !                          TWO-DIMENSIONAL ARRAY Y AS IT APPEARS
        !                          IN THE PROGRAM CALLING CMGNBN.
        !                          THIS PARAMETER IS USED TO SPECIFY THE
        !                          VARIABLE DIMENSION OF Y.
        !                          IDIMY MUST BE AT LEAST M.
        !
        !                        Y
        !                          A TWO-DIMENSIONAL COMPLEX ARRAY THAT
        !                          SPECIFIES THE VALUES OF THE RIGHT SIDE
        !                          OF THE LINEAR SYSTEM OF EQUATIONS GIVEN
        !                          ABOVE.
        !                          Y MUST BE DIMENSIONED AT LEAST M*N.
        !
        !
        !  ON OUTPUT             Y
        !
        !                          CONTAINS THE SOLUTION X.
        !
        !                        IERROR
        !                          AN ERROR FLAG WHICH INDICATES INVALID
        !                          INPUT PARAMETERS  EXCEPT FOR NUMBER
        !                          ZERO, A SOLUTION IS NOT ATTEMPTED.
        !
        !                          = 0  NO ERROR.
        !                          = 1  M .LE. 2  .
        !                          = 2  N .LE. 2
        !                          = 3  IDIMY .LT. M
        !                          = 4  NPEROD .LT. 0 OR NPEROD .GT. 4
        !                          = 5  MPEROD .LT. 0 OR MPEROD .GT. 1
        !                          = 6  A(I) .NE. C(1) OR C(I) .NE. C(1) OR
        !                               B(I) .NE. B(1) FOR
        !                               SOME I=1, 2, ..., M.
        !                          = 7  A(1) .NE. 0 OR C(M) .NE. 0 AND
        !                                 MPEROD = 1
        !                          = 20 If the dynamic allocation of real and
        !                               complex work space required for solution
        !                               fails (for example if N, M are too large
        !                               for your computer)
        !
        ! SPECIAL CONDITONS      NONE
        !
        ! I/O                    NONE
        !
        ! PRECISION              SINGLE
        !
        ! REQUIRED LIBRARY       comf.f, fish.f
        ! FILES
        !
        ! LANGUAGE               FORTRAN 90
        !
        ! HISTORY                WRITTEN IN 1979 BY ROLAND SWEET OF NCAR'S
        !                        SCIENTIFIC COMPUTING DIVISION.  MADE AVAILABLE
        !                        ON NCAR'S PUBLIC LIBRARIES IN JANUARY, 1980.
        !                        Revised in June 2004 by John Adams using
        !                        Fortran 90 dynamically allocated work space.
        !
        ! ALGORITHM              THE LINEAR SYSTEM IS SOLVED BY A CYCLIC
        !                        REDUCTION ALGORITHM DESCRIBED IN THE
        !                        REFERENCE BELOW.
        !
        ! PORTABILITY            FORTRAN 90.  ALL MACHINE DEPENDENT CONSTANTS
        !                        ARE DEFINED IN FUNCTION P1MACH.
        !
        ! REFERENCES             SWEET, R., 'A CYCLIC REDUCTION ALGORITHM FOR
        !                        SOLVING BLOCK TRIDIAGONAL SYSTEMS OF ARBITRARY
        !                        DIMENSIONS, ' SIAM J. ON NUMER. ANAL.,
        !                          14(SEPT., 1977), PP. 706-720.
        !
        ! ACCURACY               THIS TEST WAS PERFORMED ON A Platform with
        !                        64 bit floating point arithmetic.
        !                        A UNIFORM RANDOM NUMBER GENERATOR WAS USED
        !                        TO CREATE A SOLUTION ARRAY X FOR THE SYSTEM
        !                        GIVEN IN THE 'PURPOSE' DESCRIPTION ABOVE
        !                        WITH
        !                          A(I) = C(I) = -0.5*B(I) = 1, I=1, 2, ..., M
        !
        !                        AND, WHEN MPEROD = 1
        !
        !                          A(1) = C(M) = 0
        !                          A(M) = C(1) = 2.
        !
        !                        THE SOLUTION X WAS SUBSTITUTED INTO THE
        !                        GIVEN SYSTEM  AND A RIGHT SIDE Y WAS
        !                        COMPUTED.  USING THIS ARRAY Y, SUBROUTINE
        !                        CMGNBN WAS CALLED TO PRODUCE APPROXIMATE
        !                        SOLUTION Z.  THEN RELATIVE ERROR
        !                          E = MAX(abs(Z(I, J)-X(I, J)))/
        !                              MAX(abs(X(I, J)))
        !                        WAS COMPUTED, WHERE THE TWO MAXIMA ARE TAKEN
        !                        OVER I=1, 2, ..., M AND J=1, ..., N.
        !
        !                        THE VALUE OF E IS GIVEN IN THE TABLE
        !                        BELOW FOR SOME TYPICAL VALUES OF M AND N.
        !
        !                   M (=N)    MPEROD    NPEROD       E
        !                   ------    ------    ------     ------
        !
        !                     31        0         0        1.E-12
        !                     31        1         1        4.E-13
        !                     31        1         3        2.E-12
        !                     32        0         0        7.E-14
        !                     32        1         1        5.E-13
        !                     32        1         3        2.E-13
        !                     33        0         0        6.E-13
        !                     33        1         1        5.E-13
        !                     33        1         3        3.E-12
        !                     63        0         0        5.E-12
        !                     63        1         1        6.E-13
        !                     63        1         3        1.E-11
        !                     64        0         0        1.E-13
        !                     64        1         1        3.E-12
        !                     64        1         3        3.E-13
        !                     65        0         0        2.E-12
        !                     65        1         1        5.E-13
        !                     65        1         3        1.E-11
        !
        !***********************************************************************
        type(FishpackWorkspace) :: w
        !-----------------------------------------------
        !   D u m m y   A r g u m e n t s
        !-----------------------------------------------
        integer  :: nperod
        integer  :: n
        integer  :: mperod
        integer  :: m
        integer  :: idimy
        integer  :: ierror
        complex  :: a(*)
        complex  :: b(*)
        complex  :: c(*)
        complex  :: y(idimy, *)
        !-----------------------------------------------
        !   L o c a l   V a r i a b l e s
        !-----------------------------------------------
        integer :: i, icwk, irwk
        complex :: a1
        !-----------------------------------------------
        ierror = 0
        if (m <= 2) ierror = 1
        if (n <= 2) ierror = 2
        if (idimy < m) ierror = 3
        if (nperod<0 .or. nperod>4) ierror = 4
        if (mperod<0 .or. mperod>1) ierror = 5

        if (mperod /= 1) then
            do i = 2, m
                if (abs(A(i)-C(1)) /= 0.) go to 103
                if (abs(C(i)-C(1)) /= 0.) go to 103
                if (abs(B(i)-B(1)) /= 0.) go to 103
            end do
            go to 104
        end if

        if (abs(A(1))/=0. .and. abs(C(m))/=0.) ierror = 7
        go to 104
103 continue
    ierror = 6
104 continue
    if (ierror /= 0) return
    !     allocate required complex work space
    icwk = (10 + INT(log(real(n))/log(2.0)))*m + 4*n
    irwk = 0
    call w%create( irwk, icwk, ierror )
    !     return if allocation failed
    if (ierror == 20) return
    call cmgnbnn(nperod, n, mperod, m, a, b, c, idimy, y, w%cxw)
    !     release dynamically allocated work space
    call w%destroy()

end subroutine CMGNBN

subroutine CMGNBNN(nperod, n, mperod, m, a, b, c, idimy, y, w)

    !-----------------------------------------------
    !   D u m m y   A r g u m e n t s
    !-----------------------------------------------
    integer , intent (in) :: nperod
    integer  :: n
    integer , intent (in) :: mperod
    integer  :: m
    integer  :: idimy
    complex , intent (in) :: a(*)
    complex , intent (in) :: b(*)
    complex , intent (in) :: c(*)
    complex  :: y(idimy, *)
    complex  :: w(*)
    !-----------------------------------------------
    !   L o c a l   V a r i a b l e s
    !-----------------------------------------------
    integer :: iwba, iwbb, iwbc, iwb2, iwb3, iww1, iww2, iww3, iwd, &
        iwtcos, iwp, i, k, j, mp, np, ipstor, irev, mh, mhm1, modd, &
        mhpi, mhmi, nby2, mskip
    complex :: a1
    !-----------------------------------------------
    iwba = m + 1
    iwbb = iwba + m
    iwbc = iwbb + m
    iwb2 = iwbc + m
    iwb3 = iwb2 + m
    iww1 = iwb3 + m
    iww2 = iww1 + m
    iww3 = iww2 + m
    iwd = iww3 + m
    iwtcos = iwd + m
    iwp = iwtcos + 4*n
    do i = 1, m
        k = iwba + i - 1
        w(k) = -A(i)
        k = iwbc + i - 1
        w(k) = -C(i)
        k = iwbb + i - 1
        w(k) = 2. - B(i)
        y(i, :n) = -Y(i, :n)
    end do
    mp = mperod + 1
    np = nperod + 1
    go to (114, 107) mp
107 continue
    go to (108, 109, 110, 111, 123) np
108 continue
    call CMPOSP (m, n, W(iwba), W(iwbb), W(iwbc), y, idimy, w, W(iwb2) &
        , W(iwb3), W(iww1), W(iww2), W(iww3), W(iwd), W(iwtcos), W(iwp) &
        )
    go to 112
109 continue
    call CMPOSD (m, n, 1, W(iwba), W(iwbb), W(iwbc), y, idimy, w, W( &
        iww1), W(iwd), W(iwtcos), W(iwp))
    go to 112
110 continue
    call CMPOSN (m, n, 1, 2, W(iwba), W(iwbb), W(iwbc), y, idimy, w, W &
        (iwb2), W(iwb3), W(iww1), W(iww2), W(iww3), W(iwd), W(iwtcos), &
        W(iwp))
    go to 112
111 continue
    call CMPOSN (m, n, 1, 1, W(iwba), W(iwbb), W(iwbc), y, idimy, w, W &
        (iwb2), W(iwb3), W(iww1), W(iww2), W(iww3), W(iwd), W(iwtcos), &
        W(iwp))
112 continue
    ipstor = REAL(W(iww1))
    irev = 2
    if (nperod == 4) go to 124
113 continue
    go to (127, 133) mp
114 continue
    mh = (m + 1)/2
    mhm1 = mh - 1
    modd = 1
    if (mh*2 == m) modd = 2
    do j = 1, n
        do i = 1, mhm1
            w(i) = Y(mh-i, j) - Y(i+mh, j)
            w(i+mh) = Y(mh-i, j) + Y(i+mh, j)
        end do
        w(mh) = 2.*Y(mh, j)
        go to (117, 116) modd
116 continue
    w(m) = 2.*Y(m, j)
117 continue
    y(:m, j) = W(:m)
end do
k = iwbc + mhm1 - 1
i = iwba + mhm1
w(k) = (0., 0.)
w(i) = (0., 0.)
w(k+1) = 2.*W(k+1)
select case (modd)
    case default
        k = iwbb + mhm1 - 1
        w(k) = W(k) - W(i-1)
        w(iwbc-1) = W(iwbc-1) + W(iwbb-1)
    case (2)
        w(iwbb-1) = W(k+1)
end select
122 continue
    go to 107
!
!     REVERSE COLUMNS WHEN NPEROD = 4
!
123 continue
    irev = 1
    nby2 = n/2
124 continue
    do j = 1, nby2
        mskip = n + 1 - j
        do i = 1, m
            a1 = Y(i, j)
            y(i, j) = Y(i, mskip)
            y(i, mskip) = a1
        end do
    end do
    go to (110, 113) irev
127 continue
    do j = 1, n
        w(mh-1:mh-mhm1:(-1)) = 0.5*(Y(mh+1:mhm1+mh, j)+Y(:mhm1, j))
        w(mh+1:mhm1+mh) = 0.5*(Y(mh+1:mhm1+mh, j)-Y(:mhm1, j))
        w(mh) = 0.5*Y(mh, j)
        go to (130, 129) modd
129 continue
    w(m) = 0.5*Y(m, j)
130 continue
    y(:m, j) = W(:m)
end do
133 continue
    w(1) = CMPLX(real(ipstor + iwp - 1), 0.)
    return
end subroutine CMGNBNN


subroutine CMPOSD(mr, nr, istag, ba, bb, bc, q, idimq, b, w, d, tcos, p)

    !-----------------------------------------------
    !   D u m m y   A r g u m e n t s
    !-----------------------------------------------
    integer , intent (in) :: mr
    integer , intent (in) :: nr
    integer , intent (in) :: istag
    integer , intent (in) :: idimq
    complex  :: ba(*)
    complex  :: bb(*)
    complex  :: bc(*)
    complex , intent (in out) :: q(idimq, 1)
    complex  :: b(*)
    complex  :: w(*)
    complex  :: d(*)
    complex  :: tcos(*)
    complex , intent (in out) :: p(*)
    !-----------------------------------------------
    !   L o c a l   V a r i a b l e s
    !-----------------------------------------------
    integer :: m, n, ip, ipstor, jsh, kr, irreg, jstsav, i, lr, nun, &
        jst, jsp, l, nodd, j, jm1, jp1, jm2, jp2, jm3, jp3, noddpr, ip1 &
        , krpi, ideg, jdeg
    real :: fi
    complex :: t
    !-----------------------------------------------
    !
    !     SUBROUTINE TO SOLVE POISSON'S EQUATION FOR DIRICHLET BOUNDARY
    !     CONDITIONS.
    !
    !     ISTAG = 1 IF THE LAST DIAGONAL BLOCK IS THE MATRIX A.
    !     ISTAG = 2 IF THE LAST DIAGONAL BLOCK IS THE MATRIX A+I.
    !
    m = mr
    n = nr
    fi = 1./real(istag)
    ip = -m
    ipstor = 0
    jsh = 0
    select case (istag)
        case default
            kr = 0
            irreg = 1
            if (n > 1) go to 106
            tcos(1) = (0., 0.)
        case (2)
            kr = 1
            jstsav = 1
            irreg = 2
            if (n > 1) go to 106
            tcos(1) = CMPLX(-1., 0.)
    end select
103 continue
    b(:m) = Q(:m, 1)
    call CMPTRX (1, 0, m, ba, bb, bc, b, tcos, d, w)
    q(:m, 1) = B(:m)
    go to 183
106 continue
    lr = 0
    do i = 1, m
        p(i) = CMPLX(0., 0.)
    end do
    nun = n
    jst = 1
    jsp = n
!
!     IRREG = 1 WHEN NO IRREGULARITIES HAVE OCCURRED, OTHERWISE IT IS 2.
!
108 continue
    l = 2*jst
    nodd = 2 - 2*((nun + 1)/2) + nun
    !
    !     NODD = 1 WHEN NUN IS ODD, OTHERWISE IT IS 2.
    !
    select case (nodd)
        case default
            jsp = jsp - l
        case (1)
            jsp = jsp - jst
            if (irreg /= 1) jsp = jsp - l
    end select
111 continue
    call CMPCSG (jst, 1, 0.5, 0.0, tcos)
    if (l <= jsp) then
        do j = l, jsp, l
            jm1 = j - jsh
            jp1 = j + jsh
            jm2 = j - jst
            jp2 = j + jst
            jm3 = jm2 - jsh
            jp3 = jp2 + jsh
            if (jst == 1) then
                b(:m) = 2.*Q(:m, j)
                q(:m, j) = Q(:m, jm2) + Q(:m, jp2)
            else
                do i = 1, m
                    t = Q(i, j) - Q(i, jm1) - Q(i, jp1) + Q(i, jm2) + Q(i, jp2)
                    b(i) = t + Q(i, j) - Q(i, jm3) - Q(i, jp3)
                    q(i, j) = t
                end do
            end if
            call CMPTRX (jst, 0, m, ba, bb, bc, b, tcos, d, w)
            q(:m, j) = Q(:m, j) + B(:m)
        end do
    end if
    !
    !     REDUCTION FOR LAST UNKNOWN
    !
    select case (nodd)
        case default
            go to (152, 120) irreg
        !
        !     ODD NUMBER OF UNKNOWNS
        !
120     continue
        jsp = jsp + l
        j = jsp
        jm1 = j - jsh
        jp1 = j + jsh
        jm2 = j - jst
        jp2 = j + jst
        jm3 = jm2 - jsh
        go to (123, 121) istag
121 continue
    if (jst /= 1) go to 123
    do i = 1, m
        b(i) = Q(i, j)
        q(i, j) = CMPLX(0., 0.)
    end do
    go to 130
123 continue
    select case (noddpr)
        case default
            b(:m) = 0.5*(Q(:m, jm2)-Q(:m, jm1)-Q(:m, jm3)) + P(ip+1:m+ip) &
                + Q(:m, j)
        case (2)
            b(:m) = 0.5*(Q(:m, jm2)-Q(:m, jm1)-Q(:m, jm3)) + Q(:m, jp2) - Q( &
                :m, jp1) + Q(:m, j)
    end select
128 continue
    q(:m, j) = 0.5*(Q(:m, j)-Q(:m, jm1)-Q(:m, jp1))
130 continue
    call CMPTRX (jst, 0, m, ba, bb, bc, b, tcos, d, w)
    ip = ip + m
    ipstor = max(ipstor, ip + m)
    p(ip+1:m+ip) = Q(:m, j) + B(:m)
    b(:m) = Q(:m, jp2) + P(ip+1:m+ip)
    if (lr == 0) then
        do i = 1, jst
            krpi = kr + i
            tcos(krpi) = TCOS(i)
        end do
    else
        call CMPCSG (lr, jstsav, 0., fi, TCOS(jst+1))
        call CMPMRG (tcos, 0, jst, jst, lr, kr)
    end if
    call CMPCSG (kr, jstsav, 0.0, fi, tcos)
    call CMPTRX (kr, kr, m, ba, bb, bc, b, tcos, d, w)
    q(:m, j) = Q(:m, jm2) + B(:m) + P(ip+1:m+ip)
    lr = kr
    kr = kr + l
!
!     EVEN NUMBER OF UNKNOWNS
!
case (2)
    jsp = jsp + l
    j = jsp
    jm1 = j - jsh
    jp1 = j + jsh
    jm2 = j - jst
    jp2 = j + jst
    jm3 = jm2 - jsh
    select case (irreg)
        case default
            jstsav = jst
            ideg = jst
            kr = l
        case (2)
            call CMPCSG (kr, jstsav, 0.0, fi, tcos)
            call CMPCSG (lr, jstsav, 0.0, fi, TCOS(kr+1))
            ideg = kr
            kr = kr + jst
    end select
139 continue
    if (jst == 1) then
        irreg = 2
        b(:m) = Q(:m, j)
        q(:m, j) = Q(:m, jm2)
    else
        b(:m) = Q(:m, j) + 0.5*(Q(:m, jm2)-Q(:m, jm1)-Q(:m, jm3))
        select case (irreg)
            case default
                q(:m, j) = Q(:m, jm2) + 0.5*(Q(:m, j)-Q(:m, jm1)-Q(:m, jp1))
                irreg = 2
            case (2)
                select case (noddpr)
                    case default
                        q(:m, j) = Q(:m, jm2) + P(ip+1:m+ip)
                        ip = ip - m
                    case (2)
                        q(:m, j) = Q(:m, jm2) + Q(:m, j) - Q(:m, jm1)
                end select
        end select
    end if
150 continue
    call CMPTRX (ideg, lr, m, ba, bb, bc, b, tcos, d, w)
    q(:m, j) = Q(:m, j) + B(:m)
end select
152 continue
    nun = nun/2
    noddpr = nodd
    jsh = jst
    jst = 2*jst
    if (nun >= 2) go to 108
    !
    !     START SOLUTION.
    !
    j = jsp
    b(:m) = Q(:m, j)
    select case (irreg)
        case default
            call CMPCSG (jst, 1, 0.5, 0.0, tcos)
            ideg = jst
        case (2)
            kr = lr + jst
            call CMPCSG (kr, jstsav, 0.0, fi, tcos)
            call CMPCSG (lr, jstsav, 0.0, fi, TCOS(kr+1))
            ideg = kr
    end select
156 continue
    call CMPTRX (ideg, lr, m, ba, bb, bc, b, tcos, d, w)
    jm1 = j - jsh
    jp1 = j + jsh
    select case (irreg)
        case default
            q(:m, j) = 0.5*(Q(:m, j)-Q(:m, jm1)-Q(:m, jp1)) + B(:m)
        case (2)
            select case (noddpr)
                case default
                    q(:m, j) = P(ip+1:m+ip) + B(:m)
                    ip = ip - m
                case (2)
                    q(:m, j) = Q(:m, j) - Q(:m, jm1) + B(:m)
            end select
    end select
164 continue
    jst = jst/2
    jsh = jst/2
    nun = 2*nun
    if (nun > n) go to 183
    do j = jst, n, l
        jm1 = j - jsh
        jp1 = j + jsh
        jm2 = j - jst
        jp2 = j + jst
        if (j <= jst) then
            b(:m) = Q(:m, j) + Q(:m, jp2)
        else
            if (jp2 <= n) go to 168
            b(:m) = Q(:m, j) + Q(:m, jm2)
            if (jst < jstsav) irreg = 1
            go to (170, 171) irreg
168     continue
        b(:m) = Q(:m, j) + Q(:m, jm2) + Q(:m, jp2)
    end if
170 continue
    call CMPCSG (jst, 1, 0.5, 0.0, tcos)
    ideg = jst
    jdeg = 0
    go to 172
171 continue
    if (j + l > n) lr = lr - jst
    kr = jst + lr
    call CMPCSG (kr, jstsav, 0.0, fi, tcos)
    call CMPCSG (lr, jstsav, 0.0, fi, TCOS(kr+1))
    ideg = kr
    jdeg = lr
172 continue
    call CMPTRX (ideg, jdeg, m, ba, bb, bc, b, tcos, d, w)
    if (jst <= 1) then
        q(:m, j) = B(:m)
    else
        if (jp2 > n) go to 177
175 continue
    q(:m, j) = 0.5*(Q(:m, j)-Q(:m, jm1)-Q(:m, jp1)) + B(:m)
    cycle
177 continue
    go to (175, 178) irreg
178 continue
    if (j + jsh <= n) then
        q(:m, j) = B(:m) + P(ip+1:m+ip)
        ip = ip - m
    else
        q(:m, j) = B(:m) + Q(:m, j) - Q(:m, jm1)
    end if
end if
end do
l = l/2
go to 164
183 continue
    w(1) = CMPLX(real(ipstor), 0.)
    return
end subroutine CMPOSD


subroutine CMPOSN(m, n, istag, mixbnd, a, bb, c, q, idimq, b, b2, &
    b3, w, w2, w3, d, tcos, p)

    !-----------------------------------------------
    !   D u m m y   A r g u m e n t s
    !-----------------------------------------------
    integer , intent (in) :: m
    integer , intent (in) :: n
    integer , intent (in) :: istag
    integer , intent (in) :: mixbnd
    integer , intent (in) :: idimq
    complex  :: a(*)
    complex  :: bb(*)
    complex  :: c(*)
    complex , intent (in out) :: q(idimq, *)
    complex  :: b(*)
    complex  :: b2(*)
    complex  :: b3(*)
    complex  :: w(*)
    complex  :: w2(*)
    complex  :: w3(*)
    complex  :: d(*)
    complex  :: tcos(*)
    complex , intent (in out) :: p(*)
    !-----------------------------------------------
    !   L o c a l   V a r i a b l e s
    !-----------------------------------------------
    integer , dimension(4) :: k
    integer :: k1, k2, k3, k4, mr, ip, ipstor, i2r, jr, nr, nlast, kr &
        , lr, i, nrod, jstart, jstop, i2rby2, j, jp1, jp2, jp3, jm1, &
        jm2, jm3, nrodpr, ii, i1, i2, jr2, nlastp, jstep
    real :: fistag, fnum, fden
    complex :: fi, t
    !-----------------------------------------------
    !
    !     SUBROUTINE TO SOLVE POISSON'S EQUATION WITH NEUMANN BOUNDARY
    !     CONDITIONS.
    !
    !     ISTAG = 1 IF THE LAST DIAGONAL BLOCK IS A.
    !     ISTAG = 2 IF THE LAST DIAGONAL BLOCK IS A-I.
    !     MIXBND = 1 IF HAVE NEUMANN BOUNDARY CONDITIONS AT BOTH BOUNDARIES.
    !     MIXBND = 2 IF HAVE NEUMANN BOUNDARY CONDITIONS AT BOTTOM AND
    !     DIRICHLET CONDITION AT TOP.  (FOR THIS CASE, MUST HAVE ISTAG = 1.)
    !
    equivalence (K(1), K1), (K(2), K2), (K(3), K3), (K(4), K4)
    fistag = 3 - istag
    fnum = 1./real(istag)
    fden = 0.5*real(istag - 1)
    mr = m
    ip = -mr
    ipstor = 0
    i2r = 1
    jr = 2
    nr = n
    nlast = n
    kr = 1
    lr = 0
    go to (101, 103) istag
101 continue
    q(:mr, n) = 0.5*Q(:mr, n)
    go to (103, 104) mixbnd
103 continue
    if (n <= 3) go to 155
104 continue
    jr = 2*i2r
    nrod = 1
    if ((nr/2)*2 == nr) nrod = 0
    select case (mixbnd)
        case default
            jstart = 1
        case (2)
            jstart = jr
            nrod = 1 - nrod
    end select
107 continue
    jstop = nlast - jr
    if (nrod == 0) jstop = jstop - i2r
    call CMPCSG (i2r, 1, 0.5, 0.0, tcos)
    i2rby2 = i2r/2
    if (jstop < jstart) then
        j = jr
    else
        do j = jstart, jstop, jr
            jp1 = j + i2rby2
            jp2 = j + i2r
            jp3 = jp2 + i2rby2
            jm1 = j - i2rby2
            jm2 = j - i2r
            jm3 = jm2 - i2rby2
            if (j == 1) then
                jm1 = jp1
                jm2 = jp2
                jm3 = jp3
            end if
            if (i2r == 1) then
                if (j == 1) jm2 = jp2
                b(:mr) = 2.*Q(:mr, j)
                q(:mr, j) = Q(:mr, jm2) + Q(:mr, jp2)
            else
                do i = 1, mr
                    fi = Q(i, j)
                    q(i, j)=Q(i, j)-Q(i, jm1)-Q(i, jp1)+Q(i, jm2)+Q(i, jp2)
                    b(i) = fi + Q(i, j) - Q(i, jm3) - Q(i, jp3)
                end do
            end if
            call CMPTRX (i2r, 0, mr, a, bb, c, b, tcos, d, w)
            q(:mr, j) = Q(:mr, j) + B(:mr)
        !
        !     END OF REDUCTION FOR REGULAR UNKNOWNS.
        !
        end do
        !
        !     BEGIN SPECIAL REDUCTION FOR LAST UNKNOWN.
        !
        j = jstop + jr
    end if
    nlast = j
    jm1 = j - i2rby2
    jm2 = j - i2r
    jm3 = jm2 - i2rby2
    if (nrod /= 0) then
        !
        !     ODD NUMBER OF UNKNOWNS
        !
        if (i2r == 1) then
            b(:mr) = fistag*Q(:mr, j)
            q(:mr, j) = Q(:mr, jm2)
        else
            b(:mr) = Q(:mr, j) + 0.5*(Q(:mr, jm2)-Q(:mr, jm1)-Q(:mr, jm3))
            if (nrodpr == 0) then
                q(:mr, j) = Q(:mr, jm2) + P(ip+1:mr+ip)
                ip = ip - mr
            else
                q(:mr, j) = Q(:mr, j) - Q(:mr, jm1) + Q(:mr, jm2)
            end if
            if (lr /= 0) then
                call CMPCSG (lr, 1, 0.5, fden, TCOS(kr+1))
            else
                b(:mr) = fistag*B(:mr)
            end if
        end if
        call CMPCSG (kr, 1, 0.5, fden, tcos)
        call CMPTRX (kr, lr, mr, a, bb, c, b, tcos, d, w)
        q(:mr, j) = Q(:mr, j) + B(:mr)
        kr = kr + i2r
    else
        jp1 = j + i2rby2
        jp2 = j + i2r
        if (i2r == 1) then
            b(:mr) = Q(:mr, j)
            call CMPTRX (1, 0, mr, a, bb, c, b, tcos, d, w)
            ip = 0
            ipstor = mr
            select case (istag)
                case default
                    p(:mr) = B(:mr)
                    b(:mr) = B(:mr) + Q(:mr, n)
                    tcos(1) = CMPLX(1., 0.)
                    tcos(2) = CMPLX(0., 0.)
                    call CMPTRX (1, 1, mr, a, bb, c, b, tcos, d, w)
                    q(:mr, j) = Q(:mr, jm2) + P(:mr) + B(:mr)
                    go to 150
                case (1)
                    p(:mr) = B(:mr)
                    q(:mr, j) = Q(:mr, jm2) + 2.*Q(:mr, jp2) + 3.*B(:mr)
                    go to 150
            end select
        end if
        b(:mr) = Q(:mr, j) + 0.5*(Q(:mr, jm2)-Q(:mr, jm1)-Q(:mr, jm3))
        if (nrodpr == 0) then
            b(:mr) = B(:mr) + P(ip+1:mr+ip)
        else
            b(:mr) = B(:mr) + Q(:mr, jp2) - Q(:mr, jp1)
        end if
        call CMPTRX (i2r, 0, mr, a, bb, c, b, tcos, d, w)
        ip = ip + mr
        ipstor = max(ipstor, ip + mr)
        p(ip+1:mr+ip) = B(:mr) + 0.5*(Q(:mr, j)-Q(:mr, jm1)-Q(:mr, jp1))
        b(:mr) = P(ip+1:mr+ip) + Q(:mr, jp2)
        if (lr /= 0) then
            call CMPCSG (lr, 1, 0.5, fden, TCOS(i2r+1))
            call CMPMRG (tcos, 0, i2r, i2r, lr, kr)
        else
            do i = 1, i2r
                ii = kr + i
                tcos(ii) = TCOS(i)
            end do
        end if
        call CMPCSG (kr, 1, 0.5, fden, tcos)
        if (lr == 0) then
            go to (146, 145) istag
        end if
145 continue
    call CMPTRX (kr, kr, mr, a, bb, c, b, tcos, d, w)
    go to 148
146 continue
    b(:mr) = fistag*B(:mr)
148 continue
    q(:mr, j) = Q(:mr, jm2) + P(ip+1:mr+ip) + B(:mr)
150 continue
    lr = kr
    kr = kr + jr
end if
select case (mixbnd)
    case default
        nr = (nlast - 1)/jr + 1
        if (nr <= 3) go to 155
    case (2)
        nr = nlast/jr
        if (nr <= 1) go to 192
end select
154 continue
    i2r = jr
    nrodpr = nrod
    go to 104
155 continue
    j = 1 + jr
    jm1 = j - i2r
    jp1 = j + i2r
    jm2 = nlast - i2r
    if (nr /= 2) then
        if (lr /= 0) go to 170
        if (n == 3) then
            !
            !     CASE N = 3.
            !
            go to (156, 168) istag
156     continue
        b(:mr) = Q(:mr, 2)
        tcos(1) = CMPLX(0., 0.)
        call CMPTRX (1, 0, mr, a, bb, c, b, tcos, d, w)
        q(:mr, 2) = B(:mr)
        b(:mr) = 4.*B(:mr) + Q(:mr, 1) + 2.*Q(:mr, 3)
        tcos(1) = CMPLX(-2., 0.)
        tcos(2) = CMPLX(2., 0.)
        i1 = 2
        i2 = 0
        call CMPTRX (i1, i2, mr, a, bb, c, b, tcos, d, w)
        q(:mr, 2) = Q(:mr, 2) + B(:mr)
        b(:mr) = Q(:mr, 1) + 2.*Q(:mr, 2)
        tcos(1) = (0., 0.)
        call CMPTRX (1, 0, mr, a, bb, c, b, tcos, d, w)
        q(:mr, 1) = B(:mr)
        jr = 1
        i2r = 0
        go to 194
    end if
    !
    !     CASE N = 2**P+1
    !
    go to (162, 170) istag
162 continue
    b(:mr) = Q(:mr, j) + 0.5*Q(:mr, 1) - Q(:mr, jm1) + Q(:mr, nlast) - &
        Q(:mr, jm2)
    call CMPCSG (jr, 1, 0.5, 0.0, tcos)
    call CMPTRX (jr, 0, mr, a, bb, c, b, tcos, d, w)
    q(:mr, j) = 0.5*(Q(:mr, j)-Q(:mr, jm1)-Q(:mr, jp1)) + B(:mr)
    b(:mr) = Q(:mr, 1) + 2.*Q(:mr, nlast) + 4.*Q(:mr, j)
    jr2 = 2*jr
    call CMPCSG (jr, 1, 0.0, 0.0, tcos)
    tcos(jr+1:jr*2) = -TCOS(jr:1:(-1))
    call CMPTRX (jr2, 0, mr, a, bb, c, b, tcos, d, w)
    q(:mr, j) = Q(:mr, j) + B(:mr)
    b(:mr) = Q(:mr, 1) + 2.*Q(:mr, j)
    call CMPCSG (jr, 1, 0.5, 0.0, tcos)
    call CMPTRX (jr, 0, mr, a, bb, c, b, tcos, d, w)
    q(:mr, 1) = 0.5*Q(:mr, 1) - Q(:mr, jm1) + B(:mr)
    go to 194
!
!     CASE OF GENERAL N WITH NR = 3 .
!
168 continue
    b(:mr) = Q(:mr, 2)
    q(:mr, 2) = (0., 0.)
    b2(:mr) = Q(:mr, 3)
    b3(:mr) = Q(:mr, 1)
    jr = 1
    i2r = 0
    j = 2
    go to 177
170 continue
    b(:mr) = 0.5*Q(:mr, 1) - Q(:mr, jm1) + Q(:mr, j)
    if (nrod == 0) then
        b(:mr) = B(:mr) + P(ip+1:mr+ip)
    else
        b(:mr) = B(:mr) + Q(:mr, nlast) - Q(:mr, jm2)
    end if
    do i = 1, mr
        t = 0.5*(Q(i, j)-Q(i, jm1)-Q(i, jp1))
        q(i, j) = t
        b2(i) = Q(i, nlast) + t
        b3(i) = Q(i, 1) + 2.*t
    end do
177 continue
    k1 = kr + 2*jr - 1
    k2 = kr + jr
    tcos(k1+1) = (-2., 0.)
    k4 = k1 + 3 - istag
    call CMPCSG (k2 + istag - 2, 1, 0.0, fnum, TCOS(k4))
    k4 = k1 + k2 + 1
    call CMPCSG (jr - 1, 1, 0.0, 1.0, TCOS(k4))
    call CMPMRG (tcos, k1, k2, k1 + k2, jr - 1, 0)
    k3 = k1 + k2 + lr
    call CMPCSG (jr, 1, 0.5, 0.0, TCOS(k3+1))
    k4 = k3 + jr + 1
    call CMPCSG (kr, 1, 0.5, fden, TCOS(k4))
    call CMPMRG (tcos, k3, jr, k3 + jr, kr, k1)
    if (lr /= 0) then
        call CMPCSG (lr, 1, 0.5, fden, TCOS(k4))
        call CMPMRG (tcos, k3, jr, k3 + jr, lr, k3 - lr)
        call CMPCSG (kr, 1, 0.5, fden, TCOS(k4))
    end if
    k3 = kr
    k4 = kr
    call CMPTR3 (mr, a, bb, c, k, b, b2, b3, tcos, d, w, w2, w3)
    b(:mr) = B(:mr) + B2(:mr) + B3(:mr)
    tcos(1) = (2., 0.)
    call CMPTRX (1, 0, mr, a, bb, c, b, tcos, d, w)
    q(:mr, j) = Q(:mr, j) + B(:mr)
    b(:mr) = Q(:mr, 1) + 2.*Q(:mr, j)
    call CMPCSG (jr, 1, 0.5, 0.0, tcos)
    call CMPTRX (jr, 0, mr, a, bb, c, b, tcos, d, w)
    if (jr == 1) then
        q(:mr, 1) = B(:mr)
        go to 194
    end if
    q(:mr, 1) = 0.5*Q(:mr, 1) - Q(:mr, jm1) + B(:mr)
    go to 194
end if
if (n == 2) then
    !
    !     CASE  N = 2
    !
    b(:mr) = Q(:mr, 1)
    tcos(1) = (0., 0.)
    call CMPTRX (1, 0, mr, a, bb, c, b, tcos, d, w)
    q(:mr, 1) = B(:mr)
    b(:mr) = 2.*(Q(:mr, 2)+B(:mr))*fistag
    tcos(1) = CMPLX((-fistag), 0.)
    tcos(2) = CMPLX(2., 0.)
    call CMPTRX (2, 0, mr, a, bb, c, b, tcos, d, w)
    q(:mr, 1) = Q(:mr, 1) + B(:mr)
    jr = 1
    i2r = 0
    go to 194
end if
b3(:mr) = (0., 0.)
b(:mr) = Q(:mr, 1) + 2.*P(ip+1:mr+ip)
q(:mr, 1) = 0.5*Q(:mr, 1) - Q(:mr, jm1)
b2(:mr) = 2.*(Q(:mr, 1)+Q(:mr, nlast))
k1 = kr + jr - 1
tcos(k1+1) = (-2., 0.)
k4 = k1 + 3 - istag
call CMPCSG (kr + istag - 2, 1, 0.0, fnum, TCOS(k4))
k4 = k1 + kr + 1
call CMPCSG (jr - 1, 1, 0.0, 1.0, TCOS(k4))
call CMPMRG (tcos, k1, kr, k1 + kr, jr - 1, 0)
call CMPCSG (kr, 1, 0.5, fden, TCOS(k1+1))
k2 = kr
k4 = k1 + k2 + 1
call CMPCSG (lr, 1, 0.5, fden, TCOS(k4))
k3 = lr
k4 = 0
call CMPTR3 (mr, a, bb, c, k, b, b2, b3, tcos, d, w, w2, w3)
b(:mr) = B(:mr) + B2(:mr)
tcos(1) = (2., 0.)
call CMPTRX (1, 0, mr, a, bb, c, b, tcos, d, w)
q(:mr, 1) = Q(:mr, 1) + B(:mr)
go to 194
192 continue
    b(:mr) = Q(:mr, nlast)
    go to 196
194 continue
    j = nlast - jr
    b(:mr) = Q(:mr, nlast) + Q(:mr, j)
196 continue
    jm2 = nlast - i2r
    if (jr == 1) then
        q(:mr, nlast) = (0., 0.)
    else
        if (nrod == 0) then
            q(:mr, nlast) = P(ip+1:mr+ip)
            ip = ip - mr
        else
            q(:mr, nlast) = Q(:mr, nlast) - Q(:mr, jm2)
        end if
    end if
    call CMPCSG (kr, 1, 0.5, fden, tcos)
    call CMPCSG (lr, 1, 0.5, fden, TCOS(kr+1))
    if (lr == 0) then
        b(:mr) = fistag*B(:mr)
    end if
    call CMPTRX (kr, lr, mr, a, bb, c, b, tcos, d, w)
    q(:mr, nlast) = Q(:mr, nlast) + B(:mr)
    nlastp = nlast
206 continue
    jstep = jr
    jr = i2r
    i2r = i2r/2
    if (jr == 0) go to 222
    select case (mixbnd)
        case default
            jstart = 1 + jr
        case (2)
            jstart = jr
    end select
209 continue
    kr = kr - jr
    if (nlast + jr <= n) then
        kr = kr - jr
        nlast = nlast + jr
        jstop = nlast - jstep
    else
        jstop = nlast - jr
    end if
    lr = kr - jr
    call CMPCSG (jr, 1, 0.5, 0.0, tcos)
    do j = jstart, jstop, jstep
        jm2 = j - jr
        jp2 = j + jr
        if (j == jr) then
            b(:mr) = Q(:mr, j) + Q(:mr, jp2)
        else
            b(:mr) = Q(:mr, j) + Q(:mr, jm2) + Q(:mr, jp2)
        end if
        if (jr == 1) then
            q(:mr, j) = (0., 0.)
        else
            jm1 = j - i2r
            jp1 = j + i2r
            q(:mr, j) = 0.5*(Q(:mr, j)-Q(:mr, jm1)-Q(:mr, jp1))
        end if
        call CMPTRX (jr, 0, mr, a, bb, c, b, tcos, d, w)
        q(:mr, j) = Q(:mr, j) + B(:mr)
    end do
    nrod = 1
    if (nlast + i2r <= n) nrod = 0
    if (nlastp /= nlast) go to 194
    go to 206
222 continue
    w(1) = CMPLX(real(ipstor), 0.)
    return
end subroutine CMPOSN


subroutine CMPOSP(m, n, a, bb, c, q, idimq, b, b2, b3, w, w2, w3, d, tcos, p)

    !-----------------------------------------------
    !   D u m m y   A r g u m e n t s
    !-----------------------------------------------
    integer , intent (in) :: m
    integer , intent (in) :: n
    integer  :: idimq
    complex  :: a(*)
    complex  :: bb(*)
    complex  :: c(*)
    complex  :: q(idimq, 1)
    complex  :: b(*)
    complex  :: b2(*)
    complex  :: b3(*)
    complex  :: w(*)
    complex  :: w2(*)
    complex  :: w3(*)
    complex  :: d(*)
    complex  :: tcos(*)
    complex  :: p(*)
    !-----------------------------------------------
    !   L o c a l   V a r i a b l e s
    !-----------------------------------------------
    integer :: mr, nr, nrm1, j, nrmj, nrpj, i, ipstor, lh
    complex :: s, t
    !-----------------------------------------------
    !
    !     SUBROUTINE TO SOLVE POISSON EQUATION WITH PERIODIC BOUNDARY
    !     CONDITIONS.
    !
    mr = m
    nr = (n + 1)/2
    nrm1 = nr - 1
    if (2*nr == n) then
        !
        !     EVEN NUMBER OF UNKNOWNS
        !
        do j = 1, nrm1
            nrmj = nr - j
            nrpj = nr + j
            do i = 1, mr
                s = Q(i, nrmj) - Q(i, nrpj)
                t = Q(i, nrmj) + Q(i, nrpj)
                q(i, nrmj) = s
                q(i, nrpj) = t
            end do
        end do
        q(:mr, nr) = 2.*Q(:mr, nr)
        q(:mr, n) = 2.*Q(:mr, n)
        call CMPOSD (mr, nrm1, 1, a, bb, c, q, idimq, b, w, d, tcos, p)
        ipstor = REAL(W(1))
        call CMPOSN (mr, nr + 1, 1, 1, a, bb, c, Q(1, nr), idimq, b, b2 &
            , b3, w, w2, w3, d, tcos, p)
        ipstor = max(ipstor, INT(REAL(W(1))))
        do j = 1, nrm1
            nrmj = nr - j
            nrpj = nr + j
            do i = 1, mr
                s = 0.5*(Q(i, nrpj)+Q(i, nrmj))
                t = 0.5*(Q(i, nrpj)-Q(i, nrmj))
                q(i, nrmj) = s
                q(i, nrpj) = t
            end do
        end do
        q(:mr, nr) = 0.5*Q(:mr, nr)
        q(:mr, n) = 0.5*Q(:mr, n)
    else
        do j = 1, nrm1
            nrpj = n + 1 - j
            do i = 1, mr
                s = Q(i, j) - Q(i, nrpj)
                t = Q(i, j) + Q(i, nrpj)
                q(i, j) = s
                q(i, nrpj) = t
            end do
        end do
        q(:mr, nr) = 2.*Q(:mr, nr)
        lh = nrm1/2
        do j = 1, lh
            nrmj = nr - j
            do i = 1, mr
                s = Q(i, j)
                q(i, j) = Q(i, nrmj)
                q(i, nrmj) = s
            end do
        end do
        call CMPOSD (mr, nrm1, 2, a, bb, c, q, idimq, b, w, d, tcos, p)
        ipstor = REAL(W(1))
        call CMPOSN (mr, nr, 2, 1, a, bb, c, Q(1, nr), idimq, b, b2, b3 &
            , w, w2, w3, d, tcos, p)
        ipstor = max(ipstor, INT(REAL(W(1))))
        do j = 1, nrm1
            nrpj = nr + j
            do i = 1, mr
                s = 0.5*(Q(i, nrpj)+Q(i, j))
                t = 0.5*(Q(i, nrpj)-Q(i, j))
                q(i, nrpj) = t
                q(i, j) = s
            end do
        end do
        q(:mr, nr) = 0.5*Q(:mr, nr)
        do j = 1, lh
            nrmj = nr - j
            do i = 1, mr
                s = Q(i, j)
                q(i, j) = Q(i, nrmj)
                q(i, nrmj) = s
            end do
        end do
    end if
    w(1) = CMPLX(real(ipstor), 0.)
    return
end subroutine CMPOSP


subroutine CMPCSG(n, ijump, fnum, fden, a)

    real pi_mach
    !-----------------------------------------------
    !   D u m m y   A r g u m e n t s
    !-----------------------------------------------
    integer , intent (in) :: n
    integer , intent (in) :: ijump
    real , intent (in) :: fnum
    real , intent (in) :: fden
    complex , intent (out) :: a(*)
    !-----------------------------------------------
    !   L o c a l   V a r i a b l e s
    !-----------------------------------------------
    integer :: k3, k4, k, k1, k5, i, k2, np1
    real :: pi, dum, pibyn, x, y
    !-----------------------------------------------
    !
    !
    !     THIS SUBROUTINE COMPUTES REQUIRED COSINE VALUES IN ASCENDING
    !     ORDER.  WHEN IJUMP .GT. 1 THE ROUTINE COMPUTES VALUES
    !
    !        2*COS(J*PI/L) , J=1, 2, ..., L AND J .NE. 0(MOD N/IJUMP+1)
    !
    !     WHERE L = IJUMP*(N/IJUMP+1).
    !
    !
    !     WHEN IJUMP = 1 IT COMPUTES
    !
    !            2*COS((J-FNUM)*PI/(N+FDEN)) ,  J=1, 2, ... , N
    !
    !     WHERE
    !        FNUM = 0.5, FDEN = 0.0,  FOR REGULAR REDUCTION VALUES
    !        FNUM = 0.0, FDEN = 1.0, FOR B-R AND C-R WHEN ISTAG = 1
    !        FNUM = 0.0, FDEN = 0.5, FOR B-R AND C-R WHEN ISTAG = 2
    !        FNUM = 0.5, FDEN = 0.5, FOR B-R AND C-R WHEN ISTAG = 2
    !                                IN CMPOSN ONLY.
    !
    !
    pi = acos( -1.0 )
    if (n /= 0) then
        if (ijump /= 1) then
            k3 = n/ijump + 1
            k4 = k3 - 1
            pibyn = pi/real(n + ijump)
            do k = 1, ijump
                k1 = (k - 1)*k3
                k5 = (k - 1)*k4
                do i = 1, k4
                    x = k1 + i
                    k2 = k5 + i
                    a(k2) = CMPLX((-2.*COS(x*pibyn)), 0.)
                end do
            end do
        else
            np1 = n + 1
            y = pi/(real(n) + fden)
            do i = 1, n
                x = real(np1 - i) - fnum
                a(i) = CMPLX(2.*COS(x*y), 0.)
            end do
        end if
    end if
    return
end subroutine CMPCSG


subroutine CMPMRG(tcos, i1, m1, i2, m2, i3)

    !-----------------------------------------------
    !   D u m m y   A r g u m e n t s
    !-----------------------------------------------
    integer , intent (in) :: i1
    integer , intent (in) :: m1
    integer , intent (in) :: i2
    integer , intent (in) :: m2
    integer , intent (in) :: i3
    complex , intent (in out) :: tcos(*)
    !-----------------------------------------------
    !   L o c a l   V a r i a b l e s
    !-----------------------------------------------
    integer :: j11, j3, j1, j2, j, l, k, m
    complex :: x, y
    !-----------------------------------------------
    !
    !
    !     THIS SUBROUTINE MERGES TWO ASCENDING STRINGS OF NUMBERS IN THE
    !     ARRAY TCOS.  THE FIRST STRING IS OF LENGTH M1 AND STARTS AT
    !     TCOS(I1+1).  THE SECOND STRING IS OF LENGTH M2 AND STARTS AT
    !     TCOS(I2+1).  THE MERGED STRING GOES INTO TCOS(I3+1).
    !
    !
    j1 = 1
    j2 = 1
    j = i3
    if (m1 == 0) go to 107
    if (m2 == 0) go to 104
101 continue
    j11 = j1
    j3 = MAX(m1, j11)
    do j1 = j11, j3
        j = j + 1
        l = j1 + i1
        x = TCOS(l)
        l = j2 + i2
        y = TCOS(l)
        if (REAL(x - y) > 0.) go to 103
        tcos(j) = x
    end do
    go to 106
103 continue
    tcos(j) = y
    j2 = j2 + 1
    if (j2 <= m2) go to 101
    if (j1 > m1) go to 109
104 continue
    k = j - j1 + 1
    do j = j1, m1
        m = k + j
        l = j + i1
        tcos(m) = TCOS(l)
    end do
    go to 109
106 continue
    if (j2 > m2) go to 109
107 continue
    k = j - j2 + 1
    do j = j2, m2
        m = k + j
        l = j + i2
        tcos(m) = TCOS(l)
    end do
109 continue
    return
end subroutine CMPMRG


subroutine CMPTRX(idegbr, idegcr, m, a, b, c, y, tcos, d, w)

    !-----------------------------------------------
    !   D u m m y   A r g u m e n t s
    !-----------------------------------------------
    integer , intent (in) :: idegbr
    integer , intent (in) :: idegcr
    integer , intent (in) :: m
    complex , intent (in) :: a(*)
    complex , intent (in) :: b(*)
    complex , intent (in) :: c(*)
    complex , intent (in out) :: y(*)
    complex , intent (in) :: tcos(*)
    complex , intent (in out) :: d(*)
    complex , intent (in out) :: w(*)
    !-----------------------------------------------
    !   L o c a l   V a r i a b l e s
    !-----------------------------------------------
    integer :: mm1, ifb, ifc, l, lint, k, i, ip
    complex :: x, xx, z
    !-----------------------------------------------
    !
    !     SUBROUTINE TO SOLVE A SYSTEM OF LINEAR EQUATIONS WHERE THE
    !     COEFFICIENT MATRIX IS A RATIONAL FUNCTION IN THE MATRIX GIVEN BY
    !     TRIDIAGONAL  ( . . . , A(I), B(I), C(I), . . . ).
    !
    mm1 = m - 1
    ifb = idegbr + 1
    ifc = idegcr + 1
    l = ifb/ifc
    lint = 1
    do k = 1, idegbr
        x = TCOS(k)
        if (k == l) then
            i = idegbr + lint
            xx = x - TCOS(i)
            w(:m) = Y(:m)
            y(:m) = xx*Y(:m)
        end if
        z = 1./(B(1)-x)
        d(1) = C(1)*z
        y(1) = Y(1)*z
        do i = 2, mm1
            z = 1./(B(i)-x-A(i)*D(i-1))
            d(i) = C(i)*z
            y(i) = (Y(i)-A(i)*Y(i-1))*z
        end do
        z = B(m) - x - A(m)*D(mm1)
        if (abs(z) == 0.) then
            y(m) = (0., 0.)
        else
            y(m) = (Y(m)-A(m)*Y(mm1))/z
        end if
        do ip = 1, mm1
            y(m-ip) = Y(m-ip) - D(m-ip)*Y(m+1-ip)
        end do
        if (k /= l) cycle
        y(:m) = Y(:m) + W(:m)
        lint = lint + 1
        l = (lint*ifb)/ifc
    end do
    return
end subroutine CMPTRX


subroutine CMPTR3(m, a, b, c, k, y1, y2, y3, tcos, d, w1, w2, w3)

    !-----------------------------------------------
    !   D u m m y   A r g u m e n t s
    !-----------------------------------------------
    integer , intent (in) :: m
    integer , intent (in) :: k(4)
    complex , intent (in) :: a(*)
    complex , intent (in) :: b(*)
    complex , intent (in) :: c(*)
    complex , intent (in out) :: y1(*)
    complex , intent (in out) :: y2(*)
    complex , intent (in out) :: y3(*)
    complex , intent (in) :: tcos(*)
    complex , intent (in out) :: d(*)
    complex , intent (in out) :: w1(*)
    complex , intent (in out) :: w2(*)
    complex , intent (in out) :: w3(*)
    !-----------------------------------------------
    !   L o c a l   V a r i a b l e s
    !-----------------------------------------------
    integer :: mm1, k1, k2, k3, k4, if1, if2, if3, if4, k2k3k4, l1, l2 &
        , l3, lint1, lint2, lint3, kint1, kint2, kint3, n, i, ip
    complex :: x, xx, z
    !-----------------------------------------------
    !
    !     SUBROUTINE TO SOLVE TRIDIAGONAL SYSTEMS
    !
    mm1 = m - 1
    k1 = K(1)
    k2 = K(2)
    k3 = K(3)
    k4 = K(4)
    if1 = k1 + 1
    if2 = k2 + 1
    if3 = k3 + 1
    if4 = k4 + 1
    k2k3k4 = k2 + k3 + k4
    if (k2k3k4 /= 0) then
        l1 = if1/if2
        l2 = if1/if3
        l3 = if1/if4
        lint1 = 1
        lint2 = 1
        lint3 = 1
        kint1 = k1
        kint2 = kint1 + k2
        kint3 = kint2 + k3
    end if
    do n = 1, k1
        x = TCOS(n)
        if (k2k3k4 /= 0) then
            if (n == l1) then
                w1(:m) = Y1(:m)
            end if
            if (n == l2) then
                w2(:m) = Y2(:m)
            end if
            if (n == l3) then
                w3(:m) = Y3(:m)
            end if
        end if
        z = 1./(B(1)-x)
        d(1) = C(1)*z
        y1(1) = Y1(1)*z
        y2(1) = Y2(1)*z
        y3(1) = Y3(1)*z
        do i = 2, m
            z = 1./(B(i)-x-A(i)*D(i-1))
            d(i) = C(i)*z
            y1(i) = (Y1(i)-A(i)*Y1(i-1))*z
            y2(i) = (Y2(i)-A(i)*Y2(i-1))*z
            y3(i) = (Y3(i)-A(i)*Y3(i-1))*z
        end do
        do ip = 1, mm1
            y1(m-ip) = Y1(m-ip) - D(m-ip)*Y1(m+1-ip)
            y2(m-ip) = Y2(m-ip) - D(m-ip)*Y2(m+1-ip)
            y3(m-ip) = Y3(m-ip) - D(m-ip)*Y3(m+1-ip)
        end do
        if (k2k3k4 == 0) cycle
        if (n == l1) then
            i = lint1 + kint1
            xx = x - TCOS(i)
            y1(:m) = xx*Y1(:m) + W1(:m)
            lint1 = lint1 + 1
            l1 = (lint1*if1)/if2
        end if
        if (n == l2) then
            i = lint2 + kint2
            xx = x - TCOS(i)
            y2(:m) = xx*Y2(:m) + W2(:m)
            lint2 = lint2 + 1
            l2 = (lint2*if1)/if3
        end if
        if (n /= l3) cycle
        i = lint3 + kint3
        xx = x - TCOS(i)
        y3(:m) = xx*Y3(:m) + W3(:m)
        lint3 = lint3 + 1
        l3 = (lint3*if1)/if4
    end do
    return

end subroutine CMPTR3

end module module_cmgnbn
!
! REVISION HISTORY---
!
! SEPTEMBER 1973    VERSION 1
! APRIL     1976    VERSION 2
! JANUARY   1978    VERSION 3
! DECEMBER  1979    VERSION 3.1
! FEBRUARY  1985    DOCUMENTATION UPGRADE
! NOVEMBER  1988    VERSION 3.2, FORTRAN 77 CHANGES
! June      2004    Version 5.0, Fortran 90 changes
!-----------------------------------------------------------------------