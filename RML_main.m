%Main scirpt for launching all the sims from Silvetti et al. 2018 (PLoS CB)


clear all
task=0;

while sum(task~=[1 2])==2
    
    clc
    
    disp('Choose the task you want the RML to perform')
    disp(' ')
    disp(['1. Cognitive control: naive implementation                                '
          '2. Cognitive control: experiment                                          ']);
    task=input(': ');
    
    
    %select environment variables to create the desired task
    if task == 1
        arg = param_build_stroop_naive;
    elseif task == 2
        arg = param_build_stroop;
    end
    
end

delete S*.mat

seed=round(rand(1,arg.nsubj)*100000);



for s=1:arg.nsubj
    kenntask(s,arg,seed(s));
end
