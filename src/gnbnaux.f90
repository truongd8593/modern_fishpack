!
!     file gnbnaux.f
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
!
! PACKAGE GNBNAUX
!
! LATEST REVISION        June 2004
!
! PURPOSE                TO PROVIDE AUXILIARY ROUTINES FOR FISHPACK
!                        ENTRIES genbun AND POISTG.
!
! USAGE                  THERE ARE NO USER ENTRIES IN THIS PACKAGE.
!                        THE ROUTINES IN THIS PACKAGE ARE NOT INTENDED
!                        TO BE CALLED BY USERS, BUT RATHER BY ROUTINES
!                        IN PACKAGES genbun AND POISTG.
!
! SPECIAL CONDITIONS     NONE
!
! I/O                    NONE
!
! PRECISION              SINGLE
!
!
! LANGUAGE               FORTRAN 90
!
! HISTORY                WRITTEN IN 1979 BY ROLAND SWEET OF NCAR'S
!                        SCIENTIFIC COMPUTING DIVISION.  MADE AVAILABLE
!                        ON NCAR'S PUBLIC LIBRARIES IN JANUARY, 1980.
!                        Revised by John Adams in June 2004 incorporating
!                        Fortran 90 features
!
! PORTABILITY            FORTRAN 90
!
module module_gnbnaux

    use, intrinsic :: iso_fortran_env, only: &
        ip => INT32, &
        wp => REAL64

    ! Explicit typing only
    implicit none

    ! Everything is private unless stated otherwise
    private
    public :: cosgen
    public :: merge_rename
    public :: trix
    public :: tri3

contains


    pure subroutine cosgen(n, ijump, fnum, fden, a)
        !
        ! Purpose:
        !
        !     this subroutine computes required cosine values in ascending
        !     order.  when ijump .gt. 1 the routine computes values
        !
        !        2*cos(j*pi/l) , j=1, 2, ..., l and j .ne. 0(mod n/ijump+1)
        !
        !     where l = ijump*(n/ijump+1).
        !
        !
        !     when ijump = 1 it computes
        !
        !            2*cos((j-fnum)*pi/(n+fden)) ,  j=1, 2, ... , n
        !
        !     where
        !        fnum = 0.5, fden = 0.0,  for regular reduction values
        !        fnum = 0.0, fden = 1.0, for b-r and c-r when istag = 1
        !        fnum = 0.0, fden = 0.5, for b-r and c-r when istag = 2
        !        fnum = 0.5, fden = 0.5, for b-r and c-r when istag = 2
        !                                in poisn2 only.
        !
        !
        !-----------------------------------------------
        ! Dictionary: calling arguments
        !-----------------------------------------------
        integer (ip), intent (in) :: n
        integer (ip), intent (in) :: ijump
        real (wp),    intent (in) :: fnum
        real (wp),    intent (in) :: fden
        real (wp),    intent (out) :: a(*)
        !-----------------------------------------------
        ! Dictionary: local variables
        !-----------------------------------------------
        integer (ip)         :: k3, k4, k, k1, k5, i, k2, np1
        real (wp), parameter :: PI = acos( -1.0_wp)
        real (wp)            :: dum, pibyn, x, y
        !-----------------------------------------------

        if (n /= 0) then
            if (ijump /= 1) then
                k3 = n/ijump + 1
                k4 = k3 - 1
                pibyn = PI/(n + ijump)
                do k = 1, ijump
                    k1 = (k - 1)*k3
                    k5 = (k - 1)*k4
                    do i = 1, k4
                        x = k1 + i
                        k2 = k5 + i
                        a(k2) = -2.0_wp * cos(x*pibyn)
                    end do
                end do
            else
                np1 = n + 1
                y = PI/(real(n, kind=wp) + fden)

                do i = 1, n
                    x = real(np1 - i, kind=wp) - fnum
                    a(i) = 2.0_wp * cos(x*y)
                end do
            end if
        end if

    end subroutine cosgen


    subroutine trix(idegbr, idegcr, m, a, b, c, y, tcos, d, w)
        !
        ! Purpose:
        !
        !     subroutine to solve a system of linear equations where the
        !     coefficient matrix is a rational function in the matrix given by
        !     tridiagonal  ( . . . , a(i), b(i), c(i), . . . ).
        !
        !-----------------------------------------------
        ! Dictionary: calling arguments
        !-----------------------------------------------
        integer (ip), intent (in)     :: idegbr
        integer (ip), intent (in)     :: idegcr
        integer (ip), intent (in)     :: m
        real (wp),    intent (in)     :: a(*)
        real (wp),    intent (in)     :: b(*)
        real (wp),    intent (in)     :: c(*)
        real (wp),    intent (in out) :: y(*)
        real (wp),    intent (in)     :: tcos(*)
        real (wp),    intent (in out) :: d(*)
        real (wp),    intent (in out) :: w(*)
        !-----------------------------------------------
        ! Dictionary: local variables
        !-----------------------------------------------
        integer (ip) :: mm1, ifb, ifc, l, lint, k, i, ip
        real (wp)    :: x, xx, z
        !-----------------------------------------------

        mm1 = m - 1
        ifb = idegbr + 1
        ifc = idegcr + 1
        l = ifb/ifc
        lint = 1
        do k = 1, idegbr
            x = tcos(k)
            if (k == l) then
                i = idegbr + lint
                xx = x - tcos(i)
                w(:m) = y(:m)
                y(:m) = xx*y(:m)
            end if
            z = 1./(b(1)-x)
            d(1) = c(1)*z
            y(1) = y(1)*z
            do i = 2, mm1
                z = 1./(b(i)-x-a(i)*d(i-1))
                d(i) = c(i)*z
                y(i) = (y(i)-a(i)*y(i-1))*z
            end do
            z = b(m) - x - a(m)*d(mm1)
            if (z == 0.) then
                y(m) = 0.
            else
                y(m) = (y(m)-a(m)*y(mm1))/z
            end if
            do ip = 1, mm1
                y(m-ip) = y(m-ip) - d(m-ip)*y(m+1-ip)
            end do
            if (k /= l) cycle
            y(:m) = y(:m) + w(:m)
            lint = lint + 1
            l = (lint*ifb)/ifc
        end do

    end subroutine trix


    subroutine tri3(m, a, b, c, k, y1, y2, y3, tcos, d, w1, w2, w3)
        !
        ! Purpose:
        !
        ! subroutine to solve three linear systems whose common coefficient
        ! matrix is a rational function in the matrix given by
        !
        !  tridiagonal (..., a(i), b(i), c(i), ...)
        !
        !-----------------------------------------------
        ! Dictionary: calling arguments
        !-----------------------------------------------
        integer (ip), intent (in)     :: m
        integer (ip), intent (in)     :: k(4)
        real (wp),    intent (in)     :: a(*)
        real (wp),    intent (in)     :: b(*)
        real (wp),    intent (in)     :: c(*)
        real (wp),    intent (in out) :: y1(*)
        real (wp),    intent (in out) :: y2(*)
        real (wp),    intent (in out) :: y3(*)
        real (wp),    intent (in)     :: tcos(*)
        real (wp),    intent (in out) :: d(*)
        real (wp),    intent (in out) :: w1(*)
        real (wp),    intent (in out) :: w2(*)
        real (wp),    intent (in out) :: w3(*)
        !-----------------------------------------------
        ! Dictionary: local variables
        !-----------------------------------------------
        integer (ip) :: mm1, k1, k2, k3, k4, if1, if2, if3, if4, k2k3k4, l1, l2
        integer (ip) :: l3, lint1, lint2, lint3, kint1, kint2, kint3, n, i, ipp
        real (wp)    :: x, z, xx
        !-----------------------------------------------


        mm1 = m - 1
        k1 = k(1)
        k2 = k(2)
        k3 = k(3)
        k4 = k(4)
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
            x = tcos(n)
            if (k2k3k4 /= 0) then
                if (n == l1) then
                    w1(:m) = y1(:m)
                end if
                if (n == l2) then
                    w2(:m) = y2(:m)
                end if
                if (n == l3) then
                    w3(:m) = y3(:m)
                end if
            end if
            z = 1./(b(1)-x)
            d(1) = c(1)*z
            y1(1) = y1(1)*z
            y2(1) = y2(1)*z
            y3(1) = y3(1)*z
            do i = 2, m
                z = 1./(b(i)-x-a(i)*d(i-1))
                d(i) = c(i)*z
                y1(i) = (y1(i)-a(i)*y1(i-1))*z
                y2(i) = (y2(i)-a(i)*y2(i-1))*z
                y3(i) = (y3(i)-a(i)*y3(i-1))*z
            end do
            do ipp = 1, mm1
                y1(m-ipp) = y1(m-ipp) - d(m-ipp)*y1(m+1-ipp)
                y2(m-ipp) = y2(m-ipp) - d(m-ipp)*y2(m+1-ipp)
                y3(m-ipp) = y3(m-ipp) - d(m-ipp)*y3(m+1-ipp)
            end do
            if (k2k3k4 == 0) cycle
            if (n == l1) then
                i = lint1 + kint1
                xx = x - tcos(i)
                y1(:m) = xx*y1(:m) + w1(:m)
                lint1 = lint1 + 1
                l1 = (lint1*if1)/if2
            end if
            if (n == l2) then
                i = lint2 + kint2
                xx = x - tcos(i)
                y2(:m) = xx*y2(:m) + w2(:m)
                lint2 = lint2 + 1
                l2 = (lint2*if1)/if3
            end if
            if (n /= l3) cycle
            i = lint3 + kint3
            xx = x - tcos(i)
            y3(:m) = xx*y3(:m) + w3(:m)
            lint3 = lint3 + 1
            l3 = (lint3*if1)/if4
        end do

    end subroutine tri3


    subroutine merge_rename(tcos, i1, m1, i2, m2, i3)
        !
        ! Purpose:
        !
        !     this subroutine merges two ascending strings of numbers in the
        !     array tcos.  the first string is of length m1 and starts at
        !     tcos(i1+1).  the second string is of length m2 and starts at
        !     tcos(i2+1).  the merged string goes into tcos(i3+1).
        !
        !
        !-----------------------------------------------
        ! Dictionary: calling arguments
        !-----------------------------------------------
        integer (ip), intent (in)     :: i1
        integer (ip), intent (in)     :: m1
        integer (ip), intent (in)     :: i2
        integer (ip), intent (in)     :: m2
        integer (ip), intent (in)     :: i3
        real (wp),    intent (in out) :: tcos(*)
        !-----------------------------------------------
        ! Dictionary: local variables
        !-----------------------------------------------
        integer (ip) :: j11, j3, j1, j2, j, l, k, m
        real (wp)    :: x, y
        !-----------------------------------------------

        j1 = 1
        j2 = 1
        j = i3
        if (m1 == 0) go to 107
        if (m2 == 0) go to 104
101 continue
    j11 = j1
    j3 = max(m1, j11)
    do j1 = j11, j3
        j = j + 1
        l = j1 + i1
        x = tcos(l)
        l = j2 + i2
        y = tcos(l)
        if (x - y > 0.) go to 103
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
        tcos(m) = tcos(l)
    end do
    go to 109
106 continue
    if (j2 > m2) go to 109
107 continue
    k = j - j2 + 1
    do j = j2, m2
        m = k + j
        l = j + i2
        tcos(m) = tcos(l)
    end do
109 continue

end subroutine merge_rename


end module module_gnbnaux
!
! REVISION HISTORY---
!
! SEPTEMBER 1973    VERSION 1
! APRIL     1976    VERSION 2
! JANUARY   1978    VERSION 3
! DECEMBER  1979    VERSION 3.1
! OCTOBER   1980    CHANGED SEVERAL DIVIDES OF FLOATING INTEGERS
!                   TO INTEGER DIVIDES TO ACCOMODATE CRAY-1 ARITHMETIC.
! FEBRUARY  1985    DOCUMENTATION UPGRADE
! NOVEMBER  1988    VERSION 3.2, FORTRAN 77 CHANGES
!-----------------------------------------------------------------------
