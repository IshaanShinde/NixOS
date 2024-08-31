{ config, pkgs, ... }:
{
  # enable OpenGL
  hardware.graphics = {
    enable = true;
  };
  
  # load nvidia driver for xorg and wayland
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    # modesetting is required
    modesetting.enable = true;
    
    # power management: experimantal, can cause sleep/suspend to fail
    # enable in case of graphical corruption issues / application crashes after waking up from sleep
    # this fixes it by saving the entire vram memory to /tmp/ instead of just the bare essentials
    powerManagement.enable = true;
    
    # fine grained power management: turns off gpu when not in use
    # experimental, only works on modern nvidia gpus (turing or newer)
    powerManagement.finegrained = false;
    
    # use nvidia open source kernel module (not to be confused with the independent third-party "nouveau" open source driver)
    # support is limited to the turing and later architectures
    # list of compatible gpus: https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # only available from driver 515.43.04+
    # currently alpha-quality/buggy, thus reccomended to be false as of now
    open = false;
    
    # enable nvidia settings menu
    nvidiaSettings = true;
    
    # optionally you may need to select the appropriate driver version for your specific gpu
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  # Optimus PRIME
  hardware.nvidia.prime = {
    sync.enable = true;

    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";    
  };
  
}
