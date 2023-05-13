{ config
, lib
, ...
}:
with lib;
let
  cfg = config.dr460nixed.boot;
in
{
  options.dr460nixed.boot = {
    enable = mkOption
      {
        default = true;
        type = types.bool;
        description = mdDoc ''
          Configures common options for a quiet systemd-boot.
        '';
      };
  };

  config = mkIf cfg.enable {
    boot = {
      consoleLogLevel = 0;
      initrd = {
        # extremely experimental, just the way I like it on a production machine
        systemd.enable = true;

        # strip copied binaries and libraries from inframs
        # saves 30~ mb space according to the nix derivation
        systemd.strip = true;
        verbose = false;
      };
      kernelParams = [
        # enables calls to ACPI methods through /proc/acpi/call
        "acpi_call"

        # this has been defaulted to none back in 2016 - break really old binaries for security
        "vsyscall=none"

        # enable buddy allocator free poisoning
        "page_poison=1"

        # performance improvement for direct-mapped memory-side-cache utilization, reduces the predictability of page allocations
        "page_alloc.shuffle=1"

        # save power on idle by limiting c-states
        # https://gist.github.com/wmealing/2dd2b543c4d3cff6cab7
        "processor.max_cstate=5"

        # ignore access time (atime) updates on files, except when they coincide with updates to the ctime or mtime
        "rootflags=noatime"

        # enable IOMMU for devices used in passthrough and provide better host performance
        "iommu=pt"

        # disable usb autosuspend
        "usbcore.autosuspend=-1"

        # 7 = KERN_DEBUG for debugging
        "loglevel=7"

        # tell the kernel to not be verbose
        "quiet"

      ];
      loader = {
        # Fix a security hole in place for backwards compatibility. See desc in
        # nixpkgs/nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix
        systemd-boot.editor = false;

        generationsDir.copyKernels = true;
        timeout = 1;
      };
      # We need to override Stylix here to keep the splash
      plymouth = mkForce {
        enable = true;
        theme = "bgrt";
      };
      tmp = {
        # /tmp not on tmpfs, I can't build kernels otherwise
        useTmpfs = mkDefault false;

        # If not using tmpfs, which is naturally purged on reboot, we must clean
        # /tmp ourselves. /tmp should be volatile storage!
        cleanOnBoot = mkDefault (!config.boot.tmp.useTmpfs);
      };
    };
  };
}
