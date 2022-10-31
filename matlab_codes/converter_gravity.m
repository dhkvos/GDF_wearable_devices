% Demostration for generating EDF/BDF/GDF-files
% DEMO3 is part of the biosig-toolbox
%    and it tests also Matlab/Octave for its correctness. 
% 

%	Copyright (C) 2000-2005,2006,2007,2008,2011,2013 by Alois Schloegl <alois.schloegl@gmail.com>
%    	This is part of the BIOSIG-toolbox http://biosig.sf.net/
%
%    BioSig is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    BioSig is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with BioSig.  If not, see <http://www.gnu.org/licenses/>.

% Input Data (as matrix format)
fid =fopen('/Users/jenny/Desktop/me_pghd/GDFbyMatlab/Gravity.csv');
buffer=fgetl(fid);
m = textscan(fid,'%s%f%f%f%f','delimiter',',');
m = m(2:5);
x = [m{:}];

filename = '/Users/jenny/Desktop/me_pghd/GDFbyMatlab/Gravity_03';
column_label = {'Milliseconds';'X';'Y';'Z'}; % channel identification, max 80 char. per channel
sample_rate = 10; % sampling frequencyt in [Hz]
units = {'?','?','?','?'};  % physical dimesions
start_time = [2021 02 19 15 48 0.00];

GDFTYP = 16*ones(1,size(x,2)); % define datatypes (GDF only, see GDFDATATYPE.M for more details)
PhysMax = [9999;9999;9999;9999];
PhysMin = [-9999;-9999;-9999;-9999];

clear HDR;

% select file format 
HDR.TYPE='GDF';  

% set Filename
HDR.FileName = [filename,'.',HDR.TYPE];

%{
% description of recording device 
HDR.Manufacturer.Name = 'BioSig';
HDR.Manufacturer.Model = 'demo3.m';
HDR.Manufacturer.Version = '2.84';
HDR.Manufacturer.SerialNumber = '00000000';
%}

%{
% recording identification, max 80 char.
HDR.RID = 'TestFile 001'; %StudyID/Investigation [consecutive number];
HDR.REC.Hospital   = 'SNUBI'; 
if exist('OCTAVE_VERSION','builtin')
	t = getpwuid(getuid);
	HDR.REC.Technician = strtok(t.gecos,',');
else
	HDR.REC.Technician = 'Sehwan AHN';
end

HDR.REC.Equipment  = 'biosig';
HDR.REC.IPaddr	   = [127,0,0,1];	% IP address of recording system 	
HDR.Patient.Name   = 'anonymous';  
HDR.Patient.Id     = 'P0000';	
HDR.Patient.Birthday = [1951 05 13 0 0 0];
HDR.Patient.Weight = 0; 	% undefined 
HDR.Patient.Height = 0; 	% undefined 
HDR.Patient.Sex    = 'f'; 	% 0: undefined,	1: male, 2: female  
HDR.Patient.Impairment.Heart = 0;  %	0: unknown 1: NO 2: YES 3: pacemaker 
HDR.Patient.Impairment.Visual = 0; %	0: unknown 1: NO 2: YES 3: corrected (with visual aid) 
HDR.Patient.Smoking = 0;           %	0: unknown 1: NO 2: YES 
HDR.Patient.AlcoholAbuse = 0; 	   %	0: unknown 1: NO 2: YES 
HDR.Patient.DrugAbuse = 0; 	   %	0: unknown 1: NO 2: YES 
HDR.Patient.Handedness = 0; 	   % 	unknown, 1:left, 2:right, 3: equal
%}

% recording time [YYYY MM DD hh mm ss.ccc]
HDR.T0 = start_time;

% number of channels
HDR.NS = size(x,2);

HDR.SampleRate = sample_rate; % sampling frequencyt in [Hz]
HDR.NRec = 1; % number of records or blocks; 1 for continuous data
HDR.SPR = 1; % samples per record
HDR.Dur = HDR.SPR/HDR.SampleRate; 

% channel identification, max 80 char. per channel
HDR.Label = column_label;

% define datatypes (GDF only, see GDFDATATYPE.M for more details)
HDR.GDFTYP = GDFTYP;

% define scaling factors
HDR.PhysMax = PhysMax;
HDR.PhysMin = PhysMin;
HDR.DigMax  = repmat(2^15-1,size(HDR.PhysMax));
HDR.DigMin  = repmat(1-2^15,size(HDR.PhysMax));
HDR.FLAG.UCAL = 0; % data x is already converted to internal (usually integer) values (no rescaling within swrite);

% define physical dimension
HDR.PhysDim = units;

if 0, %try,
	mexSSAVE(HDR,x);
else %catch
	HDR1 = sopen(HDR,'w');
	HDR1 = swrite(HDR1,x);
	HDR1 = sclose(HDR1);
end;

%
[s0,HDR0] = sload(HDR.FileName);	% test file 

HDR0=sopen(HDR0.FileName,'r');
[s0,HDR0]=sread(HDR0);
HDR0=sclose(HDR0); 

%plot(s0-x)


