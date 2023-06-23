% AISLER_SMA_V2 OpenEMS sim. script: SMA Coaxial to Microstrip on Aisler 6Layer
%
%   Simulates a Rosenberger 32K242-40ML5 SMA Connector on an AISLER 6Layer HD 
%   Stackup
%
%   Simulation time: approx. 20min (depending on the mesh settings)
%
%
% BSD 2-Clause License
% Copyright (c) 2023, Tobias Ammann
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

close all
clear
clc
addpath('../CTB');

confirm_recursive_rmdir(0);

% ------------------------------------------------------------------------------
% - 
% - Simulation Control 
% - 
% ------------------------------------------------------------------------------
% Result touchsonte filename
#result_filename = 'rosenberger_32K242-40ML5_on_aisler_6layer_v2_final';
result_filename = 'tmp';

% Excitation
run_sim = false;
smooth_mesh = true;
deemb_p2 = true;

excite_p1 = true;
excite_p2 = true;

% Model view
show_structure_p1 = true;
show_structure_p2 = false;

% Output and Debug
write_field_dumps = true;

f_start = 0e9;
f_stop  = 30e9;
end_criteria_energy = -33; %dB

mesh_res_edge = 0.02;
minFixedMeshDist = mesh_res_edge;
mes_res_lambda_div = 20*3;

##mesh_res_edge = 0;
##minFixedMeshDist = 0.02;
%mes_res_lambda_div = 40;

BC = {'PML_8' 'PML_8' 'MUR' 'MUR' 'PML_8' 'PML_8'};

% ------------------------------------------------------------------------------
% - 
% - Simulation Path and import
% - 
% ------------------------------------------------------------------------------

sim_p1_path = 'sim_res_p1';
sim_p1_CSX = 'p1.xml';

sim_p2_path = 'sim_res_p2';
sim_p2_CSX = 'p2.xml';

mkdir(sim_p1_path);
mkdir(sim_p2_path);

mydir  = pwd;
idcs   = strfind(mydir, filesep);
parentDir = mydir(1:idcs(end)-1);

model_dir = [parentDir, filesep, 'FreeCAD_Aisler6LayerHD_SMA_v2'];
model_dir = strrep(model_dir, '\', '\\');
filesep_dbl = '\\';

% Load parameters from FreeCAD spreadsheet
[p, p_desc] = parse_freecad_spr_param([model_dir, filesep, 'param.txt'],  '\t');

% ------------------------------------------------------------------------------
% - 
% - Simulation Model Parameters 
% - 
% ------------------------------------------------------------------------------

% Pysical constants
c0 = 299792458; % m/s
MUE0 = 4e-7*pi; % N/A^2
EPS0 = 1/(MUE0*c0^2); % F/m

% Undersize the z-coordiante of the metal layers as suggested by Thorsten Liebing
% To compensate for floating point issues in  the stl import
% https://github.com/thliebig/openEMS-Project/discussions/43
float_tol = 100e-9; % units [mm]
%float_tol = 0.005; % units [mm]
#float_tol = 0;

unit = 1e-3; % all units in [mm]

Er_lambda = 1;

lambda = c0/(f_stop*sqrt(Er_lambda));
mesh_res = lambda/unit/mes_res_lambda_div;

% Simulation setup
FDTD = InitFDTD('endCriteria', 10^(end_criteria_energy/10));
FDTD = SetGaussExcite(FDTD,0.5*(f_start+f_stop),0.5*(f_stop-f_start));
FDTD = SetBoundaryCond( FDTD, BC );
CSX = InitCSX();

% Microstrip port dimensions
deemb_length_x = 5;
p_msl.length = p.port_length_x;
p_msl.w = p.l01_wg_trace_w;
% At the end of l01_compC_x, shifted by the analytical deembedding 
p_msl.meas_shift = p.pcb_x - (p.slot_x + p.edge_spacing_copper_x + p.l01_pad_x + p.l01_compL_x + p.l01_compC_x) - deemb_length_x;
p_msl.feed_shift = 10*mesh_res;

% Coaxial port dimensions
p_coax.length = 4;
p_coax.rad_i  = p.conn_inner_sec1_y;
p_coax.rad_o  = p.conn_outer_sec1_y;
p_coax.rad_os = p.conn_thread_d/2;
p_coax.meas_shift = p_coax.length - 0.1;
p_coax.feed_shift = 10*mesh_res;;

% ------------------------------------------------------------------------------
% - 
% - Mesh in X-Dimension
% - 
% ------------------------------------------------------------------------------
% PCB 
pos_x_pcb(1) = 0;
pos_x_pcb(2) = p.slot_x - p.edge_plating_th;
pos_x_pcb(3) = p.slot_x;
pos_x_pcb(4) = p.pcb_x;

% Pad and matching structure; apply "Thirds Rule"
pos_x_pad_and_match(1) = p.slot_x                   + p.edge_spacing_copper_x - 2/3*mesh_res_edge;
pos_x_pad_and_match(2) = pos_x_pad_and_match(end)   + mesh_res_edge;

pos_x_pad_and_match(3) = pos_x_pad_and_match(end-1) + 2/3*mesh_res_edge + p.l01_pad_x - 1/3*mesh_res_edge;   
pos_x_pad_and_match(4) = pos_x_pad_and_match(end)   + mesh_res_edge; 

pos_x_pad_and_match(5) = pos_x_pad_and_match(end-1) + 1/3*mesh_res_edge + p.l01_compL_x - 2/3*mesh_res_edge;
pos_x_pad_and_match(6) = pos_x_pad_and_match(end)   + mesh_res_edge;

pos_x_pad_and_match(7) = pos_x_pad_and_match(end-1) + 2/3*mesh_res_edge + p.l01_compC_x - 1/3*mesh_res_edge;
pos_x_pad_and_match(8) = pos_x_pad_and_match(end)   + mesh_res_edge;

pos_x_pad_and_match(9)  = p.edge_spacing_via_x + p.via_cp_d * 5 - p.via_cp_d/5;
pos_x_pad_and_match(10) = p.edge_spacing_via_x + p.via_cp_d * 5 - p.via_cp_d/5 + p.l01_gnd_trans_taper_len_x;

% Mesh lines for the body features of the inner conductor
pos_x_conn_inner =  p.conn_inner_ext;
pos_x_conn_inner = [pos_x_conn_inner, pos_x_conn_inner(end) - p.conn_inner_sec6_x];
pos_x_conn_inner = [pos_x_conn_inner, pos_x_conn_inner(end) - p.conn_inner_sec5_x];
pos_x_conn_inner = [pos_x_conn_inner, pos_x_conn_inner(end) - p.conn_inner_sec4_x];
pos_x_conn_inner = [pos_x_conn_inner, pos_x_conn_inner(end) - p.conn_inner_sec3_x];
pos_x_conn_inner = [pos_x_conn_inner, pos_x_conn_inner(end) - p.conn_inner_sec2_x];
pos_x_conn_inner = [pos_x_conn_inner, pos_x_conn_inner(end) - p.conn_inner_sec1_x];

% Mesh lines for the body features of the outer conductor and the substrate
pos_x_conn_outer(1) = 0;
pos_x_conn_outer(2) = -p.conn_sub_l_red;
pos_x_conn_outer(3) = pos_x_conn_outer(end) - p.conn_outer_sec4_x;
pos_x_conn_outer(4) = pos_x_conn_outer(end) - p.conn_outer_sec3_x;
pos_x_conn_outer(5) = pos_x_conn_outer(end) - p.conn_outer_sec2_x;
pos_x_conn_outer(6) = pos_x_conn_outer(end) - p.conn_outer_sec1_x;

% Move mesh lines to the position of the connector
pos_x_conn_inner = pos_x_conn_inner + p.slot_x - p.edge_plating_th;
pos_x_conn_outer = pos_x_conn_outer + p.slot_x - p.edge_plating_th;

% Via_Trans_region - lower vias
pos_x_vias_trans(1) = p.slot_x + p.edge_spacing_via_x + (p.via_cp_d - p.via_d)/2;
pos_x_vias_trans(2) = pos_x_vias_trans(end) + p.via_d;

pos_x_vias_trans(3) = pos_x_vias_trans(end-1) + p.via_pitch;
pos_x_vias_trans(4) = pos_x_vias_trans(end)   + p.via_d;

pos_x_vias_trans(5) = pos_x_vias_trans(end-1) + p.via_pitch;
pos_x_vias_trans(6) = pos_x_vias_trans(end)   + p.via_d;

pos_x_vias_trans(7) = pos_x_vias_trans(end-1) + p.via_pitch;
pos_x_vias_trans(8) = pos_x_vias_trans(end)   + p.via_d;

pos_x_vias_trans(9) = pos_x_vias_trans(end-1) + p.via_pitch;
pos_x_vias_trans(10) = pos_x_vias_trans(end)   + p.via_d;

pos_x_vias_trans(11) = pos_x_vias_trans(end) + p.via_d;

% Via Fence
tmp_y1 = p.l01_wg_trace_gndfree / 2 + p.via_pitch / 2;
tmp_y2 = p.l01_pad_y / 2 + p.l01_pad2gnd_spacing_y + p.via_cp_d / 2 + sqrt(3 / 4) * p.via_pitch;
vias_fence_delta_y = tmp_y1 - tmp_y2;

pos_x_vias_fence(1) = pos_x_vias_trans(end) - p.via_d + sqrt(p.via_pitch^2 - vias_fence_delta_y^2);
pos_x_vias_fence(2) = pos_x_vias_fence(end) + p.via_d;

pos_x_vias_fence(3) = pos_x_vias_fence(end-1) + p.via_pitch;
pos_x_vias_fence(4) = pos_x_vias_fence(end)   + p.via_d;

pos_x_vias_fence(5) = pos_x_vias_fence(end-1) + p.via_pitch;
pos_x_vias_fence(6) = pos_x_vias_fence(end)   + p.via_d;

pos_x_vias_fence(7) = pos_x_vias_fence(end-1) + p.via_pitch;
pos_x_vias_fence(8) = pos_x_vias_fence(end)   + p.via_d;

% Mesh lines for the ports (coaxial and microstrip)
pos_x_ports = [min(pos_x_conn_inner) - p_coax.length,...
               p.pcb_x - p_msl.length];

# Collect all positions
pos_x  = [  pos_x_ports,...
            pos_x_pcb,...
            pos_x_conn_outer,...
            pos_x_conn_inner,...
            pos_x_pad_and_match,...
            pos_x_vias_trans(1:6),...
            pos_x_vias_fence,...
            ];

% Skip / delete fixed mesh lines with a distance smaller than minFixedMeshDist
% Keep the one with the lowest index (assume the highest priority)
pos_x = skipFixedMeshLine(pos_x, minFixedMeshDist);
pos_x = sort(pos_x);

% Define a range to mesh with a finer resultion than the restoredefaultpath
% Use the fine resolution in areas with dense mesh lines defined by pos_x
[~, idx_mposfine_x_min] = min(abs(pos_x - pos_x_conn_outer(2)));
[~, idx_mposfine_x_max] = min(abs(pos_x - pos_x_vias_fence(3)));

% Extract the meshlines in the fine area
pos_x_fine = pos_x(idx_mposfine_x_min:idx_mposfine_x_max);

% The delete the fine meshlines from pos_x to leave the coarse lines
pos_x_coarse = pos_x;
pos_x_coarse(idx_mposfine_x_min:idx_mposfine_x_max) = [];


# Smooth the fine and coarse mesh
if smooth_mesh
  mesh_x_fine = SmoothMeshLines(pos_x_fine, mesh_res/4);
  mesh.x = sort([mesh_x_fine, pos_x_coarse]);
  mesh.x  = SmoothMeshLines(mesh.x, mesh_res);
else
  mesh.x = pos_x;
end

% ------------------------------------------------------------------------------
% - 
% Mesh in Y-Dimension
% - 
% ------------------------------------------------------------------------------

% PCB 
pos_y_pcb(1) = p.pcb_y/2;

% Pad, matching structure and GND plane; apply "Thirds Rule"
pos_y_pad_and_match(1) = 0;
pos_y_pad_and_match(2) = p.l01_compL_y/2 - 1/3*mesh_res_edge;
pos_y_pad_and_match(3) = pos_y_pad_and_match(end) + mesh_res_edge;

pos_y_pad_and_match(4) = p.l01_wg_trace_w/2 - 1/3*mesh_res_edge;   
pos_y_pad_and_match(5) = pos_y_pad_and_match(end) + mesh_res_edge;

pos_y_pad_and_match(6) = p.l01_pad_y/2 - 1/3*mesh_res_edge;
pos_y_pad_and_match(7) = pos_y_pad_and_match(end) + mesh_res_edge;

pos_y_pad_and_match(8) = p.l01_compC_y/2 - 1/3*mesh_res_edge;
pos_y_pad_and_match(9) = pos_y_pad_and_match(end) + mesh_res_edge;

pos_y_pad_and_match(10) = p.l01_pad_y/2 + p.l01_pad2gnd_spacing_y - 2/3*mesh_res_edge;
pos_y_pad_and_match(11) = pos_y_pad_and_match(end) + mesh_res_edge;

pos_y_pad_and_match(12) = p.l01_wg_trace_gndfree/2 - 2/3*mesh_res_edge;
pos_y_pad_and_match(13) = pos_y_pad_and_match(end) + mesh_res_edge;

% Mesh lines for the body features of the inner conductor
pos_y_conn_inner(1) = 0;
pos_y_conn_inner(2) = p.conn_inner_sec6_y;
pos_y_conn_inner(3) = p.conn_inner_sec5_y;
#pos_y_conn_inner(4) = p.conn_inner_sec4_y; %overdetermined
pos_y_conn_inner(4) = p.conn_inner_sec3_y;
pos_y_conn_inner(5) = p.conn_inner_sec2_y;
pos_y_conn_inner(6) = p.conn_inner_sec1_y;

pos_y_conn_outer(1) = 0;
pos_y_conn_outer(2) = p.conn_outer_sec4_y;
pos_y_conn_outer(3) = p.conn_outer_sec3_y;
pos_y_conn_outer(4) = p.conn_outer_sec2_y;
pos_y_conn_outer(5) = p.conn_outer_sec1_y;

% Vias in transition region 
pos_y_vias_trans(1) = p.l01_pad_y/2 + p.l01_pad2gnd_spacing_y + (p.via_cp_d - p.via_d)/2;
pos_y_vias_trans(2) = pos_y_vias_trans(end) + p.via_d;
pos_y_vias_trans(3) = pos_y_vias_trans(end) + sqrt(3/4)*p.via_pitch;
#pos_y_vias_trans(4) = pos_y_vias_trans(end) - p.via_d; % skipp line

% Via fence
pos_y_vias_fence(1) = pos_y_vias_trans(3) - p.via_d + vias_fence_delta_y;
pos_y_vias_fence(2) = pos_y_vias_fence(end) + p.via_d;

% GND cutout on layer 3
pos_y_l03_gnd_cutout(1) = p.l03_gnd_ref_cutout_y/2;

# Collect all positions
pos_y  = [ pos_y_pcb,...
           pos_y_l03_gnd_cutout,...
           pos_y_conn_inner,...
           pos_y_conn_outer,...
           pos_y_pad_and_match,...
           pos_y_vias_trans,...
           pos_y_vias_fence,...
            ];

% Skip / delete fixed mesh lines with a distance smaller than minFixedMeshDist
% Keep the one with the lowest index (assume the highest priority)
pos_y = skipFixedMeshLine(pos_y, minFixedMeshDist);
pos_y = sort(pos_y);

% Define a range to mesh with a finer resultion than the restoredefaultpath
% Use the fine resolution in areas with dense mesh lines defined by pos_x
[~,idx_mposfine_y_min] =  min(abs(pos_y - 0));
[~,idx_mposfine_y_max] =  min(abs(pos_y - max(pos_y_vias_fence)));
##[~, idx_mposfine_x_min] = min(abs(pos_x - pos_x_conn_outer(2)));
##[~, idx_mposfine_x_max] =  min(abs(pos_x - pos_x_vias_fence(3)));

% Extract the meshlines in the fine area
pos_y_fine = pos_y(idx_mposfine_y_min:idx_mposfine_y_max);

% The delete the fine meshlines from pos_x to leave the coarse lines
pos_y_coarse = pos_y;
pos_y_coarse(idx_mposfine_y_min:idx_mposfine_y_max) = [];

# Smooth the fine and coarse mesh
if smooth_mesh
  mesh_y_fine = SmoothMeshLines(pos_y_fine, mesh_res/7);
  mesh.y = sort([mesh_y_fine, pos_y_coarse]);
  mesh.y  = SmoothMeshLines(mesh.y, mesh_res);
else
  mesh.y = pos_y;
end

mesh.y = [-flip(mesh.y(2:end)), mesh.y]; %The structure is symmetrical at the xz plane

% ------------------------------------------------------------------------------
% - 
% Mesh in Z-Dimension
% - 
% ------------------------------------------------------------------------------
% Undersize the z-coordiante of the metal layers as suggested by Thorsten Liebing
% To compensate for floating point issues in  the stl import
% https://github.com/thliebig/openEMS-Project/discussions/43

% Decreasing pos_z_stackup(1) = 0 --> the mesher will not hit the solder joint!
# Make sure it is meshed correctly in the PEC dump (PEC_dump.vtp)

% Positions Referenced to top (most negatvie z value of the shape)
pos_z_stackup(1)  = 0               - float_tol;    % Top surface
pos_z_stackup(2)  = p.l01_pos       + float_tol;    % L01 Copper z_min
pos_z_stackup(3)  = p.sub01_pos     - float_tol;    % Prepreg 1080 
pos_z_stackup(4)  = p.l02_pos       + float_tol;    % L02 Copper z_min
pos_z_stackup(5)  = p.sub02_pos     - float_tol;    % Core
pos_z_stackup(6)  = p.l03_pos       + float_tol;    % L03 Copper z_min
pos_z_stackup(7)  = p.sub03_pos     - float_tol;    % Prepreg 7628
pos_z_stackup(8)  = p.l04_pos       + float_tol;    % L04 Copper z_min
pos_z_stackup(9)  = p.sub04_pos     - float_tol;    % Core
pos_z_stackup(10) = p.l05_pos       + float_tol;    % L05 Copper z_min
pos_z_stackup(11) = p.sub05_pos     - float_tol;    % Prepreg 1080
pos_z_stackup(12) = p.l06_pos       + float_tol;    % L06 Copper z_min, bottom layer

% Solder arount the inner connector pin
pos_z_solder_pin =  p.conn_inner_cond_pos_z - float_tol;  % move inwards to ensure at least
                                                          % one mesh line in on the surface 
                                                          %of solder_pin structure

                                                          % Connector inner conductor and solder mesh
% Symmetrical
pos_z_conn_inner =  pos_y_conn_inner(2:end);  % skip the "0" middle point
                                              % save this mesh point for the solder_pin

pos_z_conn_inner = [-flip(pos_z_conn_inner), pos_z_conn_inner]; %The structure is symmetrical
pos_z_conn_inner = pos_z_conn_inner + p.conn_inner_cond_pos_z;

pos_z_conn_outer =  pos_y_conn_outer(2:end); % skip the "0" middle point
pos_z_conn_outer = [-flip(pos_z_conn_outer), pos_z_conn_outer]; %The structure is symmetrical
pos_z_conn_outer = pos_z_conn_outer + p.conn_inner_cond_pos_z;

% Add addional points (e.g distance to boundary condition
pos_z = [  min(pos_z_conn_outer)- lambda/4/unit,...
           pos_z_stackup,...
           pos_z_solder_pin,...
           pos_z_conn_inner,...
           pos_z_conn_outer,...
           max(pos_z_conn_outer) + lambda/2/unit,...
           ];

% Skip / delete fixed mesh lines with a distance smaller than minFixedMeshDist
% Keep the one with the lowest index (assume the highest priority)
pos_z = skipFixedMeshLine(pos_z, minFixedMeshDist);
pos_z = sort(pos_z);

% Define a range to mesh with a finer resultion than the restoredefaultpath
% Use the fine resolution in areas with dense mesh lines defined by pos_x
[~,idx_mposfine_z_min] =  min(abs(pos_z - min(pos_z_conn_outer)));
[~,idx_mposfine_z_max] =  min(abs(pos_z - max(pos_z_conn_outer)));

% Extract the meshlines in the fine area
pos_z_fine = pos_z(idx_mposfine_z_min:idx_mposfine_z_max);

% The delete the fine meshlines from pos_x to leave the coarse lines
pos_z_coarse = pos_z;
pos_z_coarse(idx_mposfine_z_min:idx_mposfine_z_max) = [];

# Smooth the fine and coarse mesh
mesh.z = pos_z;
if smooth_mesh
  mesh_z_fine = SmoothMeshLines(pos_z_fine, mesh_res/4);
  mesh.z = sort([mesh_z_fine, pos_z_coarse]);
  mesh.z  = SmoothMeshLines(mesh.z, mesh_res);
end

% Define Grid
CSX = DefineRectGrid( CSX, unit, mesh);

% ------------------------------------------------------------------------------
% - 
% - Material Definition
% - 
% ------------------------------------------------------------------------------

mat_copper.name = 'Copper';
mat_copper.kappa = 56e6;

mat_prepreg1080.name = 'Prepreg_1080_Panasonic-R-1551-W';
mat_prepreg1080.er = 4.3;
mat_prepreg1080.tand = 0.015;
mat_prepreg1080.kappa = mat_prepreg1080.tand*mat_prepreg1080.er*EPS0*2*pi*(f_stop-f_start)/2;

mat_prepreg7628.name = 'Prepreg_7628_Panasonic-R-1551-W';
mat_prepreg7628.er = 4.6;
mat_prepreg7628.tand = 0.015;
mat_prepreg7628.kappa = mat_prepreg7628.tand*mat_prepreg7628.er*EPS0*2*pi*(f_stop-f_start)/2;

mat_core.name = 'Core_7628_Panasonic-R-1566-W';
mat_core.er = 4.6;
mat_core.tand = 0.015;
mat_core.kappa = mat_core.tand*mat_core.er*EPS0*2*pi*(f_stop-f_start)/2;

mat_teflon.name = 'Teflon';
mat_teflon.er = 2.1;
mat_teflon.tand = 0.002;
mat_teflon.kappa = mat_teflon.tand*mat_teflon.er*EPS0*2*pi*(f_stop-f_start)/2;

%Substrate Materials
CSX = AddMaterial(CSX, mat_teflon.name); % connector substrate
CSX = SetMaterialProperty( CSX, mat_teflon.name, 'Epsilon', mat_teflon.er, 'Kappa', mat_teflon.kappa);

CSX = AddMaterial(CSX, mat_prepreg7628.name);
CSX = SetMaterialProperty( CSX, mat_prepreg7628.name, 'Epsilon', mat_prepreg7628.er, 'Kappa', mat_prepreg7628.kappa);

CSX = AddMaterial(CSX, mat_prepreg1080.name);
CSX = SetMaterialProperty( CSX, mat_prepreg1080.name, 'Epsilon', mat_prepreg1080.er, 'Kappa', mat_prepreg1080.kappa);

CSX = AddMaterial(CSX, mat_core.name);
CSX = SetMaterialProperty( CSX, mat_core.name, 'Epsilon', mat_core.er, 'Kappa', mat_core.kappa);

%Metallic Materials
CSX = AddMetal(CSX, 'PEC');
CSX = AddMetal(CSX, 'PEC_Port'); 
%CSX = AddMetal(CSX, 'conn_inner_cond'); 
%CSX = AddMetal(CSX, 'conn_outer_cond'); 
CSX = AddMetal(CSX, 'Solder_Top_Pin'); 

CSX = AddMaterial(CSX, mat_copper.name);
CSX = SetMaterialProperty( CSX, mat_copper.name, 'Kappa', mat_copper.kappa);

CSX = AddMaterial(CSX, 'Copper_L01');
CSX = SetMaterialProperty( CSX, 'Copper_L01', 'Kappa', mat_copper.kappa);

CSX = AddMaterial(CSX, 'Copper_L02');
CSX = SetMaterialProperty( CSX, 'Copper_L02', 'Kappa', mat_copper.kappa);

CSX = AddMaterial(CSX, 'Copper_L03');
CSX = SetMaterialProperty( CSX, 'Copper_L03', 'Kappa', mat_copper.kappa);

CSX = AddMaterial(CSX, 'Copper_L04');
CSX = SetMaterialProperty( CSX, 'Copper_L04', 'Kappa', mat_copper.kappa);

CSX = AddMaterial(CSX, 'Copper_L05');
CSX = SetMaterialProperty( CSX, 'Copper_L05', 'Kappa', mat_copper.kappa);

CSX = AddMaterial(CSX, 'Copper_L06');
CSX = SetMaterialProperty( CSX, 'Copper_L06', 'Kappa', mat_copper.kappa);

CSX = AddMaterial(CSX, 'Conn_Inner');
CSX = SetMaterialProperty( CSX, 'Conn_Inner', 'Kappa', mat_copper.kappa);

CSX = AddMaterial(CSX, 'Conn_Outer');
CSX = SetMaterialProperty( CSX, 'Conn_Outer', 'Kappa', mat_copper.kappa);


% ------------------------------------------------------------------------------
% - 
% - Import 3D Model
% - 
% ------------------------------------------------------------------------------

% Stackup - L01
CSX = ImportSTL(CSX, 'Copper_L01',         10, [model_dir, filesep_dbl, 'l01_rf_trace.stl']);
CSX = ImportSTL(CSX, 'Copper_L01',         10, [model_dir, filesep_dbl, 'l01_gnd.stl']);
CSX = ImportSTL(CSX, 'PEC',                20, [model_dir, filesep_dbl, 'l01_port_gnd.stl']);

% Stackup - Substrate 01, Prepreg
CSX = ImportSTL(CSX, mat_prepreg1080.name,  1, [model_dir, filesep_dbl, 'sub01_prepreg.stl']);

% Stackup - L02
CSX = ImportSTL(CSX, 'Copper_L02',         10, [model_dir, filesep_dbl, 'l02_gnd.stl']);
CSX = ImportSTL(CSX, 'PEC',                20, [model_dir, filesep_dbl, 'l02_port_gnd.stl']);
CSX = ImportSTL(CSX, mat_prepreg1080.name,  1, [model_dir, filesep_dbl, 'l02_neg.stl']);

% Stackup - Substrate 02, Core
CSX = ImportSTL(CSX, mat_core.name,         2, [model_dir, filesep_dbl, 'sub02_core.stl']);

% Stackup - L03
CSX = ImportSTL(CSX, 'Copper_L03',         10, [model_dir, filesep_dbl, 'l03_gnd.stl']);
CSX = ImportSTL(CSX, mat_prepreg7628.name,  1, [model_dir, filesep_dbl, 'l03_neg.stl']);
CSX = ImportSTL(CSX, 'PEC',                20, [model_dir, filesep_dbl, 'l03_port_gnd.stl']);

% Stackup - Substrate 03, Prepreg
CSX = ImportSTL(CSX, mat_prepreg7628.name,  1, [model_dir, filesep_dbl, 'sub03_prepreg.stl']);

% Stackup - L04
CSX = ImportSTL(CSX, 'Copper_L04',         10, [model_dir, filesep_dbl, 'l04_gnd.stl']);
CSX = ImportSTL(CSX, 'PEC',                20, [model_dir, filesep_dbl, 'l04_port_gnd.stl']);
#CSX = ImportSTL(CSX, mat_prepreg7628.name,  1, [model_dir, filesep_dbl, 'l04_neg.stl']);

% Stackup - Substrate 04, Core
CSX = ImportSTL(CSX, mat_core.name,        2, [model_dir, filesep_dbl, 'sub04_core.stl']);

% Stackup - L05
CSX = ImportSTL(CSX, 'Copper_L05',         10, [model_dir, filesep_dbl, 'l05_gnd.stl']);
CSX = ImportSTL(CSX, 'PEC',                20, [model_dir, filesep_dbl, 'l05_port_gnd.stl']);
#CSX = ImportSTL(CSX, mat_prepreg1080.name,  1, [model_dir, filesep_dbl, 'l05_neg.stl']);

% Stackup - Substrate 05, Core
CSX = ImportSTL(CSX, mat_prepreg1080.name,  1, [model_dir, filesep_dbl, 'sub05_prepreg.stl']);

% Stackup - L06
CSX = ImportSTL(CSX, 'Copper_L06',         10, [model_dir, filesep_dbl, 'l06_gnd.stl']);
CSX = ImportSTL(CSX, 'PEC',                20, [model_dir, filesep_dbl, 'l06_port_gnd.stl']);

% Edge Plating
CSX = ImportSTL(CSX, 'Copper',             11, [model_dir, filesep_dbl, 'edge_plating.stl']);

% Via - Transition Region
CSX = ImportSTL(CSX, 'Copper',             20, [model_dir, filesep_dbl, 'via_trans.stl']);

% Via - Fence
CSX = ImportSTL(CSX, 'Copper',             20, [model_dir, filesep_dbl, 'via_fence.stl']);

% Connector

CSX = ImportSTL(CSX, 'Conn_Outer',        10, [model_dir, filesep_dbl, 'conn_outer_body.stl']);
CSX = ImportSTL(CSX, 'Conn_Inner',        20, [model_dir, filesep_dbl, 'conn_inner_cond.stl']);
CSX = ImportSTL(CSX, 'Teflon',             1, [model_dir, filesep_dbl, 'conn_sub.stl']);

##% Solder

CSX = ImportSTL(CSX, 'Solder_Top_Pin',    10,  [model_dir, filesep_dbl, 'solder_top_pin.stl']);
CSX = ImportSTL(CSX, 'PEC',               30,  [model_dir, filesep_dbl, 'solder_bot.stl']);

% ------------------------------------------------------------------------------
% - 
% - View Geometry
% - Only for disabled mesh smoothing, the script will stop here
% - (useful for checking the mesh)
% - 
% ------------------------------------------------------------------------------

if ~smooth_mesh
  WriteOpenEMS( [sim_p2_path '/' sim_p2_CSX], FDTD, CSX );
  WriteOpenEMS( [sim_p1_path '/' sim_p1_CSX], FDTD, CSX );


  if show_structure_p1
    % write/show/run the openEMS compatible xml-file
    CSXGeomPlot( [sim_p1_path '/' sim_p1_CSX] );
  end

  if show_structure_p2
    % write/show/run the openEMS compatible xml-file
    CSXGeomPlot( [sim_p2_path '/' sim_p2_CSX] );
  end

  return
end

% ------------------------------------------------------------------------------
% - 
% - Port Definition
% - 
% ------------------------------------------------------------------------------

% Port 1 - Coaxial
p1_pos = p.slot_x - p.edge_plating_th - p.conn_length_case - p.conn_length_thread;
start = [p1_pos - p_coax.length, 0 , p.conn_inner_cond_pos_z];
stop  = [p1_pos,                 0,  p.conn_inner_cond_pos_z];

[CSX, port{1}] = AddCoaxialPort(  CSX, 999, 1, 'PEC_Port', 'Teflon', start, stop, 'x',...
                                  p_coax.rad_i, p_coax.rad_o, p_coax.rad_os,...
                                 'ExciteAmp', 1,...
                                 'FeedShift', p_coax.feed_shift,...
                                 'MeasPlaneShift', p_coax.meas_shift);
                                


# Port 2 - Microstrip
start = [ p.pcb_x,               -p_msl.w/2, pos_z_stackup(2)]; % L01 Copper z_min
stop  = [ p.pcb_x - p_msl.length, p_msl.w/2, pos_z_stackup(5)]; %z_max of L03 copper or z_min of sub2

[CSX, port{2}] = AddMSLPort( CSX, 999, 2, 'PEC_Port', start, stop, 'x', [0 0 -1],...
                            'ExcitePort', true,...
                            'FeedShift', p_msl.feed_shift,...
                            'MeasPlaneShift', p_msl.meas_shift,...
                            'Feed_R', 1e6);

% ------------------------------------------------------------------------------
% - 
% - Dump Boxes (Field Monitors)
% - 
% ------------------------------------------------------------------------------
if write_field_dumps
  CSX = AddDump(CSX,'Et_xz','DumpMode', 10, 'Frequency',[20e9]);        %  10 for E-field frequency-domain dump
  start = [mesh.x(1),   0, mesh.z(1)];
  stop =  [mesh.x(end), 0, mesh.z(end)];
  CSX = AddBox(CSX,'Et_xz',0 , start,stop);

  CSX = AddDump(CSX,'Et_yz_at_p1','DumpMode', 10, 'Frequency',[20e9]);  %  10 for E-field frequency-domain dump
  start = [p.pcb_x - p_msl.meas_shift, mesh.y(1),   mesh.z(1)];
  stop =  [p.pcb_x - p_msl.meas_shift, mesh.y(end), mesh.z(end)];
  CSX = AddBox(CSX,'Et_yz_at_p1',0 , start,stop);

  CSX = AddDump(CSX,'Et_yz_at_p2','DumpMode', 10, 'Frequency',[20e9]);  %  10 for E-field frequency-domain dump
  start = [-p_coax.meas_shift,  mesh.y(1),   mesh.z(1)];
  stop =  [-p_coax.meas_shift,  mesh.y(end), mesh.z(end)];
  CSX = AddBox(CSX,'Et_yz_at_p2',0 , start,stop);

  ##CSX = AddDump(CSX,'rotH','DumpMode', 13, 'Frequency',[20e9]); %13 for total current density (rot(H)) frequency-domain dump
  ##start = [mesh.x(1),   mesh.y(1),   mesh.z(1)];
  ##stop =  [mesh.x(end), mesh.y(end), mesh.z(end)];
  ##CSX = AddBox(CSX,'rotH',0 , start,stop);
end


% ------------------------------------------------------------------------------
% - 
% - Write OpenEMS xml file
% - 
% ------------------------------------------------------------------------------

if run_sim && excite_p1
  [status, message, messageid] = rmdir( sim_p1_path, 's' ); % clear previous directory
  [status, message, messageid] = mkdir( sim_p1_path ); % create empty simulation folder
end

if run_sim && excite_p2
  [status, message, messageid] = rmdir( sim_p2_path, 's' ); % clear previous directory
  [status, message, messageid] = mkdir( sim_p2_path ); % create empty simulation folder
end

% Backup Excitations
excitations = CSX.Properties.Excitation;

%Set CSX to excite only exciation 1
CSX.Properties.Excitation =excitations(1);
WriteOpenEMS( [sim_p1_path '/' sim_p1_CSX], FDTD, CSX );

%Set CSX to excite only exciation 2
CSX.Properties.Excitation =excitations(2);
WriteOpenEMS( [sim_p2_path '/' sim_p2_CSX], FDTD, CSX );

% ------------------------------------------------------------------------------
% - 
% - View Geometry
% - 
% ------------------------------------------------------------------------------

if show_structure_p1
  % write/show/run the openEMS compatible xml-file
  CSXGeomPlot( [sim_p1_path '/' sim_p1_CSX] );
end

if show_structure_p2
  % write/show/run the openEMS compatible xml-file
  CSXGeomPlot( [sim_p2_path '/' sim_p2_CSX] );
end

% ------------------------------------------------------------------------------
% - 
% - Run Simulation
% - 
% ------------------------------------------------------------------------------

if run_sim && excite_p1
  fprintf('\n');
  fprintf('---------------------------------------------------------------------\n\n');
  fprintf('Starting exciation of Port 1...\n');
  fprintf('---------------------------------------------------------------------\n');
  fprintf('\n');
  RunOpenEMS( sim_p1_path, sim_p1_CSX ,'--debug-PEC');  
  %RunOpenEMS( sim_p1_path, sim_p1_CSX ,'--debug-material --debug-PEC --debug-operator');
end

if run_sim && excite_p2
  fprintf('\n');
  fprintf('---------------------------------------------------------------------\n\n');
  fprintf('Starting exciation of Port 2...\n\n');
  fprintf('---------------------------------------------------------------------\n');
  fprintf('\n');
  RunOpenEMS( sim_p2_path, sim_p2_CSX ,'--debug-PEC');  
  %RunOpenEMS( sim_p2_path, sim_p2_CSX ,'--debug-material --debug-PEC --debug-operator');
end

% ------------------------------------------------------------------------------
% - 
% - Post Processing
% - 
% ------------------------------------------------------------------------------

%% post-processing
close all
freq = linspace(f_start, f_stop, 1601);

s11 = zeros(1,length(freq));
s21 = zeros(1,length(freq));
s12 = zeros(1,length(freq));
s22 = zeros(1,length(freq));

legend_str = {};

if excite_p1
  
  port_excite_p1 = calcPort( port, sim_p1_path, freq, 'RefImpedance', 50);
  
  s11 = port_excite_p1{1}.uf.ref./ port_excite_p1{1}.uf.inc;
  s21 = port_excite_p1{2}.uf.ref./ port_excite_p1{1}.uf.inc;
  
  hold on;
  plot(freq/1e9,20*log10(abs(s21)),'LineWidth',2);
  plot(freq/1e9,20*log10(abs(s11)),'LineWidth',2);
  hold off;
  
  legend_str = {'S_{21}', 'S_{11}'};
end
  

if excite_p2
  
  port_excite_p2 = calcPort( port, sim_p2_path, freq, 'RefImpedance', 50);

  s12 = port_excite_p2{1}.uf.ref./ port_excite_p2{2}.uf.inc;
  s22 = port_excite_p2{2}.uf.ref./ port_excite_p2{2}.uf.inc;
  
  hold on;
  plot(freq/1e9,20*log10(abs(s12)),'LineWidth',2);
  plot(freq/1e9,20*log10(abs(s22)),'LineWidth',2);
  hold off;

  legend_str = [legend_str, {'S_{12}', 'S_{22}'}];
end


S = reshape([s11 ; s21 ; s12 ; s22], 2, 2, length(freq));

% Deembedd port 2 if requested 
if deemb_p2
  [~,~,Sfix,~,~] = read_touchstone('p2_gcwg.s2p');
  S = deembRight(S, Sfix, 50);
end

grid on;
%legend('S_{11}', 'S_{21}');
legend(legend_str);
ylabel('S-Parameter (dB)','FontSize',12);
xlabel('frequency (GHz) \rightarrow','FontSize',12);

##figure;
##plotSmith(s11, 'S11', freq, [])
##plotSmith(s22, 'S22', freq, [])
##legend('S11', 'S22');

if run_sim 
  fname = [result_filename, '_',  datestr(now,'yyyy-mm-dd_HHMMSS'), '.s2p'];
  fprintf('\n');
  fprintf('---------------------------------------------------------------------\n\n');
  fprintf('Write touchstone result fiele: %s\n\n', fname);
  fprintf('---------------------------------------------------------------------\n');
  fprintf('\n');
    
  write_touchstone( 's', freq, S, fname, 50, 'comment_to_be_done');
end