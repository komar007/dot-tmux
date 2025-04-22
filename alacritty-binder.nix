{ lib }: {
  # This function converts a tmux configuration into alacritty keyboard bindings.
  #
  # It is used to define key combinations that cannot be intercepted from a regular terminal (like
  # Ctrl+Shift+p - which is indistinguishable from Ctrl+p - or Ctrl+enter) and binding them in
  # alacritty to unicode PUA code points which can then be bound to actions in tmux.
  #
  # The tmux config needs to follow a specific format. First, define each binding in one line by
  # defining a specially-named variable whose value is a quoted unicode PUA code point, like so:
  #
  # %hidden kC_M="\uE100"
  #
  # The variable definition follows the format: %hidden k<mods>_<mnemonic>="\u<CCCC>", where:
  # - <mods> is a set of:
  #   - C for Control,
  #   - M for Alt,
  # - <mnemonic> is an alphanumeric lower- or upper-case character or one of the supported
  #   mnemonics defined below,
  # - <CCCC> is the unicode code point in hex.
  #
  # The shift modifier is automatically added when the right mnemonic is used (for example M instead
  # of m or tilde instead of tick, etc).
  #
  # Then, each defined variable can be used to define a bind in tmux, like so:
  #
  # bind -n $kC_M switch-client -l
  #
  # The returned value is a list of key bindings suitable as the value of
  # programs.alacritty.settings.keyboard.bindings home-manager option.
  getAlacrittyBindings = tmux-conf:
  let
    lines = lib.splitString "\n" tmux-conf;
    alacritty-mods = {
      C = "Control";
      M = "Alt";
    };
    keydefs = {
      tick         = { m = "`";         mods = []; };
      minus        = { m = "-";         mods = []; };
      equals       = { m = "=";         mods = []; };
      lsqbr        = { m = "[";         mods = []; };
      rsqbr        = { m = "]";         mods = []; };
      semicolon    = { m = ";";         mods = []; };
      apostrophe   = { m = "'";         mods = []; };
      comma        = { m = ",";         mods = []; };
      dot          = { m = ".";         mods = []; };
      backslash    = { m = "/";         mods = []; };
      tilde        = { m = "`";         mods = [ "Shift" ]; };
      exclamation  = { m = "1";         mods = [ "Shift" ]; };
      at           = { m = "2";         mods = [ "Shift" ]; };
      hash         = { m = "3";         mods = [ "Shift" ]; };
      dollar       = { m = "4";         mods = [ "Shift" ]; };
      percent      = { m = "5";         mods = [ "Shift" ]; };
      caret        = { m = "6";         mods = [ "Shift" ]; };
      ampersand    = { m = "7";         mods = [ "Shift" ]; };
      asterisk     = { m = "8";         mods = [ "Shift" ]; };
      lparen       = { m = "9";         mods = [ "Shift" ]; };
      rparen       = { m = "0";         mods = [ "Shift" ]; };
      underscore   = { m = "-";         mods = [ "Shift" ]; };
      plus         = { m = "=";         mods = [ "Shift" ]; };
      lcurly       = { m = "[";         mods = [ "Shift" ]; };
      rcurly       = { m = "]";         mods = [ "Shift" ]; };
      colon        = { m = ";";         mods = [ "Shift" ]; };
      quote        = { m = "'";         mods = [ "Shift" ]; };
      less         = { m = ",";         mods = [ "Shift" ]; };
      greater      = { m = ".";         mods = [ "Shift" ]; };
      question     = { m = "/";         mods = [ "Shift" ]; };
      backspace    = { m = "Backspace"; mods = []; };
      forwardslash = { m = "\\";        mods = []; };
      enter        = { m = "Enter";     mods = []; };
    };
    binds = lib.concatMap
      (line:
        let
          match = builtins.match ''^%hidden k(C|M|CM|MC)_([a-zA-Z0-9]+)="(\\uE[0-9a-fA-F]+)".*'' line;
        in
          if match == null then [] else [ match ]
      )
      lines;
    keyDef = key: keydefs.${key} or {
      m =
        if builtins.match "^[a-zA-Z0-9]$" key != null then
          lib.strings.toLower key
        else
          abort "unknown key mnemonic: ${key}";
      mods = if builtins.match "^[A-Z]$" key != null then [ "Shift" ] else [];
    };
    mapMods = mapping: s: map (m: mapping.${m}) (lib.strings.stringToCharacters s);
    keepUnique = list: builtins.attrNames (builtins.listToAttrs (map (x: { name = x; value = null; }) list));
    alacritty-keyboard-bindings = map
      (b:
        let
          in-mods = builtins.elemAt b 0;
          in-mnemonic = builtins.elemAt b 1;
          in-definition = builtins.elemAt b 2;
          def = keyDef in-mnemonic;
          mods = keepUnique ((mapMods alacritty-mods in-mods) ++ def.mods);
        in {
          mods = lib.strings.concatStringsSep " | " mods;
          key = def.m;
          chars = in-definition;
        }
      )
      binds;
  in
    alacritty-keyboard-bindings;
}
