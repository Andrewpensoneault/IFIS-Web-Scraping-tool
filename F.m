function[y]=F(x,xdata)
%This function defines a piecewise absolute value powerlaw function which 
%is zero when the the input is less than a and 0 when it is smaller. 
%This was reasoned from the idea that the function should never be complex
%valued and that once it reaches its minimum, having less water should not
%gain more water for having less. In our case, this function will be
%differentiable at zero provided beta>1.
%% New Function
%y=0*xdata;
%for i=1:length(xdata)
%    if xdata(i)>x(2)
%        y(i)=x(1)*abs(xdata(i)-x(2)).^x(3);
%    else
%        y(i)=0;
%    end
%end;

%% Old Function
y=x(1)*abs(xdata-x(2)).^x(3);

end
