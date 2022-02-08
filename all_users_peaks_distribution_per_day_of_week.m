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

%% Section 6: Mean
for user = 1:1:num_users
    mean_ass_pow = [];
    for day_in = 1:1:7
        vec1 = [];
        for time = 1:1:48
            vec1(time) = nanmean(ass_pow(user,day_in,:,time));
        end
        mean_ass_pow = [mean_ass_pow,vec1];     
    end 
    main_mean_ass_pow(user,:) = mean_ass_pow./max(mean_ass_pow); 
end

%% Section 7:
rand('seed',1)
num_groups = 5;
[idx_1,c] = kmeans(main_mean_ass_pow(1:num_users,:),num_groups);
%%
for user = 1:1:num_users
    for day_in = 1:1:7
        for w = 1:1:75
            [day_peak_val(user,day_in,w), day_peak_times(user,day_in,w)] = max(ass_pow(user,day_in,w,:));
        end
    end
end

%%
for day_in = 1:1:7
    for user = 1:1:num_users
        
        day_peak_val_need = day_peak_val(user,day_in,:);
        total_day_peak_val = sum(~isnan(day_peak_val_need));
        mu = nanmean(day_peak_val_need);
        % 5% and 10% around the mean of the peak values
        up_lim_1 = 1.05*mu;
        low_lim_1 = 0.95*mu;

        up_lim_2 = 1.1*mu;
        low_lim_2 = 0.9*mu;

        day_peak_val_check_1 = (day_peak_val_need < up_lim_1) & (day_peak_val_need > low_lim_1);
        day_peak_val_check_2 = (day_peak_val_need < up_lim_2) & (day_peak_val_need > low_lim_2);

        per_around_mean(user,1) = (sum(day_peak_val_check_1)/total_day_peak_val)*100;
%         per_around_mean(user,2) = (sum(day_peak_val_check_2)/total_day_peak_val)*100;

        edges = 1:1:48;
        day_peak_times_need = day_peak_times(user,day_in,:);
        [N] = histcounts(categorical(day_peak_times_need),categorical(edges));
        [~,mode_peak_time] = max(N);

        up_lim_1 = mode_peak_time + 1;
        low_lim_1 = mode_peak_time - 1;

        up_lim_2 = mode_peak_time + 2;
        low_lim_2 = mode_peak_time - 2;

        day_peak_times_check_1 = (day_peak_times_need < up_lim_1) & (day_peak_times_need > low_lim_1);
        day_peak_times_check_2 = (day_peak_times_need < up_lim_2) & (day_peak_times_need > low_lim_2);

        per_around_mean(user,2) = (sum(day_peak_times_check_1)/length(day_peak_times))*100;
%         per_around_mean(user,2) = (sum(day_peak_times_check_2)/length(day_peak_times))*100;
    end
    
    %%
    h4 = 0;
    data_input = per_around_mean(:,2);
    a = sum((data_input>= 0) & (data_input<= 25));
    b = sum((data_input>= 25) & (data_input<= 50));
    c = sum((data_input>= 50) & (data_input<= 75));
    d = sum((data_input>= 75) & (data_input<= 100));

    for i = 1:1:num_users

        figure(day_in)
        set(gcf,'color','w');
        fh = figure(day_in);
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
        ylabel({'percentage of peak values';'in the interval of +/- 10%';'around its mean (peak value)'})
        xlim([0 76])
        ylim([0 130])
        yticks([0 25 50 75 100])

    end
    figure(day_in)
    if h4 == 0
        legend([h1,h2,h3],'Set A','Set B', 'Set C','Orientation','horizontal')
    else
        legend([h1,h2,h3,h4],'Set A','Set B', 'Set C','Group D','Orientation','horizontal')
    end
    legend('AutoUpdate','off')
    title(['Set A = ', num2str(a),', Set B = ', num2str(b),', Group C = ', num2str(c),', Group D = ', num2str(d)])
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
    filename = num2str(day_in);
    print(filename, '-dpng', '-r300')
end