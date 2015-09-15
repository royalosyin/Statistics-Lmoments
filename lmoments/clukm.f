      SUBROUTINE CLUKM(X,NX,N,NATT,NCLUST,IASSGN,LIST,NUM,SS,MAXIT,
     *  IWORK,RW,NW)
C***********************************************************************
C*                                                                     *
C*  FORTRAN CODE WRITTEN FOR INCLUSION IN IBM RESEARCH REPORT RC20525, *
C*  'FORTRAN ROUTINES FOR USE WITH THE METHOD OF L-MOMENTS, VERSION 3' *
C*                                                                     *
C*  J. R. M. HOSKING                                                   *
C*  IBM RESEARCH DIVISION                                              *
C*  T. J. WATSON RESEARCH CENTER                                       *
C*  YORKTOWN HEIGHTS                                                   *
C*  NEW YORK 10598, U.S.A.                                             *
C*                                                                     *
C*  VERSION 3     AUGUST 1996                                          *
C*                                                                     *
C***********************************************************************
C
C  CLUSTER ANALYSIS BY THE K-MEANS ALGORITHM
C
C  PARAMETERS OF ROUTINE:
C  X      * INPUT* ARRAY OF DIMENSION (NX,NATT).  X(I,J) SHOULD
C                  CONTAIN THE J'TH ATTRIBUTE FOR THE I'TH DATA POINT.
C  NX     * INPUT* THE FIRST DIMENSION OF ARRAY X, AS DECLARED IN THE
C                  CALLING PROGRAM.
C  N      * INPUT* NUMBER OF DATA POINTS
C  NATT   * INPUT* NUMBER OF ATTRIBUTES FOR EACH DATA POINT
C  NCLUST * INPUT* NUMBER OF CLUSTERS
C  IASSGN *IN/OUT* ARRAY OF LENGTH N.  ON ENTRY, SHOULD CONTAIN THE
C                  INITIAL ASSIGNMENT OF SITES TO CLUSTERS.  ON EXIT,
C                  CONTAINS THE FINAL ASSIGNMENT.  THE I'TH ELEMENT OF
C                  THE ARRAY CONTAINS THE LABEL OF THE CLUSTER TO WHICH
C                  THE I'TH DATA POINT BELONGS.  LABELS MUST BE BETWEEN
C                  1 AND NCLUST, AND EACH OF THE VALUES 1 THROUGH NCLUST
C                  MUST OCCUR AT LEAST ONCE.
C  LIST   *OUTPUT* ARRAY OF LENGTH N. CONTAINS THE DATA POINTS IN
C                  CLUSTER 1, FOLLOWED BY THE DATA POINTS IN CLUSTER 2,
C                  ETC.  DATA POINTS IN EACH CLUSTER ARE LISTED IN
C                  INCREASING ORDER.  THE LAST DATA POINT IN EACH
C                  CLUSTER IS INDICATED BY A NEGATIVE NUMBER.
C  NUM    *OUTPUT* ARRAY OF LENGTH NCLUST.  NUMBER OF DATA POINTS IN
C                  EACH CLUSTER.
C  SS     *OUTPUT* WITHIN-GROUP SUM OF SQUARES OF THE FINAL CLUSTERS.
C  MAXIT  * INPUT* MAXIMUM NUMBER OF ITERATIONS FOR THE K-MEANS
C                  CLUSTERING ALGORITHM
C  IWORK  * LOCAL* (INTEGER) WORK ARRAY OF LENGTH NCLUST*3
C  RW     * LOCAL* REAL WORK ARRAY OF LENGTH NW.  N.B. THIS ARRAY IS OF
C                  TYPE REAL, NOT DOUBLE PRECISION!
C  NW     * INPUT* LENGTH OF ARRAY RW.  MUST BE AT LEAST
C                  (N+NCLUST)*(NATT+1)+2*NCLUST
C
C  OTHER ROUTINES USED: APPLIED STATISTICS ALGORITHM AS136 (ROUTINES
C                       KMNS,OPTRA,QTRAN), AVAILABLE FROM
C                       HTTP://STAT.LIB.CMU.EDU/APSTAT/136
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DOUBLE PRECISION X(NX,NATT)
      INTEGER IASSGN(N),LIST(N),NUM(NCLUST),IWORK(NCLUST,3)
      REAL RW(NW)
      DATA ZERO/0D0/
C
C         SET ADDRESSES FOR SUBDIVISION OF WORK ARRAY
C
      MC=1
      MA=MC+NCLUST*NATT
      MAN1=MA+N*NATT
      MAN2=MAN1+NCLUST
      MWSS=MAN2+NCLUST
      MD=MWSS+NCLUST
      NWREQ=MD+N-1
      IF(NW.LT.NWREQ)GOTO 1000
      LA=MA-1
      LWSS=MWSS-1
C
C         COPY ATTRIBUTES TO WORK ARRAY
C
      IW=LA
      DO 5 IATT=1,NATT
      DO 5 I=1,N
      IW=IW+1
    5 RW(IW)=X(I,IATT)
C
C         COMPUTE CLUSTER CENTERS
C
      DO 10 ICL=1,NCLUST
   10 NUM(ICL)=0
      IWMAX=NCLUST*NATT
      DO 20 IW=1,IWMAX
   20 RW(IW)=ZERO
      DO 40 I=1,N
      ICL=IASSGN(I)
      IF(ICL.LE.0.OR.ICL.GT.NCLUST)GOTO 1010
      NUM(ICL)=NUM(ICL)+1
      IW=ICL
      DO 30 IATT=1,NATT
      RW(IW)=RW(IW)+X(I,IATT)
      IW=IW+NCLUST
   30 CONTINUE
   40 CONTINUE
      DO 60 ICL=1,NCLUST
      NSIZE=NUM(ICL)
      IF(NSIZE.EQ.0)GOTO 1020
      IW=ICL
      DO 50 IATT=1,NATT
      RW(IW)=RW(IW)/NSIZE
      IW=IW+NCLUST
   50 CONTINUE
   60 CONTINUE
C
C         CALL ALGORITHM AS136
C
      CALL KMNS(RW(MA),N,NATT,RW(MC),NCLUST,IASSGN,LIST,NUM,RW(MAN1),
     *  RW(MAN2),IWORK(1,1),RW(MD),IWORK(1,2),IWORK(1,3),MAXIT,RW(MWSS),
     *  IFAULT)
      IF(IFAULT.EQ.2)WRITE(6,7030)
C
C         COMPUTE LIST ARRAY AND FINAL SUM OF SQUARES
C
      I=0
      DO 80 ICL=1,NCLUST
      DO 70 K=1,N
      IF(IASSGN(K).NE.ICL)GOTO 70
      I=I+1
      LIST(I)=K
   70 CONTINUE
      LIST(I)=-LIST(I)
   80 CONTINUE
      SS=ZERO
      DO 90 ICL=1,NCLUST
   90 SS=SS+RW(LWSS+ICL)
C
      RETURN
C
 1000 WRITE(6,7000)NWREQ
      RETURN
 1010 WRITE(6,7010)I
      RETURN
 1020 WRITE(6,7020)ICL
      RETURN
C
 7000 FORMAT(' *** ERROR *** ROUTINE CLUKM  : INSUFFICIENT WORKSPACE.',
     *  ' LENGTH OF WORK ARRAY SHOULD BE AT LEAST ',I8)
 7010 FORMAT(' *** ERROR *** ROUTINE CLUKM  :',
     *  ' INVALID INITIAL CLUSTER NUMBER FOR DATA POINT ',I5)
 7020 FORMAT(' *** ERROR *** ROUTINE CLUKM  :',
     *  ' INITIAL CLUSTERS INVALID.  CLUSTER ',I4,' HAS NO MEMBERS.')
 7030 FORMAT(' ** WARNING ** ROUTINE CLUKM  :',
     *  ' ITERATION HAS NOT CONVERGED. RESULTS MAY BE UNRELIABLE.')
C
      END
