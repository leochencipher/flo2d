*************************************************************************
**                 DRIVER FOR THE GMRes CODE
*************************************************************************
      subroutine test_resd(elem, edge, tedge, vedge, spts, bdedge,
     +                 coord, qc, qv, qx, qy, af, tarea, dt, cl, cd,
     +                 res, qcd)
      implicit none
      include 'size.h'
      include 'common.h'
      include 'inf.h'

      integer          elem(3,ntmax), edge(2,nemax), tedge(2,nemax),
     +                 vedge(2,nemax), spts(nspmax), bdedge(2,nbpmax)
      double precision coord(2,npmax), qc(nvar,ntmax), af(3,npmax),
     +                 qv(nvar,npmax), tarea(ntmax), res(nvar,ntmax),
     +                 qcd(nvar,ntmax), dt(ntmax), qx(3,npmax),
     +                 qy(3,npmax), cl, cd

      integer i, j, n, m, icount, p1, p2, p3

      double precision resd(nvar,ntmax), res1(nvar,ntmax)
      double precision x, y, r, u, v, p, con(nvar), con1(nvar), r1, r2,
     +                 r3, r4, qc1(nvar,ntmax), fd, ad, eps, err
      double precision rand

      do i=1,nt
         do j=1,nvar
            qcd(j,i) = 0.1d0*(2.0d0*rand(0.0d0) - 1.0d0)
         enddo
      enddo

      eps = 0.1d0

100   continue

      do i=1,nt
         p1= elem(1,i)
         p2= elem(2,i)
         p3= elem(3,i)
         x = (coord(1,p1) + coord(1,p2) + coord(1,p3))/3.0d0
         y = (coord(2,p1) + coord(2,p2) + coord(2,p3))/3.0d0

         r = r_inf + dexp(-x**2-y**2)*dsin(x)**2 * dcos(y)**2
         u = u_inf + dexp(-x**2-y**2)*dcos(x)*dsin(y)
         v = v_inf + dexp(-x**2-y**2)*dsin(x)*dcos(y)
         p = p_inf + dexp(-x**2-y**2)*dabs(dsin(x+y))

c        r = r_inf
c        u = u_inf
c        v = v_inf
c        p = p_inf

         qc(1,i) = r
         qc(2,i) = u
         qc(3,i) = v
         qc(4,i) = p

         call prim2con(qc(1,i), con)

         do j=1,nvar
            con1(j) = con(j) + eps*qcd(j,i)
         enddo
         call con2prim(con1,qc1(1,i))

      enddo

      call fvresidual(elem, edge, tedge, vedge, spts, bdedge,
     +                coord, qc, qv, qx, qy, af, tarea, cl, cd, 
     +                res)

      call fvresidual(elem, edge, tedge, vedge, spts, bdedge,
     +                coord, qc1, qv, qx, qy, af, tarea, cl, cd, 
     +                res1)

      call fvresidual_q(elem, edge, tedge, vedge, spts, bdedge,
     +                  coord, qc, qv, qx, qy, af, tarea, cl, cd, 
     +                  qcd, resd)

      err = 0.0d0
      do i=1,nt
         do j=1,nvar
            fd = (res1(j,i)-res(j,i))/eps
            ad = resd(j,i)
            err= dmax1(err, dabs(ad-fd))
c           print*,i,fd,ad
         enddo
      enddo

      print*,eps,err

      eps = eps/10.0d0
      if(eps.gt.1.0d-16)goto 100

      return
      end
