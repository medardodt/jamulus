% /****************************************************************************\
%  * Copyright (c) 2004-2009
%  *
%  * Author(s):
%  *	Volker Fischer
%  *
% \****************************************************************************/

function resamplefilter()

% Number of taps per poly phase for different resampling types
GlobalNoTaps = 4; % use global value for all types

NoTapsP2    = GlobalNoTaps; % 24 kHz
NoTapsP4_3  = GlobalNoTaps; % 32 kHz <-> 24 kHz
NoTapsP3_2  = GlobalNoTaps; % 32 kHz
NoTapsP12_7 = GlobalNoTaps; % 28 kHz
NoTapsP1    = GlobalNoTaps; % 48 kHz


% Filter for ratio 2 -----------------------------------------------------------
% I and D
I2 = 2;
D2 = 1;

% filter design
h2 = DesignFilter(NoTapsP2, I2);


% Filter for ratio 4 / 3 -------------------------------------------------------
% I and D
I4_3 = 4;
D4_3 = 3;

% filter design
h4_3 = DesignFilter(NoTapsP4_3, I4_3);


% Filter for ratio 3 / 2 -------------------------------------------------------
% I and D
I3_2 = 3;
D3_2 = 2;

% filter design
h3_2 = DesignFilter(NoTapsP3_2, I3_2);


% Filter for ratio 12 / 7 ------------------------------------------------------
% I and D
I12_7 = 12;
D12_7 = 7;

% filter design
h12_7 = DesignFilter(NoTapsP12_7, I12_7);


% Filter for ratios close to 1 -------------------------------------------------
% Fixed for sample-rate conversiones of R ~ 1
I1 = 10; % D = I in this mode

% MMSE filter-design and windowing
h1 = DesignFilter(NoTapsP1, I1);


% Export coefficiants to file ****************************************
fid = fopen('resamplefilter.h', 'w');

fprintf(fid, '/* Automatically generated file with MATLAB */\n');
fprintf(fid, '/* File name: "ResampleFilter.m" */\n');
fprintf(fid, '/* Filter taps in time-domain */\n\n');

fprintf(fid, '#ifndef _RESAMPLEFILTER_H_\n');
fprintf(fid, '#define _RESAMPLEFILTER_H_\n\n');

fprintf(fid, '#define NUM_TAPS_PER_PHASE2          ');
fprintf(fid, int2str(NoTapsP2));
fprintf(fid, '\n');
fprintf(fid, '#define NUM_TAPS_PER_PHASE4_3        ');
fprintf(fid, int2str(NoTapsP4_3));
fprintf(fid, '\n');
fprintf(fid, '#define NUM_TAPS_PER_PHASE3_2        ');
fprintf(fid, int2str(NoTapsP3_2));
fprintf(fid, '\n');
fprintf(fid, '#define NUM_TAPS_PER_PHASE12_7       ');
fprintf(fid, int2str(NoTapsP12_7));
fprintf(fid, '\n');
fprintf(fid, '#define NUM_TAPS_PER_PHASE1          ');
fprintf(fid, int2str(NoTapsP1));
fprintf(fid, '\n');
fprintf(fid, '#define INTERP_I_2                   ');
fprintf(fid, int2str(I2));
fprintf(fid, '\n');
fprintf(fid, '#define DECIM_D_2                    ');
fprintf(fid, int2str(D2));
fprintf(fid, '\n');
fprintf(fid, '#define INTERP_I_4_3                 ');
fprintf(fid, int2str(I4_3));
fprintf(fid, '\n');
fprintf(fid, '#define DECIM_D_4_3                  ');
fprintf(fid, int2str(D4_3));
fprintf(fid, '\n');
fprintf(fid, '#define INTERP_I_3_2                 ');
fprintf(fid, int2str(I3_2));
fprintf(fid, '\n');
fprintf(fid, '#define DECIM_D_3_2                  ');
fprintf(fid, int2str(D3_2));
fprintf(fid, '\n');
fprintf(fid, '#define INTERP_I_12_7                ');
fprintf(fid, int2str(I12_7));
fprintf(fid, '\n');
fprintf(fid, '#define DECIM_D_12_7                 ');
fprintf(fid, int2str(D12_7));
fprintf(fid, '\n');
fprintf(fid, '#define INTERP_DECIM_I_D1            ');
fprintf(fid, int2str(I1));
fprintf(fid, '\n');
fprintf(fid, '\n\n');

% Write filter taps
fprintf(fid, '\n// Filter for ratio 2\n');
ExportFilterTaps(fid, 'fResTaps2[INTERP_I_2 * DECIM_D_2 * NUM_TAPS_PER_PHASE2]', h2);

fprintf(fid, '\n// Filter for ratio 4 / 3\n');
ExportFilterTaps(fid, 'fResTaps4_3[INTERP_I_4_3 * DECIM_D_4_3 * NUM_TAPS_PER_PHASE4_3]', h4_3);

fprintf(fid, '\n// Filter for ratio 3 / 2\n');
ExportFilterTaps(fid, 'fResTaps3_2[INTERP_I_3_2 * DECIM_D_3_2 * NUM_TAPS_PER_PHASE3_2]', h3_2);

fprintf(fid, '\n// Filter for ratio 12 / 7\n');
ExportFilterTaps(fid, 'fResTaps12_7[INTERP_I_12_7 * DECIM_D_12_7 * NUM_TAPS_PER_PHASE12_7]', h12_7);

fprintf(fid, '// Filter for ratios close to 1\n');
ExportFilterTaps(fid, 'fResTaps1[INTERP_DECIM_I_D1 * NUM_TAPS_PER_PHASE1]', h1);

fprintf(fid, '\n#endif	/* _RESAMPLEFILTER_H_ */\n');
fclose(fid);

return;


function h = DesignFilter(NoTapsPIn, I)

% number of taps, consider interpolation factor
NoTapsP = NoTapsPIn * I;

% Cut-off frequency (normlized)
fc = 0.97 / I;

% MMSE filter design with Kaiser window, consider interpolation factor
h = sqrt(I) * firls(NoTapsP - 1, [0 fc fc 1], [1 1 0 0]) .* kaiser(NoTapsP, 5)';

return;


function ExportFilterTaps(f, name, h)

% Write filter taps
fprintf(f, ['static float ' name ' = {\n']);
fprintf(f, '	%.20ff,\n', h(1:end - 1));
fprintf(f, '	%.20ff\n', h(end));
fprintf(f, '};\n\n');

return;


