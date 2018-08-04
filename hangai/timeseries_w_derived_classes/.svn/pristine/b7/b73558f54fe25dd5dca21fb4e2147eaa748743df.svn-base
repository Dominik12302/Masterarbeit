function data_filt = ac_filter(data, v)

    % data_filt = ac_filter(data, v)
    %
    % data is nch x N
    % v    is fs/fa, where fs is the sampling rate and fa is noise
    %                frequency
    %
    % reference:
    % Cramer E, McManus D & Dietrich N, 1987,
    % Estimation and Removal of Power Line Interference in the
    % Electrocardiogram: A comparison of Digital Approaches,
    % Computers and biomedical research 20, 12-28
    %
    % where method II (same phase summation) is implemented here
    

    N = numel(data);   
    % the paper reports to use the following hp filter, but it does not
    % improve the results...    
    %noise = conv(data(:).',[-1 -1 4 -1 -1]./ ( 4 - cos(2*pi/v) - 2*cos(4*pi/v) ),'same');
    noise = data(:).';
    
    noise = repmat(mean(reshape([noise, zeros(1, v*ceil(N/v) - N)].', [v ceil(N/v)]),2).',[1 ceil(N/v)]);    
    data_filt = data(:).' - noise(1:N);        