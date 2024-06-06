//THIS FILE ONLY FOR DRAFTS!!!
//DO NOT USE CODE FROM HERE, IT`S OUTDATED OR UNCOMPLETED

//MODULE: encoder
//outdated generate block (causes warnings)
genvar i;
genvar j;
generate
	for (i = 0; i < output_width; ++i) begin: encoded_output
		wire [2 ** output_width - 1:0] OR;
		for (j = 2 ** i; j < input_width; j += 2 ** (i + 1)) begin: selection_union
			assign OR[2 ** i + (j - 2 ** i) / 2 - 1:(j - 2 ** i) / 2] = select[`min(input_width, j + 2 ** i) - 1:j];
		end
		assign out[i] = |OR;
	end
endgenerate
//encoded_output iterations by wire (not by subarrays)
for (j = 0; j < $size(collector); ++j) begin: selection_union
	assign collector[j] = select[(2 ** (i + 1)) * (j / (2 ** i)) + 2 ** i + j % (2 ** i)];
end