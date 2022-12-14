function [fidexmult] = ADTFD_IF_estimation_viterbi_modified_eeg(Sig, num)
% Extract ridges for multi-component signals.
% In each iteration,the signal component associated with the extrated ridge is
% reconstructed by the ICCD and then removed from the original signal so
% that the ridge curves of other signal components with smaller energies
% can be extracted in the subsequent iterations.
%%%%%%%%%%%%%%%%%%%%%%%    input      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sig??measured signal,a row vector
% SampFreq: sampling frequency
% num: the number of the signal components
% delta??maximum allowable frequency variation between two consecutive points
% orderIF: the order of the Fourier model used for smoothing the extracted ridge curves
% bw??the bandwidth of the ICCD (unit??Hz); herein the ICCD can be regarded as a time-frequency filtering technique
% Nfrebin,window are two parameters for implementing the STFT
% alpha??Tikhonov regularization parameter for ICCD.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%  output   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fidexmult: obtained ridge index for multi-component signals
Spec12=zeros(length(Sig),length(Sig));
for i = 1:num
    %Spec=tfr_stft_high(Sig);
    
    %[Spec,orienttfd]=HTFD_neww(Sig,2,18,54);
    [Spec,orienttfd]=HTFD_neww(Sig,2,15,48);
    
    %[Spec2,orienttfd2]=HTFD_neww(Sig,2,20,64);%
    %Spec=min(Spec1,Spec2);
    figure;tfsapl( real(Sig), Spec,'SampleFreq',16, 'GrayScale','on' );
    %    %     [Spec3,orienttfd3]=HTFD_neww(Sig,3,8,64);
    %
    % %Spec=min(Spec,Spec3);
    % %figure; imagesc(127:-1:0,0:1/256:1-1/256,Spec(end:-1:1,:));
    % for ii=1:length(Spec1)
    %     for jj=1:length(Spec2)
    %             value=min(Spec1(ii,jj),Spec2(ii,jj));
    %             Spec(ii,jj)=value;
    %             if Spec1(ii,jj)==value
    %             orienttfd(ii,jj)=orienttfd1(ii,jj);
    %             else
    %             orienttfd(ii,jj)=orienttfd2(ii,jj);
    %
    %             end
    %
    %
    %     end
    % end
    Spec=Spec/max(Spec(:));
    Spec(Spec<0.05)=0;
    %figure; imagesc(Spec)
    c = findridges_new_viterbi_adtfd(Spec,orienttfd);%(Spec,orienttfd,delta);
    %c=findridges_new_viterbi(Spec);
    %c = findridges_neww(Spec,orienttfd,delta);
    
    
    IF=(c)/(2*length(Sig));
    
    Phase=2*pi*filter(1,[1 -1],IF);
    s_dechirp=exp(-1i*Phase);
    
    
    %im_label2=bwmorph(im_label2,'dilate',3);
    
    % For each sensor do the following steps
    
    L=2;
    %TF filtering for each sensor
    s1 = Sig.*(s_dechirp);
    s2=fftshift(fft(s1));
    PPP=length(s2)/2;
    s3=zeros(1,length(Sig));
    s3(PPP-L:PPP+L)=s2(PPP-L:PPP+L);
    s2(PPP-L:PPP+L)=0;
    extr_Sig=ifft(ifftshift(s3)).*conj(s_dechirp);
    s2=ifft(ifftshift(s2)).*conj(s_dechirp);
    
    %Sig(iii)=Sig(iii)-extr_Sig(iii);
    Sig=s2;%-extr_Sig(iii);
    [Spec11,orienttfd]=HTFD_neww(extr_Sig,2,8,48);
    Spec12=Spec12+Spec11;
    % extr_Sig1=extr_Sig1+extr_Sig;
    %hold on; quiver(1:256,1:256,cos(orienttfd*pi/180),sin(orienttfd*pi/180));
    fidexmult(i,:) = c;
    
end
figure;tfsapl( real(Sig), Spec12,'SampleFreq',16, 'GrayScale','on' );
end