_:
let
  mailserver = "mail.garudalinux.net";
  key = "D245D484F3578CB17FD6DA6B67DB29BFF3C96757";
in
{
  accounts.email = {
    accounts.main = {
      address = "iggut@dr460nf1r3.org";
      gpg = {
        inherit key;
        signByDefault = false;
      };
      imap = {
        host = mailserver;
        port = 993;
      };
      primary = true;
      realName = "iggut Jensch";
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
      userName = "iggut@dr460nf1r3.org";
    };
    accounts.garuda-personal = {
      address = "dr460nf1r3@garudalinux.org";
      gpg = {
        inherit key;
        signByDefault = false;
      };
      imap = {
        host = mailserver;
        port = 993;
      };
      realName = "iggut (dr460nf1r3)";
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
      userName = "dr460nf1r3@garudalinux.org";
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
