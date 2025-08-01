clear;
clc;
close all;
close all force;
app=NaN(1);  %%%%%%%%%This is to allow for Matlab Application integration.
format shortG
top_start_clock=clock;
folder1='C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\3.1GHz Neighborhood'; %%%Folder where this file exists.
cd(folder1)
addpath(folder1)
addpath('C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\Basic_Functions') %%%Path of Repository
addpath('C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\3.1GHz_Army')  %%%%%%Sim Data
addpath('C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\3.5GHz Portal DPAs') %%%Path of Data
addpath('C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\General_Terrestrial_Pathloss') %%%Path of Repository
addpath('C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\General_Movelist')%%%Path of Repository
addpath('C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\Generic_Bugsplat') %%%Path of Repository
addpath('C:\Users\nlasorte\OneDrive - National Telecommunications and Information Administration\MATLAB2024\Census_Functions') %%%Path of Repository
addpath('C:\Local Matlab Data\Local MAT Data') %%%%%%%One Drive Error with mat files
pause(0.1) %%%It’s good to take a moment for yourself.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%From the CBRS Portal Data: Pax River
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cell_data_header=cell(1,32);
cell_data_header{1}='data_label1';
cell_data_header{2}='latitude';
cell_data_header{3}='longitude';
cell_data_header{4}='rx_bw_mhz';
cell_data_header{5}='rx_height';
cell_data_header{6}='ant_hor_beamwidth';
cell_data_header{7}='min_azimuth';
cell_data_header{8}='max_azimuth';
cell_data_header{9}='rx_ant_gain_mb';
cell_data_header{10}='rx_nf';
cell_data_header{11}='in_ratio';
cell_data_header{12}='min_ant_loss';
cell_data_header{13}='fdr_dB';
cell_data_header{14}='dpa_threshold';
cell_data_header{15}='required_pathloss';
cell_data_header{16}='base_protection_pts';
cell_data_header{17}='base_polygon';
cell_data_header{18}='gmf_num';
cell_data_header{19}='rx_lat';
cell_data_header{20}='rx_lon';
cell_data_header{21}='base_polyshape';
cell_data_header{22}='ant_diamter_m';
cell_data_header{23}='Sat_ID';
cell_data_header{24}='Noise_TempK';
cell_data_header{25}='Ground_Elevation_m';
cell_data_header{26}='Antenna_Pattern_Str';
cell_data_header{27}='rx_if_bw_mhz';
cell_data_header{28}='array_ant_pattern';  %%%Change this to tf_custom_ant_pattern
cell_data_header{29}='TF_Custom_Ant_Pattern';
cell_data_header{30}='X_POL_dB';
cell_data_header{31}='gs_azimuth';
cell_data_header{32}='gs_elevation';

cell_sim_data=cell(1,32);
cell_sim_data{1,1}='PaxRiverAdams';
cell_sim_data{1,2}=38.2975;
cell_sim_data{1,3}=-76.375833;
cell_sim_data{1,5}=10;
cell_sim_data{1,6}=3;
cell_sim_data{1,7}=37;
cell_sim_data{1,8}=214;
cell_sim_data{1,12}=40;
cell_sim_data{1,14}=-144;
cell_sim_data{1,16}=horzcat(cell_sim_data{1,2},cell_sim_data{1,3},cell_sim_data{1,5});
cell_sim_data{1,17}=horzcat(cell_sim_data{1,2},cell_sim_data{1,3});
cell_sim_data{1,29}=0;  %%%%%Not custom ant pattern, uses simple pattern
cell_sim_data=vertcat(cell_data_header,cell_sim_data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Base Station Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%1) Azimuth -180~~180
%%%2) Rural
%%%3) Suburban
%%%4) Urban
aas_zero_elevation_data=zeros(361,4);
aas_zero_elevation_data(:,1)=-180:1:180;
%%%%AAS Reduction in Gain to Max Gain (0dB is 0dB reduction)
bs_down_tilt_reduction=abs(max(aas_zero_elevation_data(:,[2:4]))) %%%%%%%%Downtilt dB Value for Rural/Suburban/Urban
norm_aas_zero_elevation_data=horzcat(aas_zero_elevation_data(:,1),aas_zero_elevation_data(:,[2:4])+bs_down_tilt_reduction);
bs_down_tilt_reduction=min(bs_down_tilt_reduction)
max(norm_aas_zero_elevation_data(:,[2:4])) %%%%%This should be [0 0 0]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Base Station Deployment
load('rand_real_2025.mat','rand_real_2025')  %%%%%%%%1)Lat, 2)Lon, 3)Antenna Height
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Test
rev=995; %%%%%Adams PAX River Example
freq_separation=0; %%%%%%%Assuming co-channel
bs_eirp=45%%%% %%%%%EIRP [dBm/10MHz] for Rural, Suburan, Urban: 62dBm/1MHz --> 36.25dBm/MHz at 50th (0,0), then - 1.25 for 80% TDD, 35dBm/Mhz --> 45dBm/10MHz
mitigation_dB=0:10:30;  %%%%%%%%% in dB%%%%% Beam Muting or PRB Blanking (or any other mitigation mechanism):  30 dB reduction %%%%%%%%%%%%Consider have this be an array, 3dB step size, to get a more granular insight into how each 3dB mitigation reduces the coordination zone.
mc_size=1%%%% Since we're at 50%
tf_full_binary_search=1;  %%%%%Search all DPA Points, not just the max distance point
min_binaray_spacing=1%2%4%8; %%%%%%%minimum search distance (km)
reliability=50% %%%For Propagation Model
move_list_reliability=reliability; %%%For Propagation Model
agg_check_reliability=reliability; %%%For Propagation Model
FreqMHz=3550; %%%For Propagation Model
confidence=50; %%%For Propagation Model
mc_percentile=100% since we're at 1 MC sim
sim_radius_km=512; %%%%%%%%Placeholder distance         binary_dist_array=[2,4,8,16,32,64,128,256,512,1024,2048];
base_station_latlonheight=rand_real_2025;  %%1)Lat, 2)Lon, 3)Height meters
tf_clutter=0%1%;  %%%%%%%????, Just do this in the EIRP reductions
sample_spacing_km=5;
sim_folder1='C:\Local Matlab Data\3.5GHz Neighborhood Test Sims'
tf_opt=1; %%%%This is for the optimized move list, (not WinnForum)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bs_eirp_reductions=(bs_eirp-bs_down_tilt_reduction)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%Create a Rev Folder
cd(sim_folder1);
pause(0.1)
tempfolder=strcat('Rev',num2str(rev));
[status,msg,msgID]=mkdir(tempfolder);
rev_folder=fullfile(sim_folder1,tempfolder);
cd(rev_folder)
pause(0.1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maine_exception=1;  %%%%%%Just leave this to 1
Tpol=1; %%%polarization for ITM
deployment_percentage=100; %%%%%%%%%%%Let's not change this.
margin=1;%%dB margin for aggregate interference
building_loss=15;  %%%%Not applicable for outdoor base stations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Saving the simulation files in a folder for the option to run from a server
'First save . . .' %%%%%24 seconds on Z drive
tic;
save('reliability.mat','reliability')
save('move_list_reliability.mat','move_list_reliability')
save('confidence.mat','confidence')
save('FreqMHz.mat','FreqMHz')
save('Tpol.mat','Tpol')
save('building_loss.mat','building_loss')
save('maine_exception.mat','maine_exception')
save('tf_opt.mat','tf_opt')
save('mc_percentile.mat','mc_percentile')
save('mc_size.mat','mc_size')
save('margin.mat','margin')
save('deployment_percentage.mat','deployment_percentage')
save('tf_full_binary_search.mat','tf_full_binary_search')
save('min_binaray_spacing.mat','min_binaray_spacing')
save('sim_radius_km.mat','sim_radius_km')
save('bs_eirp_reductions.mat','bs_eirp_reductions')
save('norm_aas_zero_elevation_data.mat','norm_aas_zero_elevation_data')
save('agg_check_reliability.mat','agg_check_reliability')
save('tf_clutter.mat','tf_clutter')
save('base_station_latlonheight.mat','base_station_latlonheight')
save('mitigation_dB.mat','mitigation_dB')
toc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%First loop does all the calculation for the 15 columns, then just saves the cell_sim_data for the server to make the folders
%%%%%%%%%For Loop the Locations
cell_data_header=cell_sim_data(1,:)
cell_sim_data(1,:)=cell_data_header;

col_data_label_idx=find(matches(cell_data_header,'data_label1'));
col_base_polygon_idx=find(matches(cell_data_header,'base_polygon'));
col_pp_pts_idx=find(matches(cell_data_header,'base_protection_pts'));
col_rx_htm_idx=find(matches(cell_data_header,'rx_height'));


[num_locations,~]=size(cell_sim_data);
table([1:num_locations]',cell_sim_data(:,1))
tic;
for base_idx=2:1:num_locations
    temp_single_cell_sim_data=cell_sim_data(base_idx,:);
    data_label1=temp_single_cell_sim_data{col_data_label_idx};
    data_label1=data_label1(find(~isspace(data_label1)));  %%%%%%%%%%Remove the White Spaces
    cell_sim_data{base_idx,col_data_label_idx}=data_label1;
    temp_base_polygon=temp_single_cell_sim_data{col_base_polygon_idx};
    temp_rx_htm=temp_single_cell_sim_data{col_rx_htm_idx};


    %%%%%%'Need to do the sample points along the base_polygon'

    [num_base_pts,~]=size(temp_base_polygon);
    if num_base_pts==1
        base_protection_pts=temp_base_polygon;
        base_protection_pts(:,3)=temp_rx_htm;
    else
        if any(isnan(temp_base_polygon(:,1)))
            nan_idx=find(isnan(temp_base_polygon(:,1)))
            num_nan=length(nan_idx)+1
            num_base_pts=size(temp_base_polygon)
            cell_base_pppts=cell(num_nan,1);
            for j=1:1:num_nan
                if j==1
                    temp_seg=temp_base_polygon([1:nan_idx(j)-1],:);
                elseif j==num_nan
                    temp_seg=temp_base_polygon([nan_idx(j-1)+1:end],:);
                else
                    temp_seg=temp_base_polygon([nan_idx(j-1)+1:nan_idx(j)-1],:);
                end
                cell_base_pppts{j}=downsample_geo_line_app(app,temp_seg,sample_spacing_km);
            end
            cell_base_pppts
            base_protection_pts=vertcat(cell_base_pppts{:});
            % % % figure;
            % % % hold on;
            % % % plot(base_protection_pts(:,2),base_protection_pts(:,1),'or')
        else
            base_protection_pts=downsample_geo_line_app(app,temp_base_polygon,sample_spacing_km);
        end
        base_protection_pts(:,3)=temp_rx_htm;
    end
    cell_sim_data{base_idx,col_pp_pts_idx}=base_protection_pts;


    strcat(num2str(base_idx/num_locations*100),'%')
end
toc;



cd(rev_folder)
pause(0.1)
cell_sim_data(1:2,:)'
'Last save . . .'
tic;
save('cell_sim_data.mat','cell_sim_data')
toc;

cell_ppt_size=cellfun(@size,cell_sim_data(:,col_pp_pts_idx),'UniformOutput',false);
temp_ppt_size=cell2mat(cellfun(@size,cell_sim_data(:,col_pp_pts_idx),'UniformOutput',false));


cell_sim_data'
%sort(temp_ppt_size(:,1))


horzcat(cell_sim_data(:,1),cell_ppt_size)
max(temp_ppt_size(:,1))
cell_sim_data(:,[1,5,6,7,8,14,16,17,21])
size(cell_sim_data)
rev_folder


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Now running the simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tf_server_status=0;
parallel_flag=0%1%0;
[workers,parallel_flag]=check_parallel_toolbox(app,parallel_flag)
workers=2
tf_recalculate=0%1%0%1
tf_rescrap_rev_data=1
tf_print_excel=0%1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Where the magic happens
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
neighborhood_wrapper_rev6_miti_geoplots_pea_custant_excel(app,rev_folder,parallel_flag,tf_server_status,workers,tf_recalculate,tf_rescrap_rev_data,tf_print_excel)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 




end_clock=clock;
total_clock=end_clock-top_start_clock;
total_seconds=total_clock(6)+total_clock(5)*60+total_clock(4)*3600+total_clock(3)*86400;
total_mins=total_seconds/60;
total_hours=total_mins/60;
if total_hours>1
    strcat('Total Hours:',num2str(total_hours))
elseif total_mins>1
    strcat('Total Minutes:',num2str(total_mins))
else
    strcat('Total Seconds:',num2str(total_seconds))
end
cd(folder1)
'Done'









