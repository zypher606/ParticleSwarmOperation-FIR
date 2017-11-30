function z = findError(currentFilterPosition, desiredFilter_h)
    [h,w] = freqz(currentFilterPosition,1,'whole',1000);
    h1 = abs(h);
    h2 = abs(desiredFilter_h);
%     disp(h1);
%     disp(h2);
    diff = (h1 - h2).^2;
     
    result = sum(diff);
    z = result.^0.5;
    
end

