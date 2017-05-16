function vbq = tbx_cfg_vbq
% Configuration file for the Voxel-Based Quantification (VBQ)
%  
% Warning and disclaimer: This software is for research use only. 
% Do not use it for clinical or diagnostic purposes.
% 
%_______________________________________________________________________
%
% Bogdan Draganski & Ferath Kherif, 2011
% ======================================================================

% $Id: tbx_cfg_vbq.m 33 2013-12-03 18:54:48Z antoine $

if ~isdeployed, addpath(fullfile(spm('Dir'),'toolbox','VBQ')); end


% ---------------------------------------------------------------------
% raws Raw Images
% ---------------------------------------------------------------------
raws3           = cfg_files;
raws3.tag       = 'T1';
raws3.name      = 'T1 images';
raws3.help      = {'Input T1 images in the same order.'}; 
raws3.filter    = 'image';
raws3.ufilter   = '.*';
raws3.num       = [0 Inf];
raws3.val       = {''};
% ---------------------------------------------------------------------
% raws Raw Images
% ---------------------------------------------------------------------
raws2           = cfg_files;
raws2.tag       = 'PD';
raws2.name      = 'PD images';
raws2.help      = {'Input PD images in the same order.'}; 
raws2.filter    = 'image';
raws2.ufilter   = '.*';
raws2.num       = [0 Inf];
raws2.val       = {''};
% ---------------------------------------------------------------------
% raws Raw Images
% ---------------------------------------------------------------------
raws1           = cfg_files;
raws1.tag       = 'MT';
raws1.name      = 'MT images';
raws1.help      = {'Input MT images in the same order.'}; 
raws1.filter    = 'image';
raws1.ufilter   = '.*';
raws1.num       = [0 Inf];
raws1.val       = {''};
% ---------------------------------------------------------------------
% vols Volumes
% ---------------------------------------------------------------------
raws            = cfg_branch;
raws.tag        = 'raw_mpm';
raws.name       = 'Raw multiparameter data';
raws.help       = {'Input all the MT/PD/T1 images in this order.'}; 
raws.val        = {raws1 raws2 raws3 };
% ---------------------------------------------------------------------
% menu type_b1
% ---------------------------------------------------------------------
b1_type         = cfg_menu;
b1_type.tag     = 'b1_type';
b1_type.name    = 'Choose the B1map type';
b1_type.help    = {'This is the option to choose the type of the B1 map acquisition. If you use B1 maps other than the explicitly stated versions the function will use the defaults for version 3D_EPI_v2b'};
b1_type.labels  = {
                '3D_EPI_v2b'
                '3D_EPI_v2b_long'
                '3D_EPI_rect700'
                }';
b1_type.values = {
                '3D_EPI_v2b'
                '3D_EPI_v2b_long'
                '3D_EPI_rect700'
                }';
b1_type.val    = {'3D_EPI_v2b'};
% ---------------------------------------------------------------------
% vols Volumes
% ---------------------------------------------------------------------
braws2          = cfg_files;
braws2.tag      = 'b1';
braws2.name     = 'Pairs of SE and STE images';
braws2.help     = {'Select B1 images - 3D EPI SE & STE'}; 
braws2.filter   = 'image';
braws2.ufilter  = '.*';
braws2.num      = [0 30];
braws2.val      = {''};
% ---------------------------------------------------------------------
% vols Volumes
% ---------------------------------------------------------------------
braws1          = cfg_files;
braws1.tag      = 'b0';
braws1.name     = 'B0 images';
braws1.help     = {'Select B0 images'}; 
braws1.filter   = 'image';
braws1.ufilter  = '.*';
braws1.num      = [0 3];
braws1.val      = {''};
% ---------------------------------------------------------------------
% vols Volumes
% ---------------------------------------------------------------------
braws           = cfg_branch;
braws.tag       = 'raw_fld';
braws.name      = 'Raw B0 & B1 data';
braws.help      = {'Input all B0 & B1 images in this order.'}; 
braws.val       = {braws1 braws2 b1_type};
% ---------------------------------------------------------------------
% subj Subject
% ---------------------------------------------------------------------
subj            = cfg_branch;
subj.tag        = 'subj';
subj.name       = 'Subject';
subj.val        = {braws raws };
subj.help       = {'Specify a subject for maps calculation.'};
% ---------------------------------------------------------------------
% data Data
% ---------------------------------------------------------------------
sdata           = cfg_repeat;
sdata.tag       = 'data';
sdata.name      = 'Few Subjects';
sdata.val       = {subj };
sdata.help      = {'Specify the number of subjects.'};
sdata.values    = {subj };
sdata.num       = [1 Inf];
% ---------------------------------------------------------------------
% indir Input directory as output directory
% ---------------------------------------------------------------------
indir         = cfg_menu;
indir.tag     = 'indir';
indir.name    = 'Input directory';
indir.help    = {'Output files will be written to the same folder as each corresponding input file.'};
indir.labels = {'Yes'};
indir.values = {1};
indir.val = {1};
% ---------------------------------------------------------------------
% outdir Output directory
% ---------------------------------------------------------------------
outdir         = cfg_files;
outdir.tag     = 'outdir';
outdir.name    = 'Output directory';
outdir.help    = {'Select a directory where output files will be written to.'};
outdir.filter = 'dir';
outdir.ufilter = '.*';
outdir.num     = [1 1];
% ---------------------------------------------------------------------
% output Output choice
% ---------------------------------------------------------------------
output         = cfg_choice;
output.tag     = 'output';
output.name    = 'Output choice';
output.help    = {'Output directory can be the same as the input directory for each input file or user selected'};
output.values  = {indir outdir };
output.val = {indir};
% ---------------------------------------------------------------------
% sdata_multi
% ---------------------------------------------------------------------
sdata_multi = cfg_branch;
sdata_multi.name = 'Many Subjects';
sdata_multi.tag = 'sdata_multi';
sdata_multi.help = {'Specify data with many subjects.'};
% ---------------------------------------------------------------------
% data_spec
% ---------------------------------------------------------------------
data_spec = cfg_choice;
data_spec.name = 'Data Specification Method';
data_spec.tag = 'data_spec';
data_spec.values = { sdata sdata_multi };
data_spec.val = { sdata };
data_spec.help = {'Specify data with either few or many subjects. The latter can be used with SmartDep toolbox.'};
% ---------------------------------------------------------------------
% create1 Create MPR maps with B0/B1 maps
% ---------------------------------------------------------------------
create1         = cfg_exbranch;
create1.tag     = 'mp_img_b_img';
create1.name    = 'Multiparameter & B0/B1 images';
raws.val        = {raws1 raws2 raws3 };
braws.val       = {braws1 braws2 };
subj.val        = {output braws raws };
sdata.val       = {subj };
sdata.values    = {subj };
sdata_multi.val = { output unlimit(braws) unlimit(raws) };
data_spec.values = { sdata sdata_multi };
data_spec.val = { sdata };
create1.val     = { b1_type data_spec };
%create1.check   = @check_maps_b0_b1;
create1.help    = {'Use this option when B0/B1 3D maps available.'};
create1.prog    = @vbq_mpr_b0_b1;
create1.vout    = @vout_crt1;
% ---------------------------------------------------------------------
% create Create MPR maps with UNICORT B1
% ---------------------------------------------------------------------
create          = cfg_exbranch;
create.tag      = 'mp_img_unicort';
create.name     = 'Multiparameter & UNICORT_B1 images';
raws.val        = {raws1 raws2 raws3 };
subj.val        = {output raws };
sdata.val       = {subj };
sdata.values    = {subj };
sdata_multi.val = { output unlimit(raws) };
data_spec.values = { sdata sdata_multi };
data_spec.val = { sdata };
create.val      = { data_spec };
%create.check    = @check_maps_unicort;
create.help     = {'Use this option when B0/B1 3D maps not available. Bias field estimation and correction will be performed',...
    'using the approach described in ''Unified segmentation based correction... (UNICORT) paper by Weiskopf et al., 2011 '};
create.prog     = @vbq_mpr_unicort;
create.vout     = @vout_crt;
% ---------------------------------------------------------------------
% maps maps Create maps
% ---------------------------------------------------------------------
crm             = cfg_choice;
crm.tag         = 'crt_maps';
crm.name        = 'Create maps';
crm.help        = {'You have the option to create B1 corrected parameter maps estimated from dual flip angle FLASH experiment.'};
crm.values      = {create create1 };

%----------------------------------------------------------------------

% ---------------------------------------------------------------------
% Data processing
% ---------------------------------------------------------------------

% ---------------------------------------------------------------------
% vols Volumes
% ---------------------------------------------------------------------
vols            = cfg_files;
vols.tag        = 's_vols';
vols.name       = 'T1w or MT images';
vols.help       = {'Select T1w or MT images for "unified segmentation".'};
vols.filter     = 'image';
vols.ufilter    = '.*';
vols.num        = [1 Inf];% channel.help    = {'Specify a channel for processing. If multiple channels are used (eg PD & T2), then the same order of subjects must be specified for each channel and they must be in register (same position, size, voxel dims etc..). The different channels can be treated differently in terms of inhomogeneity correction etc. You may wish to correct some channels and save the corrected images, whereas you may wish not to do this for other channels.'};

% % ---------------------------------------------------------------------
% % Gaussian FWHM
% % ---------------------------------------------------------------------
fwhm         = cfg_entry;
fwhm.tag     = 'fwhm';
fwhm.name    = 'Gaussian FWHM';
fwhm.val     = {[6 6 6]};
fwhm.strtype = 'e';
fwhm.num     = [1 3];
fwhm.help    = {'Specify the full-width at half maximum (FWHM) of the ',...
    'Gaussian blurring kernel in mm. Three values should be entered',... 
    'denoting the FWHM in the x, y and z directions. Note that you can also specify [0 0 0]',...
    'but any ``modulated'' data will show aliasing (see eg Wikipedia), which occurs because of the way the warped images are generated.'};


% ---------------------------------------------------------------------
% vols Volumes
% ---------------------------------------------------------------------
vols_pm         = cfg_files;
vols_pm.tag     = 'mp_vols';
vols_pm.name    = 'Volumes';
vols_pm.help    = {'Select whole brain parameter maps (e.g. MT, R2*, FA etc) for processing.'}; 
vols_pm.filter  = 'image';
vols_pm.ufilter = '.*';
vols_pm.num     = [1 Inf];
% ---------------------------------------------------------------------
% data Data
% ---------------------------------------------------------------------
pams            = cfg_branch;
pams.tag        = 'maps';
pams.name       = 'Parameter maps';
pams.val        = {vols_pm };
pams.help       = {'Select whole brain parameter maps (e.g. MT, R2*, FA etc) for processing.'}; 
% ---------------------------------------------------------------------
% indir Input directory as output directory
% ---------------------------------------------------------------------
indir         = cfg_menu;
indir.tag     = 'indir';
indir.name    = 'Input directory';
indir.help    = {'Output files will be written to the same folder as each corresponding input file.'};
indir.labels = {'Yes'};
indir.values = {1};
% ---------------------------------------------------------------------
% outdir Output directory
% ---------------------------------------------------------------------
outdir         = cfg_files;
outdir.tag     = 'outdir';
outdir.name    = 'Output directory';
outdir.help    = {'Select a directory where output files will be written to.'};
outdir.filter = 'dir';
outdir.ufilter = '.*';
outdir.num     = [1 1];
% ---------------------------------------------------------------------
% output Output choice
% ---------------------------------------------------------------------
output         = cfg_choice;
output.tag     = 'output';
output.name    = 'Output choice';
output.help    = {'Output directory can be the same as the input directory for each input file or user selected'};
output.values  = {indir outdir };

% ---------------------------------------------------------------------
% struct Structurals
% ---------------------------------------------------------------------

preproc8 = spm_cfg_preproc8;
eval(['preproc8' cfg_expr(preproc8, 'data', 'channel', 'vols') '=vols;']);
for i=1:3
    eval(['preproc8' cfg_expr(preproc8, 'tissues', i, 'warped') '.val{1}=[1 1];']);
end
struct = eval(['preproc8' cfg_expr(preproc8, 'data', 'channel')]);
struct.tag = 'struct';
struct.name = 'Structurals';

% ---------------------------------------------------------------------
% subj Subject
% ---------------------------------------------------------------------

subjc            = cfg_branch;
subjc.tag        = 'subjc';
subjc.name       = 'Subject';
subjc.val        = {output pams struct };
subjc.help       = {'Specify a subject for maps calculation.'};
% ---------------------------------------------------------------------
% data Data
% ---------------------------------------------------------------------
sdatas           = cfg_repeat;
sdatas.tag       = 'data';
sdatas.name      = 'Few subjects';
sdatas.val       = {subjc };
sdatas.help      = {'Specify the number of subjects. Note that all raw images have to be entered in the order MT/PD/T1/B1/B0.'};
sdatas.values    = {subjc };
sdatas.num       = [1 Inf];
% ---------------------------------------------------------------------
% many_pams
% ---------------------------------------------------------------------
many_pams            = cfg_repeat;
many_pams.tag        = 'maps';
many_pams.name       = 'Parameter maps';
many_pams.values        = {vols_pm };
many_pams.val        = {vols_pm };
many_pams.num = [1 Inf];
many_pams.help       = {'Select whole brain parameter maps (e.g. MT, R2*, FA etc) for processing.'}; 
% ---------------------------------------------------------------------
% Many subjects
% ---------------------------------------------------------------------
many_sdatas = cfg_branch;
many_sdatas.tag = 'many_sdatas';
many_sdatas.name = 'Many Subjects';
many_sdatas.val = {output many_pams unlimit(struct)};
many_sdatas.help = {'Specify images for many subjects'};
% ---------------------------------------------------------------------
% Choice many/few
% ---------------------------------------------------------------------
many_few_sdatas = cfg_choice;
many_few_sdatas.tag = 'many_few_sdatas';
many_few_sdatas.name = 'Data Specification Method';
many_few_sdatas.values = {sdatas, many_sdatas};
many_few_sdatas.val = {sdatas};
many_few_sdatas.help = {'Specify your data either as many or few subjects.'};
% ---------------------------------------------------------------------
% newseg Segment MT/T1w data 
% ---------------------------------------------------------------------


preproc8.name = 'Maps preprocessing - "new segmentation"';
preproc8.val = [{many_few_sdatas} preproc8.val(2:end) {fwhm}];

preproc8 = cfg_set_val(preproc8, 'tissues', 1, 'native', [1 1]);
preproc8 = cfg_set_val(preproc8, 'tissues', 2, 'native', [1 1]);
preproc8 = cfg_set_val(preproc8, 'tissues', 3, 'native', [1 1]);
preproc8 = cfg_set_val(preproc8, 'tissues', 4, 'native', [0 0]);
preproc8 = cfg_set_val(preproc8, 'tissues', 5, 'native', [0 0]);
preproc8 = cfg_set_val(preproc8, 'tissues', 6, 'native', [0 0]);

preproc8 = cfg_set_val(preproc8, 'warp', 'write', [0 1]);

preproc8.prog = @spm_local_preproc_run;
preproc8.vout = @vout_preproc;

%----------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% -------------------------------------------------------------------------
% configuration for STEP 2: diffeomorphic registration (DARTEL)
% -------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------------------------------
% warp Run DARTEL (create Templates)
% ---------------------------------------------------------------------
warp = tbx_cfg_dartel;
eval(['warp=warp' cfg_expr_values(warp, 'warp') ';']);

warp_shoot = tbx_cfg_shoot;
eval(['warp_shoot=warp_shoot' cfg_expr_values(warp_shoot, 'warp') ';']);
% ---------------------------------------------------------------------
% warp1 Run DARTEL (existing Templates)
% ---------------------------------------------------------------------

warp1 = tbx_cfg_dartel;
eval(['warp1=warp1' cfg_expr_values(warp1, 'warp') ';']);

warp1_shoot = tbx_cfg_shoot;
eval(['warp1_shoot=warp1_shoot' cfg_expr_values(warp1_shoot, 'warp') ';']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------------------------------
%
% ---------------------------------------------------------------------
% flowfield         = cfg_files;
% flowfield.tag     =  'flowfield';
% flowfield.name    = 'Flow Field';
% flowfield.filter  = 'nifti';
% flowfield.ufilter = '^u_.*\.nii$';
% flowfield.num     = [1 1];
% flowfield.help    = {'DARTEL flow field for this subject.'};
% ---------------------------------------------------------------------
%
% ---------------------------------------------------------------------
% images        = cfg_files;
% images.tag    = 'images';
% images.name   = 'Images';
% images.filter = 'nifti';
% images.num    = [2 2];
% images.help   = {'Select both GM & WM images in the same order for this subject to spatially normalise and use further for mpm_data scaling after registration.'};
% ---------------------------------------------------------------------
% vols Volumes
% ---------------------------------------------------------------------
% vols_pm         = cfg_files;
% vols_pm.tag     = 'mp_vols';
% vols_pm.name    = 'Volumes';
% vols_pm.help    = {'Select whole brain parameter maps (e.g. MT, R2*, FA etc) for registration.'}; 
% vols_pm.filter  = 'image';
% vols_pm.ufilter = '.*';
% vols_pm.num     = [1 Inf];
% ---------------------------------------------------------------------
% subj Subject
% ---------------------------------------------------------------------
% subjd            = cfg_branch;
% subjd.tag        = 'subjd';
% subjd.name       = 'Subject';
% subjd.val        = {vols_pm images flowfield };
% subjd.help       = {'Subject to be spatially normalized.'};
% ---------------------------------------------------------------------
% data Data
% ---------------------------------------------------------------------
% sdatad           = cfg_repeat;
% sdatad.tag       = 'data';
% sdatad.name      = 'Data';
% sdatad.val       = {subjd };
% sdatad.help      = {'Specify the number of subjects.'};
% sdatad.values    = {subjd };
% sdatad.num       = [1 Inf];
% ---------------------------------------------------------------------
% multsdata_gm GM Images
% ---------------------------------------------------------------------
multsdata_gm         = cfg_files;
multsdata_gm.tag     = 'multsdata_gm';
multsdata_gm.name    = 'GM Volumes';
multsdata_gm.help    = {'Select GM volumes.'}; 
multsdata_gm.filter  = 'image';
multsdata_gm.ufilter = '.*';
multsdata_gm.num     = [1 Inf];
% ---------------------------------------------------------------------
% multsdata_wm WM Images
% ---------------------------------------------------------------------
multsdata_wm         = cfg_files;
multsdata_wm.tag     = 'multsdata_wm';
multsdata_wm.name    = 'WM Volumes';
multsdata_wm.help    = {'Select WM volumes.'}; 
multsdata_wm.filter  = 'image';
multsdata_wm.ufilter = '.*';
multsdata_wm.num     = [1 Inf];
% ---------------------------------------------------------------------
% multsdata_f1 Multi-parameter maps
% ---------------------------------------------------------------------
multsdata_f1         = cfg_files;
multsdata_f1.tag     = 'multsdata_f1';
multsdata_f1.name    = 'Map';
multsdata_f1.help    = {'Select multi-parameter maps.'}; 
multsdata_f1.filter  = 'image';
multsdata_f1.ufilter = '.*';
multsdata_f1.num     = [1 Inf];
% ---------------------------------------------------------------------
% multsdata_f1 Multi-parameter maps
% ---------------------------------------------------------------------
multsdata_f         = cfg_repeat;
multsdata_f.tag     = 'multsdata_f';
multsdata_f.name    = 'Multi-parameter maps';
multsdata_f.val = { multsdata_f1 };
multsdata_f.help    = {'Select multi-parameter maps.'}; 
multsdata_f.values = { multsdata_f1 };
multsdata_f.num     = [1 Inf];
% ---------------------------------------------------------------------
% multsdata_u Deformation fields
% ---------------------------------------------------------------------
multsdata_u         = cfg_files;
multsdata_u.tag     = 'multsdata_u';
multsdata_u.name    = 'Flow fields';
multsdata_u.help    = {'Flow fields.'}; 
multsdata_u.filter  = 'image';
multsdata_u.ufilter = '.*';
multsdata_u.num     = [1 Inf];
% ---------------------------------------------------------------------
% multsdata Data
% ---------------------------------------------------------------------
multsdata = cfg_branch;
multsdata.tag = 'multsdata';
multsdata.name = 'Data';
multsdata.val = {multsdata_gm multsdata_wm multsdata_f multsdata_u};
% ---------------------------------------------------------------------
%
% ---------------------------------------------------------------------
nrm = tbx_cfg_dartel;
for i=1:numel(nrm.values)
     if strcmp(nrm.values{i}.tag, 'mni_norm')
         nrm = nrm.values{i};
         break
     end
end

eval(['nrm' cfg_expr(nrm, 'data') '=multsdata;']);
eval(['nrm' regexprep(cfg_expr(nrm, 'preserve'), '{([0-9]+)}$', '($1)') '=[];']);

nrm.prog  = @spm_dartel_norm_fun_local;
nrm.vout  = @vout_norm_fun;
nrm.check = []; % @check_norm_fun;

% ---------------------------------------------------------------------
% dartel DARTEL Tools
% ---------------------------------------------------------------------
dartel         = cfg_choice;
dartel.tag     = 'dartel';
dartel.name    = 'Maps preprocessing - "DARTEL"';
dartel.help    = {
                  'This toolbox is based around the ``A Fast Diffeomorphic Registration Algorithm'''' paper/* \cite{ashburner07} */. The idea is to register images by computing a ``flow field'''', which can then be ``exponentiated'''' to generate both forward and backward deformations. Currently, the software only works with images that have isotropic voxels, identical dimensions and which are in approximate alignment with each other. One of the reasons for this is that the approach assumes circulant boundary conditions, which makes modelling global rotations impossible. Another reason why the images should be approximately aligned is because there are interactions among the transformations that are minimised by beginning with images that are already almost in register. This problem could be alleviated by a time varying flow field, but this is currently computationally impractical.'
                  'Because of these limitations, images should first be imported. This involves taking the ``*_seg_sn.mat'''' files produced by the segmentation code of SPM5, and writing out rigidly transformed versions of the tissue class images, such that they are in as close alignment as possible with the tissue probability maps. Rigidly transformed original images can also be generated, with the option to have skull-stripped versions.'
                  'The next step is the registration itself.  This can involve matching single images together, or it can involve the simultaneous registration of e.g. GM with GM, WM with WM and 1-(GM+WM) with 1-(GM+WM) (when needed, the 1-(GM+WM) class is generated implicitly, so there is no need to include this class yourself). This procedure begins by creating a mean of all the images, which is used as an initial template. Deformations from this template to each of the individual images are computed, and the template is then re-generated by applying the inverses of the deformations to the images and averaging. This procedure is repeated a number of times.'
                  'Finally, warped versions of the images (or other images that are in alignment with them) can be generated. '
                  ''
                  'This toolbox is not yet seamlessly integrated into the SPM package. Eventually, the plan is to use many of the ideas here as the default strategy for spatial normalisation. The toolbox may change with future updates.  There will also be a number of other (as yet unspecified) extensions, which may include a variable velocity version (related to LDDMM). Note that the Fast Diffeomorphism paper only describes a sum of squares objective function. The multinomial objective function is an extension, based on a more appropriate model for aligning binary data to a template.'
}';
dartel.values  = {warp warp1 nrm }; %crt_warped jacdet crt_iwarped kernfun 
%dartel.num     = [0 Inf];

%---------------------------
% SHOOT TOOLS
%---------------------------
shoot         = cfg_choice;
shoot.tag     = 'shoot';
shoot.name    = 'Maps preprocessing - "SHOOT"';
shoot.help    = {
                   'This toolbox is based around the ``Diffeomorphic Registration using Geodesic Shooting and Gauss-Newton Optimisation'''' paper, which has been submitted to NeuroImage. The idea is to register images by estimating an initial velocity field, which can then be integrated to generate both forward and backward deformations.  Currently, the software only works with images that have isotropic voxels, identical dimensions and which are in approximate alignment with each other. One of the reasons for this is that the approach assumes circulant boundary conditions, which makes modelling global rotations impossible. Because of these limitations, the registration should be based on images that have first been ``imported'''' via the New Segment toolbox.'
                  'The next step is the registration itself, which involves the simultaneous registration of e.g. GM with GM, WM with WM and 1-(GM+WM) with 1-(GM+WM) (when needed, the 1-(GM+WM) class is generated implicitly, so there is no need to include this class yourself). This procedure begins by creating a mean of all the images, which is used as an initial template. Deformations from this template to each of the individual images are computed, and the template is then re-generated by applying the inverses of the deformations to the images and averaging. This procedure is repeated a number of times.'
                  ''
                  'This toolbox should be considered as only a beta (trial) version, and will include a number of (as yet unspecified) extensions in future updates.  Please report any bugs or problems to the SPM mailing list.'

}';
shoot.values  = {warp_shoot warp1_shoot  }; %crt_warped jacdet crt_iwarped kernfun 
%dartel.num     = [0 Inf];

%_______________________________________________________________________
%
% ---------------------------------------------------------------------
% proc proc Preprocess maps
% ---------------------------------------------------------------------
proc         = cfg_choice;
proc.tag     = 'proc';
proc.name    = 'Process maps';
proc.help    = {
                'Parameter maps are registered to standard space, scaled and ready for voxel-based quantitative (VBQ) analysis.'
}';
proc.values  = {preproc8 dartel shoot};    %shoot scale
% ---------------------------------------------------------------------
% vbq VBQ Tools
% ---------------------------------------------------------------------
vbq         = cfg_choice;
vbq.tag     = 'VBQ';
vbq.name    = 'VBQ Tools';
vbq.help    = {
                  'This toolbox is based around the ``Regional specificity of MRI contrast ... (VBQ)'' paper by Draganski et al., 2011 NeuroImage and ''Unified segmentation based correction... (UNICORT) paper by Weiskopf et al., 2011. '
                  'This toolbox should be considered as only a beta (trial) version, and will include a number of (as yet unspecified) extensions in future updates.  Please report any bugs or problems to lreninfo@gmail.com.'
}';
vbq.values  = {crm proc };

%______________________________________________________________________

% functions segment & register
%_______________________________________________________________________
%======================================================================
function job=preproc_perimage_to_persubject(job)
    if isfield(job, 'many_few_sdatas')
        if isfield(job.many_few_sdatas, 'subjc')
            job.subjc = job.many_few_sdatas.subjc;
        else
            for i=1:numel(job.many_few_sdatas.many_sdatas.struct.s_vols)
                job.subjc(i).output = job.many_few_sdatas.many_sdatas.output;
                job.subjc(i).struct = job.many_few_sdatas.many_sdatas.struct;
                job.subjc(i).struct.s_vols = job.many_few_sdatas.many_sdatas.struct.s_vols(i);
                job.subjc(i).maps.mp_vols = {};
                for k=1:numel(job.many_few_sdatas.many_sdatas.mp_vols)
                    job.subjc(i).maps.mp_vols{end+1} = job.many_few_sdatas.many_sdatas.mp_vols{k}{i};
                end
            end
        end
    end


function out = spm_local_preproc_run(job)

job=preproc_perimage_to_persubject(job);

for i=1:numel(job.tissue)
    out.tiss(i).c = {};
    out.tiss(i).rc = {};
end

for i=1:numel(job.subjc(1).maps.mp_vols)
    out.maps(i).mp_vols = {};
end

for nm=1:length(job.subjc)
    defsa.channel = job.subjc(nm).struct(1);
    defsa.channel.vols = job.subjc(nm).struct(1).s_vols;
    defsa.tissue  = job.tissue;
    defsa.warp    = job.warp;
    out.subjc(nm) = spm_preproc_run(defsa);  
    defs.comp{1}.def = strcat(spm_str_manip(job.subjc(nm).struct(1).s_vols,'h'),filesep,'y_',spm_str_manip(job.subjc(nm).struct(1).s_vols,'tr'),'.nii');
    % defs.ofname = '';
    defs.out{1}.pull.fnames = cellstr(char(strvcat(job.subjc(nm).maps.mp_vols{:})));
    if isfield(job.subjc(nm).output,'indir') && job.subjc(nm).output.indir == 1
        defs.out{1}.pull.savedir.saveusr{1}=spm_str_manip(job.subjc(nm).maps.mp_vols{1},'h');
    else
        defs.out{1}.savedir.saveusr{1}=job.subjc(nm).output.outdir{1};
    end
    defs.out{1}.pull.interp = 1;
    defs.out{1}.pull.mask = 1;
    defs.out{1}.pull.fwhm = [0 0 0];
    outdef = spm_deformations(defs);
    
    for i=1:numel(out.subjc(1).tiss)
        if isfield(out.subjc(nm).tiss(i), 'c')
            out.tiss(i).c = [out.tiss(i).c; out.subjc(nm).tiss(i).c];
        end
        if isfield(out.subjc(nm).tiss(i), 'rc')
            out.tiss(i).rc = [out.tiss(i).rc; out.subjc(nm).tiss(i).rc];
        end
    end
    for i=1:numel(outdef.warped)
        out.maps(i).mp_vols{end+1} = outdef.warped{i};
    end
    
    for i=1:length(outdef.warped)
        if isfield(job.subjc(nm).output,'indir') && job.subjc(nm).output.indir == 1
            p=spm_str_manip(job.subjc(nm).maps.mp_vols{1},'h');
        else
            p=job.subjc(nm).output.outdir{1};
        end
        c1=insert_pref(job.subjc(nm).struct(1).s_vols{1},'mwc1');
        c2=insert_pref(job.subjc(nm).struct(1).s_vols{1},'mwc2');
        f =insert_pref(job.subjc(nm).maps.mp_vols{i},'w');  % removed s f=outdef.warped{i};
        c =spm_imcalc(strvcat(char(c1),char(c2)),insert_pref(f,'bb_'),'(i1+i2)'); c=c.fname;
        m_c1 = [spm_select('FPList',fullfile(spm('Dir'),'tpm'),'^TPM.nii') ',1'];
        m_c2 = [spm_select('FPList',fullfile(spm('Dir'),'tpm'),'^TPM.nii') ',2'];
        m_c = [spm_select('FPList',fullfile(spm('Dir'),'tpm'),'^TPM.nii') ',6'];
        p1= spm_imcalc(strvcat(char(c1),char(f),m_c1),insert_pref(f,'p1_'),'(i1.*i2).*(i3>0.05)'); p1=p1.fname;
        p2= spm_imcalc(strvcat(char(c2),char(f),m_c2),insert_pref(f,'p2_'),'(i1.*i2).*(i3>0.05)'); p2=p2.fname;
        pp = spm_imcalc(strvcat(char(c),char(f),m_c),insert_pref(f,'p_'),'(i1.*i2).*((1-i3)>0.05)'); pp=pp.fname;
        m1=insert_pref(c1,'s');spm_smooth(c1,m1,job.fwhm);
        m2=insert_pref(c2,'s');spm_smooth(c2,m2,job.fwhm);
        m=insert_pref(c,'s');spm_smooth(c,m,job.fwhm);
        n1=insert_pref(p1,'s');spm_smooth(p1,n1,job.fwhm);
        n2=insert_pref(p2,'s');spm_smooth(p2,n2,job.fwhm);
        n=insert_pref(pp,'s');spm_smooth(pp,n,job.fwhm);
        q1 = spm_imcalc(strvcat(n1,m1,m1),insert_pref(p1,'fin_uni_'),'(i1./i2).*(i3>0.05)'); q1=q1.fname;
        q2 = spm_imcalc(strvcat(n2,m2,m2),insert_pref(p2,'fin_uni_'),'(i1./i2).*(i3>0.05)'); q2=q2.fname;
        q = spm_imcalc(strvcat(n,m,m),insert_pref(pp,'fin_uni_bb_'),'(i1./i2).*((i3)>0.05)'); q=q.fname;
        delfiles=strrep({c,p1,p2,m1,m2,n1,n2,pp,m,n,q},'.nii,1','.nii');
        for ii=1:numel(delfiles)
    	    delete(delfiles{ii});
        end
    end
    
end


%======================================================================
function dep = vout_preproc(job)
% This depends on job contents, which may not be present when virtual
% outputs are calculated.

cdep = cfg_dep;
% cdep(end).sname      = 'Seg Params';
% cdep(end).src_output = substruct('.','param','()',{':'});
% cdep(end).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});

% for nm=1:numel(job.subjc)
%     for i=1:numel(job.subjc(nm).struct),
%         if job.subjc(nm).struct(i).write(1),
%             cdep(end+1)          = cfg_dep;
%             cdep(end).sname      = sprintf('Bias Field (%d)',i);
%             cdep(end).src_output = substruct('.','data','()',{i},'.','biasfield','()',{':'});
%             cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
%         end
%         if job.subjc(nm).struct(i).write(2),
%             cdep(end+1)          = cfg_dep;
%             cdep(end).sname      = sprintf('Bias Corrected (%d)',i);
%             cdep(end).src_output = substruct('.','data','()',{i},'.','biascorr','()',{':'});
%             cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
%         end
%     end
% end

if isfield(job, 'many_few_sdatas')
    if isfield(job.many_few_sdatas, 'subjc')
        job.subjc = job.many_few_sdatas.subjc;
    else
         dep = cfg_dep;
         for i=1:numel(job.tissue)
             if job.tissue(i).native(1)
                dep(end+1) = cfg_dep; %#ok<AGROW>
                dep(end).sname = sprintf('c%d Images', i);
                dep(end).src_output = substruct('.', 'tiss', '()', {i}, '.', 'c', '()', {':'});
                dep(end).tgt_spec = cfg_findspec({{'filter','image','strtype','e'}});
             end
             if job.tissue(i).native(2)
                dep(end+1) = cfg_dep; %#ok<AGROW>
                dep(end).sname = sprintf('rc%d Images', i);
                dep(end).src_output = substruct('.', 'tiss', '()', {i}, '.', 'rc', '()', {':'});
                dep(end).tgt_spec = cfg_findspec({{'filter','image','strtype','e'}});
             end
         end
        
         disp(job.many_few_sdatas);
         for i=1:numel(job.many_few_sdatas.many_sdatas.mp_vols)
            dep(end+1) = cfg_dep; %#ok<AGROW>
            dep(end).sname = sprintf('%d Parameter Volumes', i);
            dep(end).src_output = substruct('.', 'maps', '()', {i}, '.', 'mp_vols', '()', {':'});
            dep(end).tgt_spec = cfg_findspec({{'filter','image','strtype','e'}});
         end
         
         dep = dep(2:end);

        return;
    end
end

for nm=1:numel(job.subjc)
    for i=1:numel(job.tissue),
        if job.tissue(i).native(1),
            cdep(end+1)          = cfg_dep;
            cdep(end).sname      = sprintf('c%d_subj%d Images',i,nm);
            cdep(end).src_output = substruct('.','subjc','()',{nm},'.','tiss','()',{i},'.','c','()',{':'});
            cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
        end
        if job.tissue(i).native(2),
            cdep(end+1)          = cfg_dep;
            cdep(end).sname      = sprintf('rc%d_subj%d Images',i,nm);
            cdep(end).src_output = substruct('.','subjc','()',{nm},'.','tiss','()',{i},'.','rc','()',{':'});
            cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
        end
    end
    for i=1:numel(job.subjc(nm).maps.mp_vols)
        cdep(end+1)          = cfg_dep;
        cdep(end).sname      = sprintf('%d_subj%d Parameter Volumes',i,nm);
        cdep(end).src_output = substruct('.','subjc','()',{nm},'.','maps','.','mp_vols','()',{i});
        cdep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
    end
    
end
dep = cdep;
%_______________________________________________________________________

function dep = vout_crt(job)
% This depends on job contents, which may not be present when virtual
% outputs are calculated.

% job = process_data_spec(job);

if ~isfield(job, 'subj') % Many subjects
    dep(1) = cfg_dep;
    dep(1).sname = 'R1 Maps';
    dep(1).src_output = substruct('.','R1','()',{':'});
    dep(1).tgt_spec = cfg_findspec({{'filter','image','strtype','e'}});
    
    dep(2) = cfg_dep;
    dep(2).sname = 'R1u Maps';
    dep(2).src_output = substruct('.','R1u','()',{':'});
    dep(2).tgt_spec = cfg_findspec({{'filter','image','strtype','e'}});
    
    dep(3) = cfg_dep;
    dep(3).sname = 'R2s Maps';
    dep(3).src_output = substruct('.','R2s','()',{':'});
    dep(3).tgt_spec = cfg_findspec({{'filter','image','strtype','e'}});
    
    dep(4) = cfg_dep;
    dep(4).sname = 'MT Maps';
    dep(4).src_output = substruct('.','MT','()',{':'});
    dep(4).tgt_spec = cfg_findspec({{'filter','image','strtype','e'}});
    
    dep(5) = cfg_dep;
    dep(5).sname = 'A Maps';
    dep(5).src_output = substruct('.','A','()',{':'});
    dep(5).tgt_spec = cfg_findspec({{'filter','image','strtype','e'}});
    
    dep(6) = cfg_dep;
    dep(6).sname = 'T1w Maps';
    dep(6).src_output = substruct('.','T1w','()',{':'});
    dep(6).tgt_spec = cfg_findspec({{'filter','image','strtype','e'}});
   
    return;
end

k=1;
for i=1:numel(job.subj)
    
    cdep(k)            = cfg_dep;
    cdep(k).sname      = sprintf('R1_subj%d',i);
    cdep(k).src_output = substruct('.','subj','()',{i},'.','R1','()',{':'});
    cdep(k).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
    
    k=k+1;
    
    cdep(k)          = cfg_dep;
    cdep(k).sname      = sprintf('R1u_subj%d',i);
    cdep(k).src_output = substruct('.','subj','()',{i},'.','R1u','()',{':'});
    cdep(k).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
    
     k=k+1;
    
    cdep(k)            = cfg_dep;
    cdep(k).sname      = sprintf('R2s_subj%d',i);
    cdep(k).src_output = substruct('.','subj','()',{i},'.','R2s','()',{':'});
    cdep(k).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
    
     k=k+1;
    
    cdep(k)            = cfg_dep;
    cdep(k).sname      = sprintf('MT_subj%d',i);
    cdep(k).src_output = substruct('.','subj','()',{i},'.','MT','()',{':'});
    cdep(k).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
   
     k=k+1;
    
    cdep(k)            = cfg_dep;
    cdep(k).sname      = sprintf('A_subj%d',i);
    cdep(k).src_output = substruct('.','subj','()',{i},'.','A','()',{':'});
    cdep(k).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
    
     k=k+1;
    
    cdep(k)            = cfg_dep;
    cdep(k).sname      = sprintf('T1w_subj%d',i);
    cdep(k).src_output = substruct('.','subj','()',{i},'.','T1w','()',{':'});
    cdep(k).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
    
     k=k+1;
end
dep = cdep;
%_______________________________________________________________________

function dep = vout_crt1(job)
% This depends on job contents, which may not be present when virtual
% outputs are calculated.

if ~isfield(job, 'subj') % Many subjects
    dep(1) = cfg_dep;
    dep(1).sname = 'R1 Maps';
    dep(1).src_output = substruct('.','R1','()',{':'});
    dep(1).tgt_spec = cfg_findspec({{'filter','image','strtype','e'}});
    
    dep(2) = cfg_dep;
    dep(2).sname = 'R2s Maps';
    dep(2).src_output = substruct('.','R2s','()',{':'});
    dep(2).tgt_spec = cfg_findspec({{'filter','image','strtype','e'}});
    
    dep(3) = cfg_dep;
    dep(3).sname = 'MT Maps';
    dep(3).src_output = substruct('.','MT','()',{':'});
    dep(3).tgt_spec = cfg_findspec({{'filter','image','strtype','e'}});
    
    dep(4) = cfg_dep;
    dep(4).sname = 'A Maps';
    dep(4).src_output = substruct('.','A','()',{':'});
    dep(4).tgt_spec = cfg_findspec({{'filter','image','strtype','e'}});
    
    dep(5) = cfg_dep;
    dep(5).sname = 'T1w Maps';
    dep(5).src_output = substruct('.','T1w','()',{':'});
    dep(5).tgt_spec = cfg_findspec({{'filter','image','strtype','e'}});
   
    return;
end

k=1;

for i=1:numel(job.subj)

    cdep(k)            = cfg_dep;
    cdep(k).sname      = sprintf('R1_subj%d',i);
    cdep(k).src_output = substruct('.','subj','()',{i},'.','R1','()',{':'});
    cdep(k).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
    
    k=k+1;
     
    cdep(k)            = cfg_dep;
    cdep(k).sname      = sprintf('R2s_subj%d',i);
    cdep(k).src_output = substruct('.','subj','()',{i},'.','R2s','()',{':'});
    cdep(k).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
    
     k=k+1;
    
    cdep(k)            = cfg_dep;
    cdep(k).sname      = sprintf('MT_subj%d',i);
    cdep(k).src_output = substruct('.','subj','()',{i},'.','MT','()',{':'});
    cdep(k).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
   
     k=k+1;
    
    cdep(k)            = cfg_dep;
    cdep(k).sname      = sprintf('A_subj%d',i);
    cdep(k).src_output = substruct('.','subj','()',{i},'.','A','()',{':'});
    cdep(k).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
    
     k=k+1;
    
    cdep(k)            = cfg_dep;
    cdep(k).sname      = sprintf('T1w_subj%d',i);
    cdep(k).src_output = substruct('.','subj','()',{i},'.','T1w','()',{':'});
    cdep(k).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
    
     k=k+1;
end
dep = cdep;


%_______________________________________________________________________

%_______________________________________________________________________
function chk = check_dartel_template(job)
n1 = numel(job.images);
n2 = numel(job.images{1});
chk = '';
for i=1:n1,
    if numel(job.images{i}) ~= n2,
        chk = 'Incompatible number of images';
        break;
    end;
end;
%_______________________________________________________________________

%_______________________________________________________________________
function dep = vout_dartel_template(job)

if isa(job.settings.template,'cfg_dep') || ~ ...
        isempty(deblank(job.settings.template))
    for it=0:numel(job.settings.param),
        tdep(it+1)            = cfg_dep;
        tdep(it+1).sname      = sprintf('Template (Iteration %d)', it);
        tdep(it+1).src_output = substruct('.','template','()',{it+1});
        tdep(it+1).tgt_spec   = cfg_findspec({{'filter','nifti'}});
    end
else
    tdep = cfg_dep;
    tdep = tdep(false);
end

for i=1:numel(job.images{1})
    fdep(i)            = cfg_dep;
    fdep(i).sname      = sprintf('Flow Field_subj%d',i);
    fdep(i).src_output = substruct('.','files','()',{i});
    fdep(i).tgt_spec   = cfg_findspec({{'filter','nifti'}});
end
dep = [tdep fdep];
%_______________________________________________________________________

%_______________________________________________________________________
function dep = vout_dartel_warp(job)
for i=1:numel(job.images{1})
    fdep(i)            = cfg_dep;
    fdep(i).sname      = sprintf('Flow Field_subj%d',i);
    fdep(i).src_output = substruct('.','files','()',{i});
    fdep(i).tgt_spec   = cfg_findspec({{'filter','nifti'}});
end
dep = fdep;
%_______________________________________________________________________

function job=perimage_to_persubject(job)
for i=1:numel(job.multsdata.multsdata_gm)
       job.subjd(i).images = {};
       job.subjd(i).images{1} = job.multsdata.multsdata_gm{i};
       job.subjd(i).images{2} = job.multsdata.multsdata_wm{i};
       job.subjd(i).flowfield = {};
       job.subjd(i).flowfield{1} = job.multsdata.multsdata_u{i};
       job.subjd(i).mp_vols = {};
       for j=1:numel(job.multsdata.multsdata_f1)
           job.subjd(i).mp_vols{j} = job.multsdata.multsdata_f1{j}{i};
       end
end

function out = spm_dartel_norm_fun_local(job)

out = struct();

% MFC - Setting up feds structure which has a copy of the (reordered) subject info:
job = perimage_to_persubject(job);

feds.template = job.template;
feds.vox      = job.vox;
feds.bb       = job.bb;
feds.fwhm     = [0 0 0];
for m=1:length(job.subjd)
    feds.data.subj(m).flowfield = job.subjd(m).flowfield;
    feds.data.subj(m).images    = job.subjd(m).images;
end

% MFC - Jacobian modulation correction to preserve total signal intensity:
feds.preserve = 1;

% MFC - Produces mwc* images, i.e. modulated, spatially normalised images.
% This produces w = |Dphi|t(phi), the product of the Jacobian determinants 
% of deformation phi and the tissue class image warped by phi, as per
% Draganski 2011, NeuroImage.  spm_dartel_norm_fun calls dartel3:
spm_dartel_norm_fun(feds);

% MFC - Now take the MPMs and do a regular normalisation but don't apply
% Jacobian modulation. Produces ws* images.
for mm=1:length(job.subjd)
    feds.data.subj(mm).images    = job.subjd(mm).mp_vols;
end
feds.preserve = 0;
spm_dartel_norm_fun(feds);
for nm=1:length(job.subjd)
    for i=1:length(job.subjd(nm).mp_vols)
        chk=check_entry(job.subjd(nm));
        if ~isempty(chk)
            error(chk)
        end
        p=spm_str_manip(job.subjd(nm).mp_vols{1},'h');
        c1=insert_pref(job.subjd(nm).images{1},'mw');   % removed s
        c2=insert_pref(job.subjd(nm).images{2},'mw');  % removed s
        f =insert_pref(job.subjd(nm).mp_vols{i},'w');  % removed s
        c =spm_imcalc(strvcat(char(c1),char(c2)),insert_pref(f,'bb_'),'(i1+i2)');
        c = c.fname;
        m_c1 = [spm_select('FPList',fullfile(spm('Dir'),'tpm'),'^TPM.nii') ',1'];
        m_c2 = [spm_select('FPList',fullfile(spm('Dir'),'tpm'),'^TPM.nii') ',2'];
        m_c = [spm_select('FPList',fullfile(spm('Dir'),'tpm'),'^TPM.nii') ',6'];
        p1= spm_imcalc(strvcat(char(c1),char(f),m_c1),insert_pref(f,'p1_'),'(i1.*i2).*(i3>0.05)');
        p1 = p1.fname;
        p2= spm_imcalc(strvcat(char(c2),char(f),m_c2),insert_pref(f,'p2_'),'(i1.*i2).*(i3>0.05)');
        p2 = p2.fname;
        pp = spm_imcalc(strvcat(char(c),char(f),m_c),insert_pref(f,'p_'),'(i1.*i2).*((1-i3)>0.05)');
        pp = pp.fname;
        m1=insert_pref(c1,'s');spm_smooth(c1,m1,job.fwhm);
        m2=insert_pref(c2,'s');spm_smooth(c2,m2,job.fwhm);
        m=insert_pref(c,'s');spm_smooth(c,m,job.fwhm);
        n1=insert_pref(p1,'s');spm_smooth(p1,n1,job.fwhm);
        n2=insert_pref(p2,'s');spm_smooth(p2,n2,job.fwhm);
        n=insert_pref(pp,'s');spm_smooth(pp,n,job.fwhm);
        q1 = spm_imcalc(strvcat(n1,m1,m1),insert_pref(p1,'fin_dart_'),'(i1./i2).*(i3>0.05)');
        q2 = spm_imcalc(strvcat(n2,m2,m2),insert_pref(p2,'fin_dart_'),'(i1./i2).*(i3>0.05)');
        q = spm_imcalc(strvcat(n,m,m),insert_pref(pp,'fin_dart_bb_'),'(i1./i2).*((i3)>0.05)');
        q = q.fname;
        delfiles=strrep({c,p1,p2,m1,m2,n1,n2,pp,m,n,q},'.nii,1','.nii');
	for ii=1:numel(delfiles)
            delete(delfiles{ii});
        end
    end
end


function dep=vout_norm_fun(job)
    dep = cfg_dep;

%======================================================================
function fout=insert_pref(f,p)
fout=strcat(spm_str_manip(f,'h'),filesep,p,spm_str_manip(f,'t'));
%======================================================================
function chk = check_entry(job)
n1 = numel(job.images);
chk = '';
n2 = sum(~cellfun('isempty',regexp(spm_str_manip(job.images,'t'),'(^c1|^c2).*.nii')));
if n1 ~= 2,
    chk = 'Wrong input - should be c1 and c2';
end
if n2 ~= 2,
    chk = 'Wrong input - should be c1 and c2';
end



function c = unlimit(c)
try
    if isa(c, 'cfg_files')
        c.num = [0 Inf];
    end
catch e
end
try
    for i=1:numel(c.val)
        c.val{i} = unlimit(c.val{i});
    end
catch e
end

function expr=cfg_expr(c, varargin) %#ok<INUSL>
    expr = 'c';
    for i=1:size(varargin,2)
        if strcmp(class(varargin{i}), 'double')
            expr = [expr '.val{' num2str(varargin{i}) '}']; %#ok<AGROW>
        else
            v = eval([expr ';']);
            for j=1:size(v.val,2)
                if strcmp(v.val{j}.tag, varargin{i})
                    break
                end
            end
            expr = [expr '.val{' num2str(j) '}']; %#ok<AGROW>
        end
    end
    expr = expr(2:end);
    
    
function expr=cfg_expr_values(c, varargin) %#ok<INUSL>
    expr = 'c';
    for i=1:size(varargin,2)
        if strcmp(class(varargin{i}), 'double')
            expr = [expr '.values{' num2str(varargin{i}) '}']; %#ok<AGROW>
        else
            v = eval([expr ';']);
            for j=1:size(v.values,2)
                if strcmp(v.values{j}.tag, varargin{i})
                    break
                end
            end
            expr = [expr '.values{' num2str(j) '}']; %#ok<AGROW>
        end
    end
    expr = expr(2:end);

function c=cfg_set_val(c, varargin)
    expr = ['c' cfg_expr(c, varargin{1:end-1})];
    eval([expr '.val={varargin{end}};']);

