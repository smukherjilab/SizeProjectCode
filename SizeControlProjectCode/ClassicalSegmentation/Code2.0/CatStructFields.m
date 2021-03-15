function S = CatStructFields(S, T, dim)
fields = fieldnames(S);
for k = 1:numel(fields)
  aField= fields{k}; % EDIT: changed to {}
  if contains(aField,'org_volumes')
      continue
  elseif contains(aField,'throw_away')
      continue
  end
  if contains(class(T.(fields{k})),'struct')
      continue
  elseif contains(class(T.(fields{k})),'double')
      S.(aField) = conc_matrices(S.(aField), T.(aField));
  elseif contains(class(T.(fields{k})),'cell')
%       try
        S.(aField) = cat(dim, S.(aField), T.(aField));
%       catch
%           disp('')
%       end
  end
%   S.(aField) = cat(dim, S.(aField), T.(aField));
%   disp(k)
  
end