import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Types "Types";
actor {
    private stable var _totalSupply : Nat = 0;
    private stable var _numberOfUser : Nat = 0;
    private var _users : HashMap.HashMap<Principal, Nat> = HashMap.HashMap<Principal, Nat>(0, Principal.equal, Principal.hash);
    private var _tokens : HashMap.HashMap<Nat, Types.TokenInfo> = HashMap.HashMap<Nat, Types.TokenInfo>(0, Nat.equal, Hash.hash);
    private stable var _userEntries : [(Principal, Nat)] = [];
    private stable var _tokenEntries : [(Nat, Types.TokenInfo)] = [];

    
};
