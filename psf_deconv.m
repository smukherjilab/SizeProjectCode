function [out_image] = psf_deconv(image,psf,algorithm)

   
    
    if contains(algorithm,'richardson-lucy','IgnoreCase',true)
        out_image = DL2.RL(image,psf,10);
    else
        error('psf algorithm')
    end
end