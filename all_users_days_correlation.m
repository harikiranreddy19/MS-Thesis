clc;
clear all;
close all;

%% Section 1: Extracting the input data
load('cesLargeDemand100_correct_without_nan.mat')
pow_con(47,:) = [];
user_id(47,:) = [];
pow_con(53,:) = [];
user_id(53,:) = [];

size_large_data = size(pow_con);     
num_time_intervals = size_large_data(2); % time intervals
num_users = length(user_id);
num_months = length(month_id);  

%% Section 2: Assigning day to dates
ass_day = zeros(num_months,31);
day_in = 6;                                      % August 01st 2009 was Saturday
week_in = 1;
for month = 1:1:num_months
    len_days = numdays_nonleap(month_id(month));
    for date = 1:1:len_days   
        if day_in >7
            day_in =1;
            ass_day(month,date) = day_in;
        else
            ass_day(month,date) = day_in;   
        end
        day_in = day_in+1;
    end  
end

%% Section 3: Assiging Power Consumption according to month, date, time
for user = 1:1:num_users
    g = 0;
    for month = 1:1:num_months
        len_days = numdays_nonleap(month_id(month));
        for date = 1:1:len_days
            for time = 1:1:48
                g = g+1;
                pow_con_spec(user,month,date,time) = pow_con(user,g);
            end
        end
    end
end

%% Section 4: Extracting Month and Date indexes for all days
for user = 1:1:num_users
    for day_in = 1:1:7
        
        % making the elements to NaN to be even
        % if a month starts from 5, then just add day_in == 5 and likewise
        if day_in == 6 || day_in == 7     
            t(user,day_in) = 0;
            for i = 1:1:num_months
                for j = 1:1:31
                    if day_in == ass_day(i,j)
                        t(user,day_in) = t(user,day_in)+1;
                        month_index(user,day_in,t(user,day_in)) = i;
                        date_index(user,day_in,t(user,day_in)) = j;
                    end
                end
            end
        else
            t(user,day_in) = 1;         
            for i = 1:1:num_months
                for j = 1:1:31
                    if day_in == ass_day(i,j)
                        t(user,day_in) = t(user,day_in)+1;
                        month_index(user,day_in,t(user,day_in)) = i;
                        date_index(user,day_in,t(user,day_in)) = j;
                    end
                end
            end
        end
            
    end
end

%% Section 5: Assigning Power based on day and time
for user = 1:1:num_users
    for day_in = 1:1:7    
        % making the main set even by adding NaN elements
        for w = 1:1:t(user,day_in)
            for time = 1:1:48
                if month_index(user,day_in,w) ~= 0 && date_index(user,day_in,w) ~= 0
                    ass_pow(user,day_in,w,time) = pow_con_spec(user,month_index(user,day_in,w),date_index(user,day_in,w),time);
                else
                    ass_pow(user,day_in,w,time) = NaN;
                end
            end
        end     
        % making the ending elements equal to NaN
        % suppose if the last day is 3, then, we should have to add 4,5,6,7
        
        if day_in == 6 || day_in == 7       
            ass_pow(user,day_in,w+1,:) = NaN;
        end            
    end   
end

%% Section 6: Calculating R^2 (adj.) value among different users and different days
Rsqr = zeros(num_users,7,num_users,7);
for sel_user = 1:1:num_users
    for sel_day_in = 1:1:7
        y = reshape(ass_pow(sel_user,sel_day_in,:,:),[],1);
        for user = 1:1:num_users
            for day_in = 1:1:7
                x = [];
                x = reshape(ass_pow(user,day_in,:,:),[],1);
                tbl = table(x,y,'VariableNames',{'x','y'});
                mdl = fitlm(tbl,'y~x');
                Rsqr(sel_user,sel_day_in,user,day_in) = mdl.Rsquared.Adjusted;
            end
        end
    end
end
%%
clc;
clear all;
close all;

load('r_sqr_values.mat')
%% Section 7: Analysis on R^2 values
set(0,'defaultpatchlinewidth',2);
set(0,'defaultlinelinewidth',2);
set(0,'DefaultAxesFontSize',12);

figure(1)
set(gcf,'color','w');
fh = figure(1);
histogram(Rsqr(:))
xlabel('Coefficient of Determination (R^{2})')
ylabel('Frequency')
ax = gca;
ax.YGrid = 'on';
filename = num2str(1);
print(filename, '-dpng', '-r300')