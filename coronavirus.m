%% COVID-19 nCOV CORONAVIRUS ANALYSIS
%==========================================================================
clc; close all; clear;
P.home = '/Users/bradleymonk/Documents/MATLAB/GIT/COVID19'; cd(P.home)
P.data = [P.home filesep 'DATA'];
P.funs = [P.home filesep 'FUNS'];
P.imgs = [P.home filesep 'IMGS'];
P.figs = [P.home filesep 'FIGS'];
P.geos = [P.home filesep 'GEOS'];
addpath(join(string(struct2cell(P)),':',1))
clearvars -except P; P.f = filesep;



% Data Sources...
% 
% https://github.com/CSSEGISandData/COVID-19
% https://github.com/nytimes/covid-19-data
% https://bit.ly/UShospitals
% https://bit.ly/PopByZip



%==========================================================================
%% IMPORT DATA
%==========================================================================
clc; clearvars -except P


% DATA IS ONLINE AT:
% https://bit.ly/UShospitals
% https://bit.ly/PopPerZips





% IMPORT U.S. HOSPITAL DATA
%-------------------------------------------------------------
P.hosp = [P.data P.f 'US_HOSPITAL_DATA.xlsx'];
opts   = detectImportOptions(P.hosp,'Sheet','US_Hospital_Beds');
HOSP   = readtable(P.hosp,opts);




% IMPORT U.S. POPULATION DATA
%-------------------------------------------------------------
P.ppz = [P.data P.f 'PopPerZip.csv'];
opts  = detectImportOptions(P.ppz);
POP   = readtable(P.ppz,opts);





% IMPORT U.S. COVID-19 CASES PER COUNTY
%-------------------------------------------------------------
P.ncov = [P.data P.f 'us-counties.csv'];
opts   = detectImportOptions(P.ncov);
NCOV   = readtable(P.ncov,opts);

NCOV.Properties.VariableNames{'date'} = 'DATE';
NCOV.Properties.VariableNames{'county'} = 'COUNTY';
NCOV.Properties.VariableNames{'state'} = 'STATE';
NCOV.Properties.VariableNames{'fips'} = 'FIPS';
NCOV.Properties.VariableNames{'cases'} = 'CASES';
NCOV.Properties.VariableNames{'deaths'} = 'DEATHS';

NCOV.COUNTY = string(NCOV.COUNTY);
NCOV.STATE  = string(NCOV.STATE);

NCOV = sortrows(NCOV,{'FIPS','DATE'});

peektable(NCOV);






% IMPORT U.S. COVID-19 CONFIRMED DEATHS TIME-SERIES DATA
%-------------------------------------------------------------
P.deaths = [P.data P.f 'time_series_covid19_deaths_US.csv'];
opts     = detectImportOptions(P.deaths);
DEATH    = readtable(P.deaths,opts);

DEATH(1,:) = [];

DEATH.Properties.VariableNames{1}  = 'UID';
DEATH.Properties.VariableNames{2}  = 'ISO2';
DEATH.Properties.VariableNames{3}  = 'ISO3';
DEATH.Properties.VariableNames{4}  = 'CODE3';
DEATH.Properties.VariableNames{5}  = 'FIPS';
DEATH.Properties.VariableNames{6}  = 'COUNTY';
DEATH.Properties.VariableNames{7}  = 'STATE';
DEATH.Properties.VariableNames{8}  = 'NATION';
DEATH.Properties.VariableNames{9}  = 'LAT';
DEATH.Properties.VariableNames{10} = 'LON';
DEATH.Properties.VariableNames{11} = 'COMBKEY';
DEATH.Properties.VariableNames{12} = 'POPULATION';


% DEATHS SINCE JANUARY 22ND - TODAY
D = table2array(DEATH(:,13:end));
DEATH(:,13:end) = [];
DEATH.DEATHS = D;

DEATH = sortrows(DEATH,{'FIPS','UID'});

DEATH(1:5,:) = [];

DEATH(DEATH.LAT==0,:) = [];
DEATH(isnan(DEATH.FIPS),:) = [];

peektable(DEATH);







% IMPORT U.S. COVID-19 CONFIRMED CASES TIME-SERIES DATA
%-------------------------------------------------------------
P.cases = [P.data P.f 'time_series_covid19_confirmed_US.csv'];
opts    = detectImportOptions(P.cases);
CASE    = readtable(P.cases,opts);

CASE(1,:) = [];

CASE.Properties.VariableNames{1}  = 'UID';
CASE.Properties.VariableNames{2}  = 'ISO2';
CASE.Properties.VariableNames{3}  = 'ISO3';
CASE.Properties.VariableNames{4}  = 'CODE3';
CASE.Properties.VariableNames{5}  = 'FIPS';
CASE.Properties.VariableNames{6}  = 'COUNTY';
CASE.Properties.VariableNames{7}  = 'STATE';
CASE.Properties.VariableNames{8}  = 'NATION';
CASE.Properties.VariableNames{9}  = 'LAT';
CASE.Properties.VariableNames{10} = 'LON';
CASE.Properties.VariableNames{11} = 'COMBKEY';


% CASES SINCE JANUARY 22ND - TODAY
D = table2array(CASE(:,12:end));
CASE(:,13:end) = [];
CASE.CASES = D;

CASE = sortrows(CASE,{'FIPS','UID'});

CASE(1:5,:) = [];

CASE(CASE.LAT==0,:) = [];
CASE(isnan(CASE.FIPS),:) = [];

peektable(CASE);





% CONCATINATE TIME-SERIES CASE & DEATH TABLES
%-------------------------------------------------------------

[u,i,j] = intersect(CASE.FIPS,DEATH.FIPS);

COVSTATS = DEATH(j,:);

COVSTATS.CASES = CASE.CASES(i,:);






% PREVIEW IMPORTED DATA
%-------------------------------------------------------------
% close all; 
% subplot(1,2,1); plot(nansum(COVSTATS.CASES));
% subplot(1,2,2); plot(nansum(COVSTATS.DEATHS));
% figure; stackedplot(HOSP)
% figure; stackedplot(POP)
% figure; stackedplot(NCOV)
% figure; stackedplot(COVSTATS)









clc; clearvars -except P HOSP POP NCOV COVSTATS
%==========================================================================
%% SUM CASES WITHIN EACH COUNTY
%==========================================================================
clc; clearvars -except P HOSP POP NCOV COVSTATS


nonan = @(x) numel(x(~isnan(x)));



[G,FIPS] = findgroups(NCOV.FIPS);
DAYS     = splitapply(nonan,NCOV.CASES,G);
CASES    = splitapply(@nansum,NCOV.CASES,G);
DEATHS   = splitapply(@nansum,NCOV.DEATHS,G);

TAB      = table(FIPS, DAYS, CASES, DEATHS);
disp(head(TAB))
 


[C,i,j] = intersect(TAB.FIPS,NCOV.FIPS);
TCOV = NCOV(j,:);

% MAKE SURE EVERY ROW MATCHES
all(TCOV.FIPS == TAB.FIPS)


TCOV.DAYS   = TAB.DAYS;
TCOV.CASES  = TAB.CASES;
TCOV.DEATHS = TAB.DEATHS;

TCOV.Properties.VariableNames{'DATE'} = 'DATE1stCASE';










%==========================================================================
%% GET INTERSECTION OF HOSP AND ZIP DATA
%==========================================================================
clc; clearvars -except P HOSP POP NCOV COVSTATS TCOV


[ai,bi] = ismember(HOSP.ZIP,POP.ZIP);


HOSP.POP2016 = nan(height(HOSP),1);
HOSP.POP2015 = nan(height(HOSP),1);
HOSP.POP2014 = nan(height(HOSP),1);
HOSP.POP2013 = nan(height(HOSP),1);
HOSP.POP2012 = nan(height(HOSP),1);
HOSP.POP2011 = nan(height(HOSP),1);
HOSP.POP2010 = nan(height(HOSP),1);


HOSP.POP2016(ai) = POP.POP2016(bi(ai),:);
HOSP.POP2015(ai) = POP.POP2015(bi(ai),:);
HOSP.POP2014(ai) = POP.POP2014(bi(ai),:);
HOSP.POP2013(ai) = POP.POP2013(bi(ai),:);
HOSP.POP2012(ai) = POP.POP2012(bi(ai),:);
HOSP.POP2011(ai) = POP.POP2011(bi(ai),:);
HOSP.POP2010(ai) = POP.POP2010(bi(ai),:);









%==========================================================================
%% SUM HOSPITAL BEDS WITHIN EACH COUNTY
%==========================================================================
clc; clearvars -except P HOSP POP NCOV COVSTATS TCOV



TBL = HOSP;

TBL.OPEN_BEDS = round(TBL.BEDS .* (1-TBL.FULL_BEDS));

TBL.PPL_PER_BED =  round(TBL.POP2016 ./ TBL.BEDS,1);

TBL(isnan(TBL.PPL_PER_BED),:) = [];

TBL = movevars(TBL,{'OPEN_BEDS','PPL_PER_BED'},'After','ROOM_FOR_BEDS');





nonan = @(x) numel(x(~isnan(x)));

[G,FIPS]    = findgroups(TBL.FIPS);
NHOSPS      = splitapply(nonan,TBL.BEDS,G);
BEDS        = splitapply(@nansum,TBL.BEDS,G);
ICU_BEDS    = splitapply(@nansum,TBL.ICU_BEDS,G);
OPEN_BEDS   = splitapply(@nansum,TBL.OPEN_BEDS,G);

TAB = table(FIPS, NHOSPS, BEDS, ICU_BEDS, OPEN_BEDS);
disp(head(TAB))
 





[C,i,j] = intersect(TAB.FIPS,TBL.FIPS);
T = TBL(j,:);

% MAKE SURE EVERY ROW MATCHES
all(T.FIPS == TAB.FIPS)


T.HOSPITALS = TAB.NHOSPS;
T.BEDS      = TAB.BEDS;
T.ICU_BEDS  = TAB.ICU_BEDS;
T.OPEN_BEDS = TAB.OPEN_BEDS;



COVID = movevars(T,{'HOSPITALS'},'Before','BEDS');

COVID.PPL_PER_BED =  round(COVID.POP2016 ./ COVID.BEDS,1);

COVID(isnan(COVID.PPL_PER_BED),:) = [];






















%==========================================================================
%% SUM CASES WITHIN EACH COUNTY
%==========================================================================
clc; clearvars -except P HOSP POP NCOV COVSTATS TCOV COVID




[C,i,j] = intersect(COVID.FIPS,TCOV.FIPS);

Ta = COVID(i,:);
Tb = TCOV(j,:);


Tb.Properties.VariableNames{'COUNTY'} = 'COUNTYb';
Tb.STATE = [];
Tb.FIPS  = [];


NCOV = [Ta Tb];


NCOV.PPL_PER_BED(NCOV.PPL_PER_BED > 2000) = 2000;

NCOV.PPL_PER_BED = round(NCOV.PPL_PER_BED);



clc; clearvars -except P NCOV COVSTATS





%==========================================================================
%% GET ONLY CONTIGUOUS 48 STATES + DC
%==========================================================================
clc; clearvars -except P NCOV COVSTATS


% LOWER 48 STATES FIT WITHIN THESE LAT/LON BOUNDS
LXY = [24.5 50.0 -125.0 -66.0];


DROP = (NCOV.LAT < LXY(1));
NCOV(DROP,:) = [];

DROP = (NCOV.LAT > LXY(2));
NCOV(DROP,:) = [];

DROP = (NCOV.LON < LXY(3));
NCOV(DROP,:) = [];

DROP = (NCOV.LON > LXY(4));
NCOV(DROP,:) = [];





%==========================================================================
%% COMPUTE MISC STATS
%==========================================================================
clc; clearvars -except P NCOV COVSTATS




NCOV.CASESperBED = NCOV.CASES ./ NCOV.BEDS;

NCOV.CASESperBED(NCOV.CASESperBED < 1) = 1;
NCOV.CASESperBED(NCOV.CASESperBED > 100) = 100;


NCOV.logCASES = log(NCOV.CASES);


COVSTATS.NEW_CASES  = COVSTATS.CASES - ...
    [zeros(height(COVSTATS),1) COVSTATS.CASES(:,1:end-1)];

COVSTATS.NEW_DEATHS = COVSTATS.DEATHS - ...
    [zeros(height(COVSTATS),1) COVSTATS.DEATHS(:,1:end-1)];




return
%==========================================================================
%% MAP PLOT (wmpolygon): HOSPITAL LOCATIONS
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS



% OPEN A MAP AND CENTER IT AT THE USA
%----------------------------------------
clat = 39.08320; 
clon = -94.57713;

wm = webmap('World Street Map');
wmcenter(wm,clat,clon,5)




% DRAW A CIRCLE POLYGON AT EACH NCOVITAL
%----------------------------------------

LATS = nan(height(NCOV)*2,1);
LONS = nan(height(NCOV)*2,1);

LATS(1:2:end) = NCOV.LAT;
LONS(1:2:end) = NCOV.LON;

RADIUS = repmat(.07,size(LATS,1),1); 
RADIUS(1:2:end) = NCOV.BEDS./10000; 


[LA,LO] = scircle1(LATS,LONS,RADIUS);

wmpolygon(wm,LA,LO,'EdgeColor','none','FaceColor','r','FaceAlpha',.4, 'Autofit', false)







%==========================================================================
%% MAP PLOT (wmmarker): HOSPITAL LOCATIONS
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS



% OPEN A MAP AND CENTER IT AT THE USA
%----------------------------------------
clat = 39.08320; 
clon = -94.57713;

wm = webmap('World Street Map');
wmcenter(wm,clat,clon,5)





% DROP A PIN
%----------------------------------------

wmmarker(wm, NCOV.LAT, NCOV.LON, 'Autofit', false);

% for i = 1:2:17
%     wmcenter(wm,clat,clon,i)
%     pause(2)
% end








%==========================================================================
%% MAP PLOT (SCATTERM): HOSPITAL LOCATIONS
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS



fh = figure('Units','pixels','Position',[10 50 1200 700],'Color','w');

ax = usamap('conus');

states = shaperead('usastatelo', 'UseGeoCoords', true,...
  'Selector',{@(name) ~any(strcmp(name,{'Alaska','Hawaii'})), 'Name'});

geoshow(ax(1), states,  'FaceColor', [0.5 1 0.5])
gridm off; framem off; %mlabel off; plabel off;

hm = scatterm(NCOV.LAT,NCOV.LON,100,'r');

hm.Children.Marker = '.';
hm.Children.MarkerEdgeAlpha = .3;








%==========================================================================
%% MAP PLOT (GEOBUBBLE):  SIZE=BEDS  COLOR=BEDS_PER_PERSON
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS



TAB = NCOV;

TAB.OPEN_BEDS = round(TAB.BEDS .* (1-TAB.FULL_BEDS));

TAB.BEDS_PER_POP = TAB.BEDS ./ TAB.POP2016 .* 1000;

TAB(isnan(TAB.BEDS_PER_POP),:) = [];

TAB.BEDS_PER_POP(TAB.BEDS_PER_POP > 20) = 20;


ncats = 5;

[BEDGROUP,GROUPS] = discretize(TAB.BEDS_PER_POP,ncats);

g = string(GROUPS(2:end)); g(end) = "20+";
TAB.BEDS_PER_1kPOP = categorical(BEDGROUP, 1:ncats, g);


fh = figure('Units','pixels','Position',[10 50 1200 700],'Color','w');

gb = geobubble(TAB,'LAT','LON', ...
    'SizeVariable','BEDS','ColorVariable','BEDS_PER_1kPOP');

cm = cool(ncats+1);
gb.BubbleColorList = [cm(2:end,:); 1 1 1];






%==========================================================================
%% MAP PLOT (GEOBUBBLE):  SIZE=BEDS  COLOR=PPL_PER_BED
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS

TAB = NCOV;



%==========================================================================
% CREATE FIGURE WINDOW
%-----------------------------------
close all;
fh1 = figure('Units','pixels','Position',[10 100 1400 700],'Color','w');
ax1 = axes('Position',[.08 .1 .85 .8],'Color','none'); box off;
ax1.YAxis.Exponent = 0; ax1.XAxis.Exponent = 0;
ax1.TickDir='out'; ax1.LineWidth=2;
xl=xlabel('PEOPLE PER HOSPITAL BED','Units','normalized','Position',[.5 -.08]);
yl=ylabel('N COUNTIES','Units','normalized','Position',[-.05 .5]);
ax1.FontSize = 18; cm = lines(2); hold on;

histogram(TAB.PPL_PER_BED);






round(quantile(TAB.PPL_PER_BED, [.01,.99]))

TAB.PPL_PER_BED(TAB.PPL_PER_BED > 1000) = 1000;






%==========================================================================
% CREATE FIGURE WINDOW
%-----------------------------------
fh1 = figure('Units','pixels','Position',[10 100 1400 700],'Color','w');
ax1 = axes('Position',[.08 .1 .85 .8],'Color','none'); box off;
ax1.YAxis.Exponent = 0; ax1.XAxis.Exponent = 0;
ax1.TickDir='out'; ax1.LineWidth=2;
xl=xlabel('X-LABEL TITLE','Units','normalized','Position',[.5 -.08]);
yl=ylabel('Y-LABEL TITLE','Units','normalized','Position',[-.05 .5]);
ax1.FontSize = 18; cm = lines(2); hold on;

histogram(TAB.PPL_PER_BED,80);







% TAB = NCOV;

ncats = 5;

[BEDGROUP,GROUPS] = discretize(TAB.PPL_PER_BED,ncats);

g = string(GROUPS(2:end)); g(end) = "1000+";
TAB.kPPL_PER_BED = categorical(BEDGROUP, 1:ncats, g);


fh = figure('Units','pixels','Position',[10 50 1200 700],'Color','w');

gb = geobubble(TAB,'LAT','LON', 'Basemap','streets-dark', ...
    'SizeVariable','BEDS','ColorVariable','kPPL_PER_BED');

cm = parula(ncats+2);
gb.BubbleColorList = cm(3:end,:);








%==========================================================================
%% MAP PLOT (GEOBUBBLE):  SIZE=BEDS  COLOR=log(CASES)
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS

TAB = NCOV;


ncats = 10;

TAB.lnCASES = log(TAB.CASES);

[logCASES,GROUPS] = discretize(TAB.lnCASES,ncats);


N = sprintf('%.1f',GROUPS(end));
g = string(GROUPS(2:end)); 
g(end) = string(N);
TAB.logCASES = categorical(logCASES, 1:ncats, g);


fh = figure('Units','pixels','Position',[10 50 1200 700],'Color','w');

gb = geobubble(TAB,'LAT','LON', 'Basemap','streets-dark',...
    'SizeVariable','BEDS','ColorVariable','logCASES');

cm = parula(ncats+2);
gb.BubbleColorList = cm(3:end,:);







%==========================================================================
%% MAP PLOT (GEOBUBBLE):  SIZE=CASESperBED  COLOR=log(CASES)
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS

TAB = NCOV;



% MAKE COLOR VARIABLE CATEGORICAL
%----------------------
VAR = TAB.logCASES;
%------
ncats = 10;
[CAT,GROUPS] = discretize(VAR,ncats);
N = sprintf('%.1f',GROUPS(end));
g = string(GROUPS(2:end)); 
g(end) = string(N);
%------
TAB.logCASES = categorical(CAT, 1:ncats, g);
%----------------------



fh = figure('Units','pixels','Position',[10 50 1200 700],'Color','w');

gb = geobubble(TAB,'LAT','LON', 'Basemap','streets-dark',...
    'SizeVariable','CASESperBED','ColorVariable','logCASES');

%cm = parula(ncats+2);
cm = cmocean('thermal',ncats+2);
gb.BubbleColorList = cm(3:end,:);





%==========================================================================
%% MAP PLOT (GEOBUBBLE):  SIZE=log(CASES)  COLOR=CASESperBED
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS

TAB = NCOV;


TAB.sqrtCASES = round(sqrt(TAB.CASES));

TAB.CASESperBED(TAB.CASESperBED > 50) = 50;

close all; histogram(TAB.CASESperBED)

close all; histogram(TAB.logCASES)

close all; histogram(TAB.sqrtCASES)


% MAKE COLOR VARIABLE CATEGORICAL
%----------------------
VAR = TAB.CASESperBED;
%------
ncats = 10;
[CAT,GROUPS] = discretize(VAR,ncats);
N = sprintf('%.1f',GROUPS(end));
g = string(GROUPS(2:end)); 
g(end) = string(N);
%------
TAB.CASESperBED = categorical(CAT, 1:ncats, g);
%----------------------



fh = figure('Units','pixels','Position',[10 50 1200 700],'Color','w');

gb = geobubble(TAB,'LAT','LON', 'Basemap','streets-dark',...
    'SizeVariable','sqrtCASES','ColorVariable','CASESperBED');

%cm = parula(ncats+2);
cm = cmocean('thermal',ncats+2);

gb.BubbleColorList = cm(3:end,:);











%==========================================================================
%% MAP PLOT (GEOBUBBLE):  TIMESERIES DATA
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS

TAB = COVSTATS;
TAB(string(TAB.STATE)=="Alaska",:) = [];
TAB(string(TAB.STATE)=="Hawaii",:) = [];




TAB.CASETOT  = TAB.CASES(:,end);
TAB.DEATHTOT = TAB.DEATHS(:,end);

TAB.logCASETOT  = log(TAB.CASETOT);
TAB.logDEATHTOT = log(TAB.DEATHTOT);


TAB(TAB.CASETOT<1,:) = [];
TAB(TAB.DEATHTOT<1,:) = [];
TAB(TAB.CASETOT<=TAB.DEATHTOT,:) = [];
TAB(TAB.POPULATION<1e5,:) = [];


COLOR = TAB.DEATHTOT ./ TAB.CASETOT .* 100;
NCATS = 10;



[BIN,GRP] = discretize(COLOR,NCATS);
BINGROUP  = string(GRP(2:end));
COLOR = categorical(BIN, 1:NCATS, BINGROUP);

TAB.PCT_DEATHS = COLOR;




fh = figure('Units','pixels','Position',[10 50 1200 700],'Color','w');

gb = geobubble(TAB,'LAT','LON', 'Basemap','streets-dark',...
    'SizeVariable','logCASETOT','ColorVariable','PCT_DEATHS');

cm = parula(NCATS+2);
gb.BubbleColorList = cm(3:end,:);

gb.SizeLegendTitle = 'Log Cases';
gb.ColorLegendTitle = 'Mortality Rate';



















%==========================================================================
%% NY vs US
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS

TAB = COVSTATS;



% SEPARATE DATA INTO 'NY' AND 'US'
%----------------------------------
% NYi = string(NCOV.STATE) == "NY";
NYi = string(TAB.STATE) == "New York";

NY.COV = TAB(NYi,:);
US.COV = TAB(~NYi,:);


% NY CASE STATS
%----------------------------------
NY.CV.NEW      = movmean(nansum(NY.COV.NEW_CASES),3);
NY.CV.NEW(end) = [];
NY.CV.CUM      = cumsum(NY.CV.NEW);
NY.CV.logNEW   = log(NY.CV.NEW);
NY.CV.logCUM   = log(NY.CV.CUM);
NY.CV.DELTA    = [0   NY.CV.NEW(2:end) - NY.CV.NEW(1:end-1)];

% NY DEATH STATS
%----------------------------------
NY.DV.NEW      = movmean(nansum(NY.COV.NEW_DEATHS),3);
NY.DV.NEW(end) = [];
NY.DV.CUM      = cumsum(NY.DV.NEW);
NY.DV.logNEW   = log(NY.DV.NEW);
NY.DV.logCUM   = log(NY.DV.CUM);
NY.DV.DELTA    = [0   NY.DV.NEW(2:end) - NY.DV.NEW(1:end-1)];


% US CASE STATS
%----------------------------------
US.CV.NEW      = movmean(nansum(US.COV.NEW_CASES),3);
US.CV.NEW(end) = [];
US.CV.CUM      = cumsum(US.CV.NEW);
US.CV.logNEW   = log(US.CV.NEW);
US.CV.logCUM   = log(US.CV.CUM);
US.CV.DELTA    = [0   US.CV.NEW(2:end) - US.CV.NEW(1:end-1)];

% US DEATH STATS
%----------------------------------
US.DV.NEW      = movmean(nansum(US.COV.NEW_DEATHS),3);
US.DV.NEW(end) = [];
US.DV.CUM      = cumsum(US.DV.NEW);
US.DV.logNEW   = log(US.DV.NEW);
US.DV.logCUM   = log(US.DV.CUM);
US.DV.DELTA    = [0   US.DV.NEW(2:end) - US.DV.NEW(1:end-1)];



% DATETIME ARRAY
%----------------------------------
D1 = datetime(2020,1,22);
D2 = datetime('now')-2;
NY.CV.DATES = D1:D2;
NY.DV.DATES = D1:D2;
US.CV.DATES = D1:D2;
US.DV.DATES = D1:D2;



%==========================================================================
%% CASES & DEATHS PER DAY
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS NY US



date_start = 40;


%-----------------------------------
fh1 = figure('Units','pixels','Position',[10 100 1400 700],'Color','w');

ax1 = axes('Position',[.10 .15 .37 .75],'Color','none'); box off;
    ax1.YAxis.Exponent = 0; ax1.TickDir='out'; ax1.LineWidth=2;
    yl=ylabel('Cases Per Day','Units','normalized','Position',[-.16 .5]);
    ax1.FontSize = 18; cm = lines(2); xtickangle(90); hold on;

ax2 = axes('Position',[.55 .15 .37 .75],'Color','none'); box off;
    ax2.YAxis.Exponent = 0; ax2.TickDir='out'; ax2.LineWidth=2;
    yl=ylabel('Deaths Per Day','Units','normalized','Position',[-.13 .5]);
    ax2.FontSize = 18; cm = lines(2); xtickangle(90); hold on;
%-----------------------------------




axes(ax1)
ph1 = plot(NY.CV.DATES(date_start:end),NY.CV.NEW(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.2 .2 .2],'MarkerFaceColor',[.2 .2 .2]);
    xtickangle(90); title('COVID-19 CASES')
hold on
ph1 = plot(US.CV.DATES(date_start:end),US.CV.NEW(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.7 .2 .2],'MarkerFaceColor',[.7 .2 .2]);
    xtickangle(90); title('COVID-19 CASES')
%legend({'NY','US'},'location','best')

axes(ax2)
ph2 = plot(NY.CV.DATES(date_start:end),NY.DV.NEW(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.2 .2 .2],'MarkerFaceColor',[.2 .2 .2]);
xtickangle(90); title('COVID-19 DEATHS')

hold on

ph2 = plot(US.CV.DATES(date_start:end),US.DV.NEW(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.7 .2 .2],'MarkerFaceColor',[.7 .2 .2]);
xtickangle(90); title('COVID-19 DEATHS')
legend({'NY','US'},'location','best')









%==========================================================================
%% CASES & DEATHS CUMULATIVE
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS NY US



date_start = 40;


%-----------------------------------
close all;
fh1 = figure('Units','pixels','Position',[10 100 1400 700],'Color','w');

ax1 = axes('Position',[.10 .15 .37 .75],'Color','none'); box off;
    ax1.YAxis.Exponent = 0; ax1.TickDir='out'; ax1.LineWidth=2;
    yl=ylabel('Cumulative Cases','Units','normalized','Position',[-.16 .5]);
    ax1.FontSize = 18; cm = lines(2); xtickangle(90); hold on;

ax2 = axes('Position',[.55 .15 .37 .75],'Color','none'); box off;
    ax2.YAxis.Exponent = 0; ax2.TickDir='out'; ax2.LineWidth=2;
    yl=ylabel('Cumulative Deaths','Units','normalized','Position',[-.13 .5]);
    ax2.FontSize = 18; cm = lines(2); xtickangle(90); hold on;
%-----------------------------------


axes(ax1)
ph1 = plot(US.CV.DATES(date_start:end),US.CV.CUM(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.1 .1 .9],'MarkerFaceColor',[.1 .1 .9]);
    xtickangle(90); title('COVID-19 CASES')

axes(ax2)
ph2 = plot(US.CV.DATES(date_start:end),US.DV.CUM(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.7 .1 .5],'MarkerFaceColor',[.7 .1 .5]);
xtickangle(90); title('COVID-19 DEATHS')















%==========================================================================
%% CASES & DEATHS log(NEW)
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS NY US



date_start = 40;





%-----------------------------------
close all;
fh1 = figure('Units','pixels','Position',[10 100 1400 700],'Color','w');

ax1 = axes('Position',[.10 .15 .37 .75],'Color','none'); box off;
    ax1.YAxis.Exponent = 0; ax1.TickDir='out'; ax1.LineWidth=2;
    yl=ylabel(' log(Cases Per Day)','Units','normalized','Position',[-.16 .5]);
    ax1.FontSize = 18; cm = lines(2); xtickangle(90); hold on;

ax2 = axes('Position',[.55 .15 .37 .75],'Color','none'); box off;
    ax2.YAxis.Exponent = 0; ax2.TickDir='out'; ax2.LineWidth=2;
    yl=ylabel('log(Deaths Per Day)','Units','normalized','Position',[-.13 .5]);
    ax2.FontSize = 18; cm = lines(2); xtickangle(90); hold on;
%-----------------------------------


axes(ax1)
ph1 = plot(US.CV.DATES(date_start:end),US.CV.logNEW(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.1 .1 .9],'MarkerFaceColor',[.1 .1 .9]);
    xtickangle(90); title('COVID-19 CASES')

axes(ax2)
ph2 = plot(US.CV.DATES(date_start:end),US.DV.logNEW(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.7 .1 .5],'MarkerFaceColor',[.7 .1 .5]);
xtickangle(90); title('COVID-19 DEATHS')








%==========================================================================
%% CASES & DEATHS log(cumulative)
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS NY US



date_start = 40;



%-----------------------------------
close all;
fh1 = figure('Units','pixels','Position',[10 100 1400 700],'Color','w');

ax1 = axes('Position',[.10 .15 .37 .75],'Color','none'); box off;
    ax1.YAxis.Exponent = 0; ax1.TickDir='out'; ax1.LineWidth=2;
    yl=ylabel('log(Cumulative Cases)','Units','normalized','Position',[-.16 .5]);
    ax1.FontSize = 18; cm = lines(2); xtickangle(90); hold on;

ax2 = axes('Position',[.55 .15 .37 .75],'Color','none'); box off;
    ax2.YAxis.Exponent = 0; ax2.TickDir='out'; ax2.LineWidth=2;
    yl=ylabel('log(Cumulative Deaths)','Units','normalized','Position',[-.13 .5]);
    ax2.FontSize = 18; cm = lines(2); xtickangle(90); hold on;
%-----------------------------------


axes(ax1)
ph1 = plot(US.CV.DATES(date_start:end),US.CV.logCUM(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.1 .1 .9],'MarkerFaceColor',[.1 .1 .9]);
    xtickangle(90); title('COVID-19 CASES')

axes(ax2)
ph2 = plot(US.CV.DATES(date_start:end),US.DV.logCUM(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.7 .1 .5],'MarkerFaceColor',[.7 .1 .5]);
xtickangle(90); title('COVID-19 DEATHS')










%==========================================================================
%%   X=cumsum(CASES)   Y=CASES
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS NY US



date_start = 43;

US.CV.DATES(date_start:end)


%-----------------------------------
fh1 = figure('Units','pixels','Position',[10 100 1400 700],'Color','w');

ax1 = axes('Position',[.10 .15 .37 .75],'Color','none'); box off;
    ax1.YAxis.Exponent = 0; ax1.TickDir='out'; ax1.LineWidth=2;
    xl=xlabel('log(New Cases)','Units','normalized','Position',[.5 -.08]);
    yl=ylabel('log(Cumulative Cases)','Units','normalized','Position',[-.16 .5]);
    ax1.FontSize = 18; cm = lines(2); xtickangle(90); hold on;

ax2 = axes('Position',[.55 .15 .37 .75],'Color','none'); box off;
    ax2.YAxis.Exponent = 0; ax2.TickDir='out'; ax2.LineWidth=2;
    xl=xlabel('log(New Deaths)','Units','normalized','Position',[.5 -.08]);
    yl=ylabel('log(Cumulative Deaths)','Units','normalized','Position',[-.13 .5]);
    ax2.FontSize = 18; cm = lines(2); xtickangle(90); hold on;
%-----------------------------------



axes(ax1)
ph1 = plot(US.CV.logCUM(date_start:end),US.CV.logNEW(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.1 .1 .9],'MarkerFaceColor',[.1 .1 .9]);
    xtickangle(90); title('COVID-19 CASES')


axes(ax2)
ph2 = plot(US.DV.logCUM(date_start:end),US.DV.logNEW(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.7 .1 .5],'MarkerFaceColor',[.7 .1 .5]);
xtickangle(90); title('COVID-19 DEATHS')










%==========================================================================
%%   X=cumsum(CASES)   Y=CASES
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS NY US



date_start = 43;

US.CV.DATES(date_start:end)


%-----------------------------------
fh1 = figure('Units','pixels','Position',[10 100 1400 700],'Color','w');
ax1 = axes('Position',[.09 .15 .37 .75],'Color','none');
ax2 = axes('Position',[.57 .15 .37 .75],'Color','none');
%-----------------------------------



axes(ax1)
ph1 = loglog(US.CV.CUM(date_start:end),US.CV.NEW(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.1 .1 .9],'MarkerFaceColor',[.1 .1 .9]);
    title('COVID-19 CASES'); grid on;
    ax1.TickDir='out'; ax1.LineWidth=1.8;
    xl=xlabel('Cumulative Cases','Units','normalized','Position',[.5 -.08]);
    yl=ylabel('New Cases','Units','normalized','Position',[-.11 .5]);
    ax1.FontSize = 18; cm = lines(2); box off;
    %ax1.XLim(1) = 0; ax1.YLim(1) = 0; axis equal


axes(ax2)
ph2 = loglog(US.DV.CUM(date_start:end),US.DV.NEW(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.7 .1 .5],'MarkerFaceColor',[.7 .1 .5]);
    title('COVID-19 DEATHS'); grid on;
    ax2.TickDir='out'; ax2.LineWidth=1.8;
    xl=xlabel('Cumulative Deaths','Units','normalized','Position',[.5 -.08]);
    yl=ylabel('New Deaths','Units','normalized','Position',[-.11 .5]);
    ax2.FontSize = 18; cm = lines(2); box off; 
    %ax2.XLim(1) = 0; ax2.YLim(1) = 0; axis equal









%==========================================================================
%%   X=cumsum(CASES)   Y=CASES
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS NY US



date_start = 43;

US.CV.DATES(date_start:end)


%-----------------------------------
fh1 = figure('Units','pixels','Position',[10 100 1400 700],'Color','w');
ax1 = axes('Position',[.09 .15 .37 .75],'Color','none');
ax2 = axes('Position',[.57 .15 .37 .75],'Color','none');
%-----------------------------------



axes(ax1)
ph1 = loglog(US.CV.CUM(date_start:end),US.CV.NEW(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.1 .1 .9],'MarkerFaceColor',[.1 .1 .9]);
    title('COVID-19 CASES'); grid on;
    ax1.TickDir='out'; ax1.LineWidth=1.8;
    xl=xlabel('Cumulative Cases','Units','normalized','Position',[.5 -.08]);
    yl=ylabel('New Cases','Units','normalized','Position',[-.11 .5]);
    ax1.FontSize = 18; cm = lines(2); box off;
    %ax1.XLim(1) = 0; ax1.YLim(1) = 0; axis equal


axes(ax2)
ph2 = loglog(US.DV.CUM(date_start:end),US.DV.NEW(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.7 .1 .5],'MarkerFaceColor',[.7 .1 .5]);
    title('COVID-19 DEATHS'); grid on;
    ax2.TickDir='out'; ax2.LineWidth=1.8;
    xl=xlabel('Cumulative Deaths','Units','normalized','Position',[.5 -.08]);
    yl=ylabel('New Deaths','Units','normalized','Position',[-.11 .5]);
    ax2.FontSize = 18; cm = lines(2); box off; 
    %ax2.XLim(1) = 0; ax2.YLim(1) = 0; axis equal



%==========================================================================
%% XXX
%==========================================================================




%==========================================================================
%% COMPUTE CASES & DEATHS PER DAY
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS

TAB = COVSTATS;



% CASE STATS
%----------------------------------
CV.NEW      = movmean(nansum(TAB.CASES),3);
CV.NEW(end) = [];

CV.CUM      = cumsum(CV.NEW);
CV.logNEW   = log(CV.NEW);
CV.logCUM   = log(CV.CUM);
CV.DELTA    = [0   CV.NEW(2:end) - CV.NEW(1:end-1)];




% DEATH STATS
%----------------------------------
DV.NEW      = movmean(nansum(TAB.DEATHS),3);
DV.NEW(end) = [];

DV.CUM      = cumsum(DV.NEW);
DV.logNEW   = log(DV.NEW);
DV.logCUM   = log(DV.CUM);
DV.DELTA    = [0   DV.NEW(2:end) - DV.NEW(1:end-1)];




% DATETIME ARRAY
%----------------------------------
D1 = datetime(2020,1,22);
D2 = datetime('now')-2;
CV.DATES = D1:D2;
DV.DATES = D1:D2;









%==========================================================================
%% CASES & DEATHS PER DAY
%==========================================================================
clc; close all; wmclose; clearvars -except P NCOV COVSTATS CV DV



date_start = 40;


%-----------------------------------
fh1 = figure('Units','pixels','Position',[10 100 1400 700],'Color','w');

ax1 = axes('Position',[.10 .15 .37 .75],'Color','none'); box off;
    ax1.YAxis.Exponent = 0; ax1.TickDir='out'; ax1.LineWidth=2;
    yl=ylabel('Cases Per Day','Units','normalized','Position',[-.16 .5]);
    ax1.FontSize = 18; cm = lines(2); xtickangle(90); hold on;

ax2 = axes('Position',[.55 .15 .37 .75],'Color','none'); box off;
    ax2.YAxis.Exponent = 0; ax2.TickDir='out'; ax2.LineWidth=2;
    yl=ylabel('Deaths Per Day','Units','normalized','Position',[-.13 .5]);
    ax2.FontSize = 18; cm = lines(2); xtickangle(90); hold on;
%-----------------------------------




axes(ax1)
ph1 = plot(CV.DATES(date_start:end),CV.DELTA(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.1 .1 .9],'MarkerFaceColor',[.1 .1 .9]);
    xtickangle(90); title('COVID-19 CASES')

axes(ax2)
ph2 = plot(CV.DATES(date_start:end),DV.DELTA(date_start:end) ,'k',...
    'LineWidth',5,'Marker','.','MarkerSize',55,...
    'MarkerEdgeColor',[.7 .1 .5],'MarkerFaceColor',[.7 .1 .5]);
xtickangle(90); title('COVID-19 DEATHS')






















%==========================================================================
%% XXX
%==========================================================================


%==========================================================================
%% XXX
%==========================================================================


%==========================================================================
%% XXX
%==========================================================================


%==========================================================================
%% XXX
%==========================================================================


