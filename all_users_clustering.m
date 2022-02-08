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

%% Section 6: Mean and Median
for user = 1:1:num_users
    mean_ass_pow = [];
    median_ass_pow = [];
    for day_in = 1:1:7
        vec1 = [];
        vec2 = [];
        for time = 1:1:48
            vec1(time) = nanmean(ass_pow(user,day_in,:,time));
            vec2(time) = nanmedian(ass_pow(user,day_in,:,time));
        end
        mean_ass_pow = [mean_ass_pow,vec1];
%         median_ass_pow = [median_ass_pow,vec2];
        
    end
    
    main_mean_ass_pow(user,:) = mean_ass_pow./max(mean_ass_pow);
%     main_median_ass_pow(user,:) = median_ass_pow./max(median_ass_pow);
    
end

%% Section 7:
rand('seed',1)
num_groups = 5;
[idx_1,c] = kmeans(main_mean_ass_pow(1:75,:),num_groups);

% %%
% for i = 1:1:num_users
%     switch idx_1(i)
%         case 1
%             idx_1_mod(i) = 1;
%             c_mod(1,:) = c(1,:);
%         case 2
%             idx_1_mod(i) = 4;
%             c_mod(2,:) = c(4,:);
%         case 3
%             idx_1_mod(i) = 3;
%             c_mod(3,:) = c(3,:);
%         case 4
%             idx_1_mod(i) = 6;
%             c_mod(4,:) = c(6,:);
%         case 5
%             idx_1_mod(i) = 2;
%             c_mod(5,:) = c(2,:);
%         case 6
%             idx_1_mod(i) = 5;
%             c_mod(6,:) = c(5,:);
%     end
%         
% end

% %%
% count = [];
% for i = 1:1:num_groups
%     count(i) = sum(idx_1 == i);
% end
% 
% %%
% user_count = 0;
% for user = 1:1:num_users
%     
% %     set(0,'defaultpatchlinewidth',2);
% %     set(0,'defaultlinelinewidth',2);
%     set(0,'DefaultAxesFontSize',10);
%     
%     n = idx_1(user);
%     switch n
%         
%         case n
%             figure(n)
%             set(gcf,'color','w');
%             fh = figure(n);
%             fh.Position = [100 100 700 200];
%             plot(main_mean_ass_pow(user,:),'y--','LineWidth',0.1)
%             hold on
%             title(['Cluster - ',num2str(n),', No. of Users - ',num2str(count(n))])
%             xlabel('metering interval')
%             ylabel('normalized mean')
%             xlim([0 337])
%             yticks([0 0.2 0.4 0.6 0.8 1])
% %             xticks([1,24,48,49,72,96,97,120,144,145,168,192,193,216,240,241,264,288,289,312,336])
% %             xticklabels({'1','24','48','1','24','48','1','24','48','1','24','48','1','24','48','1','24','48','1','24','48'})
%             grid on
%     end
% end
% 
% %%
% for n = 1:1:num_groups
%     set(0,'defaultpatchlinewidth',2);
%     set(0,'defaultlinelinewidth',2);
%     set(0,'DefaultAxesFontSize',10);
%     figure(n)
%     set(gcf,'color','w');
%     fh = figure(n);
%     fh.Position = [100 100 700 200];
%     plot(c(n,:),'b-')
%     hold on
%     plot([48 48],[0 1],'color',[1 0 0],'LineWidth',0.5)
%     hold on
%     plot([96 96],[0 1],'color',[1 0 0],'LineWidth',0.5)
%     hold on
%     plot([144 144],[0 1],'color',[1 0 0],'LineWidth',0.5)
%     hold on
%     plot([192 192],[0 1],'color',[1 0 0],'LineWidth',0.5)
%     hold on
%     plot([240 240],[0 1],'color',[1 0 0],'LineWidth',0.5)
%     hold on
%     plot([288 288],[0 1],'color',[1 0 0],'LineWidth',0.5)
%     hold on
%     
%     title(['Cluster - ',num2str(n),', No. of Users - ',num2str(count(n))])
%     xlabel('day of week')
%     ylabel('normalized mean')
%     xlim([0 337])
%     xticks([24:48:336])
%     xticklabels({'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'})
%     grid on
%     filename = num2str(n);
%     print(filename, '-dpng', '-r300')
% end











