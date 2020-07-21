function [ r_out, ETERNA_score, min_SHAPE, max_SHAPE, threshold_SHAPE] = put_SHAPEscore_into_RDAT( r, five_prime_inset, three_prime_inset, r_out_file_name );
%
% r_out = put_SHAPEscore_into_RDAT( r, [ five_prime_inset, three_prime_inset, r_out_file_name ] );
%  or
% r_out = put_SHAPEscore_into_RDAT( r, [ r_out_file_name ] );
%
% input
%  r                 = RDAT filename or RDAT object, which must have desired structure defined along with reactivities.
%  five_prime_inset  = [optional] position of first residue for which to take into accout reactivity in scoring [default 5]
%  three_prime_inset = [optional] position of last residue for which to take into accout reactivity in scoring, relative to end [default 20+8]
%  r_out_file_name   = [optional] file name for RDAT output [default: '', no output]
%
%
if nargin < 1; help( mfilename); return; end;
if ischar( r ); r = show_rdat( r ); end;

sequence = r.sequence;
if nargin == 2 & ischar( five_prime_inset );  r_out_file_name = five_prime_inset; five_prime_inset = []; end;
if ~exist( 'r_out_file_name' ) r_out_file_name = ''; end;
if ~exist( 'five_prime_inset' ) | isempty( five_prime_inset); five_prime_inset = 5; end;
if ~exist( 'three_prime_inset' ) | isempty( three_prime_inset );  three_prime_inset = 20 + 8; end;


D_output = r.reactivity;
N = size( D_output, 2 );
%N = min( N, 10 ); % for testing

ETERNA_score = zeros(1,N);
min_SHAPE = ETERNA_score*0;
max_SHAPE = ETERNA_score*0;
threshold_SHAPE = ETERNA_score*0;


for i = [1:N];
  seqlength = length( r.sequences{i} );
  first_pos = five_prime_inset + r.offset; 
  last_pos  = seqlength - three_prime_inset + r.offset; 

  score_idx = [];
  for m = first_pos:last_pos;  score_idx = [ score_idx, find( r.seqpos == m ) ]; end

  data = D_output(score_idx, i)';
  pred = 0 * data;
  structure_subset = r.structures{i}( score_idx );
  pred( strfind( structure_subset, '.' ) ) = 1.0;   

  % new -- worried about cases with strong negative reactivities -- driving
  % score to 0.0
  data = max( data, 0 );
  
  if sum( data ) > 0;
    [min_SHAPE(i), max_SHAPE(i), threshold_SHAPE(i), ETERNA_score(i)] = determine_thresholds_and_ETERNA_score( data, pred ); 
  end;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r_out = r;
for j = 1:N
  r_out.data_annotations{j} = [r.data_annotations{j}, ...
		    ['EteRNA:score:EteRNA_score:',num2str(ETERNA_score(j),'%6.1f')],...
		    ['EteRNA:score:min_SHAPE:',num2str(min_SHAPE(j),'%7.3f')],...
		    ['EteRNA:score:max_SHAPE:',num2str(max_SHAPE(j),'%7.3f')],...
		    ['EteRNA:score:threshold_SHAPE:',num2str(threshold_SHAPE(j),'%7.3f')],...
		    ];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length( r_out_file_name ) > 0;  output_rdat_to_file( r_out_file_name, r_out ); end