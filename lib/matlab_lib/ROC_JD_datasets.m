% ------------------------------------------------------------------------
% Generate the results of the ROC curve on forever21 datasets.
% The methods tested include the 'Fast-RCNN', 'Pose detector'.
%
% Written by Tingwu Wang, 20.7.2015, as a junior RA in CUHK, MMLAB
% ------------------------------------------------------------------------

function [number_gt, number_pst_detection, ...
    number_detection, number_recall] = ...
    ROC_JD_datasets(method, cfd_threshhold, IOU_threshhold)
% the result variable
number_gt = 0; number_pst_detection = 0;
number_detection = 0; number_recall = 0;

% basic experiment parameters
number_category = 26;

% transmit the 26 class into the 3 class, upper, lower and whole
twentysix2three = [ones(1, 7), 3, ones(1, 2), 3, ones(1, 8), 3, ones(1, 6)];

% prepare the path directory
switch method
    case 'fast-RCNN',
        [mat_file_path] = fileparts(mfilename('fullpath'));
        gd_result_dir = [mat_file_path '/../../data/results/Jingdong'];
        gt_results_dir = [mat_file_path '/../../data/clothesDataset/test'];
    case 'pose',
        fprintf('The pose method is not available! Check again!\n')
        fprintf('Use `fast-RCNN` or `pose` !\n')
        error('Program exit')
    otherwise
        fprintf('The method doesnt exist! Check again!\n')
        fprintf('Use `fast-RCNN` or `pose` !\n')
        error('Program exit')
end

% the extension of the class
float_ext = 'floatResults';
int_ext = 'intResults';
label_ext = '.clothInfo';

% the class map list
type_classes = {'风衣', '毛呢大衣', '羊毛衫/羊绒衫', ...
    '棉服/羽绒服',  '小西装/短外套', '西服', '夹克', '旗袍', '皮衣', '皮草', ...
    '婚纱', '衬衫', 'T恤', 'Polo衫', '开衫', '马甲', '男女背心及吊带', '卫衣', ...
    '雪纺衫', '连衣裙', '半身裙', '打底裤', '休闲裤', '牛仔裤', ...
    '短裤', '卫裤/运动裤'};

% the directory function
for i_category = 1: 1: number_category
    
    % read the test results!
    float_results_file = [gd_result_dir '/' num2str(i_category) float_ext];
    int_results_file = [gd_result_dir '/' num2str(i_category) int_ext];
    
    % get the number of test image this class
    results = get_float_text_results(float_results_file);
    results_cls = get_int_text_results(int_results_file);
    if length(results(:, 1)) ~= length(results_cls(:, 1))
        error('The result sizes are not matched! Check the dimension!\n')
    end
    
    % read the image index and the label index
    image_name_file = fopen([gt_results_dir '/' num2str(i_category) ...
        '/newGUIDMapping.txt'], 'r');
    i_image = 1;  % this variable record the number of image in this categ
    tline = fgets(image_name_file);
    while tline ~= -1
        
        if mod(i_image, 50) == 1
            fprintf('    Testing the %d th image in the %d cat\n', ...
                i_image, i_category)
        end
        % cur_image_name = tline(8: find(tline == '"') - 1);
        cur_label_name = [tline(find(tline == '"') + 1: end - 1), label_ext];
        
        [gt_position, class] = read_cloth_xml( ...
            [gt_results_dir '/' num2str(i_category) ...
            '/Label/' cur_label_name], type_classes);
        class = twentysix2three(class);
        
        % get the detection results of this image
        [sgl_number_gt, sgl_number_pst_detection, ...
            sgl_number_detection, sgl_number_recall] = ...
            precision_test([gt_position, class], ...
            results(10 * i_image - 9: 10 * i_image, :), ...
            results_cls(10 * i_image - 9: 10 * i_image, :), ...
            cfd_threshhold, IOU_threshhold, 'JD');
        
        number_gt = number_gt + sgl_number_gt;
        number_pst_detection = number_pst_detection + ...
            sgl_number_pst_detection;
        number_detection = number_detection + sgl_number_detection;
        number_recall = number_recall + sgl_number_recall;
        
        i_image = i_image + 1;
        tline = fgets(image_name_file);  % read the next line
    end
    
end


end