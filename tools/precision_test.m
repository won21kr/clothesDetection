function [number_gt, number_pst_detection, number_detection] = ...
    precision_test(coordinates, results, results_cls, ...
        cfd_threshhold, IOU_threshhold)

number_gt = 0;
number_pst_detection = 0;
number_detection = 0;

co_size = size(coordinates);  % validate the size
if co_size(1) ~= 3
    fprintf('The size is unmatched, Upper, Lower1, Lower2 means 3!\n')
end

map_class = [1, 2, 2];  % it is a mapping, as the 2, 3 are both in class 2
for i = 1: 1: co_size(1)
    cur_coordinates = zeros(4, 1);
    cur_coordinates(:) = coordinates(i, :);
    
    index = find(results_cls == map_class(i));      % get the index of
    index = index(results(index, 5) > cfd_threshhold);  % the according class
    
    % accumulate the number of total test, note that cls 2,3 are the same
    if i ~= 3; number_detection = number_detection + length(index); end
    
    % no gt of this class in this image
    if cur_coordinates(1) >= cur_coordinates(3) || ...
            cur_coordinates(2) >= cur_coordinates(4)
        continue
    end
    
    % test for this class
    number_gt = number_gt + 1;
    
    number_pst_detection = IOU_test( ...
        cur_coordinates, results(index, :), IOU_threshhold);
    
    
end
end

function pst_detection = IOU_test( ...
    coordinate, det_coordinate, IOU_threshhold)

pst_detection = 0;
gt_size = (coordinate(4) - coordinate(2)) * (coordinate(3) - coordinate(1));

for i_coord = 1: 1: length(det_coordinate(:, 1))
    cur_coordinates = zeros(4, 1);  % process the detection coord one by
                                    % one
    cur_coordinates(:) = det_coordinate(i_coord, 1 : 4);
    
    det_size = (cur_coordinates(4) - cur_coordinates(2)) * ...
        (cur_coordinates(3) - cur_coordinates(1));
    
    overlaps = ...
        (min(cur_coordinates(4), coordinate(4)) - ...
            max(cur_coordinates(2), coordinate(2))) * ...
        (min(cur_coordinates(3), coordinate(3)) - ...
            max(cur_coordinates(1), coordinate(1)));
    if overlaps / (gt_size + det_size - overlaps) > IOU_threshhold
        pst_detection = pst_detection + 1;
    end
end

end