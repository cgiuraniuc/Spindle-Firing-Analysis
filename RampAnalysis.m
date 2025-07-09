function [ ] = RampAnalysis(p1,st,h1,h2,rel,p2,rep,crit,timeS,ftype1,ftype2)

% Author: Claudiu Giuraniuc, University of Aberdeen
% Contact: v.c.giuraniuc@abdn.ac.uk

r=10;

%% Identify files of interest
s1=strcat('*',ftype1,'*',ftype2,'*.txt'); %select the files that have a given sequence in the title
datafiles = dir(s1); 
nfiles = length(datafiles);
fileData=[];
p1_part=round(p1*0.5*r); %we take just half of the first pause as the background - 1s BEWARE, the rate is already included
p2_part=round(p2*0.25); %we take just one quart of the second pause  - 1s

F_count=zeros(nfiles,rep,6); %create file for the results
F_countB=zeros(nfiles,rep,6); %create file for the results - background
s2=strcat(ftype1,ftype2,'_CountsB.txt');
fid=fopen(s2,'w');
fprintf(fid,'time pause1 stretch hold1 hold2 release pause2  pause1_B stretch_B hold1_B hold2_B release_B pause2_B\n'); %write the headers

s3=strcat(ftype1,ftype2,'_Averages.txt');
fid2=fopen(s3,'w');
fprintf(fid2,'time pause1 stretch hold1 hold2 release pause2  pause1_B stretch_B hold1_B hold2_B release_B pause2_B\n'); %write the headers

%% Analyze individual files
   for i=1:nfiles
       
       
   f_name = datafiles(i).name; %get file name and write it in the result file
   fprintf(fid,'%s\n',f_name);
   disp(f_name)
   
   
   fid_i=fopen(f_name);
   dh=textscan(fid_i,'%s',1);
   fclose(fid_i);
   dhs=dh{1}{1};
   
   dhs=dhs(1:19); %record the date and hour, write to file
   fprintf(fid,'%s\n',dhs); 
   fprintf(fid2,'%s',dhs); 
   
   F_dataI= dlmread(f_name,';',0,2); %Read the sum of firing events until current time.
   F_dataI=F_dataI(:,1); %The instruction above reads a second column with zeros????? Use just the first column.
%   adapt these to read the date and hour also
%   formatSpec = '%C%{dd/MM/yyyy;HH:mm:ss}D%f%f%{MM/dd/yyyy HH:mm}D%C'; -
%   F_data= readtable(im_name);  



   F_data=zeros(size(F_dataI)); %determine the number of firings at each time point
   F_data(2:size(F_data))=F_dataI(1:(size(F_dataI)-1));
   F_data=F_dataI-F_data;

   
   %It takes at least a second to start the sequence after starting the
   %count. That second should give us a baseline and the start shoud be
   %when firing is at least "crit times"  higher.
   F_data_temp=F_data; %define a copy of the datafrom which the previously analized information is deleted. It might be useful to have at a later point the original data although currently not used.
   st_t=zeros(rep,1);
  
   j=1;
   while j<=rep
   
   if isempty(find(F_data_temp>(crit*(F_dataI(r)/r+0.1)),1)); % +0.1 in case the background is zero
        break
   end       

   st_t(j)=find(F_data_temp>(crit*(F_dataI(r)/r+0.1)),1);  % +0.1 in case the background is zero
  

  if (st_t(j)+(st+h1+h2+rel+p2_part)*r-1)>size(F_dataI); % To avoid crashing if it attempts to search beyond the end
      break
  end    
  
  if (sum(F_data_temp(st_t(j):(st_t(j)+round(r/timeS)))))*timeS/r>=F_data_temp(st_t(j)) %The firing should be sustained at least for the r/timeS interval.

      
                    %Extraction of data 
                    F_count(i,j,1)=(F_dataI(st_t(j)-1)-F_dataI(st_t(j)-1-p1_part))*r/p1_part; % background or pause 1 phase - just the last half of it
                    F_count(i,j,2)=(F_dataI(st_t(j)+st*r-1)-F_dataI(st_t(j)-1))/st; % stretch
                    F_count(i,j,3)=(F_dataI(st_t(j)+(st+h1)*r-1)-F_dataI(st_t(j)-1+st*r))/h1; % hold 1
                    F_count(i,j,4)=(F_dataI(st_t(j)+(st+h1+h2)*r-1)-F_dataI(st_t(j)-1+(st+h1)*r))/h2; %hold 2
                    F_count(i,j,5)=(F_dataI(st_t(j)+(st+h1+h2+rel)*r-1)-F_dataI(st_t(j)-1+(st+h1+h2)*r))/rel; %release
                    F_count(i,j,6)=(F_dataI(st_t(j)+(st+h1+h2+rel+p2_part)*r-1)-F_dataI(st_t(j)-1+(st+h1+h2+rel)*r))*r/p2_part; %pause 2 - just the first quarter
       
          
    
      F_data_temp(1:(st_t(j)+(st+h1+h2+rel+p2)*r))=0; %Clean the recording up to that point and start the search again for the next repeat.
      j=j+1;

  else
      F_data_temp(1:st_t(j))=0; % If the firing was not sustained then most likely it was spontaneus. Delete that part and search again. Might give errors about the p1 phase.
   end  %end if   
   end  %end while 
   
F_countB(i,:,:)=F_count(i,:,:)-F_count(i,2,1);  %calculate the data for each timepoint - background - the pause before the second repeat

   st_plot=20*ones(rep,1);
   figure;
   plot(F_data*10);
   title(f_name) 
   hold on;
   scatter(st_t,st_plot,200,'r','fill');
%    figure;

for j=1:rep
fprintf(fid,'%f ',st_t(j)); %write the start of the protocol
fprintf(fid,'%f %f %f %f %f %f ',F_count(i,j,:)); %write the data for each timepoint
fprintf(fid,' %f %f %f %f %f %f \n',F_countB(i,j,:)); %write the data for each timepoint - background - the pause before the second repeat
end %end for writing part

fprintf(fid,'%s \n',' '); 

fprintf(fid2,' %f %f %f %f %f %f ',mean(F_count(i,2:rep,:),2)); %write the averages for each file
fprintf(fid2,' %f %f %f %f %f %f \n',mean(F_countB(i,2:rep,:),2)); %write the averages for each file - background - the pause before the second repeat
%fprintf(fid2,'%s \n',' '); 

   end %end for - number of files

fprintf(fid,'%f %f %f %f %f %f %f %f %f %f %f\n',p1,st,h1,h2,rel,p2,rep,crit,timeS,(p1_part/r),p2_part); %write the parameters   
fclose(fid);
fclose(fid2);

end
