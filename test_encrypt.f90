program test_encrypt
  use iso_c_binding
  implicit none
  
  integer(c_int8_t) :: data0(11)
  integer(kind=8) :: epoch
  integer :: i
  
  interface
    subroutine encrypt_wspr_payload(data, epoch) bind(C)
      use iso_c_binding
      integer(c_int8_t) :: data(11)
      integer(c_int64_t), value :: epoch
    end subroutine
  end interface
  
  ! Set test data
  data0 = (/ int(z'F7',c_int8_t), int(z'0C',c_int8_t), int(z'23',c_int8_t), &
             int(z'8B',c_int8_t), int(z'0D',c_int8_t), int(z'18',c_int8_t), &
             int(z'40',c_int8_t), int(z'00',c_int8_t), int(z'00',c_int8_t), &
             int(z'00',c_int8_t), int(z'00',c_int8_t) /)
  
  epoch = 1609459200_8
  
  print *, "BEFORE:"
  do i = 1, 11
    write(*,'(Z2.2)', advance='no') ichar(transfer(data0(i), char(1)))
  end do
  print *, ""
  
  call encrypt_wspr_payload(data0, epoch)
  
  print *, "AFTER:"
  do i = 1, 11
    write(*,'(Z2.2)', advance='no') ichar(transfer(data0(i), char(1)))
  end do
  print *, ""
  
end program test_encrypt
