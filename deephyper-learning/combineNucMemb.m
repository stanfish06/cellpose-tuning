nuc_channel_id = 0;
membrane_channel_id = 2;
colony_id = 1;
train_window_l = 700;
train_window_r = 1000;
train_window_t = 600;
train_window_b = 900;
cwd = fileparts(matlab.desktop.editor.getActiveFilename);
nuc = tiffreadVolume(fullfile(cwd, sprintf('stitched_p000%d_w000%d_t0000.tif', colony_id, nuc_channel_id)));
memb = tiffreadVolume(fullfile(cwd, sprintf('stitched_p000%d_w000%d_t0000.tif', colony_id, membrane_channel_id)));
merged = cat(4, nuc, memb);

fiji_descr = ['ImageJ=1.52p' newline ...
    'images=' num2str(size(merged,3)*...
    size(merged,4)) newline...
    'channels=' num2str(size(merged,4)) newline...
    'slices=' num2str(size(merged,3)) newline...
    'hyperstack=true' newline...
    'mode=grayscale' newline...
    'loop=false' newline...
    'min=0.0' newline...
    'max=65535.0'];  % change this to 256 if you use an 8bit image

t = Tiff(fullfile(cwd, sprintf('stitched_p000%d_wnucmemb_t0000.tif', colony_id)),'w');

tagstruct.ImageLength = size(merged,1);
tagstruct.ImageWidth = size(merged,2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 16;
tagstruct.SamplesPerPixel = 1;
tagstruct.Compression = Tiff.Compression.LZW;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
tagstruct.ImageDescription = fiji_descr;

fiji_descr_sub_tif = ['ImageJ=1.52p' newline ...
    'images=1' newline...
    'channels=2' newline...
    'mode=grayscale' newline...
    'hyperstack=true' newline...
    'loop=false' newline...
    'min=0.0' newline...
    'max=65535.0'];
tagstruct_sub_tif.ImageLength = train_window_r - train_window_l + 1;
tagstruct_sub_tif.ImageWidth = train_window_b - train_window_t + 1;
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct_sub_tif.BitsPerSample = 16;
tagstruct_sub_tif.SamplesPerPixel = 2;
tagstruct_sub_tif.Compression = Tiff.Compression.LZW;
tagstruct_sub_tif.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct_sub_tif.SampleFormat = Tiff.SampleFormat.UInt;
tagstruct_sub_tif.ImageDescription = fiji_descr_sub_tif;
tagstruct_sub_tif.ExtraSamples = [];

for slice = 1:size(merged,3)
    for channel = 1:size(merged,4)
        t.setTag(tagstruct)
        t.write(merged(:,:,slice,channel))
        t.writeDirectory(); % saves a new page in the tiff file
    end
    t_sub = Tiff(fullfile(cwd, 'train_window', sprintf('z%d.tif', slice)),'w');
    t_sub.setTag(tagstruct_sub_tif);
    t_sub.write(merged(train_window_t:train_window_b,train_window_l:train_window_r,slice,:));
    t_sub.close()
end
t.close()