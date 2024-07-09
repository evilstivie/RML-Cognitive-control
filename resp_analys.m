%response analysis
function [opt, rw, RW,s1]=resp_analys(trin,se,miniblock,s,resp,rwlist,rwlistm,RWM,RWP,trans,chance)


%rwlist=squeeze(rwlist);
%RWP=squeeze(RWP);

if se==0 %SE 0 is stationary warmup
    se=1;
end



if resp<3 %if decides to engage in the task
    
  if rem(miniblock,2)==0 && se == 4
    se = 2;
  elseif se == 4
    se = 3;
  end

  if sum(RWM(s,resp+(se-1)*2))~=0 %if there is a primary reward in state s
     if (RWM(s,resp+(se-1)*2)*RWP(s,resp+(se-1)*2))==max(RWM(s,[1:2]+(se-1)*2).*RWP(s,[1:2]+(se-1)*2))%pascalian optimum
        opt=1;%otpimality 1=yes
     else
        opt=0;
     end
     rw=rwlist(s,resp+(se-1)*2,trin);
     RW=rwlistm(s,resp+(se-1)*2,trin);

       if rw==1%if successful transition to the next state
           s1=trans(s,resp); %transition based on transition matrix
           rw=abs(sign(RW*rw)); %check if there is primary reward 
       else%if unsuccessful transition non final state
           s1=max(trans(:));%end of trial
       end

  else
        if (RWP(s,resp+(se-1)*2))==max(RWP(s,[1:2]+(se-1)*2))%pascalian optimum
           opt=1;%otpimality 1=yes                  
        else        
           opt=0;                 
        end
        rw=rwlist(s,resp+(se-1)*2,trin);
        RW=rwlistm(s,resp+(se-1)*2,trin);

        if rw==1%if successful transition to the next state
           s1=trans(s,resp); %transition based on transition matrix
           rw=abs(sign(RW*rw)); %check if there is primary reward 
        else%if unsuccessful transition 
           s1=max(trans(:));%end of trial
        end
%        
   end
    
    
else %if decides to do not engage
    rw=0;
    RW=1;
    opt=chance;
    s1=max(trans(:));%end of trial
end


end