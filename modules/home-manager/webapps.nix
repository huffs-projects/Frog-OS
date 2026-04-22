{ pkgs, ... }:
{
  xdg.desktopEntries = {
    chatgpt = {
      name = "ChatGPT";
      genericName = "AI Assistant";
      comment = "OpenAI ChatGPT in Firefox";
      exec = "${pkgs.firefox}/bin/firefox --new-window https://chat.openai.com";
      categories = [ "Network" "Utility" ];
      terminal = false;
    };
    gmail = {
      name = "Gmail";
      genericName = "Email";
      comment = "Gmail in Firefox";
      exec = "${pkgs.firefox}/bin/firefox --new-window https://mail.google.com";
      categories = [ "Network" "Email" ];
      terminal = false;
    };
  };
}
