clc;
clear all;
close all;

set(0,'defaultpatchlinewidth',2);
set(0,'defaultlinelinewidth',2);
set(0,'DefaultAxesFontSize',10);

%% Section 1: Extracting the input data
load('cesLargeDemand100_correct_without_nan.mat')
pow_con(47,:) = [];
user_id(47,:) = [];
pow_con(53,:) = [];
user_id(53,:) = [];

num_users = 75;

for user = 1:1:num_users
    pow_con_user_1 = pow_con(user,:);
    size_large_data = size(pow_con_user_1);     
    num_time_intervals = size_large_data(2); % time intervals
    num_months = length(month_id);

    %% section 2: Assigning power based on days and time
    for count_int = 1:1:num_time_intervals
        time_count = rem(count_int,48);
        day_count = ((count_int-time_count)/48)+1;
        if time_count == 0
            time_count = 48;
            day_count = ((count_int-time_count)/48)+1;
        end
        ass_pow_user_time(day_count,time_count) = pow_con_user_1(count_int);
    end

    %% All daily peaks irrespective of the days of the week
    for day_ind = 1:1:day_count
        [daily_peak_val(day_ind), daily_peak_times(day_ind)] = max(ass_pow_user_time(day_ind,:));
    end

%     % Histogram of all daily peak values
%     edges = [0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70];
%     figure(user)
%     set(gcf,'color','w');
%     fh = figure(user);
%     histogram(daily_peak_val(:),edges);
%     fh.Position = [100 100 700 200];
%     ax = gca;
%     ax.YGrid = 'on';
%     xlabel('peak power consumption values (in kW)')
%     ylabel('Frequency')
%     xlim([0 70])
%     xticks([0 5 10 15 20 25 30 35 40 45 50 55 60 65 70])
%     filename = num2str(user);
%     print(filename, '-dpng', '-r300')

%     % QQ Plot
%     figure(user)
%     set(gcf,'color','w');
%     fh = figure(user);
%     fh.Position = [100 100 700 200];
%     pd = fitdist(daily_peak_val(:),'Normal');
%     qqplot(daily_peak_val(:))
%     title(['\mu = ', num2str(pd.mu),', \sigma = ', num2str(pd.sigma)])
%     str = {'x'};
%     text(0,pd.mu,str,'Color','red','FontSize',20,'HorizontalAlignment','center','VerticalAlignment','middle')
%     ylabel('power consumption (in kW)')
%     ylim([0 70])
%     yticks([0 10 20 30 40 50 60 70])
%     grid on
%     filename = num2str(user);
%     print(filename, '-dpng', '-r300')

    % 5% and 10% around the mean of the peak values
    pd = fitdist(daily_peak_val(:),'Normal');
    up_lim_1 = 1.05*pd.mu;
    low_lim_1 = 0.95*pd.mu;
    
    up_lim_2 = 1.1*pd.mu;
    low_lim_2 = 0.9*pd.mu;
    
    daily_peak_val_check_1 = (daily_peak_val < up_lim_1) & (daily_peak_val > low_lim_1);
    daily_peak_val_check_2 = (daily_peak_val < up_lim_2) & (daily_peak_val > low_lim_2);
    
    per_around_mean(user,1) = (sum(daily_peak_val_check_1)/length(daily_peak_val))*100;
    per_around_mean(user,2) = (sum(daily_peak_val_check_2)/length(daily_peak_val))*100;

%     % Histogram for Peak Times
%     edges = 1:1:48;
%     figure(user)
%     set(gcf,'color','w');
%     fh = figure(user);
%     fh.Position = [100 100 700 200];
%     histogram(categorical(daily_peak_times),categorical(edges));
%     ax = gca;
%     ax.YGrid = 'on';
%     xlabel('Peak Power Consumption Times')
%     ylabel('Frequency')
%     filename = num2str(user);
%     print(filename, '-dpng', '-r300')
    
%     edges = 1:1:48;
%     [N] = histcounts(categorical(daily_peak_times),categorical(edges));
%     [~,mode_peak_time] = max(N);
%     
%     up_lim_1 = mode_peak_time + 1;
%     low_lim_1 = mode_peak_time - 1;
%     
%     up_lim_2 = mode_peak_time + 2;
%     low_lim_2 = mode_peak_time - 2;
%     
%     daily_peak_times_check_1 = (daily_peak_times < up_lim_1) & (daily_peak_times > low_lim_1);
%     daily_peak_times_check_2 = (daily_peak_times < up_lim_2) & (daily_peak_times > low_lim_2);
%     
%     per_around_mean(user,1) = (sum(daily_peak_times_check_1)/length(daily_peak_times))*100;
%     per_around_mean(user,2) = (sum(daily_peak_times_check_2)/length(daily_peak_times))*100;
    
    
end

%%
h4 = 0;
data_input = per_around_mean(:,2);
a = sum((data_input>= 0) & (data_input<= 25));
b = sum((data_input>= 25) & (data_input<= 50));
c = sum((data_input>= 50) & (data_input<= 75));
d = sum((data_input>= 75) & (data_input<= 100));

for i = 1:1:num_users

    figure(1)
    set(gcf,'color','w');
    fh = figure(1);
    fh.Position = [100 100 700 200];
    
    h = data_input(i);
    if h >= 0 && h <= 25
        col = 'r';
        h1 = bar(i,data_input(i),'Facecolor',col);
        hold on
    elseif h > 25 && h <= 50
        col = 'b';
        h2 = bar(i,data_input(i),'Facecolor',col);
        hold on
    elseif h >50 && h <= 75
        col = 'g';
        h3 = bar(i,data_input(i),'Facecolor',col);
        hold on
    elseif h > 75 && h <= 100
        col = 'y';
        h4 = bar(i,data_input(i),'Facecolor',col);
        hold on
    end
    
    xlabel('user')
    ylabel({'percentage of daily peak';'values in the interval of +/- 10%';'around its mean(peak value)'})
    xlim([0 76])
    ylim([0 130])
    yticks([0 25 50 75 100])
    
end
figure(1)
if h4 == 0
legend([h1,h2,h3],'Group A','Group B', 'Group C','Orientation','horizontal')
else
    legend([h1,h2,h3,h4],'Group A','Group B', 'Group C','Group C','Orientation','horizontal')
end
legend('AutoUpdate','off')
title(['Group A = ', num2str(a),', Group B = ', num2str(b),', Group C = ', num2str(c),', Group D = ', num2str(d)])
xticks([1 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75])
x_patch = [0 76];
y_patch = [0 25 50 75 100];

set(0,'defaultpatchlinewidth',0.1);
set(0,'defaultlinelinewidth',0.1);
patch('XData',[x_patch(1),x_patch(2),x_patch(2),x_patch(1)],'YData',[y_patch(1),y_patch(1),y_patch(2),y_patch(2)],'FaceColor','r','FaceAlpha',0.1,'LineStyle','--')
hold on
patch('XData',[x_patch(1),x_patch(2),x_patch(2),x_patch(1)],'YData',[y_patch(2),y_patch(2),y_patch(3),y_patch(3)],'FaceColor','b','FaceAlpha',0.1,'LineStyle','--')
hold on
patch('XData',[x_patch(1),x_patch(2),x_patch(2),x_patch(1)],'YData',[y_patch(3),y_patch(3),y_patch(4),y_patch(4)],'FaceColor','g','FaceAlpha',0.1,'LineStyle','--')
hold on
patch('XData',[x_patch(1),x_patch(2),x_patch(2),x_patch(1)],'YData',[y_patch(4),y_patch(4),y_patch(5),y_patch(5)],'FaceColor','y','FaceAlpha',0.1,'LineStyle','--')
hold off
filename = num2str(1);
print(filename, '-dpng', '-r300')