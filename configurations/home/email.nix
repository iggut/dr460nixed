_: let
  mailserver = "mail.garudalinux.net";
  key = "D245D484F3578CB17FD6DA6B67DB29BFF3C96757";
in {
  accounts.email = {
    accounts.main = {
      address = "igor.gutchin@gmail.com";
      gpg = {
        inherit key;
        signByDefault = false;
      };
      imap = {
        host = mailserver;
        port = 993;
      };
      primary = true;
      realName = "Igor G";
      signature = {
        text = ''
          Sent from NixOS
        '';
        showSignature = "append";
      };
      thunderbird.enable = true;
      smtp = {
        host = mailserver;
      };
      userName = "igor.gutchin@gmail.com";
    };
    accounts.garuda-personal = {
      address = "igor.gutchin@gmail.com";
      gpg = {
        inherit key;
        signByDefault = false;
      };
      imap = {
        host = mailserver;
        port = 993;
      };
      realName = "Igor G";
      thunderbird.enable = true;
      signature = {
        text = ''
          Sent from NixOS
        '';
        showSignature = "append";
      };
      smtp = {
        host = mailserver;
      };
      userName = "igor.gutchin@gmail.com";
    };
    accounts.garuda-team = {
      address = "team@garudalinux.org";
      gpg = {
        inherit key;
        signByDefault = false;
      };
      imap = {
        host = mailserver;
        port = 993;
      };
      realName = "Garuda Team";
      signature = {
        text = ''
          Sent from NixOS
        '';
        showSignature = "append";
      };
      thunderbird.enable = true;
      smtp = {
        host = mailserver;
      };
      userName = "team@garudalinux.org";
    };
  };
}
