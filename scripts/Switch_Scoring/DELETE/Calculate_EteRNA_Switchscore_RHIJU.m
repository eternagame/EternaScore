load Workspace/R51_workspace.mat 

which_sets = 1:length(sequence);

%% generating area_pred
for j = which_sets  
  seqpos = length(sequence{j})-20 - [1:(length(sequence{j})-20)] + 1;
  [ marks{j}, all_area_pred{j}, mutpos{j} ] = get_predicted_marks_SHAPE_DMS_CMCT( structure, sequence{j}, 0 , seqpos, data_types );
end

% area_pred for switched structure
if(~isempty(alt_structure))
    alt_lane = [2 4];
    for j = which_sets  
      seqpos = length(sequence{j})-20 - [1:(length(sequence{j})-20)] + 1;
      [ alt_marks{j}, alt_area_pred{j}, alt_mutpos{j} ] = get_predicted_marks_SHAPE_DMS_CMCT( alt_structure, sequence{j}, 0 , seqpos, data_types );
      all_area_pred{j}(:,alt_lane) = alt_area_pred{j}(:,alt_lane);
    end
end

% peak fitting
%overmodlength( sequence{j} )
for j = which_sets
    [area_peak{j}, prof_fit{j}] = do_the_fit_fast( d_bsub{j}, xsel{j}', 0.0, 0);
end

backgd_sub_col = find(strcmp(data_types, 'nomod'));

% Thisis new -- fixing the modification rate so that we don't add noise. Note that this parameter is poorly constrained anyway.
fixed_overmod_correct = 1.0 * (length( sequence{j} ) - 20)/80;  % this is approximate -- we shoot for single hit over 100 residues.
for j = which_sets
  [ area_bsub{j}, darea_bsub{j}] = overmod_and_background_correct_logL( area_peak{j}, backgd_sub_col, [4:size(area_peak{j},1)-4], all_area_pred{j}, [], fixed_overmod_correct);
end


calc_eterna_score_RHIJU

calc_switch_score_RHIJU




%[name path] = uiputfile('Output.rdat', 'Save to RDAT file');

%eterna_create_rdat_files_GUI( strcat(path,name), target_names{1}, structure, sequence, ...
%            area_bsub_norm, ids, target_names, subrounds, sequence, ...
%            design_names , seqpos, goodbins, data_types, [], [], ...
%            min_SHAPE, max_SHAPE, threshold_SHAPE, ETERNA_score, ...
%            switch_score,[], darea_bsub_norm );