# Calculating Eterna SHAPE score from an RDAT file
## Example data from a classic-style Eterna lab with eight different sequences
This example shows how to compute the Eterna SHAPE scores for an RDAT file containing 1M7 chemical mapping data for eight designs (seven top-voted player sequences plus the WT starting sequence) from the Ribosome Challenge: Return of the PTC lab.

The input file PTC_round_1_SHAPE.rdat was prepared using the [RDATKit](https://ribokit.github.io/RDATKit/) package as part of the [HiTRACE](https://ribokit.github.io/HiTRACE/) analysis pipeline in one of the final steps, described [here](https://ribokit.github.io/HiTRACE/tutorial/step_9/).
	- Since this RDAT file contains designs with different sequences but the same target secondary structure, the sequence in the header is a string of X's with the same length (284) as the puzzle. Each individual design's unique sequence is included as a data annotation field.

1. Make sure that you have the directory containing the put_SHAPEscore_into_RDAT.m and determine_thresholds_and_ETERNA_score.m function files (currently `EternaScore/scripts/EteRNA_Script/`)on your MATLAB path.

2. In MATLAB, set `EternaScore/examples/ribosome_PTC/` as your working directory.

3. Run the command `rdat_out = put_SHAPEscore_into_RDAT( 'PTC_round_1_SHAPE.rdat', 0, 0, 'PTC_round_1_SHAPE_Eterna_score_test.rdat' );`. This will load in the standard RDAT file PTC_round_1_SHAPE.rdat, calculate the Eterna SHAPE score for each entry, store the new RDAT with scores and asociated parameters added as data annotations in the workspace variable `rdat_eterna_scores`, and write the result to a new file named PTC_round_1_SHAPE_Eterna_score_test.rdat.
	- The middle input arguments set the 5' and 3' insets, which define the portion of the sequence that will be used in the score calculation. Their default values are 5 and 28, respectively.
	- In this example, the extraneous 5' and 3' sequences, which include reference hairpins for reactivity normalization and the RT primer annealing site, have already been trimmed off as part of the HiTRACE analysis. We want to keep reactivity for the entire remaining sequence, which corresponds to each individual design from the puzzle.

4. If the script is running properly, the new file PTC_round_1_SHAPE_Eterna_score_test.rdat should be identical to PTC_round_1_SHAPE_Eterna_score.rdat and contain the same calculated Eterna SHAPE scores and parameters added as data annotations for each sequence.

## Considerations for use
`put_SHAPEscore_into_RDAT` has additional output options to capture the calculated score and associated parameters in MATLAB variables if you want to do more analysis or plotting with them: `[ rdat_out, ETERNA_score, min_SHAPE, max_SHAPE, threshold_SHAPE] = put_SHAPEscore_into_RDAT( rdat_in_filename, five_prime_inset, three_prime_inset, rdat_out_filename );`

The 5' and 3' insets can be used in case you want your final RDAT to contain extra sequences that are not part of player designs, like the reference hairpins or barcodes, for example. We want to ignore these when determining Eterna SHAPE scores for player designs and just focus on the sequence corresponding to the puzzle design they submitted.

Sometimes, it may be helpful to concatenate multiple RDAT files into a single RDAT file before calculating the SHAPE score, e.g. if you want to aggregrate results from different rounds of a challenge. RDATKit includes a function called `cat_rdat_files` that can do this for separate RDAT files containing reactivity data that have the same target secondary structure and sequence in the header.
	- In MATLAB, run the command `rdat_out = cat_rdat_files( rdat_out_filename, rdat_files );`, where rdat_files is a cell array containing the names of the RDAT files you wish to concatenate together.
	- Data annotations will remain matched to the corresponding reactivity data, while comments will just be concatenated together.