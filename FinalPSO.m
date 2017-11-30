clc;
clear;
close all;


%% Parameters of PSO

MaxIt = 1000;           % Maximum Number of Iterations
order = 31;
noOfCoeff = order + 1;
nPop = 22;              % Population Size (Swarm Size)  Size of the frequency list
w = 0.3;                % Intertia Coefficient
wdamp = 0.999;          % Damping Ratio of Inertia Coefficient
c1 = 2;                 % Personal Acceleration Coefficient
c2 = 2;                 % Social Acceleration Coefficient
ShowIterInfo = true;    % Flag for Showing Iteration Informatin
isfirstPrint = false;

MaxPosition = 1;
MinPosition = -1;
MaxVelocity = 2;
MinVelocity = -2;



%% Starting plot of desired graph

desiredFilter = fir1(31,0.5,kaiser(32,8));

[desiredFilter_h, desiredFilter_w] = freqz(desiredFilter, 1, 'whole', 1000);

figure('name', 'PSO on FIR order 31');
plot(desiredFilter_w/pi,20*log10(abs(desiredFilter_h)));



%% Calling PSO

%% Initialization

% The Particle Template
particle_struct.Position = [];
particle_struct.Velocity = [];
particle_struct.Best.Position = [];


% Create Population Array
particle = repmat(particle_struct, nPop, 1);

% Initialize Global Best
GlobalBest.Position = unifrnd(MinPosition, MaxPosition, 1, noOfCoeff);

% Initialize Population Members
for i=1:nPop

    % Generate Random Solution
    particle(i).Position = unifrnd(MinPosition, MaxPosition, 1, noOfCoeff);
    particle(i).Velocity = unifrnd(MinVelocity, MaxVelocity, 1, noOfCoeff);
   
    particle(i).Best.Position = particle(i).Position;
   
    if findError(particle(i).Position, desiredFilter_h) < findError(GlobalBest.Position, desiredFilter_h)
        GlobalBest.Position  = particle(i).Position;
    end

end



disp('Running PSO...');
%% Main Loop of PSO
for it=1:MaxIt

    for i=1:nPop
       
        % Update Velocity
        for j = 1:noOfCoeff
            particle(i).Velocity(j) = w*particle(i).Velocity(j) ...
                + c1*rand*(particle(i).Best.Position(j) - particle(i).Position(j)) ...
                + c2*rand*(GlobalBest.Position(j) - particle(i).Position(j));
        end
        
        % Update Position
        particle(i).Position = particle(i).Position + particle(i).Velocity;
        
        % Update Local Best
        if findError(particle(i).Position, desiredFilter_h) < findError(particle(i).Best.Position, desiredFilter_h)
            
            particle(i).Best.Position = particle(i).Position;
            
            % Update Global Best
            if findError(particle(i).Best.Position, desiredFilter_h) < findError(GlobalBest.Position, desiredFilter_h)
                GlobalBest.Position = particle(i).Best.Position;
            end 
        end
    end
 
    
    % Display Iteration Information
    if ShowIterInfo
        hold all

        [temp_y,temp_x] = freqz(GlobalBest.Position,1 , 'whole', 1000);
        
        % Check if first entry
        if(isfirstPrint)
            delete(mt);
        end
        
        mt = plot(temp_x/pi,20*log10(abs(temp_y)));
        
        title({['Interation #: ' num2str(it) ' (Population Size: ' num2str(nPop) ')']});
        xlabel('w ( x pi)');
        ylabel('|H(jw)| (dB)');
        
        hold off
        drawnow
        isfirstPrint = true;
    end

    % Damping Inertia Coefficient
    w = w * wdamp;
end

disp('Done!');


%%  Reference
% - Open source PSO code from github


