
%RML-environment interaction. Simulation of one subject (subID). Argument "arg" defines the environment
%type. Arg is generated by param_build*.m

function kenntask(subID,arg,seed)

%Variables and data structure initialization%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create a specific random stream for current workspace (for parallel batching)
rss = RandStream('mt19937ar','Seed',seed);
RandStream.setGlobalStream(rss);

nstate=arg.constAct.nstate;

%miniblock length in trials (each block consists of 5 miniblocks)
Nminiblock=50;
MBLOCK=repmat(arg.volnum(1):arg.volnum(2), 100);%miniblocks possible lengths
while sum(MBLOCK(1:Nminiblock))~=90 % 90 trials is the length of a block
    MBLOCK=MBLOCK(randperm(length(MBLOCK)));
end
MBLOCK=MBLOCK(1:Nminiblock);



%number of miniblock in each SE
MBLN=length(MBLOCK);
%statistical environment length (each SE is made of 4 miniblocks)
BL=sum(MBLOCK);


%arg.SEN(2:end)=randperm(max(arg.SEN)); %first environment is always stat0
%number of trials
NTRI=BL*length(arg.SEN);


%binary reward list
RWLIST=zeros(nstate,length(arg.RWP),NTRI);
for i=1:length(arg.RWP)
    for s=1:nstate
        RWLIST(s,i,1:round(arg.RWP(s,i)*NTRI))=1;
        RWLIST(s,i,:)=RWLIST(s,i,randperm(NTRI));
    end
end

%reward list magnitude
RWLISTM=zeros(size(arg.RWM,1),size(arg.RWM,2),NTRI);
for i=1:size(arg.RWM,2)
    for j=1:nstate
        RWLISTM(j,i,:)=arg.RWM(j,i)+randn(1,NTRI)*arg.var(j,i).^.5;
    end
end



%data structure storing all events
dat.se=zeros(NTRI,1); %statistical environment 1=Stat;2=Stat2;3=Vol
dat.blck=zeros(NTRI,1); %block number
dat.ttype=zeros(NTRI,1); %trial type
dat.respside=zeros(nstate,NTRI); %response side
dat.optim=zeros(nstate,NTRI)+arg.chance2; %response optimality in terms of rw probability
dat.rw=zeros(nstate,NTRI); %reward 1=yes
dat.V=zeros(nstate,NTRI,arg.nactions);
dat.V2=zeros(nstate,NTRI,arg.nactions_boost);
dat.D=zeros(nstate,NTRI);
dat.k=zeros(nstate,NTRI);
dat.k2=zeros(nstate,NTRI);
dat.varD=zeros(nstate,NTRI);
dat.varV=zeros(nstate,NTRI);
dat.varV2=zeros(nstate,NTRI);
dat.VTA=zeros(nstate,NTRI);
dat.VTA2=zeros(nstate,NTRI);

dat.val=zeros(nstate,NTRI);

dat.b=zeros(nstate,NTRI);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Start Experiment%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%create RML object%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AccAct=RML(nstate,arg.nactions,arg.constAct);
AccBoost=RML(nstate,arg.nactions_boost,arg.constBoost);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initial weights
AccAct.V(1:nstate,:)=arg.W3;
AccBoost.V(1:nstate,:)=arg.We3;

%add noise to initial s-a values
AccAct.V(1:nstate,:)=AccAct.V(1:nstate,:)+randn(nstate,arg.nactions)*.05.*AccAct.V(1:nstate,:);
AccBoost.V(1:nstate,:)=AccBoost.V(1:nstate,:)+randn(nstate,arg.nactions_boost)*.05.*AccBoost.V(1:nstate,:);

trial=1;%trials counter


for se=arg.SEN
    for mb=1:MBLN%miniblock counter
        for mbtri=1:MBLOCK(mb)
            
            % s-a transitions trace
            AccBoost.sat=zeros(nstate,1);
            
            %RML initialization
            if se==0 %if training
                
                AccAct.costs=[.5 .5 0
                              .5 .5 0
                              .5 .5 0]; %no barrier and no lesion
                    
                AccAct.DAlesion=1;%default=1 (no lesion)
                AccAct.NElesion=1;%default=1 (no lesion)
                AccAct.HTlesion=.15;%default=.15 (no lesion)
                AccBoost.DAlesion=1;%default=1 (no lesion)
                AccBoost.NElesion=1;%default=1 (no lesion)
                AccBoost.HTlesion=.15;%default=.15 (no lesion)
            elseif se == 2
                AccAct.costs=[1.5 1.5 0
                              1.5 1.5 0
                              1.5 1.5 0];
                AccAct.DAlesion=arg.constAct.DAlesion;%default=1 (no lesion)
                AccAct.NElesion=arg.constAct.NElesion;%default=1 (no lesion)
                AccAct.HTlesion=arg.constAct.HTlesion;%default=.15 (no lesion)
                AccBoost.DAlesion=arg.constBoost.DAlesion;%default=1 (no lesion)
                AccBoost.NElesion=arg.constBoost.NElesion;%default=1 (no lesion)
                AccBoost.HTlesion=arg.constBoost.HTlesion;%default=.15 (no lesion)
            else
                
                AccAct.costs=arg.constAct.costs;
                AccAct.DAlesion=arg.constAct.DAlesion;%default=1 (no lesion)
                AccAct.NElesion=arg.constAct.NElesion;%default=1 (no lesion)
                AccAct.HTlesion=arg.constAct.HTlesion;%default=.15 (no lesion)
                AccBoost.DAlesion=arg.constBoost.DAlesion;%default=1 (no lesion)
                AccBoost.NElesion=arg.constBoost.NElesion;%default=1 (no lesion)
                AccBoost.HTlesion=arg.constBoost.HTlesion;%default=.15 (no lesion)
                 
            end
            
            s=arg.initstate;%start trial from state s
            
            while s<=nstate %within trial state transitions
                               
                %%%%%RML action selection%%%%%% b=boost, res=motor response
                [b,res]=RML_decision(s,arg,AccAct,AccBoost);
                
                %%%%%environment analyzes the response by dCC_Action and
                %%%%%provides outcome (that can be a primary reward, a
                %%%%%state transition or both). S1 = next state
                [opt, rw, RW, s1]=resp_analys(trial,se,mb,s,res,RWLIST,RWLISTM,arg.RWM,arg.RWP,arg.trans,arg.chance);
                
                %RML updates; VTA=VTA-to-AccAct, VTA2=VTA-to-AccBoost
                [VTA,VTA2]=RML_update(rw,RW,s,s1,b,res,AccAct,AccBoost);

      
                %%%record events
                %dat.iscon(trial)=(RWLIST(s,2+(se-1)*2,trial)==1);
                dat.val(s,trial)=AccAct.V(s,res);

                dat.D1(s,trial)=AccAct.D(s,1);
                dat.D2(s,trial)=AccAct.D(s,2);

                dat.se(trial)=se; %statistical environment 1=Stat;2=Stat2;3=Vol
                dat.blck(trial)=mb; %block number                             
                dat.respside(s,trial)=res; %response side
                dat.optim(s,trial)=opt; %response optimality in terms of rw probability                    
                dat.rw(s,trial)=rw*RW; %reward 1=yes           
                dat.VTA(s,trial)=VTA;
                dat.VTA2(s,trial)=VTA2;                       
                dat.V(:,trial,:)=AccAct.V(1:nstate,:);
                dat.V2(:,trial,:)=AccBoost.V(1:nstate,:);
                dat.D(s,trial)=AccAct.D(s,res);
                dat.k(s,trial)=(AccAct.k);
                dat.k2(s,trial)=(AccBoost.k);
                dat.varD(s,trial)=mean(AccAct.varD(s,res));
                dat.varK(s,trial)=mean(AccAct.varK(s,res));
                dat.varV(s,trial)=mean(AccAct.varV(s,res));
                dat.varV2(s,trial)=mean(AccAct.varV2(s,res));
                dat.b(s,trial)=b;
             
                                
                s=s1; %update state
             
                
            end
                     
            %update trial counter
            trial=trial+1;
        
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eval(['save S' num2str(subID) ' dat']);

end









