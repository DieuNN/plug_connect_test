import Principal "mo:base/Principal";
actor {
  public shared({caller}) func isAnonymous() : async Bool {
    return Principal.isAnonymous(caller);
  };
};
