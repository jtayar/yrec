






C
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
C LIR
C$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      SUBROUTINE  LIR(Z,ZI,Y,YI,II,ID,NT,L,INTER)                              

      IMPLICIT REAL*8 (A-H,O-Z)                                      
          
C     INTERPOLATION/EXTRAPOLATION ROUTINE                            
C     FOR A SUCH THAT Z=ZI(A),  SETS Y(I)=YI(I,A), I=1,II            
C     ZI(N),YI(I,N) MUST BE SUPPLIED FOR N=1,NT AND I=1,II            
C     ID IS FIRST DIMENSION OF YI                                              
C     INTER IS SET TO 1 FOR INTERPOLATION AND 0 FOR EXTRAPOLATION              
C     IF L.LE.1, SCAN TO FIND THE ZI(N) WHICH IMMEDIATELY BOUND Z              
C                STARTS AT N=1                                                 
C     IF L.GT.1, SCAN STARTS FROM VALUE OF N FROM PREVIOUS CALL OF LIR         
C     LIR USE CUBIC INTERPOLATION/EXTRAPOLATION UNLESS NT.LT.4                 
C     LIR1 USE LINEAR INTERPOLATION/EXTRAPOLATION                              
C     NOTE                                                                     
C     MOST OF THE COMPUTATION IS PERFORMED IN SINGLE PRECISION                 
      DIMENSION ZI(1),Y(1),YI(1),A(4)                                          
      DATA N/-1/                                                               
      save
C                                                                              
      IL=0                                                                     
      GO TO 1                                                                  
      ENTRY LIR1(Z,ZI,Y,YI,II,ID,NT,L,INTER)                                   
      IL=1                                                                     
    1 CONTINUE                                                                 
      IR=1                                                                     
C     CHECK NT AND RESET IL IF NECESSARY                                       
      IF(NT.LT.2) GO TO 101                                                    
      IF(NT.LT.4) IL=1                                                         
C     ADDRESSING CONSTANTS                                                     
      INTER=1                                                                  
      IR1=IR-1                                                                 
      IRD=IR*ID                                                                
      IIR=(II-1)*IR+1                                                          
      J=(NT-1)*IR+1                                                            
      DIFF=ZI(J)-ZI(1)                                                         
C     SET INDEX FOR START OF SEARCH                                            
      N=(N-2)*IR+1                                                             
      IF(L.LE.1.OR.N.LT.1) N=1                                                 
C     DETERMINE POSITION OF Z WITHIN ZI                                        
    2 IF(N.GT.J) GO TO 8                                                       
      IF(DIFF) 4,102,3                                                         
    3 IF(ZI(N)-Z) 5,6,9                                                        
    4 IF(ZI(N)-Z) 9,6,5                                                        
    5 N=N+IR                                                                   
      GO TO 2                                                                  
C     SET Y WHEN Z LIES ON A MESH POINT                                        
    6 J=(N-1)*ID                                                               
      DO 7 I=1,IIR                                                             
      Y(I)=YI(I+J)                                                             
    7 IF(Y(I).EQ.0.D0) Y(I+IR1)=0.D0                                               
      GO TO 30                                                                 
C     CONTROL WHEN Z DOES NOT LIE ON A MESH POINT                              
    8 INTER=0                                                                  
    9 IF(N.LE.1) INTER=0                                                       
      IF(IL.EQ.1) GO TO 20                                                     
C     CUBIC INTERPOLATION/EXTRAPOLATION                                        
C     PIVOTAL POINT (M) AND POINT (K) CLOSEST TO Z                             
   10 M=N                                                                      
      K=3                                                                      
      IF(N.GT.1+IR) GO TO 11                                                   
      M=1+IR+IR                                                                
      K=N                                                                      
   11 IF(N.LT.J) GO TO 12                                                      
      M=J-IR                                                                   
      K=4                                                                      
C     WEIGHTING FACTORS                                                        
   12 Y1=ZI(M-IR*2)                                                            
      Y2=ZI(M-IR)                                                              
      Y3=ZI(M)                                                                 
      Y4=ZI(M+IR)                                                              
      Z1=Z-Y1                                                                  
      Z2=Z-Y2                                                                  
      Z3=Z-Y3                                                                  
      Z4=Z-Y4                                                                  
   13 Z12=Z1*Z2                                                                
      Z34=Z3*Z4                                                                
   14 A(1)=Z2*Z34/((Y1-Y2)*(Y1-Y3)*(Y1-Y4))                                    
      A(2)=Z1*Z34/((Y2-Y1)*(Y2-Y3)*(Y2-Y4))                                    
      A(3)=Z12*Z4/((Y3-Y1)*(Y3-Y2)*(Y3-Y4))                                    
      A(4)=Z12*Z3/((Y4-Y1)*(Y4-Y2)*(Y4-Y3))                                    
C     CORRECT A(K)                                                             
   15 DIFF=A(1)+A(2)+A(3)+A(4)                                                 
      A(K)=(1.D0+A(K))-DIFF                                                    
C     COMPUTE Y                                                                
   16 M=(M-1)/IR-3                                                             
      M=M*IRD                                                                  
      DO 18 I=1,IIR                                                            
      K=I+M                                                                    
      YY=0.D0                                                                   
      DO 17 J=1,4                                                              
      K=K+IRD                                                                  
      DIFF=YI(K)                                                               
   17 YY=YY+A(J)*DIFF                                                          
      Y(I)=YY                                                                  
   18 IF(Y(I).EQ.0.D0) Y(I+IR1)=0.D0                                               
      GO TO 30                                                                 
C     LINEAR INTERPOLATION/EXTRAPOLATION                                       
   20 IF(N.EQ.1) N=1+IR                                                        
      IF(N.GT.J) N=J                                                           
      Z1=ZI(N)                                                                 
      Y1=(Z1-Z)/(Z1-ZI(N-IR))                                                  
      Y2=1.0D0-Y1                                                                
      J=(N-1)*ID                                                               
      M=J-IRD                                                                  
      DO 21 I=1,IIR,IR                                                         
      Y(I)=Y1*YI(I+M)+Y2*YI(I+J)                                               
   21 IF(Y(I).EQ.0.D0) Y(I+IR1)=0.D0                                               
C     RESET N                                                                  
   30 N=(N+IR-1)/IR                                                            
      RETURN                                                                   
C     DIAGNOSTICS                                                              
  101 CONTINUE
      RETURN                                                                   
  102 CONTINUE
      RETURN                                                                   
 1001 FORMAT(/1X,10('*'),5X,'THERE ARE FEWER THAN TWO DATA POINTS IN',         
     *      ' LIR     NT =',I4,5X,10('*')/)                                    
 1002 FORMAT(/1X,10('*'),5X,'EXTREME VALUES OF INDEPENDENT VARIABLE',          
     *      ' EQUAL IN LIR',5X,10('*')/16X,'ZI(1) =',1PE13.5,',   ',           
     *       'ZI(',I4,') =',1PE13.5/)                                          
      END                                                                      
