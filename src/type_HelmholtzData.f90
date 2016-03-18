!
! Purpose:
!
! Defines an object whose one-dimensional array components contain
! the west, east, south, and north boundary conditions (Dirichlet or Neumann), respectively.
!
! For instance, take the two-dimensional helmholtz equation
! in Cartesian coordinates
!
! (d/dx)(df/dx) + (d/dy)(df/dy)
!               + lambda * f(x,y) = source(x,y).
!
!                   north
!       A___________________________B
!      D|                           |D
!       |                           |
!       |                           |
!  west |       (x(i),y(j))         | east
!       |                           |
!       |                           |
!      C|___________________________|C
!       A          south            B
!
!
module type_HelmholtzData

    use, intrinsic :: iso_fortran_env, only: &
        wp => REAL64, &
        ip => INT32, &
        stderr => ERROR_UNIT

    use type_RectangularDomain, only: &
        RectangularDomain

    ! Explicit typing only
    implicit none

    ! Everything is private unless stated otherwise
    private
    public :: HelmholtzData

    !--------------------------------------------------------------------------------
    ! Dictionary: variables confined to the module
    !---------------------------------------------------------------------------------
    character (len=250) :: error_message !! Probably long enough
    integer (ip)        :: allocate_status  !! To check allocation status
    integer (ip)        :: deallocate_status !! To check deallocation status
    !---------------------------------------------------------------------------------

    ! Declare derived data type
    type, public ::  HelmholtzData
        !---------------------------------------------------------------------------------
        ! Class variables
        !---------------------------------------------------------------------------------
        logical,                  public :: initialized = .false.
        integer (ip),             public :: Y_BOUNDARY_CONDITION_TYPE = -1 !! Boundary conditions in the vertical direction
        integer (ip),             public :: X_BOUNDARY_CONDITION_TYPE = -1 !! Boundary conditions in the horizontal direction
        real (wp), allocatable,   public :: west(:)
        real (wp), allocatable,   public :: east(:)
        real (wp), allocatable,   public :: south(:)
        real (wp), allocatable,   public :: north(:)
        type (RectangularDomain), public :: domain
        !---------------------------------------------------------------------------------
    contains
        !---------------------------------------------------------------------------------
        ! Class methods
        !---------------------------------------------------------------------------------
        procedure, public                   :: create => create_helmholtz_data
        procedure, public                   :: destroy => destroy_helmholtz_data
        procedure, non_overridable, public  :: create_helmholtz_data
        procedure, non_overridable, public  :: destroy_helmholtz_data
        procedure, nopass,          private :: get_boundary_condition_type
        final                               :: finalize_helmholtz_data
        !---------------------------------------------------------------------------------
    end type HelmholtzData


contains


    subroutine create_helmholtz_data( this, nx, ny, x_type, y_type, rectangular_domain )
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        class (HelmholtzData),     intent (in out)            :: this
        integer (ip),              intent (in)                :: nx
        integer (ip),              intent (in)                :: ny
        integer (ip),              intent (in),     optional  :: x_type
        integer (ip),              intent (in),     optional  :: y_type
        class (RectangularDomain), intent (in out), optional  :: rectangular_domain
        !--------------------------------------------------------------------------------

        ! Ensure that object is usable
        call this%destroy()

        ! Set rectangular domain
        if ( present ( rectangular_domain ) ) then
            this%domain = rectangular_domain
        end if

        ! Allocate arrays
        allocate ( &
            this%west( ny ), &
            this%east( ny ), &
            this%south( nx ), &
            this%north( nx ), &
            stat = allocate_status, &
            errmsg = error_message )

        ! Check allocation status
        if ( allocate_status /= 0 ) then
            write( stderr, '(A)' ) 'TYPE (HelmholtzData)'
            write( stderr, '(A)' ) 'Allocation failed in create'
            write( stderr, '(A)' ) trim( error_message )
        end if

        ! Initialize values to zero
        this%west = 0.0_wp
        this%east = 0.0_wp
        this%south = 0.0_wp
        this%north = 0.0_wp

        ! Set the boundary condition types
        associate( &
            x => this%X_BOUNDARY_CONDITION_TYPE, &
            y => this%Y_BOUNDARY_CONDITION_TYPE &
            )

            ! Set horizontal boundary conditions
            if ( present( x_type ) ) then
                call this%get_boundary_condition_type( x_type, x )
            end if

            ! Set vertical boundary conditions
            if ( present( y_type ) ) then
                call this%get_boundary_condition_type( y_type, y )
            end if

        end associate

        ! Set initialization flag
        this%initialized = .true.

    end subroutine create_helmholtz_data


    subroutine destroy_helmholtz_data( this )
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        class (HelmholtzData), intent (in out)   :: this
        !--------------------------------------------------------------------------------

        ! Check if object is already usable
        if ( .not. this%initialized ) return

        ! Deallocate west component
        if ( allocated( this%west ) ) then

            deallocate( &
                this%west, &
                stat = deallocate_status, &
                errmsg = error_message )

            ! Check deallocation status
            if ( deallocate_status /=0 ) then
                write( stderr, '(A)' ) 'TYPE (HelmholtzData)'
                write( stderr, '(A)' ) 'Deallocating WEST failed in DESTROY_HELMHOLTZ_DATA'
                write( stderr, '(A)' ) trim( error_message )
            end if
        end if

        ! Deallocate east component
        if ( allocated( this%east) ) then

            deallocate( &
                this%east, &
                stat = deallocate_status, &
                errmsg = error_message )

            ! Check deallocation status
            if ( deallocate_status /=0 ) then
                write( stderr, '(A)' ) 'TYPE (HelmholtzData)'
                write( stderr, '(A)' ) 'Deallocating EAST failed in DESTROY_HELMHOLTZ_DATA'
                write( stderr, '(A)' ) trim( error_message )
            end if
        end if

        ! Deallocate south component
        if ( allocated( this%south ) ) then

            deallocate( &
                this%south, &
                stat = deallocate_status, &
                errmsg = error_message )

            ! Check deallocation status
            if ( deallocate_status /=0 ) then
                write( stderr, '(A)' ) 'TYPE (HelmholtzData)'
                write( stderr, '(A)' ) 'Deallocating SOUTH failed in DESTROY_HELMHOLTZ_DATA'
                write( stderr, '(A)' ) trim( error_message )
            end if
        end if

        ! Deallocate north component
        if ( allocated( this%north ) ) then

            deallocate( &
                this%north, &
                stat = deallocate_status, &
                errmsg = error_message )

            ! Check deallocation status
            if ( deallocate_status /=0 ) then
                write( stderr, '(A)' ) 'TYPE (HelmholtzData)'
                write( stderr, '(A)' ) 'Deallocating NORTH failed in DESTROY_HELMHOLTZ_DATA'
                write( stderr, '(A)' ) trim( error_message )
            end if
        end if

        ! destroy component data type
        call this%domain%destroy()

        ! Reset constants
        this%X_BOUNDARY_CONDITION_TYPE = -1
        this%Y_BOUNDARY_CONDITION_TYPE = -1

        ! Reset status
        this%initialized = .false.

    end subroutine destroy_helmholtz_data


    subroutine get_boundary_condition_type( type, return_value )
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        integer (ip), intent (in)   :: type
        integer (ip), intent (out)  :: return_value
        !--------------------------------------------------------------------------------

        ! Initialize return value
        return_value = -1

        select case (type)
            case (4)
                return_value = type
            case (3)
                return_value = type
            case (2)
                return_value = type
            case (1)
                return_value = type
            case (0)
                return_value = type
            case default
                ! handle invalid boundary type
                write( stderr, '(A)' ) 'TYPE (HelmholtzData)'
                write( stderr, '(A,I4)' ) 'invalid calling argument type = ', type
                write( stderr, '(A)' ) 'must be either 0, 1, ..., 4'
        end select

    end subroutine get_boundary_condition_type


    subroutine finalize_helmholtz_data( this )
        !--------------------------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------------------------
        type (HelmholtzData), intent (in out) :: this
        !--------------------------------------------------------------------------------

        call this%destroy()

    end subroutine finalize_helmholtz_data


end module type_HelmholtzData