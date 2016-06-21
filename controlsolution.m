% Author Will
% Build time 20160128
% 說明：文字檔分析工具，畫出原始的分析區域RGB值，Normalize後的RGB值，齊頭之後的Normalize RGB值
%
% v1.0.0    a. 分析APP文字檔
%           b. 如果是工程版就是雙色卡實驗的分析，如果是量測版(M_T3V5_T)
%           c. 量測版資料分析：畫出原始的分析區域RGB值，Normalize後的RGB值，齊頭之後的Normalize
%           RGB值，每條曲線都會附上APP計算出來的血糖值作為標簽
%           d. 增加samsung S6的判斷
% v1.1.0    edit 20160325
%           a. 新增Offset補償演算法
%           b. 新增單色多色卡驗證用程式
%           c. 新增雙紅卡多色卡驗證用程式
% v1.2.0    edit 20160328
%           a. 新增三色卡Offset補償分析程式

%close all;
%clear all;
%clc;

bImageAnalysis = 0;
bPlot = 1;
bCalOffset = 0;
bOffsetVerify = 0; % 單色多色卡驗證
bTwoRedCardOffsetVerify = 0; %雙紅卡多色卡驗證
bTriColorOffset = 0; % 三色卡Offset補償驗證
lightleak = 1; % 漏光Offset

MultiCardNo = 4;
Phone = 'iphone';


Folder = uigetdir;
disp(Folder);

save4ori = [];
save4modify = [];


% List = dir([ Folder  '\' (outsource{t}) ]);

List = dir([Folder '/Eng*']);
NoAnalysisCount = 0;
AnalysisCount = 0;
if size(List,1)==0
    
%      List = dir([Folder '\M_T3V5*' ]);
     List = dir([Folder '\M_T3V5*' ]);
  
%    List = dir([Folder '/Pixo*']);
    
    if size(List,1)==0
        List = dir([Folder '/Tag*']);
        if size(List,1) == 0;
            disp('No Data!!');
        else
            APP = 'Eng';
            Phone = 'Samsung';
        end
    else
        APP = 'M_T3V5';
    end
else
    APP = 'Eng';
end

SP1 = ceil(length(List)/20);


%for j=1:5 
%cards ={'R75', 'R100', 'R150', 'R175', 'R200' };
%cards{j};
%end

switch(APP)%% 判斷工程版或量測版
    case 'Eng'
        for ii = 1:length(List)
            switch(Phone)
                case 'iphone'
                    
                    txt_list = dir([ Folder  '/' List(ii).name '/*.txt']);
                case 'Samsung'
                    txt_list = dir([ Folder '/' List(ii).name '/Tag*.txt']);
            end
            if bImageAnalysis
                img_list = dir([ Folder '/' List(ii).name '/*.tiff']);
                for jj = 1:20
                    img = imread([ Folder  '/' List(ii).name '/' img_list(jj).name]);
                    disp(img_list(jj).name);
                    imgga = (double(img)/255).^2.2*255;
                    X = 540;
                    YC = 520;
                    YD = 170;
                    XE = 200;
                    YE = 140;
                    CC(ii,jj) = mean(mean(imgga(YC-20:YC+20,X-20:X+20,1)));
                    DD(ii,jj) = mean(mean(imgga(YD-20:YD+20,X-20:X+20,1)));
                    EE(ii,jj) = mean(mean(imgga(YE-20:YE+20,XE-20:XE+20,1)));
                    SD_CC(ii,1) = std(reshape(CC,[],1));
                    SD_DD(ii,1) = std(reshape(DD,[],1));
                end
                figure(99);
                subplot(2,1,1);plot(CC(ii,:),'o-');
                subplot(2,1,2);plot(DD(ii,:),'o-');
                
            end
            disp(sprintf('Processing  = %d / %d ... %s', ii , length(List),List(ii).name));

            txt = importdata([ Folder  '/' List(ii).name '/' txt_list(1).name]);
            AA=txt.data;
            AA = AA(:,1:30);
%             size(AA)
            
            %評估不同資料量(10pt,20pt,30pt)造成的Normalize誤差
            AAA=txt.data;
            AAA_Nor(ii,:)=[ mean(AAA(4,1:30))/mean(AAA(1,1:30))*1000, mean(AAA(4,1:20))/mean(AAA(1,1:20))*1000, mean(AAA(4,1:10))/mean(AAA(1,1:10))*1000];
           

            %             DATA_Anova_Z1(:,ii)=AA(1,1:20)';
            %             DATA_Anova_Z2(:,ii)=AA(4,1:20)';
            
            %             figure(101);subplot(8,4,ii);plot(AA(1,:));ylim([205 220]);
            %             figure(102);subplot(8,4,ii);plot(AA(4,:));ylim([35 45]);
            
            %             AAA(ii,:) = [mean(AA(1,:)), std(AA(1,:)), mean(AA(4,:)), std(AA(4,:))];
            %             E1(ii) = std(AA(1,:));
            %             E2(ii) = std(AA(4,:));
            %             AA = (AA/255).^(1/2.2).^1.8*255;
            Data(:,ii) = mean(AA,2);
            if ii == 1
                Data_all = zeros(size(AA,1),size(AA,2),length(List));
            end
            Data_all(:,1:length(AA),ii) = AA;
            
            % 畫出每次的信號分佈圖
%             if rem(ii,2) ~= 0
%             figure(11);subplot(SP1,10,ceil(ii/2));plot(AA(1,:),'-');xlim([0 ceil(size(AA,2)/10)*10]);title(sprintf('%d',ceil(ii/2)));
%             figure(12);subplot(SP1,10,ceil(ii/2));plot(AA(4,:),'-');xlim([0 ceil(size(AA,2)/10)*10]);title(sprintf('%d',ceil(ii/2)));
%             else
%             figure(13);subplot(SP1,10,ii/2);plot(AA(1,:),'-');xlim([0 ceil(size(AA,2)/10)*10]);title(sprintf('%d',(ii/2)));
%             figure(14);subplot(SP1,10,ii/2);plot(AA(4,:),'-');xlim([0 ceil(size(AA,2)/10)*10]);title(sprintf('%d',(ii/2)));
%             end
%             
            
        end
        
        
        if strcmp(Phone,'Samsung')
            Data_temp = Data(1:3,:);
            Data(1:3,:) = Data(4:6,:);
            Data(4:6,:) = Data_temp;
        end
        
        
        Nor = Data(4:6,:)./Data(1:3,:)*1000;
        
        %%
        for jj = 1:9
            if jj<7
                Data_sd(jj,1) = std(Data(jj,:));
                figure(1);subplot(3,3,jj);plot(1:length(List),Data(jj,:),'-x');
            else
                figure(1);subplot(3,3,jj);plot(1:length(List),Nor(jj-6,:),'-x');
            end
            if jj == 1;
                title('NoReact-R');
            elseif jj == 2;
                title('NoReact-G');
            elseif jj == 3;
                title('NoReact-B');
            elseif jj == 4;
                title('React-R');
            elseif jj == 5;
                title('React-G');
            elseif jj == 6;
                title('React-B');
            elseif jj == 7;
                title('Nor-R');
            elseif jj == 8;
                title('Nor-G');
            elseif jj == 9;
                title('Nor-B');
            end
        end
        
        for jj= 1:3
            Nor_sd(jj,1) = std(Nor(jj,:));
        end
        Data_ave = mean(Data,2);
        Data_CV = Data_sd./Data_ave(1:6,:);
        Nor_ave = mean(Nor,2);
        Nor_CV = Nor_sd./Nor_ave;
        
        Excel = [Data_ave; Data_sd; Data_CV; Nor_ave; Nor_sd; Nor_CV];
        
    case 'M_T3V5'
        Data = zeros(3,1:3001,length(List));
        ii = 0;
        for cc = 1:length(List)
            txt_list = dir([ Folder '/' List(cc).name '/iX*.txt']);
            if isempty(txt_list)% 判斷是否為空資料夾
                disp('No Txt');
                NoAnalysisCount = NoAnalysisCount + 1;
            else% 判斷是否為空資料夾
                
                txt = ([ Folder  '/' List(cc).name '/' txt_list(1).name]);
                disp(txt);
                fid = fopen(txt);
                TxtCell = textscan(fid,'%s','BufSize',50000);
                
                Level =0;
                Count =1;
                Flag_Error = 0;
                
                
                for mm=1:length(TxtCell{1,1})
                    TxtContent = TxtCell{1,1}{mm,1};
                    if strncmpi(TxtContent,'Glucose:',8)
                        BG_value=str2num(TxtContent(9:end));
                        % ======backup
                        if isempty(BG_value)% 判斷是否為APP_Error
                            Flag_Error = 1;
                            disp('APP_Error');
                            NoAnalysisCount = NoAnalysisCount + 1;
                        else% 判斷是否為APP_Error
                            ii = ii + 1;
                            BG_List(ii) = BG_value;
                            AnalysisCount = AnalysisCount + 1;
                        end% 判斷是否為APP_Error
                        % =======backup
                        % %========3min
                        % %                         if isempty(BG_value)% 判斷是否為APP_Error
                        % %                             Flag_Error = 1;
                        % %                             disp('APP_Error');
                        % %                             NoAnalysisCount = NoAnalysisCount + 1;
                        % %                         else% 判斷是否為APP_Error
                        %                             ii = ii + 1;
                        %                             BG_List(ii) = 0;
                        %                             AnalysisCount = AnalysisCount + 1;
                        % %                         end% 判斷是否為APP_Error
                        % %========3min
                    end
                    
                end
                if Flag_Error == 0% 判斷是否為APP_Error
                    for nn = 1:length(TxtCell{1,1})
                        
                        TxtContent = TxtCell{1,1}{nn,1};
                        if strcmp(TxtContent,'value:')
                            Level = Level +1;
                            Count=1;
                        end
                        if strcmp(TxtContent,'FPS:')
                            break;
                        end
                        TxtNum=str2num(TxtContent);
                        
                        if ~isempty(TxtNum)
                            switch(Level)
                                case 1
                                    Avalue_txt(Count,1) = TxtNum;% Reaction
                                case 2
                                    Bvalue_txt(Count,1) = TxtNum;% Reaction
                                case 3
                                    Cvalue_txt(Count,1) = TxtNum;% Reaction
                            end
                            Count=Count+1;
                        end
                    end
                    Data(1:length(Avalue_txt),1,ii) = Avalue_txt;
                    Data(1:length(Avalue_txt),2,ii) = Bvalue_txt;
                    Data(1:length(Avalue_txt),3,ii) = Cvalue_txt(1:length(Avalue_txt));
                    clear Avalue_txt Bvalue_txt Cvalue_txt
                    
                    
                    
                end % 判斷是否為APP_Error
                fclose(fid);
                
                %             Data(1,ii) = mean(Avalue_txt(1:20));
                %             Data(2,ii) = mean(Bvalue_txt(1:20));
                %             Data(3,ii) = mean(Cvalue_txt(1:20));
                %             Data(4,ii) = std(Avalue_txt(1:20));
                %             Data(5,ii) = std(Bvalue_txt(1:20));
                %             Data(6,ii) = std(Cvalue_txt(1:20));
                
                %             Data(4,ii) = std(Avalue_txt(1:20));
                %             Data(5,ii) = std(Bvalue_txt(1:20));
                %             Data(6,ii) = std(Cvalue_txt(1:20));
                
            end % 判斷是否為空資料夾
            
        end
        disp(sprintf( 'Total Folder = %d', length(List)));
        disp(sprintf( 'Analysis Number = %d', AnalysisCount));
        disp(sprintf( 'Not Analysis Number = %d', NoAnalysisCount));
        
        
        %         Data(:,ii) = mean(AA,2);
        %     figure(100),subplot(1,2,1);plot(1:length(AA),AA(1,:),'x');
        %     figure(100);subplot(1,2,2);plot(1:length(AA),AA(4,:),'x');
        %     pause(0.5);
        
        Ori_R = squeeze(Data(:,1,:));
        Ini_R = mean(Ori_R(1:10,:),1);
%         Ini_R = mean(Ori_R(1,:),1);
        Ini_R_mat = repmat(Ini_R,size(Ori_R,1),1);
        Nor_R = (Ori_R ./Ini_R_mat) *1000;
        Nor_R_align = zeros(size(Nor_R));
        
        Ori_G = squeeze(Data(:,2,:));
        %Ini_G = mean(Ori_G(1:10,:),1);
        Ini_G = mean(Ori_G(1,:),1);
        Ini_G_mat = repmat(Ini_G,size(Ori_G,1),1);
        Nor_G = Ori_G ./Ini_G_mat *1000;
        Nor_G_align = zeros(size(Nor_G));
        
        Ori_B = squeeze(Data(:,3,:));
        %Ini_B = mean(Ori_B(1:10,:),1);
        Ini_B = mean(Ori_B(1,:),1);
        Ini_B_mat = repmat(Ini_B,size(Ori_B,1),1);
        Nor_B = Ori_B ./Ini_B_mat *1000;
        Nor_B_align = zeros(size(Nor_B));
        
        clear idx;
        for qq = 1:size(Ori_R,2)
            idx_temp = find(Nor_R(30:end,qq)<800);
            if isempty(idx_temp)
                break;
            end
            idx(qq) = idx_temp(1)+29;
            Nor_R_align(1:length(Nor_R(:,qq))-idx(qq)+1,qq) = Nor_R(idx(qq):end,qq);
            Nor_G_align(1:length(Nor_G(:,qq))-idx(qq)+1,qq) = Nor_G(idx(qq):end,qq);
            Nor_B_align(1:length(Nor_B(:,qq))-idx(qq)+1,qq) = Nor_B(idx(qq):end,qq);
            
            %             if bPlot
            %             figure(1);plot(Nor_R_align(:,qq),'r-','DisplayName',num2str(BG_List(qq)));hold on;
            %             xlim([1 320]);
            %             figure(2);plot(Nor_G_align(:,qq),'g-','DisplayName',num2str(BG_List(qq)));hold on;
            %             xlim([1 320]);
            %             figure(3);plot(Nor_B_align(:,qq),'b-','DisplayName',num2str(BG_List(qq)));hold on;
            %             xlim([1 320]);
            %             end
            
           legt = length (Ori_R(idx(qq):idx(qq)+200)) 
          
          Rr (1:legt,qq) = Ori_R(idx(qq):idx(qq)+200,qq)
         
            
        end
            %         figure(1);plot(Nor_R_align(1:qq),'-','DisplayName', BG_List); hold on;
            
            
        
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
 %%%%%%%%%%                    %%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
 %%%%%%%%%%   漏光補償演算法    %%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
 %%%%%%%%%%                   %%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 %%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
 %%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 %%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
 %%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      

 
 
       
%         figure(101);plot(forplot,'r-');
        figure(101);plot(Rr,'b-');
        title('Iphone 5se #2 high','Fontsize',12)
        xlabel('0.1sec','Fontsize',12);
        ylabel(' signal','Fontsize',12);
        hold on
        
       
%          pause
%         figure(102);plot(Ori_G,'g-');
%         figure(103);plot(Ori_B,'b-');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                 %%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                 %%%%%%   高斯濾波   %%%%%
                                                                                                 %%%%%%%%%%%%%%%%%%%%%%%%
      filter = fspecial('ga',[1 3],3);                                                         
     %filter = ones(1,3)/5
     
     
     Before_screen = (mean (Ori_R(1:10,:)))';                                                   %反應前
     Before_black = ( mean (Ori_R(12:25,:)))';                                                  %反應前螢幕關掉
     
      
                    

         for i=1:size(Ori_R,2)

                After_s(i) = mean (Ori_R( idx(i)+50: idx(i)+70,i));                                 %反應後
                After_b(i) = mean (Ori_R( idx(i)+72: idx(i)+83,i));                                 %反應後螢幕關掉

%                After_b_long(i) = mean (Ori_R( idx(i)+85: idx(i)+135,i));


                x = (idx(i)+75: idx(i)+85)'       
                y = (Ori_R( idx(i)+75: idx(i)+85,i));



                Xx = (idx(i)+50: idx(i)+70)' ;
                Yy = (Ori_R( idx(i)+50: idx(i)+70,i));




                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                x_for_compare1 = (idx(i)+72: idx(i)+77)' ;
                y_for_compare1 = (Ori_R( idx(i)+72: idx(i)+77,i));
                x_for_compare2 = (idx(i)+78: idx(i)+83)' ;
                y_for_compare2 = (Ori_R( idx(i)+78: idx(i)+83,i));
                x1_mean(i) = mean( x_for_compare1);
                x2_mean(i)  = mean( x_for_compare2);
                y1_mean(i)  = mean( y_for_compare1);
                y2_mean(i) = mean( y_for_compare2);


                x_for_compare5_6 = (idx(i)+50: idx(i)+60)' ;
                y_for_compare5_6 = (Ori_R( idx(i)+50: idx(i)+60,i));
                x_for_compare6_7 = (idx(i)+60: idx(i)+70)' ;
                y_for_compare6_7 = (Ori_R( idx(i)+60: idx(i)+70,i));
                x_5_6mean(i) = mean( x_for_compare5_6)';
                x_6_7mean(i)  = mean( x_for_compare6_7);
                y_5_6mean(i)  = mean( y_for_compare5_6)';
                y_6_7mean(i) = mean( y_for_compare6_7);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


                if size(y,1) == 1
                   filter = filter;
                else 
                   filter = filter';
                end
                 % denoise = conv(y,filter,'same')                                                     %%卷積converlution
                   denoise = y;                                                                         %不使用捲積


                if size(x,1) == 1
                    x = x'
                end

                if size(denoise,1) == 1
                   denoise = denoise'
                end
                ddnoise = denoise(2:11);                                                             %取第2~第11 的frame
                xx = x(2:11);

%                 figure(99);plot(x,y,'bo-',x,denoise,'rx-');
%                 pause;



          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
                                                                                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                    %%%%   不用高斯算斜率區   %%%
                                                                                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          ddd = ddnoise(1:find(ddnoise == min(ddnoise))) ;
          xxx = xx(1:find(ddnoise == min(ddnoise)));
          max_dnoise = max(ddd) ;
          min_dnoise = min(ddd);                                                                   
          max_temp = find(ddd == max(ddd));
          min_temp = find(ddd == min(ddd));
          xxx_with_max_dnoise = xxx(max_temp);
          xxx_with_min_dnoise = xxx(min_temp);

         fit  = polyfit([xxx_with_min_dnoise xxx_with_max_dnoise]' ,[min_dnoise max_dnoise]',1);    %把做curve fitting

         fit_prediction = polyval(fit,idx(i)+50: idx(i)+70) ;                                       %用curve  算出來的最大最小值求出斜率來估算5~7s的數值
         fit_mean = mean(fit_prediction)';
         ffit_mean(i) = fit_mean;


         fit_curve(i,:) =fit;                                                                        % 只是要看比值然後另存到矩陣裡
         look_ratio_for_fit_curve(i,1)  = fit_curve(i,1);                                            % 只是要看比值然後另存到矩陣裡  


          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
                                                                                                     %%%%%%%%%%%%%%%%%%%%%%%
                                                                                                     %%%  用高斯算平均區  %%%
                                                                                                     %%%%%%%%%%%%%%%%%%%%%%%

    %      fit  = polyfit([x]' ,[denoise]',1);                                                         %把做curve fitting
    %      fit(1,1) = fit(1,1)/2.5 
    %     
    %      
%          fit_prediction = polyval(fit,idx(i)+50: idx(i)+70) ;                                        %用curve  算出來的最大最小值求出斜率來估算5~7s的數值
%          fit_mean (i)= mean(fit_prediction);
%          ffit_mean = (fit_mean);
    % 
    %      




         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                    %%%%%%%% 7.5-8.5slpoe:  此區有計算5~7秒斜率, 7~8秒斜率 %%%%%%
                                                                                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%          fit_7_8sec(i,:) = polyfit([ x1_mean(i)    x2_mean(i)  ]'   ,[   y1_mean(i)     y2_mean(i) ]',1)
%          fit_5_7sec(i,:) = polyfit([ x_5_6mean(i)  x_6_7mean(i)  ]' ,[   y_5_6mean(i)   y_6_7mean(i) ]',1); % 看原本5~7秒時的斜率  
% 
% 
%          look_ratio_for_5_7sec =fit_5_7sec(i,1);                                                     % 看原本5~7秒時的斜率  
%          fit_7_8sec(i) = fit_7_8sec(i,1)/1.5;                                                       % 7.5-8.5slpoe: /倍數 (不看時註解掉)



%          carson_prediction = polyval(fit_7_8sec(i,:),idx(i)+50: idx(i)+70) ;                          % 用carson算出來的斜率來估算
%          carson_fit_mean (i)= mean( carson_prediction)';
%          carson_ffit_mean =  carson_fit_mean;
%                
         
                                                                                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                    %%%%      Exponential   %%%
                                                                                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                                                                                                            

     
%                   idd = idx'
                                                                                                                                                                             
                 if   (Before_black(i) >3)       
                    %  [fitresult, gof] = createFit([idd(i);x], [Before_black(i);denoise]);
                      [fitresult, gof] = createFit(x, denoise);
                       expo_50_70 =fitresult(Xx)
                       mean_expo_50_70(i) = ((mean(expo_50_70))+1)
                       %mean_expo_50_70 = (mean_expo_50_70)'
                else
                       mean_expo_50_70(i) = After_b(i)
                 end

                    mean_expo_50_70 = (mean_expo_50_70)'
                    
              pause  
                 
  
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


         end



         fit_dark =  (ffit_mean)'
%          carson_fit_dark =  (carson_ffit_mean)'
         After_screen = (After_s)';
         
         
         
         
         After_black = (After_b)';
%          if   (Before_black >3)  
%             After_black = (After_b+2)';                                                                % for +2 替換用
%          else
%             After_black = (After_b)'
%          end
%          After_black_long = (After_b_long)';



         ori = ((After_screen)./ (Before_screen )*1000);
         modify = ((After_screen -  After_black)./ (Before_screen - Before_black)*1000);
         modify_fit_dark = ((After_screen - fit_dark)./ (Before_screen - Before_black)*1000);
%          carson_modify_fit_dark = ((After_screen - carson_fit_dark)./ (Before_screen - Before_black)*1000);

         exponental_fit_dark =  ((After_screen -  mean_expo_50_70)./ (Before_screen - Before_black)*1000);
%        modify_long = ((After_screen -  After_black_long)./ (Before_screen - Before_black)*1000); 
         
         
         
         
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
                                                                                                    %%%%%%%%%%%%%%%%%
                                                                                                    %%% 計算血糖區 %%%
                                                                                                    %%%%%%%%%%%%%%%%%

        temp_all_i_want_show =        [Before_screen,     Before_black,     After_screen,     After_black,       look_ratio_for_fit_curve,       ori ,    modify];
%         temp_polyfit_to_show =        [Before_screen,     Before_black,     After_screen,     fit_dark,          look_ratio_for_fit_curve,       ori ,    modify_fit_dark];
%         temp_carson_polyfit_to_show = [Before_screen,     Before_black,     After_screen,     carson_fit_dark,   look_ratio_for_fit_curve,       ori ,    carson_modify_fit_dark];                                                                                           

        temp_exponental_fit_dark =    [Before_screen,     Before_black,     After_screen,     mean_expo_50_70,   look_ratio_for_fit_curve,       ori ,    exponental_fit_dark];
 %       temp_long_want_show =         [Before_screen,     Before_black,     After_screen,      After_black_long, look_ratio_for_fit_curve,       ori ,    modify_long];





        AA = temp_all_i_want_show(:, 6:7);
        BG= Signal2BG(1000-AA, 'ML_i6S_Terumo_16E11_5s_R.txt'); 
%         BB= temp_polyfit_to_show(:, 6:7);
%         BG_polyfit= Signal2BG(1000-BB, 'ML_i6S_Terumo_gamma_5s_R.txt');
%         CC = temp_carson_polyfit_to_show(:, 6:7);
%         BG_carson= Signal2BG(1000-CC, 'ML_i6S_Terumo_gamma_5s_R.txt'); 

        DD = temp_exponental_fit_dark(:, 6:7);
        BG_exponental= Signal2BG(1000-DD, 'ML_i6S_Terumo_16E11_5s_R.txt'); 
%        EE =  temp_long_want_show(:, 6:7);
%        BG_long= Signal2BG(1000-EE, 'ML_i6S_Terumo_gamma_5s_R.txt');


       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        all_i_want_show =     [Before_screen,     Before_black,     After_screen,        After_black,       look_ratio_for_fit_curve,    ori ,      modify,                      BG     ]        
%        use_polyfit_to_show = [Before_screen,     Before_black,     After_screen,        fit_dark,          look_ratio_for_fit_curve,    ori ,      modify_fit_dark,             BG_polyfit  ]    % 有無高斯都看這個
%        carson_polyfit_to_show = [Before_screen,     Before_black,     After_screen,     carson_fit_dark,   look_ratio_for_fit_curve,    ori ,      carson_modify_fit_dark,      BG_carson  ]     % carson說的7.5~8.5推法看這個

   
                    
        exponental_fit_to_show = [Before_screen,     Before_black,   After_screen,    mean_expo_50_70,      look_ratio_for_fit_curve,    ori ,      exponental_fit_dark,         BG_exponental  ] 
 %       long_want_show =      [Before_screen,     Before_black,     After_screen,        After_black_long,  look_ratio_for_fit_curve,    ori ,      modify_long,                 BG_long     ] 

 
       
       
    end %% 判斷工程版或量測版


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 
%%
% Signal_R5s = [1000-mean(Nor_R_align(61:80,:),1)]';
% Signal_R8s = [1000-mean(Nor_R_align(91:110,:),1)]';
% Signal_R20s = [1000-mean(Nor_R_align(211:230,:),1)]';
% Signal_G20s = [1000-mean(Nor_G_align(211:230,:),1)]';
%
% load ML_i5S_Terumo_16A20_20s_R.txt
% load ML_i5S_Terumo_16B23_5s_R.txt
%
% for ii = 1:length(Signal_R20s)
%     [mm, IDX5s(ii,1) ]=min(abs(Signal_R5s(ii)-ML_i5S_Terumo_16B23_5s_R));
%     [mm, IDX8s(ii,1) ]=min(abs(Signal_R8s(ii)-ML_i5S_Terumo_16A20_20s_R));
%     [mm, IDX20s(ii,1) ]=min(abs(Signal_R20s(ii)-ML_i5S_Terumo_16A20_20s_R));
%
% end
% BG_Matlab = IDX20s-1;
% BG_Matlab_5s = IDX5s-1;
%
% Data_size = length(BG_List);
% ExcleForTC = [BG_List' BG_Matlab(1:Data_size) Signal_R5s(1:Data_size) Signal_R8s(1:Data_size) Signal_R20s(1:Data_size)];
% disp('Done!!');
%
%



%%
% for qq=1:size(Ori_R,2)
%     %             figure(21);plot(Nor_R_align(11:end,qq),'r-','DisplayName',num2str(BG_List(qq)));hold on;
%     %             xlim([1 320]);
%     %             figure(22);plot(Nor_G_align(11:end,qq),'g-','DisplayName',num2str(BG_List(qq)));hold on;
%     %             xlim([1 320]);
%     %             figure(23);plot(Nor_B_align(11:end,qq),'b-','DisplayName',num2str(BG_List(qq)));hold on;
%     %             xlim([1 320]);
%     if bPlot
%         figure(1);plot(Nor_R_align(:,qq),'r-','DisplayName',num2str(BG_Matlab(qq)));hold on;
%         xlim([1 320]);
%         figure(2);plot(Nor_G_align(:,qq),'g-','DisplayName',num2str(BG_Matlab(qq)));hold on;
%         xlim([1 320]);
%         figure(3);plot(Nor_B_align(:,qq),'b-','DisplayName',num2str(BG_Matlab(qq)));hold on;
%         xlim([1 320]);
%     end
% end

%% Offset補償演算法 calculate Slope and Intercept
if bCalOffset
M_zone2 = mean(Data(4,1:2:end));
M_zone1 = mean(Data(1,1:2:end));

% MMM= [183.34 64.90 81.83 27.15];
% SDSD=[1.7135 0.7867 0.9852 0.5805];
% MMM=[182.57 64.22 83.69 29.43];
% SDSD=[0.9816 0.6939 0.7971 0.5527];
% 
% for kk=1:30
%     Data(1,kk*2-1)=mean(MMM(1)+SDSD(1).*randn(30,1));
%     Data(4,kk*2-1)=mean(MMM(2)+SDSD(2).*randn(30,1));
%     Data(1,kk*2)=mean(MMM(3)+SDSD(3).*randn(30,1));
%     Data(4,kk*2)=mean(MMM(4)+SDSD(4).*randn(30,1));
% end


for ii = 1:2:length(List)
    Ra1 = Data(1,ii);
    Rb1 = Data(4,ii);
    Ra2 = Data(1,ii+1);
    Rb2 = Data(4,ii+1);
    B1 = Ra1-Rb1;
    B2 = Ra2-Rb2;
      Offset((ii+1)/2,1) = -(Ra2-(B2/B1)*Ra1)/(1-B2/B1);
%     Offset((ii+1)/2,1) = (M_zone2-Rb1+M_zone1-Ra1)/2;
    Data_adj(1,(ii+1)/2) = Ra1+Offset((ii+1)/2,1);
    Data_adj(2,(ii+1)/2) = Rb1+Offset((ii+1)/2,1);
    Data_adj(3,(ii+1)/2) = Ra2+Offset((ii+1)/2,1);
    Data_adj(4,(ii+1)/2) = Rb2+Offset((ii+1)/2,1);
    
end
Data_ori = Data([1 4],1:2:end);



Nor_adj = Data_adj(2,:)./Data_adj(1,:)*1000;
Nor_ori = Data(4,1:2:end)./Data(1,1:2:end)*1000;
Data_zone2 = [Data(1,2:2:end); Data(4,2:2:end)];
Nor_zone2 = Data(4,2:2:end)./Data(1,2:2:end)*1000;
figure(2);
subplot(3,3,1);plot(1:length(Data_ori),Data_ori(1,:),'-x');
subplot(3,3,4);plot(1:length(Data_ori),Data_ori(2,:),'-x');
subplot(3,3,7);plot(1:length(Data_ori),Nor_ori,'-x');
subplot(3,3,2);plot(1:length(Data_ori),Data(1,2:2:end),'-x');
subplot(3,3,5);plot(1:length(Data_ori),Data(4,2:2:end),'-x');
subplot(3,3,8);plot(1:length(Data_ori),Nor_zone2,'-x');
subplot(3,3,3);plot(1:length(Data_ori),Data_adj(1,:),'-x');
subplot(3,3,6);plot(1:length(Data_ori),Data_adj(2,:),'-x');
subplot(3,3,9);plot(1:length(Data_ori),Nor_adj,'-x');


Excel_Nor_Adj = [ mean(Nor_ori); std(Nor_ori); std(Nor_ori)/mean(Nor_ori); mean(Nor_adj); std(Nor_adj); std(Nor_adj)/mean(Nor_adj);]

Excel_Data =[Data_ori', Nor_ori', Data_zone2', Nor_zone2', Offset,...
    Data_adj(1:2,:)', (Data_adj(2,:)./Data_adj(1,:)*1000)', Data_adj(3:4,:)', (Data_adj(4,:)./Data_adj(3,:)*1000)'];
end

%% 多色卡驗證Offset補償演算法

if bOffsetVerify
    
    for ii = 1:(MultiCardNo+1):length(List)
        cc = (ii+MultiCardNo)/(MultiCardNo+1);
    Ra1 = Data(1,ii);
    Rb1 = Data(4,ii);
    Ra2 = Data(1,ii+1);
    Rb2 = Data(4,ii+1);
    
    B1 = Ra1-Rb1;
    B2 = Ra2-Rb2;
        Offset(cc,1) = -(Ra2-(B2/B1)*Ra1)/(1-B2/B1);
%     Offset((ii+1)/2,1) = (M_zone2-Rb1+M_zone1-Ra1)/2;
%     Data_adj(1,cc) = Ra1+Offset(cc,1);
%     Data_adj(2,cc) = Rb1+Offset(cc,1);
%     Data_adj(3,cc) = Ra2+Offset(cc,1);
%     Data_adj(4,cc) = Rb2+Offset(cc,1);
    
    Data_ori(cc,:) = [Ra1,Rb1,Data(1,ii+2:ii+MultiCardNo)];
    Data_adj(cc,:) = Data_ori(cc,:) + Offset(cc,1);
    
    end
    Nor_ori = Data_ori./repmat(Data_ori(:,1),1,MultiCardNo+1)*1000;
    Nor_adj = Data_adj./repmat(Data_adj(:,1),1,MultiCardNo+1)*1000;

    
    Excel_Data = [Data_ori, Data_adj, Offset, Nor_ori, Nor_adj];

end

%% 雙紅卡多色卡驗證

if bTwoRedCardOffsetVerify
    
    for ii = 1:(MultiCardNo+1):length(List)
        cc = (ii+MultiCardNo)/(MultiCardNo+1);
    Ra1 = Data(1,ii);
    Rb1 = Data(4,ii);
    Ra2 = Data(1,ii+1);
    Rb2 = Data(4,ii+1);
    
    B1 = Ra1-Rb1;
    B2 = Ra2-Rb2;
        Offset(cc,1) = -(Ra2-(B2/B1)*Ra1)/(1-B2/B1);
%     Offset((ii+1)/2,1) = (M_zone2-Rb1+M_zone1-Ra1)/2;
%     Data_adj(1,cc) = Ra1+Offset(cc,1);
%     Data_adj(2,cc) = Rb1+Offset(cc,1);
%     Data_adj(3,cc) = Ra2+Offset(cc,1);
%     Data_adj(4,cc) = Rb2+Offset(cc,1);
    
    Data_ori(cc,:) = [Ra1,Rb1,Data(4,ii+2:ii+MultiCardNo)];
    Data_adj(cc,:) = Data_ori(cc,:) + Offset(cc,1);
    
    end
    Nor_ori = Data_ori./repmat(Data_ori(:,1),1,MultiCardNo+1)*1000;
    Nor_adj = Data_adj./repmat(Data_adj(:,1),1,MultiCardNo+1)*1000;

    
    Excel_Data = [Data_ori, Data_adj, Offset, Nor_ori, Nor_adj];

end
%% 三色卡Offset分析

if bTriColorOffset

for ii = 1:2:length(List)
    A1L1 = Data(1,ii);
    C1L1 = Data(4,ii);
    E1L1 = Data(7,ii);
    A1L2 = Data(1,ii+1);
    C1L2 = Data(4,ii+1);
    E1L2 = Data(7,ii+1);
    
    B1 = A1L1-C1L1;
    B2 = A1L2-C1L2;
        Offset((ii+1)/2,1) = -(A1L2-(B2/B1)*A1L1)/(1-B2/B1);
%     Offset((ii+1)/2,1) = (M_zone2-Rb1+M_zone1-Ra1)/2;
    Data_adj(1,(ii+1)/2) = A1L1+Offset((ii+1)/2,1);
    Data_adj(2,(ii+1)/2) = C1L1+Offset((ii+1)/2,1);
    Data_adj(3,(ii+1)/2) = E1L1+Offset((ii+1)/2,1);
    Data_adj(4,(ii+1)/2) = A1L2+Offset((ii+1)/2,1);
    Data_adj(5,(ii+1)/2) = C1L2+Offset((ii+1)/2,1);
    Data_adj(6,(ii+1)/2) = E1L2+Offset((ii+1)/2,1);

    
end
Data_L1 = Data([1 4 7],1:2:end);
Data_L2 = Data([1 4 7],2:2:end);

Nor_L1 = [Data(4,1:2:end)./Data(1,1:2:end)*1000 ;Data(7,1:2:end)./Data(1,1:2:end)*1000];
Nor_L2 = [Data(4,2:2:end)./Data(1,2:2:end)*1000 ;Data(7,2:2:end)./Data(1,2:2:end)*1000];


figure(2);title('Offset compensation comparison');
subplot(3,3,1);plot(1:length(Data_L1),Data_L1(1,:),'-x');
subplot(3,3,4);plot(1:length(Data_L1),Data_L1(2,:),'-x');
subplot(3,3,7);plot(1:length(Data_L1),Nor_L1(1,:),'-x');
subplot(3,3,2);plot(1:length(Data_L1),Data(1,2:2:end),'-x');
subplot(3,3,5);plot(1:length(Data_L1),Data(4,2:2:end),'-x');
subplot(3,3,8);plot(1:length(Data_L1),Nor_L2(1,:),'-x');
subplot(3,3,3);plot(1:length(Data_L1),Data_adj(1,:),'-x');
subplot(3,3,6);plot(1:length(Data_L1),Data_adj(2,:),'-x');
subplot(3,3,9);plot(1:length(Data_L1),Data(4,1:2:end)./Data(1,1:2:end)*1000,'-x');


% Excel_Nor_Adj = [ mean(Nor_ori); std(Nor_ori); std(Nor_ori)/mean(Nor_ori); mean(Nor_adj); std(Nor_adj); std(Nor_adj)/mean(Nor_adj);]

Excel_Data =[Data_L1', Nor_L1', Data_L2', Nor_L2', Offset,...
    Data_adj(1:3,:)', (Data_adj(2,:)./Data_adj(1,:)*1000)',(Data_adj(3,:)./Data_adj(1,:)*1000)',...
    Data_adj(4:6,:)', (Data_adj(5,:)./Data_adj(4,:)*1000)',(Data_adj(6,:)./Data_adj(4,:)*1000)'];


Excel_new(5,5) =  mean(Excel_Data(:,21))'

end




%% 漏光Offset分析

% if lightleak
%     
%  Before_screen = mean (Ori_R(1:10,1))
%  Before_black =  mean (Ori_R(12:25,1))
%  After_screen = mean (Ori_R(205:225,1))
%  After_black =  mean (Ori_R(227:236,1)) 
%  
%  modify = (After_screen -  After_black)/ (Before_screen - Before_black)
%     
% end


