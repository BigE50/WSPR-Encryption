subroutine genwspr(message,msgsent,itone,epoch)
! Encode a WSPR message and generate the array of channel symbols.

  use iso_c_binding
  character*22 message,msgsent
  parameter (MAXSYM=176)
  integer*1 symbol(MAXSYM)
  integer*1 data0(11)
  integer*4 itone(162)
  integer(c_int64_t), intent(in) :: epoch
  integer npr3(162)

  interface
    subroutine encrypt_wspr_payload(data, epoch) bind(C)
      use iso_c_binding
      integer(c_int8_t) :: data(11)
      integer(c_int64_t), value :: epoch
    end subroutine
  end interface

  data npr3/                                      &
      1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0,    &
      0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1,    &
      0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1,    &
      1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1,    &
      0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0,    &
      0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1,    &
      0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1,    &
      0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0,    &
      0,0/

  call wqencode(message,ntype,data0)          !Source encoding
  call encrypt_wspr_payload(data0, epoch)     !AES encryption
  call encode232(data0,162,symbol)            !Convolutional encoding
  call inter_wspr(symbol,1)                   !Interleaving
  do i=1,162
     itone(i)=npr3(i) + 2*symbol(i)
  enddo
  msgsent=message                             !### To be fixed... ?? ###

  return
end subroutine genwspr
