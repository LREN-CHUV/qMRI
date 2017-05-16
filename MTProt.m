function [fR1, fR2s, fMT, fA, PPDw, PT1w]  = MTProt(P_mtw, P_pdw, P_t1w, TE_mtw, TE_pdw, TE_t1w, TR_mtw, TR_pdw, TR_t1w, fa_mtw, fa_pdw, fa_t1w, P_trans, P_receiv)

% Evaluation function for multi-contrast multi-echo FLASH protocol
% P_mtw, P_pdw, P_t1w: MTw, PDw, T1w images (can be multiple echoes = images)
% TE_mtw, TE_pdw, TE_t1w, TR_mtw, TR_pdw, TR_t1w: echo times and TR of images
% fa_mtw, fa_pdw, fa_t1w: excitation flip angles of images
% P_trans: transmit bias map (p.u.) of B1 field of RF body coil
% P_receiv: sensitivity map of phased-array coil relative to BC (p.u.)
%
% Gunther Helms, MR-Research in Neurology and Psychiatry, University of Goettingen
% Nikolaus Weiskopf, Antoine Lutti, John Ashburner, Wellcome Trust Centre for Neuroimaging at UCL, London



%
% Antoine Lutti 15/01/09
% This version of MTProt corrects for imperfect RF spoiling when a B1 map is loaded (line 229 and below)
% based on Preibisch and Deichmann's paper MRM 61:125-135 (2009).
% The values for P2_a and P2_b were obtained using the code supplied by
% Deichmann with the experimental parameters used to get our PDw and T1w
% images.
%

% MFC 31.05.2013    If the spoiling correction has not been defined for the
%                   protocol then none is applied.
%
% MFC 27.03.2014    Use PDw image as template for writing out maps to be
%                   robust in cases of inconsistent FoV positioning.

% $Id: MTProt.m 46 2014-04-23 07:30:40Z antoine $

P_receiv = []; %CPL to supress error message

if nargin < 14
    P_receiv = [];
end
if nargin < 13
    P_trans = [];
end


TE_limit = 30; % TE time up to which echoes are averaged (in ms)

% Settings for R.Deichmann steady state correction using T2=64ms at 3T
% Correction parameters were calculated for 3 different parameter sets:
if (feq(TR_pdw, 23.7) && feq(TR_t1w, 18.7) && feq(fa_pdw, 6) && feq(fa_t1w, 20))
    % 1) classic FIL protocol (Weiskopf et al., Neuroimage 2011):
    % PD-weighted: TR=23.7ms; a=6deg; T1-weighted: TR=18.7ms; a=20deg
    disp('Classic FIL protocol');
    P2_a= [78.9228195006542,-101.113338489192,47.8783287525126];
    P2_b=[-0.147476233142129,0.126487385091045,0.956824374979504];
    RFCorr = true;
elseif (feq(TR_pdw, 24.5) && feq(TR_t1w, 24.5) && feq(fa_pdw, 5) && feq(fa_t1w, 29))
    % 2) new FIL/Helms protocol
    % PD-weighted: TR=24.5ms; a=5deg; T1-weighted: TR=24.5ms; a=29deg
    disp('New FIL/Helms protocol');
    P2_a= [93.455034845930480,-120.5752858196904,55.911077913369060];
    P2_b=[-0.167301931434861,0.113507432776106,0.961765216743606];
    RFCorr = true;
elseif (feq(TR_pdw, 24.0) && feq(TR_t1w, 19.0) && feq(fa_pdw, 6) && feq(fa_t1w, 20))
    % 3) Siemens product sequence protocol used in Lausanne (G Krueger)
    %PD-weighted: TR=24ms; a=6deg; T1-weighted: TR=19ms; a=20deg
    disp('Siemens product Lausanne (GK) protocol');
    P2_a= [67.023102027100880,-86.834117103841540,43.815818592349870];
    P2_b=[-0.130876849571103,0.117721807209409,0.959180058389875];
    RFCorr = true;
elseif (feq(TR_pdw, 23.7) && feq(TR_t1w, 23.7) && feq(fa_pdw, 6) && feq(fa_t1w, 28))
    % 4) High-res (0.8mm) FIL protocol:
    % PD-weighted: TR=23.7ms; a=6deg; T1-weighted: TR=23.7ms; a=28deg
    disp('High-res FIL protocol');
    P2_a= [1.317257319014170e+02,-1.699833074433892e+02,73.372595677371650];
    P2_b=[-0.218804328507184,0.178745853134922,0.939514554747592];
    RFCorr = true;
elseif (feq(TR_pdw, 25.25) && feq(TR_t1w, 25.25) && feq(fa_pdw, 5) && feq(fa_t1w, 29))
    % 4)NEW  High-res (0.8mm) FIL protocol:
    % PD-weighted: TR=25.25ms; a=5deg; T1-weighted: TR=TR=25.25ms; a=29deg
    disp('High-res FIL protocol');
    P2_a= [88.8623036106612,-114.526218941363,53.8168602253166];
    P2_b=[-0.132904017579521,0.113959390779008,0.960799295622202];
    RFCorr = true;
elseif (feq(TR_pdw, 24.5) && feq(TR_t1w, 24.5) && feq(fa_pdw, 6) && feq(fa_t1w, 21))
    % 5)NEW  1mm protocol - seq version v2k:
    % PD-weighted: TR=24.5ms; a=6deg; T1-weighted: TR=24.5ms; a=21deg
    disp('v2k protocol');
    P2_a= [71.2817617982844,-92.2992876164017,45.8278193851731];
    P2_b=[-0.137859046784839,0.122423212397157,0.957642744668469];
    RFCorr = true;
elseif (feq(TR_pdw, 120.86) && feq(TR_t1w, 24.5) && feq(fa_pdw, 10) && feq(fa_t1w, 21))
    disp('long-TR protocol');
    P2_a= [39.225771603296565,-50.417628944098760,30.5377440762605161];
    P2_b=[-0.089713505678481,0.062360105870434,0.978526065137486];
    RFCorr = true;
else
    warning('Warning!!! Spoiling correction not defined for this protocol. No correction being applied.');
    RFCorr = false;
end

% check that echo times are identical
for nr=1:min([length(TE_mtw), length(TE_pdw), length(TE_t1w)])
    if (TE_mtw(nr) == TE_pdw(nr)) & (TE_pdw(nr) == TE_t1w(nr))
        ok=1;
    else
        error('Echo times do not match!')
    end
end
nr_c_echoes = min([length(TE_mtw), length(TE_pdw), length(TE_t1w)]);


V_mtw   = spm_vol(P_mtw);
V_pdw   = spm_vol(P_pdw);
V_t1w   = spm_vol(P_t1w);

if ~isempty(P_trans) % B1 map (p.u.)
    V_trans   = spm_vol(P_trans);
else
    V_trans   = [];
end
if ~isempty(P_receiv) % sensitivity map (p.u.)
    V_receiv   = spm_vol(P_receiv);
else
    V_receiv   = [];
end

V_templ = spm_vol(P_pdw);
V       = V_templ(1);

[pth,nam,ext] = fileparts(P_mtw(1,:));

if (vbq_get_defaults('QA')||vbq_get_defaults('PDmap')||vbq_get_defaults('ACPCrealign'))
    MPMcalcFolder=fullfile(pth,'MPMcalcFolder');
    if(exist(MPMcalcFolder,'dir'))%in case a previous run was stopped prematurely
        rmdir(MPMcalcFolder,'s')
    end
    mkdir(MPMcalcFolder)
end

% calculate T2* map from PD echoes
dm        = V.dim;
spm_progress_bar('Init',dm(3),'R2* fit','planes completed');
disp('----- Calculation of T2* map -----');
V         = V_templ(1);
n         = numel(V_pdw);
dt        = [spm_type('float32'),spm_platform('bigend')];
Ni        = nifti;
Ni.mat    = V.mat;
Ni.mat0   = V.mat;
Ni.descrip='R2* map [1/ms]';
Ni.dat    = file_array(fullfile(pth,[nam '_R2s' '.nii']),dm,dt, 0,1,0);
create(Ni);
fR2s = fullfile(pth,[nam '_R2s' '.nii']);

reg = [ones(numel(TE_pdw),1) TE_pdw(:)];
W   = (reg'*reg)\reg';
W   = -W(2,:)';
for p = 1:dm(3),
    M = spm_matrix([0 0 p 0 0 0 1 1 1]);
    Y = zeros(dm(1:2));
    for i = 1:n,
        M1 = V_pdw(i).mat\V_pdw(1).mat*M;
        Y  = Y + W(i)*log(max(spm_slice_vol(V_pdw(i),M1,dm(1:2),1),1));
    end
    Ni.dat(:,:,p) = max(min(Y,vbq_get_defaults('R2sthresh')),-vbq_get_defaults('R2sthresh')); % threshold T2* at +/- 0.1ms or R2* at +/- 10000 *(1/sec), negative values are allowed to preserve Gaussian distribution
    spm_progress_bar('Set',p);
end
spm_progress_bar('Clear');

% Average first few echoes for increased SNR and fit T2*
disp('----- Reading and averaging the images -----');

nr_TE_limit = min(find(TE_mtw > TE_limit));
avg_nr      = min([nr_c_echoes nr_TE_limit]);
% avg_nr      = 1;
avg_nr_forA = 1;
PP   = {P_mtw,P_pdw,P_t1w};
nam1 = {'MTw','PDw','T1w'};
avg  = [0 0 0];
for ii=1:3,
    V         = spm_vol(PP{ii});
    dm        = V(1).dim;
    Ni        = nifti;
    Ni.mat    = V(1).mat;
    Ni.mat0   = V(1).mat;
    Ni.descrip= sprintf('Averaged %s images', nam1{ii});
    Ni.dat    = file_array(fullfile(pth,[nam '_' nam1{ii} '.nii']),dm,dt, 0,1,0);
    create(Ni);
    spm_progress_bar('Init',dm(3),Ni.descrip,'planes completed');
    sm = 0;
    for p=1:dm(3),
        M = spm_matrix([0 0 p]);
        Y = zeros(dm(1:2));
        for nr=1:avg_nr,
            M1 = V(nr).mat\V(1).mat*M;
            Y  = Y + spm_slice_vol(V(nr),M1,dm(1:2),1);
        end
        Ni.dat(:,:,p) = Y/avg_nr;
        sm = sm + sum(Y(:))/avg_nr;
        spm_progress_bar('Set',p);
    end
    avg(ii) = sm/prod(dm);
    spm_progress_bar('Clear');
end

V         = spm_vol(PP{3});
dm        = V(1).dim;
Ni        = nifti;
Ni.mat    = V(1).mat;
Ni.mat0   = V(1).mat;
%     Ni.descrip= sprintf('Averaged %s images', nam1{ii});
%     Ni.dat    = file_array(fullfile(MPMcalcFolder,[nam '_' nam1{ii} '.nii']),dm,dt, 0,1,0);
Ni.descrip= sprintf('Averaged %s images', 'T1w_forA');
Ni.dat    = file_array(fullfile(MPMcalcFolder,[nam '_' 'T1w_forA.nii']),dm,dt, 0,1,0);
create(Ni);
spm_progress_bar('Init',dm(3),Ni.descrip,'planes completed');
sm = 0;
for p=1:dm(3),
    M = spm_matrix([0 0 p]);
    Y = zeros(dm(1:2));
    for nr=1:avg_nr_forA,
        M1 = V(nr).mat\V(1).mat*M;
        Y  = Y + spm_slice_vol(V(nr),M1,dm(1:2),1);
    end
    Ni.dat(:,:,p) = Y/avg_nr_forA;
    sm = sm + sum(Y(:))/avg_nr_forA;
    spm_progress_bar('Set',p);
end
spm_progress_bar('Clear');

PPDw = fullfile(pth,[nam '_PDw' '.nii']);
PMTw = fullfile(pth,[nam '_MTw' '.nii']);
PT1w = fullfile(pth,[nam '_T1w' '.nii']);
PT1w_forA = fullfile(MPMcalcFolder,[nam '_T1w_forA' '.nii']);

if true,
    disp('----- Coregistering the images -----');
    x_MT2PD=coreg_mt(PPDw, PMTw);%output: coregistration parameters. Vector form: x, y, z pitch roll yaw. Can be turned into a matric using spm_matrix 
    x_T12PD=coreg_mt(PPDw, PT1w);
    coreg_mt(PPDw, PT1w_forA);
    if ~isempty(V_trans)
        coreg_bias_map(PPDw, P_trans);
    end
    if ~isempty(V_receiv)
        coreg_bias_map(PPDw, P_receiv);
    end
    if vbq_get_defaults('QA')
        if (exist(fullfile(pth,'QualityAssessment.mat'),'file')==2)
            load(fullfile(pth,'QualityAssessment.mat'));
        end
        QA.ContrastCoreg.MT2PD=x_MT2PD;QA.ContrastCoreg.T12PD=x_T12PD;
        save(fullfile(pth,'QualityAssessment'),'QA')
    end
end

VPDw = spm_vol(PPDw);
VMTw = spm_vol(PMTw);
VT1w = spm_vol(PT1w);
VT1w_forA = spm_vol(PT1w_forA);

if ~isempty(V_trans)
    Vtrans = spm_vol(P_trans(2,:)); % map only, we do not need the T1w image any more
else
    Vtrans = [];
end
if ~isempty(V_receiv)
    Vreceiv = spm_vol(P_receiv(2,:)); % map only, we do not need the T1w image any more
else
    Vreceiv = [];
end

if vbq_get_defaults('QA')
    % multi-contrast R2s fitting
    disp('----- multi-contrast R2* map -----');
    
    allTEs = {TE_mtw, TE_pdw, TE_t1w};
    Suffix = {'MTw', 'PDw', 'T1w'};
    V_all=[VMTw VPDw VT1w];V_PD = spm_vol(PP{2});
    for ctr=1:size(PP,2)
        dt        = [spm_type('float32'),spm_platform('bigend')];
        Ni        = nifti;
        Ni.mat    = V.mat;
        Ni.mat0   = V.mat;
        Ni.descrip='OLS R2* map [1/ms]';
        %     Ni.dat    = file_array(fullfile(pth,[nam '_R2s_' num2str(ctr) '.nii']),dm,dt, 0,1,0);
        Ni.dat    = file_array(fullfile(MPMcalcFolder,[nam '_R2s_' Suffix{ctr} '.nii']),dm,dt, 0,1,0);
        create(Ni);
        
        TE=allTEs{ctr};
        V_contrasts = spm_vol(PP{ctr});
        % The assumption is that the result of co-registering the average
        % weighted volumes is applicable for each of the echoes of that
        % contrast => Replicate the mat field across contrasts for all echoes.

%         matField = cat(3, repmat(VPDw.mat, [1, 1, nPD]), ...
%         repmat(VMTw.mat, [1, 1, nMT]), repmat(VT1w.mat, [1, 1, nT1]));

        
        reg = [ones(size(TE)) TE(:)];
        W   = (reg'*reg)\reg';
        
        spm_progress_bar('Init',dm(3),'multi-contrast R2* fit','planes completed');
        for p = 1:dm(3),
            M = spm_matrix([0 0 p 0 0 0 1 1 1]);
            data = zeros([size(TE,1) dm(1:2)]);
            
            for e = 1:size(TE,1)
                % Take slice p (defined in M) and map to a location in the
                % appropriate contrast using the matField entry for that
                % contrast, which has been co-registered to the PD-weighted
                % data:
                M1 = V_all(ctr).mat\V_PD(1).mat*M;
                
                % Third order B-spline interpolation for OLS R2* estimation
                % since we no longer assume that the echoes are perfectly
                % aligned as we do for the standard PDw derived R2* estimate.
                data(e,:,:) = log(max(spm_slice_vol(V_contrasts(e),M1,dm(1:2),3),eps));
            end
            Y = W*reshape(data, [size(TE,1) prod(dm(1:2))]);
            Y = -reshape(Y(2,:), dm(1:2));
            
            % Written out in Ni with mat field defined by V_templ => first PDw
            % echo:
            Ni.dat(:,:,p) = max(min(Y,vbq_get_defaults('R2sthresh')),-vbq_get_defaults('R2sthresh')); % threshold T2* at +/- 0.1ms or R2* at +/- 10000 *(1/sec), negative values are allowed to preserve Gaussian distribution
            spm_progress_bar('Set',p);
        end
        spm_progress_bar('Clear');
    end
end
%  --- BEGIN OLS R2s CODE MFC  ---
if vbq_get_defaults('R2sOLS')

    % Calculate OLS R2* map from all echoes (ESTATICS, Weiskopf et al. 2014)
    disp('----- Calculation of OLS R2* map -----');
    
    dt        = [spm_type('float32'),spm_platform('bigend')];
    Ni        = nifti;
    Ni.mat    = V.mat;
    Ni.mat0   = V.mat;
    Ni.descrip='OLS R2* map [1/ms]';
    Ni.dat    = file_array(fullfile(pth,[nam '_R2s_OLS' '.nii']),dm,dt, 0,1,0);
    create(Ni);
    
    % Combine the data and echo times:
    TE = [TE_pdw; TE_mtw; TE_t1w];
    
    nPD = numel(TE_pdw);
    nMT = numel(TE_mtw);
    nT1 = numel(TE_t1w);
    nEchoes = nPD + nMT + nT1;
    
    V_contrasts = spm_vol(P_pdw);
    V_contrasts(nPD+1:nPD+nMT) = spm_vol(P_mtw);
    V_contrasts(nPD+nMT+1:nEchoes) = spm_vol(P_t1w);
    
    % The assumption is that the result of co-registering the average 
    % weighted volumes is applicable for each of the echoes of that
    % contrast => Replicate the mat field across contrasts for all echoes.
    matField = cat(3, repmat(VPDw.mat, [1, 1, nPD]), ...
        repmat(VMTw.mat, [1, 1, nMT]), repmat(VT1w.mat, [1, 1, nT1]));
    
    % Same formalism as for PDw fit but now extra colums for the "S(0)" 
    % amplitudes of the different contrasts:
    reg = [zeros(nEchoes,3) TE(:)];
    reg(1 : nPD, 1)             = 1;
    reg(nPD + 1 : nPD+nMT, 2)   = 1;
    reg(nPD+nMT+1:nEchoes, 3)   = 1;
    W   = (reg'*reg)\reg';
    
    spm_progress_bar('Init',dm(3),'OLS R2* fit','planes completed');
    for p = 1:dm(3),
        M = spm_matrix([0 0 p 0 0 0 1 1 1]);
        data = zeros([nEchoes dm(1:2)]);
        
        for e = 1:nEchoes
            % Take slice p (defined in M) and map to a location in the 
            % appropriate contrast using the matField entry for that
            % contrast, which has been co-registered to the PD-weighted 
            % data:
            M1 = matField(:,:,e)\V_contrasts(1).mat*M;

            % Third order B-spline interpolation for OLS R2* estimation
            % since we no longer assume that the echoes are perfectly 
            % aligned as we do for the standard PDw derived R2* estimate.
            data(e,:,:) = log(max(spm_slice_vol(V_contrasts(e),M1,dm(1:2),3),eps));
        end
        Y = W*reshape(data, [nEchoes prod(dm(1:2))]);
        Y = -reshape(Y(4,:), dm(1:2));
        
        % Written out in Ni with mat field defined by V_templ => first PDw
        % echo:
        Ni.dat(:,:,p) = max(min(Y,vbq_get_defaults('R2sthresh')),-vbq_get_defaults('R2sthresh')); % threshold T2* at +/- 0.1ms or R2* at +/- 10000 *(1/sec), negative values are allowed to preserve Gaussian distribution
        spm_progress_bar('Set',p);
    end
    spm_progress_bar('Clear');
        
end % OLS code


% nam2    = {'R1','A','MT','MTR_synt'};
% descrip = {'R1 map [1000/s]', 'A map','Delta MT map', 'Synthetic MTR image'};
nam2    = {'R1','A','MT'};
descrip = {'R1 map [1000/s]', 'A map','Delta MT map'};
if (TR_mtw == TR_pdw) & (fa_mtw == fa_pdw),
%     nam2    = {nam2{:}, 'MTR','MTRdiff'};
%     descrip = {descrip{:}, 'Classic MTR image','Percent diff. MTR image (RD/BD)'};
    nam2    = {nam2{:}, 'MTR'};descrip = {descrip{:}, 'Classic MTR image'};
end
Nmap    = nifti;
for ii=1:numel(nam2),
    V         = V_templ(1);
    dm        = V(1).dim;
    Ni        = nifti;
    Ni.mat    = V(1).mat;
    Ni.mat0   = V(1).mat;
    Ni.descrip= descrip{ii};
    Ni.dat    = file_array(fullfile(pth,[nam '_' nam2{ii} '.nii']),dm,dt, 0,1,0);
    create(Ni);
    Nmap(ii) = Ni;
end
fR1 = fullfile(pth,[nam '_' nam2{1} '.nii']);
fA  = fullfile(pth,[nam '_' nam2{2} '.nii']);
fMT = fullfile(pth,[nam '_' nam2{3} '.nii']);

disp('----- Calculating the maps -----');
M0 = Ni.mat;
dm = size(Ni.dat);

fa_pdw = fa_pdw * pi / 180;
fa_mtw = fa_mtw * pi / 180;
fa_t1w = fa_t1w * pi / 180;

spm_progress_bar('Init',dm(3),'Calculating maps','planes completed');

for p=1:dm(3),
    M = M0*spm_matrix([0 0 p]);

    MTw = spm_slice_vol(VMTw,VMTw.mat\M,dm(1:2),3);
    PDw = spm_slice_vol(VPDw,VPDw.mat\M,dm(1:2),3);
    T1w = spm_slice_vol(VT1w,VT1w.mat\M,dm(1:2),3);
    T1w_forA = spm_slice_vol(VT1w_forA,VT1w_forA.mat\M,dm(1:2),3);
    if ~isempty(Vtrans)
        f_T = spm_slice_vol(Vtrans,Vtrans.mat\M,dm(1:2),3)/100; % divide by 100, since p.u. maps
    else
        f_T = [];
    end
    if ~isempty(Vreceiv)&~isempty(Vtrans)
        f_R = spm_slice_vol(Vreceiv,Vreceiv.mat\M,dm(1:2),3)/100; % divide by 100, since p.u. maps
        f_R = f_R .* f_T; % f_R is only the sensitivity map and not the true receive bias map, therefore needs to be multiplied by transmit bias (B1+ approx. B1- map)
    else
        f_R = [];
    end
    
    % Standard magnetization transfer ratio (MTR) in percent units [p.u.]
    % only if  trpd = trmt and fapd = fmt
    % else calculate "synthetic MTR using A and T1 (see below)
    if (TR_mtw == TR_pdw) && (fa_mtw == fa_pdw),
%     if numel(Nmap)>4&&(TR_mtw == TR_pdw) && (fa_mtw == fa_pdw),
        MTR = (PDw-MTw)./(PDw+eps) * 100;
        % write MTR image
        Nmap(end).dat(:,:,p) = max(min(MTR,vbq_get_defaults('MTRthresh')),-vbq_get_defaults('MTRthresh'));
        
%         % calculate a modified MTR map according to RD/BD
%         MTR = 100*(PDw-MTw)./(eps+PDw).*(MTw./(eps+PDw)<1.3&MTw./(eps+PDw)>0&PDw>25);
%         Nmap(6).dat(:,:,p) = max(min(MTR,vbq_get_defaults('MTRthresh')),-vbq_get_defaults('MTRthresh'));
    end
    
    % calculating T1 and A from a rational approximation of the Ernst equation using radian units
    % divide by fa and subtract
    % PD_d = PDw / fa_pdw;
    % T1_d = T1w / fa_t1w;
    %PD_T1_d = (PDw / fa_pdw) - (T1w / fa_t1w);
    
    % multiply by fa and divide by 2TR and subtract
    % PD_m = PDw * fa_pdw / 2 / TR_pdw;
    % T1_m = T1w * fa_t1w / 2 / TR_t1w;   % nw: corrected from T1_d to T1_m, correct?!,
    %T1_PD_m = (T1w * fa_t1w / 2 / TR_t1w) - (PDw * fa_pdw / 2 / TR_pdw);
    
    
    if isempty(f_T)
        % semi-quantitative T1
        T1 = ((PDw / fa_pdw) - (T1w / fa_t1w)) ./ ...
            max((T1w * (fa_t1w / 2 / TR_t1w)) - (PDw * fa_pdw / 2 / TR_pdw),eps);
        R1 = (((T1w * (fa_t1w / 2 / TR_t1w)) - (PDw * fa_pdw / 2 / TR_pdw)) ./ ...
            max(((PDw / fa_pdw) - (T1w / fa_t1w)),eps))*10^6;
    else
        % Transmit bias corrected quantitative T1 values
        % correct T1 for transmit bias f_T with fa_true = f_T * fa_nom
        % T1corr = T1 / f_T / f_T
        if RFCorr
            % MFC: We do have P2_a and P2_b parameters for this sequence
            % => T1 = A(B1) + B(B1)*T1app (see Preibisch 2009)
            T1 = P2_a(1)*f_T.^2+P2_a(2)*f_T+P2_a(3)+(P2_b(1)*f_T.^2+P2_b(2)*f_T+P2_b(3)).*((((PDw / fa_pdw) - (T1w / fa_t1w)+eps) ./ ...
                max((T1w * fa_t1w / 2 / TR_t1w) - (PDw * fa_pdw / 2 / TR_pdw),eps))./f_T.^2);
        else
            % MFC: We do not have P2_a or P2_b parameters for this sequence
            % => T1 = T1app
            T1 = ((((PDw / fa_pdw) - (T1w / fa_t1w)+eps) ./ max((T1w * fa_t1w / 2 / TR_t1w) - (PDw * fa_pdw / 2 / TR_pdw),eps))./f_T.^2);
        end
        
        R1=1./T1*10^6;
    end
    T1_forMT = ((PDw / fa_pdw) - (T1w / fa_t1w)) ./ ...
        max((T1w * (fa_t1w / 2 / TR_t1w)) - (PDw * fa_pdw / 2 / TR_pdw),eps);
    T1       = max(T1,0);

    
    R1(R1<0)=0;
    tmp      = R1;
    Nmap(1).dat(:,:,p) = min(max(tmp,-vbq_get_defaults('R1thresh')),vbq_get_defaults('R1thresh')); %Truncating images to dynamic range. Originally 20000. Negative values are allowed or min(max(tmp,0),2000)
    
    % A values proportional to PD
    if (~isempty(f_T)) && (~isempty(f_R))
        % Transmit and receive bias corrected quantitative A values
        % again: correct A for transmit bias f_T and receive bias f_R
        % Acorr = A / f_T / f_R , proportional PD
        A = (T1 .* (T1w_forA * fa_t1w / 2 / TR_t1w) + (T1w_forA / fa_t1w))./f_T./f_R;
    elseif(~isempty(f_T))&&(isempty(f_R))%&&(vbq_get_defaults('PDmap'))
        A = T1 .* (T1w_forA .*(fa_t1w*f_T) / 2 / TR_t1w) + (T1w_forA ./ (fa_t1w*f_T));
    else
        % semi-quantitative A
        A = T1 .* (T1w_forA * fa_t1w / 2 / TR_t1w) + (T1w_forA / fa_t1w);
    end
    
    A_forMT = T1_forMT .* (T1w * fa_t1w / 2 / TR_t1w) + (T1w / fa_t1w);
    tmp      = A;
    Nmap(2).dat(:,:,p) = max(min(tmp,vbq_get_defaults('Athresh')),-vbq_get_defaults('Athresh')); % dynamic range increased to 10^5 to accommodate phased-array coils and symmetrical for noise distribution
    % MT in [p.u.]; offset by - famt * famt / 2 * 100 where MT_w = 0 (outside mask)
    MT       = ( (A_forMT * fa_mtw - MTw) ./ (MTw+eps) ./ (T1_forMT + eps) * TR_mtw - fa_mtw * fa_mtw / 2 ) * 100;
    if (~isempty(f_T))
        MT = MT .* (1 - 0.4) ./ (1 - 0.4 * f_T);
    end
    tmp      = MT;
    Nmap(3).dat(:,:,p) = max(min(tmp,vbq_get_defaults('MTthresh')),-vbq_get_defaults('MTthresh'));
    
    % calculate synthetic reference signal at trmt and famt using the
    % rational approximation of the Ernst equation
    S_ref      = A_forMT .* fa_mtw * TR_mtw ./ (T1_forMT+eps) ./ ( TR_mtw ./ (T1_forMT+eps) +  fa_mtw * fa_mtw / 2 );
%     % MTR_synt = (S_ref ./ MTw - 1) * 100;
%     MTR_synt   = (S_ref-MTw) ./ (S_ref+eps) * 100;
%     tmp      = MTR_synt;
%     Nmap(4).dat(:,:,p) = max(min(tmp,vbq_get_defaults('MTR_syntthresh')),-vbq_get_defaults('MTR_syntthresh'));
    spm_progress_bar('Set',p);
    
        
end

if vbq_get_defaults('ACPCrealign')
    Vsave=spm_vol(spm_select('FPList',pth,'^s.*_MT.(img|nii)$'));
    MTimage=spm_read_vols(Vsave);    
    Vsave.fname=fullfile(MPMcalcFolder,['masked_' spm_str_manip(Vsave.fname,'t')]);
    PDWimage=spm_read_vols(spm_vol(spm_select('FPList',pth,'^s.*_PDw.(img|nii)$')));
    MTimage(find(PDWimage<0.6*mean(PDWimage(:))))=0;
    spm_write_vol(Vsave,MTimage);

    MTimage=spm_select('FPList',MPMcalcFolder,'^masked.*_MT.(img|nii)$');    
    [~,R]=vbq_comm_adjust(1,MTimage,MTimage,8,0,sprintf('%s//canonical//%s.nii',spm('Dir'),'avg152T1')); % Commissure adjustment to find a rigth image center and have good segmentation.
    Vsave=spm_vol(MTimage);
    Vsave.descrip=[Vsave.descrip ' - AC-PC realigned'];
    spm_write_vol(Vsave,spm_read_vols(spm_vol(MTimage)));
    ACPC_images = spm_select('FPList',pth,'^s.*_(MT||A||R1||R2s||R2s_OLS||MTR).(img|nii)$');
    for i=1:size(ACPC_images,1)
        spm_get_space(deblank(ACPC_images(i,:)),...
            R*spm_get_space(deblank(ACPC_images(i,:))));
        Vsave=spm_vol(ACPC_images(i,:));
        Vsave.descrip=[Vsave.descrip ' - AC-PC realigned'];
        spm_write_vol(Vsave,spm_read_vols(spm_vol(ACPC_images(i,:))));
    end;
    if vbq_get_defaults('QA')
        ACPC_images = spm_select('FPList',MPMcalcFolder,'^s.*_(PDw||T1w||MTw).(img|nii)$');
        for i=1:size(ACPC_images,1)
            spm_get_space(deblank(ACPC_images(i,:)),...
                R*spm_get_space(deblank(ACPC_images(i,:))));
            Vsave=spm_vol(ACPC_images(i,:));
            Vsave.descrip=[Vsave.descrip ' - AC-PC realigned'];
            spm_write_vol(Vsave,spm_read_vols(spm_vol(ACPC_images(i,:))));
        end;
    end
    save(fullfile(pth,'ACPCrealign'),'R')
    delete(deblank(spm_select('FPList',MPMcalcFolder,'^masked.*_MT.(img|nii)$')));
end
if vbq_get_defaults('QA')||(vbq_get_defaults('PDmap'))
    R = spm_select('FPList',pth,'^s.*_MT.(img|nii)$');
    copyfile(R(1,:),MPMcalcFolder);
    Vsave = spm_vol(spm_select('FPList',MPMcalcFolder,'^s.*_MT.(img|nii)$'));
    MTtemp=spm_read_vols(Vsave);
    %The 5 outer voxels in all directions are nulled in order to remove artefactual effects from the MT map on segmentation:
    MTtemp(1:5,:,:)=0; MTtemp(end-5:end, :,:)=0;
    MTtemp(:, 1:5,:)=0; MTtemp(:, end-5:end,:)=0;
    MTtemp(:,:, 1:5)=0; MTtemp(:,:,end-5:end)=0;
    spm_write_vol(Vsave,MTtemp);

    P = spm_select('FPList',MPMcalcFolder,'^s.*_MT.(img|nii)$');
    clear matlabbatch
    matlabbatch{1}.spm.spatial.preproc.channel.vols = {P};
    matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
    spm_jobman('initcfg');
    spm_jobman('run', matlabbatch);
end
    
if vbq_get_defaults('QA')
    TPMs=spm_read_vols(spm_vol(spm_select('FPList',MPMcalcFolder,'^c.*\.(img|nii)$')));
    WMmask=zeros(size(squeeze(TPMs(:,:,:,2))));
    WMmask(squeeze(TPMs(:,:,:,2))>=vbq_get_defaults('WMMaskTh'))=1;
    WMmask=spm_erode(spm_erode(double(WMmask)));
    R2s = spm_read_vols(spm_vol(spm_select('FPList',MPMcalcFolder,'^s.*_R2s_(MTw|PDw|T1w).(img|nii)$')));
    R2s=R2s.*repmat(WMmask,[1 1 1 size(R2s,4)]);
    SDR2s=zeros(1,size(R2s,4));
    for ctr=1:size(R2s,4)
        MaskedR2s=squeeze(R2s(:,:,:,ctr));
        SDR2s(ctr)=std(MaskedR2s(MaskedR2s~=0),[],1);
    end
    if (exist(fullfile(pth,'QualityAssessment.mat'),'file')==2)
        load(fullfile(pth,'QualityAssessment.mat'));
    end
    QA.SDR2s.MTw=SDR2s(1);QA.SDR2s.PDw=SDR2s(2);QA.SDR2s.T1w=SDR2s(3);
    save(fullfile(pth,'QualityAssessment'),'QA')
end
if(~isempty(f_T))&&(isempty(f_R))&&(vbq_get_defaults('PDmap'))
    PDcalculation(pth,MPMcalcFolder)
end

if (vbq_get_defaults('QA')||vbq_get_defaults('PDmap'))
    rmdir(MPMcalcFolder,'s')
end
spm_progress_bar('Clear');

return;

% --------------------------------------------------------------
function [x] = coreg_mt(P_ref, P_src)
% coregisters the structural images
% for MT protocol

for src_nr=1:size(P_src, 1)
    P_src(src_nr,:);
    VG = spm_vol(P_ref);
    VF = spm_vol(P_src(src_nr,:));
    %coregflags.sep = [2 1];
    coregflags.sep = [4 2];
    x = spm_coreg(VG,VF, coregflags);
    %x  = spm_coreg(mireg(i).VG, mireg(i).VF,flags.estimate);
    M  = inv(spm_matrix(x));
    MM = spm_get_space(deblank(VF.fname));
    spm_get_space(deblank(deblank(VF.fname)), M*MM);
end
return;


% -----------------------------------------------------------------

% --------------------------------------------------------------
function [] = coreg_bias_map(P_ref, P_src)
% coregisters the B1 or receive maps with
% the structurals in the MT protocol

P_src(1,:);
VG = spm_vol(P_ref);
VF = spm_vol(P_src(1,:));
%coregflags.sep = [2 1];
coregflags.sep = [4 2];
x = spm_coreg(VG,VF, coregflags);
%x  = spm_coreg(mireg(i).VG, mireg(i).VF,flags.estimate);
M  = inv(spm_matrix(x));
MM = spm_get_space(deblank(VF.fname));
spm_get_space(deblank(deblank(VF.fname)), M*MM);

VF2 = spm_vol(P_src(2,:)); % now also apply transform to the map
M  = inv(spm_matrix(x));
MM = spm_get_space(deblank(VF2.fname));
spm_get_space(deblank(deblank(VF2.fname)), M*MM);

return;

function PDcalculation(pth,MPMcalcFolder)
disp('----- Calculating Proton Density map -----');

TPMs=spm_read_vols(spm_vol(spm_select('FPList',MPMcalcFolder,'^c.*\.(img|nii)$')));
WBmask=zeros(size(squeeze(TPMs(:,:,:,1))));
WBmask(sum(cat(4,TPMs(:,:,:,1:2),TPMs(:,:,:,end)),4)>=vbq_get_defaults('WBMaskTh'))=1;
WMmask=zeros(size(squeeze(TPMs(:,:,:,1))));
WMmask(squeeze(TPMs(:,:,:,2))>=vbq_get_defaults('WMMaskTh'))=1;

% Saves masked A map for bias-field correction later
P=spm_select('FPList',pth ,'^.*_A.(img|nii)$');
Vsave=spm_vol(P);
Vsave.fname=fullfile(MPMcalcFolder,['masked_' spm_str_manip(Vsave.fname,'t')]);
Amap=spm_read_vols(spm_vol(P)).*WBmask;
Amap(Amap==Inf)=0;Amap(isnan(Amap))=0;Amap(Amap==vbq_get_defaults('Athresh'))=0;
spm_write_vol(Vsave,Amap);

% Bias-field correction of masked A map
P=spm_select('FPList',MPMcalcFolder ,'^masked.*_A.(img|nii)$');
clear matlabbatch
matlabbatch{1}.spm.spatial.preproc.channel.vols = {P};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = vbq_get_defaults('biasreg');
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = vbq_get_defaults('biasfwhm');
matlabbatch{1}.spm.spatial.preproc.channel.write = [1 0];
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

temp=spm_select('FPList',MPMcalcFolder,'^(c|masked).*\_A');
for counter=1:size(temp,1)
    delete(deblank(temp(counter,:)));
end

% Bias field correction of A map. The bias field is calculated on
% the masked A map but we want to apply it on the unmasked A map. We
% therefore need to explicitly load the bias field and apply it on the original A map instead of just
% loading the bias-field corrected A map from the previous step
P=spm_select('FPList',pth ,'^s.*_A.(img|nii)$');
bf = fullfile(MPMcalcFolder, spm_select('List', MPMcalcFolder, '^BiasField.*\.(img|nii)$'));
BF = double(spm_read_vols(spm_vol(bf)));
Y = BF.*spm_read_vols(spm_vol(P));

% Calibration of flattened A map to % water content using typical white
% matter value from the litterature (69%)

A_WM=WMmask.*Y;
Y=Y/mean(A_WM(A_WM~=0))*69;
sprintf('mean White Matter intensity: %04d',mean(A_WM(A_WM~=0)))
sprintf('SD White Matter intensity %04d',std(A_WM(A_WM~=0),[],1))
Y(Y>200)=0;
% MFC: Estimating Error for data set to catch bias field issues:
errorEstimate = std(A_WM(A_WM > 0))./mean(A_WM(A_WM > 0));
Vsave=spm_vol(P);
Vsave.descrip = ['A Map.  Error Estimate: ', num2str(errorEstimate)];
if errorEstimate > 0.06
    % MFC: Testing on 15 subjects showed 6% is a good cut-off:
    warning(['Error estimate is high: ', Vsave.fname]);
end
if vbq_get_defaults('QA')
    if (exist(fullfile(pth,'QualityAssessment.mat'),'file')==2)
        load(fullfile(pth,'QualityAssessment.mat'));
    end
    QA.PD.mean=mean(A_WM(A_WM > 0));QA.PD.SD=std(A_WM(A_WM > 0));
    save(fullfile(pth,'QualityAssessment'),'QA')
end
% V.fname = P;
spm_write_vol(Vsave,Y);

temp=spm_select('FPList',MPMcalcFolder,'^Bias.*\_A');
for counter=1:size(temp,1)
    delete(deblank(temp(counter,:)));
end


return;

%__________________________________________________________________________


function bl = feq(val, comp_val)
% floating point comparison
bl = abs(val - comp_val) <= eps(comp_val);
return;
