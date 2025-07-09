function [ ] = BinTh(p1,freq,sr,rep,crit,timeS,ftype1,ftype2)

r=10;

%% Identify files of interest
s1=strcat('*',ftype1,'*',ftype2,'*.txt'); %select the files that have a given sequence in the title
datafiles = dir(s1); 
nfiles = length(datafiles);
fileData=[];

F_count=zeros(nfiles,rep,6); %create file for the results
s2=strcat(ftype1,ftype2,'_Counts.txt');
fid=fopen(s2,'w');
fprintf(fid,'time  pause1  stretch1 release1  stretch2 release2  stretch3 release3  stretch4 release4  stretch5 release5\n'); %write the headers

s3=strcat(ftype1,ftype2,'_Averages.txt');
fid2=fopen(s3,'w');
fprintf(fid2,'time  pause1  stretch1 release1  stretch2 release2  stretch3 release3  stretch4 release4  stretch5 release5\n'); %write the headers



T2=round(1/freq/2*r); %define the half period from frequency
%sr is the number of repeats in one series, rep is the number of series
p1=round(p1*r); %it avoids repeating the calculation each time and allows for pauses shorter than 1 s
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
   fprintf(fid2,'%s ',dhs); 
   
   F_dataI= dlmread(f_name,';',0,2); %Read the sum of firing events until current time.
   F_dataI=F_dataI(:,1); %The instruction above reads a second column with zeros????? Use just the first column.
%   adapt these to read the date and hour also
%   formatSpec = '%C%{dd/MM/yyyy;HH:mm:ss}D%f%f%{MM/dd/yyyy HH:mm}D%C'; -
%   F_data= readtable(im_name);  



   F_data=zeros(size(F_dataI)); %Determine the number of firings at each time point
   F_data(2:size(F_data))=F_dataI(1:(size(F_dataI)-1));
   F_data=F_dataI-F_data;

   
   
   %It takes at least a second to start the sequence after starting the
   %count. That second should give us a baseline and the start shoud be
   %when firing is at least "crit times"  higher.
   F_data_temp=F_data; %define a copy of the datafrom which the previously analized information is deleted. It might be useful to have at a later point the original data although currently not used.
   st_t=zeros(rep,1);
  
  
   j=1;

   while j<=rep
     if isempty(find(F_data_temp>(crit*(F_dataI(p1)/p1+0.1)),1)); %To avoid crashing if it doesn't find any. +0.1 in case the background is zero
       break
     end 
     
st_t(j)=find(F_data_temp>(crit*(F_dataI(p1)/p1+0.1)),1);  % +0.1 in case the background is zero. Beware, might lead identifying the start with a delay. 

  if (st_t(j)-1+2*sr*T2)>size(F_dataI); % To avoid crashing if it attempts to search beyond the end
        break
  end
  

     if st_t(1)<=(p1+1)      %To avoid crashing if it assumes it started too early. 
        j1=1;
        while st_t(1)<=(p1+1) 
            j1=j1+1; 
            st_t(1)=max(find(F_data_temp>(crit*(F_dataI(p1)/p1+0.1)/r),j1));    
        end     
     end    
     

  if (sum(F_data_temp(st_t(j):(st_t(j)+round(T2/timeS))))/round(T2/timeS))>=F_data_temp(st_t(j)) %The firing should be sustained at least for the next fraction of period.

      
                    
                    F_count(i,j,1)=F_dataI(st_t(j)-1)-F_dataI(st_t(j)-1-p1); % background or pause 1 phase
                    for k=1:sr
                    F_count(i,j,2*k)=F_dataI(st_t(j)-1+T2*(2*k-1))-F_dataI(st_t(j)-1+T2*(2*k-2)); % stretch k
                    F_count(i,j,2*k+1)=F_dataI(st_t(j)-1+2*k*T2)-F_dataI(st_t(j)-1+T2*(2*k-1)); % release k
                    end %end for k
       
       fprintf(fid,'%d ',st_t(j)); %write the start of the protocol
       fprintf(fid,' %d  %d %d  %d %d  %d %d  %d %d  %d %d \n',F_count(i,j,:)); %write the data for each timepoint. Make sure that the number of %d equals 2*sr+1 
          
   % (sr*T2*2)
      F_data_temp(1:(st_t(j)+(sr*T2*2)))=0; %Clean the recording up to that point and start the search again for the next repeat.
      j=j+1; 

  else
      F_data_temp(1:st_t(j))=0; % If the firing was not sustained then most likely it was spontaneus. Delete that part and search again. Might give errors about the p1 phase.
   end  %end if   
   end  %end while 
   
   
   st_plot=20*ones(rep,1);
   figure;
   plot(F_data*r);
   title(f_name);
   hold on;
   scatter(st_t,st_plot,300,'r','fill');
   hold on;
   scatter(st_t+T2,st_plot,300,'g','fill') ; % release k 
   
   
   for k=2:sr
   hold on;
   scatter(st_t+T2*(2*k-2),st_plot,300,'b','fill') ; % stretch k   
   hold on;
   scatter(st_t+T2*(2*k-1),st_plot,300,'g','fill') ; % release k                  
   end %end for k
%    figure;

fprintf(fid,'%s \n',' '); 

fprintf(fid2,' %f  %f %f  %f %f  %f %f  %f %f  %f %f \n',mean(F_count(i,1:rep,:),2)); %write the averages for each file

   end %end for  - number of files

fclose(fid);
fclose(fid2);

end

