function [ a, K ] = computeParams( u_in, in_pp, u_out, N, verbosity )

l_in=length(u_in);
l_out=length(u_out);
%Signale übereinanderlegen --> Interpolation und Signale übereinander
%legen: 
%Interpolation
x_in=linspace(1,l_out,l_in);
x_out=linspace(1,l_out, l_out);
u_in=interp1(x_in, u_in, x_out);
%Signale übereinanderschieben -> über Kreuzkorrelation
xc=xcorr(u_in, u_out);
shift=find(xc==max(xc));

%if shift>=0
%   in=u_in;
%   out=in;
%   out(1:l_out-shift)=u_out(shift+1:end);
%   out(l_out-shift+1:end)=u_out(1:shift);
%end

%if shift>=0
%   out=u_out;
%   in=out;
%   in(1:l_out-shift)=u_in(shift+1:end);
%   in(l_out-shift+1:end)=u_in(1:shift);
%end


if shift > length(u_out)
    shift=length(u_out)-shift;
end

if shift>=0
   out=u_out;
   in=out;
   in(1:l_out-shift)=u_in(shift+1:end);
   in(l_out-shift+1:end)=u_in(1:shift);
end

if shift<0
   out=u_out;
   in=out;
   in(l_out+shift+1:end)=u_in(1:-shift);
   in(1:l_out+shift)=u_in(-shift+1:end);
end


%i_in=find(u_in==max(u_in));
%i_out=find(u_out==max(u_out));
%%Übereinanderlegen (Maxima als Start)
%in=zeros(l_out,1);
%out=in;
%in(1:l_out-i_in)=u_in(i_in+1:l_out);
%in(l_out-i_in+1:l_out)=u_in(1:i_in);
%out(1:l_out-i_out)=u_out(i_out+1:l_out);
%out(l_out-i_out+1:l_out)=u_out(1:i_out);

%NOrmierung: u_out wird in V gemessen--> mV; u_in aus arb-file:Normierung
%händisch anhand in_pp
out=1000*out;
in=in_pp/(max(in)-min(in))*in;

%Spannungsmatrix erzeugen
U=zeros(l_out,N);
for ind=1:N
    U(:,ind)=in.^ind;
end
    
a=U\out';

K=K1(a,1);

if verbosity
    figure
    t=linspace(0,1/900000*1000000,length(in));
    plot(t,in,t,out)
    title('Spannungssignale')
    xlabel('t in us')
    ylabel('u in mV')
    legend('U_in', 'H^-1*U_out')

    figure
    plot(K(:,1),K(:,2));
    title('Kennlinie')
    xlabel('U_in in mV')
    ylabel('U_out in mV')

end

