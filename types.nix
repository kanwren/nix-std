with rec {
  function = import ./function.nix;
  inherit (function) const identity;

  list = import ./list.nix;

  string = import ./string.nix;
};

let
  /* unsafe show functions */
  showBool = x:
    if x == true
    then "true"
    else "false";
  showFloat = _: "";
  showFunction = const "<<lambda>>";
  showInt = builtins.toString;
  showList = ls: "[ " + string.concatSep ", " (list.map show ls) + " ]";
  showNull = const "null";
  showPath = builtins.toString;
  showSet = const "<<set>>";
  showString = s: "\"" + s + "\"";
  show = x:
    let /* shows :: [{ isType :: a -> bool, showType :: a -> string }]*/
        shows = [
          { isType = builtins.isBool; showType = showBool; }
          { isType = builtins.isFloat; showType = showFloat; }
          { isType = builtins.isFunction; showType = showFunction; }
          { isType = builtins.isInt; showType = showInt; }
          { isType = builtins.isList; showType = showList; }
          { isType = builtins.isNull; showType = showNull; }
          { isType = builtins.isPath; showType = showPath; }
          { isType = builtins.isString; showType = showString; }
          { isType = builtins.isAttrs; showType = showSet; }
        ];

        /* show' :: a -> string */
        show' = (list.foldr
          (c: n: if n.isType x then n else c)
          ({ isType = const false; showType = builtins.toString; })
          shows).showType;
    in show' x;
in
rec {
  inherit show;
}
